# CLAUDE.md — working notes for agents

## Repo layout

Two branches, deliberately:

- **`main`** — the installable R package only (`R/`, `man/`, `tests/`). Keep PRs into it
  package-scoped so they stay reviewable. Package code stays ASCII and scraper-only.
- **`corpus`** — **all research work; this is where you work.** The package plus:

| path | what |
|---|---|
| `nlp/` | Corpus pipeline (DuckDB build, near-dup families, issue tags, topics, sentiment, attack scores, partisan terms, network, readability) + the Shiny dashboard |
| `institutional/` | Committee / leadership / caucus collection (scoping, feed configs, collectors) |
| `blog/` | Readability write-up, analysis scripts, figures |
| `tools/` | Repo utilities (e.g. `update_readme_stats.R`) |

## The corpus

DuckDB (single file, **single-writer**):
`~/Library/Application Support/org.R-project.R/R/pressR_nlp/press.duckdb`

Currently **900,016** releases: `scraped` 436,201 + `stout` 288,043 + `wangtucker` 169,366 +
`wayback` 6,406. Every layer table (`readability`, `sentiment`, `issue_labels`,
`release_family`) sits at 862,613 = the usable subset. Analyses key on the **`source`**
column; institutional rows will add `committee`/`leadership`/`caucus` values so member-level
analyses can exclude them with one predicate.

## Rules that have actually bitten us

- **DuckDB is single-writer.** Read with `read_only = TRUE` (many readers are fine). Stop the
  dashboard before anything that writes: `lsof -ti tcp:7788 | xargs kill`. Leave the dashboard
  **down** unless actively using it.
- **Verify by counts, not exit codes.** A full fold-in once ran 12/12 green while three layers
  silently used a stale `dfm_raw.rds` and `issue_labels` never grew. Check row counts and
  spot-check content after any pipeline run.
- **`dfm_raw.rds` is a reuse-if-exists cache** read by tag-complete/topics/partisan.
  `nlp/run_foldin.sh` now deletes it up front; don't reintroduce a path that skips that.
