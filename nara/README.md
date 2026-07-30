# nara/ — NARA webharvest.gov crawler

Recovers congressional press releases from NARA's end-of-Congress web harvests
(109th–118th, webharvest.gov). Design, probe evidence, yield tiers, and the
robots.txt decision record: **`SCOPING-nara-crawler.md`** at the repo root.

Operating rules (binding): single process, `Crawl-delay: 10` exact, identifying
UA, 429 → ≥5 min sleep, ~6k requests/day, stop if NARA/IA object.

## Pipeline

| step | network | what |
|---|---|---|
| `R/01_discover.R` | yes (80 index pages, robots-allowed, cached) | units table → `data/units.rds` |
| `R/02_feed_configs.R` | – | tier-A feed configs (sourced, not run) |
| `R/03_walk.R` | yes | listing walks → `data/walk/`, then item pages → page cache |
| `R/04_extract.R` | no | extraction cascade over the cache → `data/extracted/` + QA |
| `R/05_stage.R` | no | 13-col schema, corpus anti-join → `external/nara/` + provenance sidecar |

Runner: `bash nara/run_tierA.sh` (see header for the detached launch line).
Page cache: `pressR_nlp/nara_page_cache/` (200s only — never cache an error).
Everything in `data/` is gitignored collected output; only code is tracked.

Read 04's printed date-vs-body samples before staging; ask before folding in.
