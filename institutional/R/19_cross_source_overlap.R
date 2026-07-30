# 19_cross_source_overlap.R -- how much do institutional releases duplicate
# member releases? (The README's open question, answerable now that the fold-in
# ran family detection over member + institutional rows together.)
#
# A "member-shared family" is a near-dup family containing at least one
# institutional row (committee/leadership/caucus) AND at least one member-source
# row (scraped/stout/wangtucker/wayback). For those families we also ask who
# published first, since lead/lag is the interesting political quantity: does
# the committee originate and members echo, or the reverse?
#
# Read-only. Prints the digest and saves institutional/data/cross_source_overlap.rds.
#
# Run:  Rscript institutional/R/19_cross_source_overlap.R

suppressMessages({library(DBI); library(duckdb)})
ROOT <- "/Users/zaynesember/GitRepos/pressR"
RU <- file.path(path.expand("~"), "Library/Application Support/org.R-project.R/R/pressR_nlp")
con <- dbConnect(duckdb::duckdb(), dbdir = file.path(RU, "press.duckdb"), read_only = TRUE)

INST <- c("committee", "leadership", "caucus")
MEM  <- c("scraped", "stout", "wangtucker", "wayback")

# Per-family source mix + per-side date minima, one pass.
fam <- dbGetQuery(con, "
  SELECT rf.family_id,
         SUM((r.source IN ('committee','leadership','caucus'))::INT) n_inst,
         SUM((r.source IN ('scraped','stout','wangtucker','wayback'))::INT) n_mem,
         MIN(CASE WHEN r.source IN ('committee','leadership','caucus') THEN r.date END) inst_min,
         MIN(CASE WHEN r.source IN ('scraped','stout','wangtucker','wayback') THEN r.date END) mem_min
  FROM release_family rf JOIN releases r ON rf.url = r.url
  WHERE r.usable
  GROUP BY rf.family_id")

tot_inst <- dbGetQuery(con, "SELECT source, COUNT(*) n FROM releases
  WHERE usable AND source IN ('committee','leadership','caucus') GROUP BY source")

shared <- fam[fam$n_inst > 0 & fam$n_mem > 0, ]
inst_in_shared <- dbGetQuery(con, "
  SELECT r.source, COUNT(*) n
  FROM release_family rf
  JOIN releases r ON rf.url = r.url
  WHERE r.usable AND r.source IN ('committee','leadership','caucus')
    AND rf.family_id IN (
      SELECT rf2.family_id FROM release_family rf2 JOIN releases r2 ON rf2.url = r2.url
      WHERE r2.usable
      GROUP BY rf2.family_id
      HAVING SUM((r2.source IN ('committee','leadership','caucus'))::INT) > 0
         AND SUM((r2.source IN ('scraped','stout','wangtucker','wayback'))::INT) > 0)
  GROUP BY r.source")

cat("================ CROSS-SOURCE OVERLAP ================\n")
cat(sprintf("families with >=1 usable doc: %s\n", format(nrow(fam), big.mark = ",")))
cat(sprintf("member-shared families: %s\n\n", format(nrow(shared), big.mark = ",")))
cat("institutional releases sharing a family with a member release:\n")
m <- merge(tot_inst, inst_in_shared, by = "source", all.x = TRUE,
           suffixes = c("_total", "_shared"))
m$n_shared[is.na(m$n_shared)] <- 0L
m$pct <- round(100 * m$n_shared / m$n_total, 1)
print(m[order(-m$n_total), ], row.names = FALSE)

cat("\nlead/lag inside member-shared families (by earliest date per side):\n")
lag <- shared[!is.na(shared$inst_min) & !is.na(shared$mem_min), ]
lag$diff <- as.integer(as.Date(lag$mem_min) - as.Date(lag$inst_min))
cat(sprintf("  institutional first: %s (%.1f%%)\n",
    format(sum(lag$diff > 0), big.mark = ","), 100 * mean(lag$diff > 0)))
cat(sprintf("  same day           : %s (%.1f%%)\n",
    format(sum(lag$diff == 0), big.mark = ","), 100 * mean(lag$diff == 0)))
cat(sprintf("  member first       : %s (%.1f%%)\n",
    format(sum(lag$diff < 0), big.mark = ","), 100 * mean(lag$diff < 0)))
cat(sprintf("  median |gap| when not same-day: %s days\n",
    stats::median(abs(lag$diff[lag$diff != 0]))))

saveRDS(list(fam_mix = fam, shared = shared, by_source = m, lag = lag),
        file.path(ROOT, "institutional", "data", "cross_source_overlap.rds"))
dbDisconnect(con, shutdown = TRUE)
