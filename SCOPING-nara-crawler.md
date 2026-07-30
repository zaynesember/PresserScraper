# Scoping — the NARA webharvest.gov crawler (2026-07-30)

Deliverable of `HANDOFF-nara-crawler.md`. Everything below is backed by ~50 cached probe
responses in `~/Library/Application Support/org.R-project.R/R/pressR_nlp/nara_probe_cache/`
(pattern: `<name>.html` + `<name>.hdr`; only HTTP-200 bodies are cached) and by an offline
extractor harness run against those caches. Building the crawler is the next session's work.

## TL;DR

The crawler is **feasible and worth building**: the archive is navigable, the host lists are
machine-readable and authoritative, all five sampled CMS families extract with the shipped
code, and sampled yield confirms ~3× the IA Wayback run (Gordon: 516 article links in NARA
vs 169 from CDX). Two operational surprises change the plan, though:

1. **webharvest.gov IS rate-limited after all.** ~20–25 requests at 3 s spacing tripped HTTP
   429 ("Rate limit reached … contact Aitratelimit@archive.org" — the replay runs on
   Internet Archive infrastructure). Recovery took ≤4 min. At 10 s spacing, dozens of
   consecutive requests sustained cleanly. The 2026-07-28 "not rate-limited" evaluation was
   simply below the threshold. Budget ~6–8.6k requests/day, single lane.
2. **robots.txt explicitly disallows the replay paths** (`Disallow: /congress*/*/http://`
   and `.../https://`, all user agents) and sets `Crawl-delay: 10`. Index pages under
   `/collections/` are allowed. **A decision is needed before building** — see
   "The robots.txt question" below. Recommended first step either way: email NARA's Center
   for Legislative Archives asking for guidance or bulk WARC access; that could eliminate
   ~120k HTTP requests entirely.

## 1. Site anatomy (probed + cached)

- **Canonical host is `webharvest.gov`** — `www.webharvest.gov` 302s to it. Crawl the bare
  host or every request costs double.
- **Discovery is 80 static, machine-readable index pages**:
  `/collections/congress{109..118}th/{house|senate}_{members_alpha|leadership|committees|organizations}.html`.
  Entry format: `<h3>Name</h3>` followed by one absolute replay link whose text is the
  original URL. Counts check out (House members: 439 in 109th, 438 in 111th, 438 in 118th;
  House committees 112th: 41 including all 20 `democrats.*` minority-branded hosts).
- **The 109th list confirms path-based member sites** (`house.gov/abercrombie/`,
  `house.gov/ackerman/`) — the Barney Frank failure mode. These are invisible to surname
  guessing and exactly why the roster must come from these pages, not inference.
- **Replay URL**: `https://webharvest.gov/congress{N}th/{token}/{original_url}`. The token
  varies by index vintage — 14-digit timestamp (111th), placeholder `20061114000000` +
  scheme-less original (109th), bare year `2014` (113th), crawl id `3` (118th) — but it
  doesn't matter: **any token 302s to the nearest real capture** (OpenWayback semantics).
  Requested `20101201094017`, served `20101202011931`. Exact timestamps are never needed.
- **`id_` raw mode works**: `/{ts}id_/{url}` serves the original bytes without replay
  chrome (Gordon presskit: 21,153 B raw vs 29,006 B rewritten). `im_` exists for images.
  Item pages should be fetched `id_` — that is also what `run_wayback.R` does on IA.
- **Link rewriting inside replayed pages is complete and consistent**: on Gordon's press
  listing, 764 root-relative + 53 absolute links all point back into
  `/congress111th/{ts}/http://…`; 4 raw external links. Standard `abs_urls()` resolution
  works unchanged. Caveat: resolved URLs can carry `http%3A//` (percent-encoded scheme) —
  decode before stripping the replay prefix for identity.
- **Rewritten pagination links carry their own nearest-capture timestamps** (a `page=78`
  link on a listing captured at `…213040` points at `…214730`). Follow links as given;
  don't try to hold one timestamp constant across a walk.
- **No CDX API** (confirmed again), and the on-site full-text search is legacy/broken: the
  collection form posts to a path that 404s on Tomcat, and the help page still documents
  the retired NutchWAX-era `websearch.archive.org` syntax. Search cannot substitute for
  crawling; navigation is the only enumeration.
