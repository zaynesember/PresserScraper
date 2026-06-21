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
  SELECT f.family_id, f.n_docs, f.n_members, f.parties, f.cross_party, f.cross_chamber,
         f.date_min, f.date_max, f.span_days, ANY_VALUE(r.title) rep_title
  FROM families f JOIN release_family rf USING(family_id) JOIN releases r USING(url)
  WHERE f.is_reused AND f.n_members >= 2
  GROUP BY f.family_id, f.n_docs, f.n_members, f.parties, f.cross_party, f.cross_chamber,
           f.date_min, f.date_max, f.span_days
  ORDER BY f.n_members DESC, f.n_docs DESC LIMIT 1000")

# ---- filter vocab ----
members <- q("SELECT DISTINCT name, party, chamber, state FROM releases WHERE name IS NOT NULL ORDER BY name")
years   <- q("SELECT DISTINCT year FROM releases WHERE year IS NOT NULL ORDER BY year")$year

dbDisconnect(con, shutdown = TRUE)

dash <- list(
  overview = c(as.list(ov), as.list(fam_ov), as.list(reuse), as.list(lab)),
  issue_trends_all = issue_trends_all, issue_trends_office = issue_trends_office,
  issues = issues, topic_dict = topic_dict, topic_trends = topic_trends,
  fam_top = fam_top, members = members, years = years,
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
