# Handoff — scope the NARA webharvest crawler

> **DONE 2026-07-30.** Deliverable: `SCOPING-nara-crawler.md` (site anatomy, rate-limit +
> robots.txt findings, extractor evidence, yield tiers, crawler design, answered open
> questions) + cached probes in `pressR_nlp/nara_probe_cache/`. The robots.txt decision is
> RESOLVED (crawl politely, no email — scoping doc §2); the build is unblocked.
>
> **BUILD STATE (paused 2026-07-30 ~14:30):** `nara/` scaffold BUILT + smoke-tested
> offline; discovery COMPLETE (units.rds, 6,720 entries, all clean). Pilot walk aborted:
> the IA limiter serves its block page with HTTP **200** (196 poisoned cache pages, since
> purged) and the penalty from grinding was still active after ~2 h of silence. Fetch layer
> now body-sniffs + burst-rest paces (scoping doc §1 rate-limit table). **Resume:** verify
> release with one probe —
> `curl -sSL -o /tmp/p.html "https://webharvest.gov/congress109th/20061114004947/http://aging.senate.gov/public/index.cfm?FuseAction=PressReleases.Home&Month=9&Year=2006" && grep -c "Rate limit reached" /tmp/p.html` (want 0)
> — then `nohup caffeinate -i bash nara/run_tierA.sh >> ~/nara_tierA.log 2>&1 &`
> (lid open, plugged in). Afterwards: `Rscript nara/R/04_extract.R` offline, READ its QA,
> then 05_stage only after review. Ask before any fold-in.

Resuming pressR work. Read CLAUDE.md first — repo layout, corpus state, and the
operational rules (network needs `dangerouslyDisableSandbox: true` from the Bash tool;
inline `Rscript -e` mangles regex backslashes so write script files; `as.Date()` on non-ISO
strings THROWS — use `first_parseable_date()`; verify by counts, never exit codes;
deterministic sampling via `ORDER BY hash(col)`). Project memory loads automatically; the
directly relevant files are `nara-webharvest-source`, `wayback-extractor-status`,
`institutional-sources-status`, `pressR-coverage-state`.

Branch: `corpus` in /Users/zaynesember/GitRepos/pressR. Corpus is LIVE at **1,041,259**
releases (fold-in 2026-07-30); all layer tables at 999,654. Institutional sources
(committee/leadership/caucus) are collected and folded in. Do not commit or push without
asking; leave the dashboard down.

## THIS SESSION'S TASK — scope (not build) the webharvest.gov crawler

webharvest.gov hosts NARA's official end-of-Congress web harvests, 109th–118th Congresses
(~2006–2024): member, leadership, committee, and org sites, both chambers. Evaluated
2026-07-28: **not rate-limited**, navigable without URL guessing, authoritative per-congress
host lists, roughly **3× the yield** of our Wayback CDX run. It has **no CDX-style API**, so
recovery means an actual crawler — which has never been built. Nothing has been collected
from it.

Scoping deliverables, in order:

1. **Map the site's anatomy.** How is a harvest organized — per-congress collections, replay
   URL scheme, index/directory pages, WARC access? Confirm the per-congress host lists are
   machine-readable. Save every probe response to a local cache directory (pattern:
   `wayback_cdx_cache/` — cached raw responses make iteration free).
2. **Confirm replayed pages are extractable.** Fetch a handful of archived member and
   committee press pages across congresses and run the existing extractors against them —
   the archived sites are the same CMS families the package already handles, and the
   institutional walker (`institutional/R/lib_institutional.R`) plus the stock extractors
   should mostly work against replayed HTML. Verify by reading bodies, not measuring length.
3. **Pick the target set and estimate yield.** Candidates, roughly in value order: the
   339-member Wayback expansion roster (IA's CDX throttling made that run stall — NARA may
   substitute entirely for 2006–2024); pre-flip House minority committee archives; known
   holes from the institutional round (jec.senate.gov minority pre-2025, drugcaucus
   pre-2022, energycommerce's 49 unreachable posts, aging pre-2007). Estimate page counts
   and runtime under politeness.
4. **Design the crawler** as a written plan: discovery → listing walks → item extraction →
   staging. Reuse, don't reinvent — read `nlp/run_wayback.R` and the wayback extractor
   first; the NARA crawler should rhyme with them.

## Design constraints that already bit us (do not relearn these)

- **Replay URLs are not identity.** Strip the webharvest replay prefix to recover the
  original URL before anything touches identity, dedup, or staging. The corpus is
  **URL-unique by construction** and duplicate urls CRASH the fold-in's tag-complete step
  (`docnames must be unique`) — dedup must happen against the full corpus at staging time
  (see `institutional/R/17_stage_external.R` for the anti-join pattern), not only in DuckDB,
  because the NLP layers stream the year files directly.
- **Dates need their own check.** A capture-timestamp fallback once mis-dated 82% of one
  member's releases. Archived pages must yield their *published* date from page content;
  compare assigned dates against dates visible in bodies on a sample.
- **webharvest.gov is one host.** The institutional runner's parallelism came from
  partitioning across many servers; that trick does not apply here. One process, normal
  throttle (`options(pressR.throttle = 30)`), and check robots.txt. "Not rate-limited"
  is an observation, not a license.
- **Skip-if-exists treats a zero-row output as finished.** If the crawler writes per-unit
  outputs, empty-vs-failed must be distinguishable (see `12_diagnose_thin_feeds.R` for the
  diagnostic pattern that resulted).
- **Network jobs die on lid close** (sleep kills connections; local compute survives).
  Long crawls run detached with `caffeinate`, machine open and plugged in.
- **Ingest path exists and is proven**: stage year-partitioned
  `external/<source>/releases-YYYY.rds` files in the 13-column wayback schema (date, title,
  body, tags, url, cms, name, state, district, party, committee, chamber, source) and
  `bash nlp/run_foldin.sh` picks them up (`nlp/resume_foldin.sh` continues an interrupted
  run). A fold-in is hours — batch NARA with any other pending sources when the time comes,
  and ask before launching it.

## Open questions the scoping should answer

- One `source` value (`nara`?) or reuse `wayback`? (Provenance vs analytical equivalence —
  both are archival recovery of the same site families. Recommend, don't decide silently.)
- Where does the code live — a new top-level dir, or alongside the wayback tooling in
  `nlp/`? Member-site recovery and committee-site recovery may want different homes.
- Overlap policy with IA Wayback: for members in both, prefer which capture, and dedupe how?
- Whether the 339-member expansion should now run on NARA alone, IA alone, or both merged.

End state for this session: a written scoping doc (site anatomy, extractor compatibility
evidence, target set with yield estimates, crawler design, answered open questions) — plus
cached probe data. Building the crawler is the *next* session's work; only prototype as far
as scoping demands.