- **FAQ facts**: harvests run September→Jan 3 each cycle, conducted by the Internet Archive
  under NARA contract (Heritrix + Brozzler); 190 TB total; the 118th alone is 400M URLs /
  32 TB. Forms, streaming media, and dynamic content are not captured.

### Rate-limit empirics (measured 2026-07-30, updated after the first pilot run)

| observation | value |
|---|---|
| burst that tripped 429 | ~20–25 requests over ~6 min at 3 s spacing |
| 429 recovery after a SHORT burst | ≤4 min (cleared between probes at 60 s intervals) |
| sustained trip | 72 index requests at exactly 6/min (10 s spacing), then the **first replay request** was limited — the robots-compliant pace still trips it after ~70 sustained requests |
| **limiter answers HTTP 200 too** | the pilot got the "Rate limit reached" page with code **200** for 196 straight requests — status-only detection cached 192 poisoned pages; detection MUST sniff the body (`Rate limit reached|Aitratelimit@archive.org`) |
| penalty under continued traffic | never cleared across 32 min of requests at 10 s spacing — only **full silence** releases it, and after a long limited grind even 10 min of silence was not enough |
| index vs replay | `/collections/` index pages have never been observed limited; replay paths carry the budget |

Design consequences (all now implemented in `nara/R/lib_nara.R`): body-sniff the limiter
page regardless of status; on detection FULL STOP with escalating rests (5→10→20→30 min)
and a hard-abort if it never releases (grinding on collects nothing and keeps the penalty
pinned); burst-rest pacing (~30 requests, then ~7 min of silence ≈ 2.5 req/min average)
instead of naive continuous 10 s spacing; cache only 200-and-clean bodies. Realistic
sustained throughput is therefore **~3–3.5k requests/day**, roughly half the original
estimate — double the tier wall-clock estimates in §4.

## 2. The robots.txt question — RESOLVED 2026-07-30

> **User decision: crawl politely, no email** (option 2 below). Constraints that are now
> binding on the build: identifying UA with contact info, `Crawl-delay: 10` honored
> exactly, 429 → sleep ≥5 min, ~6k requests/day budget, off-peak preferred, single lane,
> stop-on-objection if NARA/IA ever reach out. The options are preserved below for the
> record.

```
User-agent: *
Allow: /
Disallow: /nara/*/http://
Disallow: /nara/*/https://
Disallow: /peth*/*/http://
Disallow: /peth*/*/https://
Disallow: /congress*/*/http://
Disallow: /congress*/*/https://
Crawl-delay: 10
```

The index pages we need for discovery are allowed; the replay pages the yield lives in are
disallowed for every user agent. Options, in recommended order:

1. **Ask first (recommended).** Email NARA's Center for Legislative Archives (and/or
   `Aitratelimit@archive.org`, the contact the 429 page itself offers) describing the
   research use and asking either for blessing to crawl politely or — much better — for
   bulk/WARC access to the member+committee press subsets. NARA's mission for this
   collection is public access; the Disallow is most plausibly aimed at search-engine and
   AI-training crawlers. WARC extracts would collapse ~3 weeks of polite crawling into a
   local extraction job, and the same email can ask whether the harvest WARCs are
   orderable through catalog.archives.gov. Cost: one email and some latency.
2. **Proceed politely without asking**: identifying UA with contact info, `Crawl-delay: 10`
   honored, 429-backoff, off-peak hours, ~6k requests/day. This is a deliberate decision to
   cross an explicit `Disallow` on a public-access federal archive — defensible for
   scholarship, but it is the user's call to make, not a default.
3. **Honor robots strictly**: no crawler; only index-page discovery plus manual sampling.
   Kills the project as designed.

This scoping session itself made ~50 replay-path requests (evaluation-scale, human-driven);
the full crawl is ~120k and qualitatively different.

## 3. Extractor compatibility — verified by reading bodies

Harness: define `run_wayback.R`'s functions without running its backfill, source
`institutional/R/lib_institutional.R`, run both extractor stacks on cached `id_` pages.
(Script preserved at `nara_probe_cache/nara_extract_test.R`; results below are from its
run this session. Re-running it is free — everything it reads is cached.)

