# pressR NLP layer

An exploratory, **classical-R** NLP layer built on the archived press-release
corpus, plus a Shiny dashboard. This is research code and is intentionally kept
**out of the package `R/`** (the package is scraper-only); nothing here is
installed with `pressR`.

## Corpus

The layer operates on a combined corpus of **~893,610 releases (2004–2026)**:

| `source` | releases | chambers | span | provenance |
|----------|---------:|----------|------|------------|
| `scraped` | 436,201 | House + Senate | 2010–2026 | the pressR scraper (`download_archive()`) |
| `stout` | 288,043 | House | 2015–2023 | Garcia, Stout & Tate (2025), *Black Voices in the Halls of Power*, Cambridge UP |
| `wangtucker` | 169,366 | House + Senate | 2004–2019 | Wang & Tucker (2020), *American Politics Research* 49(1):76–90 |

The two external datasets are folded in for historical depth, each mapped to the
archive schema with a `source` provenance column. Their raw files are **not**
redistributed (only the scraped corpus is published via `publish_archive()`).

Everything is precomputed into a DuckDB store at
`<dirname(R_user_dir("pressR","data"))>/pressR_nlp/press.duckdb`
(tables: `releases`, `families`, `release_family`, `issue_labels`,
`topic_dictionary`, `topic_trends`, `sentiment`). **Never** `read_archive()` the
whole corpus into memory — stream per year via the `nlp_stream_years()` helper in
[`R/00_foundation.R`](R/00_foundation.R).

## Layers (run order)

| Step | Script | Output |
|------|--------|--------|
| Fold in external datasets | `run_external.R` | `pressR_nlp/external/releases-YYYY.rds` |
| Build DuckDB + identity stoplist | `run_rebuild.R` | `releases` table (+`source`) |
| Near-dup "message families" | `run_families.R` | `families`, `release_family` (MinHash/LSH → `family_id`, `cross_source`) |
| Issue-tag completion | `run_tag_complete.R` | `issue_labels`, `tagmodel.rds` (per-issue glmnet, group-aware by family) |
| Topic model | `run_topics.R` | `topic_dictionary`, `topic_trends` (STM, K=40) |
| Sentiment | `run_sentiment.R` → `dashboard/persist_sentiment.R` | `sentiment.rds` → `sentiment` table |
| Dashboard aggregates | `dashboard/prep_dashboard.R` | `dashboard/dashboard.rds` |

`run_foundation.R` is the original combined foundation+families runner (pre
fold-in). Sources/helpers live in [`R/`](R); the issue crosswalk (400 raw tags →
31 canonical issues) is in [`crosswalks/issue_crosswalk.csv`](crosswalks/issue_crosswalk.csv).

The family/tag/topic steps are heavy (MinHash over ~770k unique texts; DFM over
~856k docs). Run them detached and watch the logs; sentiment is multi-core and
fast (~25 min). After the chain, run `persist_sentiment.R` then `prep_dashboard.R`.

## Dashboard

```r
shiny::runApp("nlp/dashboard/app.R")
```

Precompute-then-serve (bslib): loads `dashboard.rds` at startup and queries the
DuckDB `releases` table live only for Explore + drill-downs (short-lived
read-only connections). Seven tabs: Overview, Issue Trends, Topics (STM), Tone
(sentiment), Coordinated Messaging, Explore, and **Data & Methods** (sources +
verified method citations).

## Caveats

- **Tag availability is MNAR by CMS** — some offices never tag, so predicted issue
  labels on never-tagged offices are extrapolation, not validated.
- **Cross-source families** — the folded datasets overlap the scraped corpus in
  time, so the *same* release can appear in more than one collection. These are
  flagged `cross_source` so mechanical duplicates are distinguishable from genuine
  coordinated messaging (and filterable in the dashboard).
- **Sentiment is weak on congressional/promotional prose** — off-the-shelf
  sentimentr skews mildly positive; read differences as suggestive, not definitive.

Citations for every method (quanteda, MinHash/textreuse, glmnet, STM, DuckDB,
sentimentr) and both datasets are listed on the dashboard's Data & Methods tab.
