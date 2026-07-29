# institutional/ — committee, leadership & caucus press releases

Scoping + first collection of press releases from congressional sources that are
not individual member offices: standing/select committees (majority *and*
minority feeds), floor leadership offices, and party conferences/caucuses.
Everything here is exploratory analysis-layer code on the `sources` branch; the
package (`R/`) is untouched.

## Layout

| path | what |
|---|---|
| `R/01_enumerate_hosts.R` | Build the candidate host list (house.gov + senate.gov directories, minority-prefix probing, leadership candidates) → `data/hosts.csv` |
| `R/02_classify_cms.R` | Drop senator member sites, fix labels, run `detect_cms()` per host → `data/hosts_clean.csv` |
| `R/03_spot_test.R` | Try the stock extractors on every host (90-day window) → `data/spot_results.csv` |
| `R/04_diagnose_failures.R` | Per-host diagnosis of spot-test failures → `data/diagnose.log` |
| `R/lib_institutional.R` | Custom feed walker (explicit listing URL + item regex, pager auto-detection, item-page date/body fallback) |
| `R/06_feed_configs.R` | Hand-curated feed configs for hosts the stock extractors can't walk, party-tagged |
| `R/05_collect_worker.R` / `R/07_collect_feeds.R` | Tier-1 (stock) / Tier-2 (custom) full-history collectors → `data/raw/*.rds` |
| `R/08_probe_stragglers.R` | Targeted probes (wp-json, GraphQL, listing anatomy) |
| `data/` | **gitignored** — hosts tables, logs, and per-host/per-feed raw RDS |

Collection is re-runnable: both collectors skip hosts/feeds whose output RDS
already exists. Network required (`dangerouslyDisableSandbox` in the harness, or
a normal terminal).

## Schema proposal (the §4 design question from the handoff)

**One new `source` value per institution type: `"committee"`, `"leadership"`,
`"caucus"`.** The NLP layer already keys on `source`; a single predicate
(`source IN (...)` / `NOT IN`) cleanly includes or excludes institutional rows
from any member-level analysis (partisan gaps, coordination network, per-member
trends stay uncontaminated).

Mapping onto the existing `releases` columns:

| column | institutional semantics |
|---|---|
| `name` | Canonical unit name, chamber-prefixed for uniqueness: "House Committee on Agriculture", "Senate Committee on the Judiciary", "Speaker of the House", "Senate Republican Conference". Never a person. |
| `party` | Party of the **feed**, not the unit. Party-branded feeds map directly (`democrats-*.house.gov` → D; `/press/rep/…` → R). Feeds branded only majority/minority resolve through a congress × chamber majority-control lookup **at the release date** — never "majority today" (House sites swap content between the main and `democrats-`/`republicans-` prefixed hosts when control flips). Nonpartisan/joint feeds (Ethics, joint statements) → NA. |
| `state`, `district` | NA. |
| `chamber` | house / senate / joint. |
| `committee` | For `source="committee"`: the committee's own name. For leadership/caucus: NA. (Note the semantic difference from member rows, where `committee` = the member's assignment.) |
| `source` | `"committee"` / `"leadership"` / `"caucus"`. |

Feed-level provenance (host, listing URL, raw feed branding
majority/minority/rep/dem/chair/ranking) stays in the staging RDS files under
`data/raw/` and should ride along into a fold-in as extra columns or a side
table — it is the audit trail for the party attribution.

**Majority vs minority matters analytically**: the same committee's two feeds
carry opposed messaging. Collection is feed-level (one config row per feed) so
party attribution is native, not inferred from text.

**Dedup**: committee releases often duplicate member releases (joint
statements). The corpus already detects cross-source near-duplicate families
(`cross_source`); institutional rows should flow through the same family
detection at fold-in, not be pre-deduped.

## Feasibility findings (2026-07-28/29 overnight)

- 126 candidate hosts enumerated → 85 institutional hosts after dropping the
  senator member sites the senate.gov directory links; 82 resolve.
- CMS mix: every host falls into a family the package already handles
  (aspx 16, drupal 14, wordpress 14, guid 5, nextwp 2, generic-fallback 31).
- **66/82 hosts work with the unmodified package** (spot test: 1,582 releases
  in 90 days ⇒ roughly 6–7k/yr steady-state across sources).
- The 16 failures shared one root cause — item permalinks living *off* the
  listing path, which the generic extractor's in-listing filter rejects — plus
  three side cases (empty-anchor card layouts, CFM `pressreleases?ID=` links,
  stale WP REST feeds). The custom walker (`lib_institutional.R`) + 22 feed
  configs recover all but:
  - `energycommerce.house.gov` (+ its `democrats-` twin): new Next.js/Strapi
    SPA; `/api/news` returns only the latest 9 posts and ignores pagination;
    `totalPosts` = 58, so the gap is tiny. Needs a small custom client later.
  - `rpc.senate.gov`: no press listing at all (newsletter only).
  - `www.dpcc.senate.gov`, `www.democrats.senate.gov`: handled by stock tools.
  - `republicans.senate.gov` / `src.senate.gov`: WP REST is open but the feed
    stops 2024-12 (platform moved after the 2024 election) — collected as
    historical archive.
- Senate committees publish **separate majority + minority feeds on one host**
  (e.g. `/newsroom/majority-press-releases` vs `…minority…`); House committees
  put the minority on a prefixed host (`democrats-<committee>.house.gov`).
  Leadership offices run the same CMSes as member sites (speaker.gov WordPress,
  whips/leaders aspx+drupal).

## Open questions for the write-up

- How much do committee releases duplicate member releases? (Run the family
  detector over the fold-in candidate set.)
- Do minority-party House sites keep pre-flip archives? Check collected date
  ranges on `democrats-*` hosts; Wayback backfill may be needed for older
  congresses (IA was rate-limiting this IP as of 2026-07-28).
- HSGAC prior-congress archives live at separate paths
  (`/media/majority-news/<congress>`); only current-congress is configured.
- Party/campaign committees (DNC/RNC, DCCC/NRCC, DSCC/NRSC) and member caucuses
  (CBC, Freedom Caucus, …) are `.org`/campaign entities — deliberately **not**
  enumerated here pending the editorial call on whether they belong in a
  congressional corpus.