| sample (cached file) | family | wayback `extract()` | `insti_page_date`/`insti_item_body` | verdict |
|---|---|---|---|---|
| `gordon_art_vets_id` (111th member) | legacy `apps/list` .shtml | date ✓ 2010-11-11; body 5.3k but head is Dynamic-Drive JS junk; title = site banner ("ONLINE OFFICE", known noise) | date ✓; body 3.2k **real prose** ("On the eleventh hour of the eleventh day…") | insti body wins |
| `aging109_art_id` (109th cmte) | CFM `FuseAction=PressReleases.Detail` | body ✓ real ("Bipartisan Group of Senators… Pension Gap"); **date ✗ capture-day fallback** — dateline is ordinal "September 27th, 2006" and `parse_date2` has no ordinal branch | **date ✓ 2006-09-27** (`first_parseable_date` handles ordinals); body NA (2006 table layout fails the prose gate) | complementary: insti date + wayback body |
| `demec112_art_id` (112th minority cmte) | Drupal `?q=news/<slug>` | both stacks: identical 6.4k real body, date ✓ 2012-12-06 (page's own `date-display-single` says Dec 6, 2012) | same | either; trim nav prefix/footer |
| `drug115_art_id` (115th caucus) | Drupal `/content/<slug>` | body ✓ real; **date ✗ 2018-12-22 capture fallback** (page holds Aug-2014 content, no meta date; outside `parse_date2`'s ~3y prose window) | **date ✓ 2014-08-22** from in-prose dateline — externally correct (hydrocodone rescheduling was Aug 2014) | insti date required |
| `jec113_art_id` (113th joint cmte) | CFM GUID `ContentRecord_id=` | body ✓ real, tight 1.3k; date ✓ 2014-12-05 (matches the Nov-2014 BLS release timing); title = site banner | same date/body | either |

Listing side: `insti_item_urls` + `insti_feed_items` ran **unchanged** on a rewritten replay
listing (demec112): 10/10 items, all with dates, correct titles. Pagination links are plain
`?page=N` present in the HTML, so `insti_detect_pager` / link-following works.

Date lessons to bake in (both already bitten us elsewhere):
- **Cascade insti-first**: `insti_page_date` (meta → `<time>` → JSON-LD → URL → first
  parseable in text) then `parse_date2` dateline heuristics. Never accept a bare
  capture-timestamp fallback silently — flag it, and QA the fallback share per feed.
- **Add an ordinal branch to the dateline regex** (`September 27th, 2006`) wherever
  `parse_date2` is reused.
- **Listing dates can misalign on Drupal card layouts** (one demec112 row showed 2012-11-02
  in the listing for a page whose own date block says Dec 6, 2012). Prefer item-page dates;
  sample-compare assigned dates against in-body datelines per feed before staging.
- Titles on pre-2010 member/committee templates are often the site banner (Gordon, JEC,
  Aging) — accepted noise with precedent (cantor/gordon in the IA run); `insti_page_title`
  (og:title → h1) recovers real titles where they exist.

## 4. Target set and yield estimates

Sampled anchors: Gordon 516 article links on one page (IA CDX got 169 → 3.05×);
demec112 79 listing pages × 10 items ≈ 790; drugcaucus 115th ≈ 55 (11/page × 5 pages);
aging 109th CFM archive paginates with Prev + Month/Year params, ids observed up to 565.

Tiers in value-per-request order (all under ~6–8.6k requests/day):

| tier | scope | est. new releases | est. requests | est. wall-clock |
|---|---|---|---|---|
| **A. Institutional holes** | aging pre-2007 (109th), jec minority ≤113th, drugcaucus ≤115th, energycommerce's 49 unreachable posts (112th–114th snapshots are pre-SPA Drupal) | ~2–5k | ~3–5k | ~half a day–1 day |
| **B. House minority committee archives** | 20 `democrats.*` feeds in 112th (+R-minority equivalents in 110th–111th, D-minority 113th–114th); heavy cross-snapshot overlap | ~10–20k unique | ~25–40k | ~4–6 days |
| **C. 339-member expansion roster** | final terms 2007–2016 → congresses 110–114; authoritative hosts from members_alpha pages replace surname inference | ~50–80k | ~95–120k | ~2.5–3.5 weeks |

Notes on C: IA batch-1 averaged ~347/member over the top-25 by capture volume; assume
~150–350 across the full roster with union across snapshots. URL collisions with
stout/wangtucker proved negligible in past fold-ins (different URL conventions), so staged ≈
new. The corpus filter (2005–2016 for member archival rows) still applies. Members whose
sites NARA yields thin remain IA-CDX retry candidates (the `wayback_cdx_cache/` split makes
those retries CDX-free).

Total full program ≈ **120–160k requests ≈ 3–4 weeks of single-lane polite crawling** —
or one bulk-access email. Run tiers A→B→C so value lands early and each tier's QA informs
the next; each tier is independently stageable and fold-in-able (batch with other pending
sources; ask before launching a fold-in).

## 5. Crawler design (build plan for next session)

Rhymes with `run_wayback.R` (cache-everything, resumable, gates) and
`lib_institutional.R` (walker, pager detection, prose gate). One host → **one process**,
`Crawl-delay: 10`, UA identifying the research + contact email, detached + `caffeinate`,
lid open, plugged in.

**Layer 0 — HTTP + cache (`nara_fetch()`)**
- `GET` via httr2 with retry/backoff; on 429 sleep ≥300 s then resume; never retry-storm.
- Disk cache keyed by `congress + mode(id_/rewritten) + stripped original URL`
  (`nara_page_cache/` beside `wayback_cdx_cache/`). Cache 200s only. Every later stage
  reads the cache, so extraction/pattern iteration is free forever (the CDX-cache lesson).

**Layer 1 — discovery (index pages, robots-allowed)**
- Fetch all 80 `/collections/` indexes once (cached). Parse `<h3>`+link into a units table:
  `(congress, chamber, category, name, original_url, replay_url)`. ~4,000 member entries +
  ~800 committee/leadership/org entries; join members to bioguide/roster (the 339 roster
  carries `house_end` for the service-window guard) and committees to canonical names à la
  `09_assemble.R`.
- Normalize entry tokens: resolve each unit's entry link once, record the concrete
  timestamp from the 302, and derive the replay prefix `https://webharvest.gov/congress{N}th/{ts}`.

**Layer 2 — listing walk (per unit × congress)**
- Feed-config table like `11_feed_configs2.R`: `listing` (original URL), `item_re` (matched
  against the STRIPPED original URL, never the replay form), `engine`
  (`walk|cfm_monthyear|onepage`). Member sites mostly `onepage`/`walk`; 109th-era CFM
  archives need Month/Year enumeration (aging); Drupal minorities are plain `?page=N`.
- Walk in rewritten mode (links resolve for free), `insti_feed_items` for titles/dates,
  stop rules as in `walk_feed` (repeat page, empty page, page_limit).
- Per-unit output `.rds` with an explicit `status` field — empty-vs-failed must be
  distinguishable (`12_diagnose_thin_feeds.R` lesson: zero-row ≠ finished).

**Layer 3 — item extraction**
- Fetch each item once in `id_` mode. Extract with the cascade proven in §3:
  title `insti_page_title` → wayback title path; date `insti_page_date` →
  `parse_date2`+ordinal branch → capture-ts only with a `date_src="capture"` flag;
  body wayback `extract()` body path → `insti_item_body` fallback, prose gate throughout.
- Gates: date present, body ≥300 chars, soft-404 scrub (word-boundary regex from
  `run_wayback.R`), `is_listing` check, `n_dates ≤ 6`.
- **Identity = stripped original URL**: remove `^https://webharvest\.gov/congress\d+th/\d{14}(id_)?/`,
  percent-decode the scheme (`http%3A//`), and use that for all dedup/staging. Replay URLs
  never reach the corpus.
- Cross-snapshot dedup: same stripped URL in consecutive harvests collapses to one row
  (process newest congress first, keep first extraction).

**Layer 4 — attribution + staging**
- Member rows: roster name/state/district/party; `house_end + 90d` service-window guard
  (the bilirakis/payne succession trap).
- Committee/leadership/caucus rows: canonical chamber-prefixed names; party from feed
  branding with MAJ resolved by `chamber_majority(date, chamber)`; conflicting branding →
  NP-first (the `09_assemble.R` rule).
- Stage to `external/nara/releases-YYYY.rds` in the 13-column wayback schema, with the
  `17_stage_external.R` anti-join against **the full corpus year files + every external
  subdir** (layers stream files directly; DuckDB-only dedup is the wrong layer). Write a
  provenance sidecar `nara_provenance.csv` (`url, congress, capture_ts, replay_url`) so the
  13-column schema stays untouched but the audit trail survives.
- QA before any fold-in: counts by unit/year, date-vs-body sample per feed (mandatory),
  spot-read bodies per CMS family, fallback-date share, thin-feed diagnosis.

**Code home (recommendation)**: new top-level `nara/` mirroring `institutional/`'s layout
(`nara/R/01_discover.R … lib_nara.R`, outputs under `nara/data/`, gitignored). One replay
engine serves both member and committee targets; splitting it between `nlp/` and
`institutional/` would duplicate the walker. `nlp/run_wayback.R` stays untouched.

## 6. Open questions — answered (recommendations, not decisions)

1. **`source` value**: member-site recoveries → **`source="nara"`** (a sibling of
   `wayback`: analytically both are archival member recovery; provenance stays legible and
   the institutional predicate `source IN ('committee','leadership','caucus')` is
   unaffected — member-level analyses that today include `wayback` must add `nara`, one
   enum value). Committee/leadership/caucus recoveries → **their institutional source
   values** (so the one-predicate isolation keeps working), with NARA provenance carried by
   the sidecar CSV, not the schema. Do not reuse `wayback` for NARA rows: the two archives
   have different failure modes and we will want to QA them separately.
2. **Code home**: top-level `nara/` (see §5).
3. **IA-overlap policy**: corpus stays URL-unique, first-staged wins. Existing 16,972
   wayback rows are kept; NARA staging anti-joins against them and adds only new URLs. Add
   a light canonicalization (scheme, host case, default port — never path/query) as the
   dedup KEY while storing the original URL, since the same release can appear as
   `http://` (IA-era capture) and `https://` (late NARA capture).
4. **339-member strategy**: **NARA-primary** (authoritative hosts incl. path-based sites,
   3× yield, navigable, no CDX dependency), IA CDX as targeted fill-in for members NARA
   yields thin. Don't merge blind: run NARA tier C, diff per-member counts against the IA
   probe (`wayback_expansion_probe.csv`), and retry the shortfall members on IA off the
   existing CDX cache.

## 7. Next-session build checklist

1. ~~Resolve the robots.txt decision~~ **RESOLVED: crawl politely (§2)** — build can start.
2. Scaffold `nara/R/`: `lib_nara.R` (fetch+cache, prefix strip, extraction cascade),
   `01_discover.R` (80 index pages → units table), `02_feed_configs.R` (tier A first),
   `03_walk.R`, `04_extract.R`, `05_stage.R`, plus a `diagnose_thin` port.
3. Pilot on tier A (institutional holes, ~3–5k requests ≈ 1 day) — smallest, highest
   value-per-request, exercises every engine (CFM month/year, Drupal pager, GUID CFM).
4. QA pilot by counts + date-vs-body samples; then decide tier B/C scheduling.
5. Batch the fold-in with any other pending sources; ask before launching (hours).

## Cache inventory (nara_probe_cache/)

Discovery/meta: `robots`, `home`, `faq`, `help`, `c111_landing`, `collections` (404 — no
such index), `search_gordon`/`search_probe` (404s — search is dead).
Indexes: `c109_house_members`, `c110_house_members`, `c111_house_members`,
`c118_house_members`, `c109_senate_committees`, `c112_house_committees`,
`c113_senate_committees`, `c115_senate_organizations`.
Replay/listings: `gordon_home`, `gordon_press` (197 KB one-pager), `aging109_home`,
`aging109_listing`, `demec112_home`, `demec112_listing`, `drug115_home`, `drug115_listing`,
`jec113_home`.
Articles (id_ raw unless noted): `gordon_article`, `gordon_article_id`, `gordon_art_vets_id`,
`aging109_art_id`, `demec112_art_id`, `drug115_art_id`, `drug115_art_rw` (rewritten twin),
`jec113_art_id`, `adams_home_118`.