- **Dates deserve their own check.** A date bug is invisible in both exit codes and row counts.
  When adding an extractor/discovery pattern, compare assigned dates against dates visible in
  the body (a capture-timestamp fallback once mis-dated 82% of one member's releases).
- **Network is sandboxed off** in the Bash tool — pass `dangerouslyDisableSandbox: true` for
  any fetch, or run from a normal terminal.
- **Inline `Rscript -e` mangles regex backslashes** (`\\s`, `\\.`). Write a script file.
- **Heavy steps run detached/background** (fold-ins are hours; scrapes can be all night) and
  keep the machine awake — `caffeinate` blocks idle sleep but a lid close still kills the job.
- **Sampling must be deterministic.** Never `USING SAMPLE` or `random()` in DuckDB; use
  `ORDER BY hash(<col>) LIMIT n`. `set.seed(1)` does not reach DuckDB's RNG.
- **Internet Archive throttles CDX hard** while its *content* endpoint stays fast — a throttled
  CDX response is indistinguishable from an empty archive, so never conclude "no data" during
  a throttle. Raw CDX results are cached in `wayback_cdx_cache/` so pattern iteration is free.
- **Skip-if-exists treats a zero-row output as finished.** The institutional collectors write a
  file even when a walk returns nothing, so a *failed* feed looks identical to a genuinely empty
  one and will never be retried. Check for thin/empty outputs before assembling or folding in.
  `institutional/R/12_diagnose_thin_feeds.R` re-probes a feed and says which stage died
  (listing dead / item_re matches nothing / pagination never engaged / body extraction fails).
- **`as.Date()` on a non-ISO string THROWS**, and `suppressWarnings()` does not catch an error.
  `<time datetime="Jul 27, 2026">` (ethics.house.gov) killed a whole feed this way and it
  collected as 0 rows. Parse page dates with `first_parseable_date()`, never
  `as.Date(substr(x, 1, 10))` — truncating to 10 chars also mangles non-ISO values.
- **A thin haul is usually pagination, not a quiet committee.** `insti_detect_pager()` probes the
  live site, so it can return `none` for a listing that paginated fine an hour earlier; the walk
  then silently returns page 0 only. Because of that a re-collect can come back *smaller* than
  what it replaces — `14_recollect_feed.R` refuses that regression unless `--force`.
- **Elementor sites have no `<article>`/`<main>`/`.content`,** so the stock body extractor
  returns NA for every item — that alone was ~9.4k body-less rows (hsgac, commerce, drugcaucus).
  `insti_item_body()` falls back to the densest `<p>` block, but *only* on Elementor pages and
  only past a link-ratio and mean-paragraph-length gate: the same heuristic ungated returned the
  identical 2,085-char sidebar ("Chairman | Vice Chairman | S.4615 …") for every
  intelligence.senate.gov release. Verify a recovered body by reading it, not by its length.
- **Some committees publish releases as PDFs** (ethics.senate.gov: `content-type:
  application/pdf`). `fetch_html()` correctly returns NULL, so those rows are legitimately
  body-less — not a bug to chase.
- **One release can be listed under several party-branded feeds.** Aging and Small Business list
  bipartisan releases under majority *and* minority *and* joint at one permalink. Deduping on
  URL alone kept whichever file sorted first, which stamped all 105 such rows `D` purely because
  `#d#` precedes `#np#`/`#r#`. `09_assemble.R` now resolves conflicting branding to NP first.
- **macOS ships bash 3.2** — no negative array subscripts. `${pids[-1]}` under `set -u` is a
  fatal error, and it once left `run_parallel.sh` having launched only lane 1 while reporting
  nothing was wrong. Check lane count with `pgrep -f 07_collect_feeds.R`, not the runner's exit.
- **Analysis scripts hard-code absolute paths** (`ROOT <- "/Users/zaynesember/GitRepos/pressR"`).
  If a checkout ever moves, grep and fix them first — pointing at a missing directory makes a
  skip-if-exists collector find no prior work and silently re-collect everything.

## Long-running collection

- **Institutional feeds:** `bash institutional/run_parallel.sh` runs N lanes (default 4,
  `LANES=` to change) over `11_feed_configs2.R`. Lanes are partitioned **by host**, never by
  feed, so no two processes hit one server; each keeps the normal throttle, so per-host
  politeness is unchanged and only total throughput rises. Kill any running collector first
  (`pkill -f 07_collect_feeds.R`) — concurrent writers would race on the same feed file.
  Logs: `~/institutional_logs/lane<K>.log`.
- **Repairing feeds while the lanes run:** never start a second `07_collect_feeds.R` over the
  same config — it would pick up feeds the lanes have not finished (no output yet ⇒ no skip) and
  two processes would hit one host. Use `14_recollect_feed.R <feed_id>` (walks only the feeds you
  name, moves the old output to `data/raw_stale/`) and `13_backfill_bodies.R <file.rds>` (fills
  missing bodies in place, no re-walk; refuses any host in the active config). One host per
  process.
- **Party attribution:** `institutional/R/lib_party.R` `chamber_majority(date, chamber)` resolves
  majority-branded (`MAJ`) feeds — 44% of institutional rows — from who held the chamber **on the
  release date**. `09_assemble.R` writes both `party_feed` (raw branding, audit trail) and
  `party` (resolved). Joint-chamber rows stay NA by design.
- **Wayback:** `Rscript nlp/run_wayback.R` (roster via `WAYBACK_TARGETS`, cap via
  `WAYBACK_MAXART`). A full run **rewrites `external/wayback/` from the roster's caches only**,
  so an expansion roster must still include the original 16 members or previously recovered
  releases are dropped.
- **Fold-in:** `bash nlp/run_foldin.sh` (hours; rebuilds DuckDB + every layer).

## Data that is NOT in git

Gitignored and therefore existing in exactly one place — back up before destructive operations:

- `institutional/data/` (~101 MB) — collected committee/leadership releases.
- `blog/data/` (~8.7 GB) — newsletters, congresstweets, CrowdTangle Facebook.
- The archive + DuckDB under `R_user_dir("pressR")`.

Do **not** commit: `.claude/` (machine-specific), `blog/*.pdf` (copyrighted; the repo is public).

## Conventions

- Commit per coherent slice; don't commit or push without asking.
- Commit signing uses 1Password SSH — a "failed to fill whole buffer" error means it's locked;
  ask the user to unlock rather than working around it.
- Scripts write outputs to real repo paths (e.g. `blog/figures/`), never to an ephemeral
  scratchpad — a previous session's scratch path is dead on arrival for anyone else.
