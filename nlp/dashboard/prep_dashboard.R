#!/usr/bin/env Rscript
# Precompute every aggregate the Shiny dashboard needs into ONE small RDS, so the
# app loads instantly and does ZERO heavy work at runtime (precompute-then-serve).
# The big `releases` table stays in DuckDB; the app queries it live only for the
# Explore tab + family/issue drill-downs.
suppressMessages({ library(DBI); library(duckdb); library(dplyr); library(tidyr) })

NLP <- file.path(dirname(tools::R_user_dir("pressR", "data")), "pressR_nlp")
con <- dbConnect(duckdb::duckdb(), file.path(NLP, "press.duckdb"), read_only = TRUE)

q <- function(sql) dbGetQuery(con, sql)
splitfn <- function(col) sprintf("unnest(string_split(%s, ';'))", col)
has_table <- function(t) t %in% dbListTables(con)

# ---- overview headline stats ----
ov <- q("SELECT
  COUNT(*) n_total,
  SUM(usable::INT) n_usable,
  MIN(date) dmin, MAX(date) dmax,
  ROUND(100.0*AVG(has_body::INT),1) pct_body,
  ROUND(100.0*AVG((tags IS NOT NULL)::INT),1) pct_office_tagged,
  SUM((chamber='house')::INT) n_house, SUM((chamber='senate')::INT) n_senate
  FROM releases")
fam_ov <- q("SELECT COUNT(*) n_fam, SUM(is_reused::INT) n_reused_fam,
  SUM(cross_party::INT) n_xparty, SUM(cross_chamber::INT) n_xchamber FROM families")
reuse <- q("SELECT ROUND(100.0*AVG(is_reused::INT),1) pct_reused FROM release_family")
lab <- q("SELECT ROUND(100.0*AVG((COALESCE(office_issues,predicted_issues) IS NOT NULL)::INT),1) pct_labeled FROM issue_labels")

# ---- source provenance (scraped + folded external datasets) ----
sources <- q("SELECT source, COUNT(*) n, SUM(usable::INT) usable,
  MIN(date) dmin, MAX(date) dmax,
  ROUND(100.0*AVG(has_body::INT),1) pct_body,
  ROUND(100.0*AVG((tags IS NOT NULL)::INT),1) pct_tagged
  FROM releases GROUP BY source ORDER BY n DESC")

# ---- sentiment aggregates (only if the precomputed sentiment table is present) ----
sentiment_trends <- sentiment_by_issue <- sentiment_sources <- NULL
if (has_table("sentiment")) {
  sentiment_trends <- q("SELECT r.year, r.party, ROUND(AVG(s.sentiment),4) mean_sent,
      COUNT(*) n FROM sentiment s JOIN releases r USING(url)
      WHERE r.party IN ('D','R') AND r.usable AND r.year IS NOT NULL
      GROUP BY 1,2 ORDER BY 1,2")
  sentiment_by_issue <- q(sprintf("SELECT trim(iss) issue, r.party,
      ROUND(AVG(s.sentiment),4) mean_sent, COUNT(*) n
      FROM sentiment s JOIN releases r USING(url) JOIN issue_labels il USING(url),
      %s AS u(iss)
      WHERE r.party IN ('D','R') AND trim(iss) <> ''
      GROUP BY 1,2 HAVING COUNT(*) >= 100", splitfn("COALESCE(il.office_issues, il.predicted_issues)")))
  sentiment_sources <- q("SELECT r.source, ROUND(AVG(s.sentiment),4) mean_sent,
      ROUND(MEDIAN(s.sentiment),4) med_sent, COUNT(*) n
      FROM sentiment s JOIN releases r USING(url) GROUP BY 1 ORDER BY 4 DESC")
}

# ---- issue trends (within-year share), office-only and office+predicted ----
issue_trend <- function(label_expr) {
  long <- q(sprintf("
    SELECT r.year, r.party, r.chamber, trim(iss) AS issue FROM releases r
    JOIN issue_labels il USING(url), %s AS u(iss)
    WHERE r.usable AND r.party IN ('D','R') AND %s IS NOT NULL AND trim(iss)<>''",
    splitfn(sprintf("COALESCE(%s)", label_expr)), label_expr))
  denom <- q(sprintf("
    SELECT r.year, r.party, r.chamber, COUNT(*) n_rel FROM releases r JOIN issue_labels il USING(url)
    WHERE r.usable AND r.party IN ('D','R') AND %s IS NOT NULL GROUP BY 1,2,3", label_expr))
  long %>% count(year, party, chamber, issue, name = "n_issue") %>%
    left_join(denom, by = c("year","party","chamber")) %>%
    mutate(share = n_issue / n_rel)
}
issue_trends_all    <- issue_trend("COALESCE(il.office_issues, il.predicted_issues)")
issue_trends_office <- issue_trend("il.office_issues")
issues <- sort(unique(issue_trends_all$issue))

# ---- topic model tables ----
topic_dict   <- q("SELECT * FROM topic_dictionary ORDER BY prevalence DESC")
topic_trends <- q("SELECT * FROM topic_trends")

# ---- coordinated-messaging families (top reused multi-member) ----
fam_top <- q("
  SELECT f.family_id, f.n_docs, f.n_members, f.parties, f.sources,
         f.cross_party, f.cross_chamber, f.cross_source,
         f.date_min, f.date_max, f.span_days, ANY_VALUE(r.title) rep_title
  FROM families f JOIN release_family rf USING(family_id) JOIN releases r USING(url)
  WHERE f.is_reused AND f.n_members >= 2
  GROUP BY f.family_id, f.n_docs, f.n_members, f.parties, f.sources,
           f.cross_party, f.cross_chamber, f.cross_source,
           f.date_min, f.date_max, f.span_days
  ORDER BY f.n_members DESC, f.n_docs DESC LIMIT 1000")

# ---- filter vocab ----
members <- q("SELECT DISTINCT name, party, chamber, state FROM releases WHERE name IS NOT NULL ORDER BY name")
years   <- q("SELECT DISTINCT year FROM releases WHERE year IS NOT NULL ORDER BY year")$year

# ---- partisan language: Monroe weighted log-odds (only if present) ----
partisan_terms <- partisan_scopes <- NULL
if (has_table("partisan_terms")) {
  partisan_terms  <- q("SELECT * FROM partisan_terms")
  partisan_scopes <- q("SELECT * FROM partisan_scopes")
}

# ---- coordination network: members linked by shared message families ----
network <- NULL
if (has_table("network_nodes")) {
  nn   <- q("SELECT * FROM network_nodes")
  ne   <- q("SELECT * FROM network_edges")
  nts  <- q("SELECT * FROM network_ts")
  nsum <- q("SELECT * FROM network_summary")
  brokers <- nn[nn$party %in% c("D","R"), ]
  brokers <- brokers[order(-brokers$cross_party_strength), ][seq_len(min(25, nrow(brokers))), ]
  thr <- if (nrow(ne) > 600) sort(ne$weight, decreasing = TRUE)[600] else min(ne$weight)
  network <- list(nodes = nn, edges = ne, ts = nts, summary = nsum, brokers = brokers,
                  w_min = min(ne$weight), w_max = max(ne$weight), w_default = round(thr, 3))
}

# ---- targeted tone / attack score (if present) ----
attack <- NULL
if (has_table("attack_scores")) {
  dd <- "WITH d AS (
      SELECT a.out_attack, r.name, r.party, r.year,
        ROW_NUMBER() OVER (PARTITION BY rf.family_id ORDER BY a.url) rn
      FROM attack_scores a JOIN releases r USING(url) LEFT JOIN release_family rf USING(url)
      WHERE r.party IN ('D','R') AND a.out_attack IS NOT NULL)
    SELECT * FROM d WHERE rn = 1"           # de-leak: one release per message family
  abyp <- q(sprintf("SELECT party, year, ROUND(AVG(out_attack),4) mean_attack, COUNT(*) n
    FROM (%s) WHERE year BETWEEN 2005 AND 2026 GROUP BY 1,2 ORDER BY 1,2", dd))
  abrokers <- q(sprintf("SELECT name, party, ROUND(AVG(out_attack),4) mean_attack, COUNT(*) n
    FROM (%s) GROUP BY 1,2 HAVING COUNT(*) >= 40 ORDER BY mean_attack DESC LIMIT 25", dd))
  ets <- q("SELECT entity_id, entity_type, sp_party, year,
    ROUND(SUM(mean_sentiment*n)/SUM(n),4) mean, SUM(n) n FROM entity_stance
    WHERE sp_party IN ('D','R') GROUP BY 1,2,3,4 HAVING SUM(n) >= 20")
  asum <- q(sprintf("SELECT party, ROUND(AVG(out_attack),4) mean_attack FROM (%s) GROUP BY 1", dd))
  attack <- list(by_party_year = abyp, brokers = abrokers, entity_ts = ets, summary = asum,
                 entities = sort(unique(ets$entity_id)))
}

dbDisconnect(con, shutdown = TRUE)

dash <- list(
  overview = c(as.list(ov), as.list(fam_ov), as.list(reuse), as.list(lab)),
  sources = sources,
  issue_trends_all = issue_trends_all, issue_trends_office = issue_trends_office,
  issues = issues, topic_dict = topic_dict, topic_trends = topic_trends,
  fam_top = fam_top, members = members, years = years,
  sentiment_trends = sentiment_trends, sentiment_by_issue = sentiment_by_issue,
  sentiment_sources = sentiment_sources,
  partisan_terms = partisan_terms, partisan_scopes = partisan_scopes,
  network = network, attack = attack,
  built_at = as.character(Sys.time())
)
dir.create(file.path(NLP, "dashboard"), showWarnings = FALSE)
saveRDS(dash, file.path(NLP, "dashboard", "dashboard.rds"))
cat("dashboard.rds written:\n")
cat(sprintf("  overview: %s releases, %s usable, %s..%s\n",
  format(ov$n_total,big.mark=","), format(ov$n_usable,big.mark=","), ov$dmin, ov$dmax))
cat(sprintf("  issue_trends rows: %s (all) / %s (office) | issues: %d\n",
  nrow(issue_trends_all), nrow(issue_trends_office), length(issues)))
cat(sprintf("  topics: %d | top families: %s | members: %s\n",
  nrow(topic_dict), nrow(fam_top), nrow(members)))
cat(sprintf("  sources: %s | sentiment: %s\n",
  paste(sources$source, collapse=", "),
  if (is.null(sentiment_trends)) "ABSENT (run sentiment + persist first)" else
    sprintf("%d trend rows, %d issue rows", nrow(sentiment_trends), nrow(sentiment_by_issue))))
cat(sprintf("  partisan: %s\n",
  if (is.null(partisan_terms)) "ABSENT (run nlp/run_partisan.R first)" else
    sprintf("%d term rows across %d scopes", nrow(partisan_terms), nrow(partisan_scopes))))
cat(sprintf("  network: %s\n",
  if (is.null(network)) "ABSENT (run nlp/run_network.R first)" else
    sprintf("%d members, %d edges, %d communities", network$summary$n_nodes,
            network$summary$n_edges, network$summary$n_communities)))
cat(sprintf("  attack: %s\n",
  if (is.null(attack)) "ABSENT (run nlp/run_attack.R first)" else
    sprintf("%d party-year rows, %d entities, %d brokers", nrow(attack$by_party_year),
            length(attack$entities), nrow(attack$brokers))))
