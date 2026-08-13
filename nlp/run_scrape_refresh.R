#!/usr/bin/env Rscript
# Incremental catch-up scrape: the on-disk archive's 'scraped' source hasn't
# been refreshed since 2026-06-20 (max-depth re-scrape). Not a repeat of that
# run -- this walks each office's LISTING PAGES ONLY back to FROM (page_limit
# defaults bind on ~1000 items, far beyond what a 7-week window needs), so it
# is a light, single-process job, not a sharded historical backfill.
# archive_releases() dedupes by url and refreshes existing rows, so overlap
# with the prior scrape is harmless -- FROM has a few days' safety margin.
#
# Writes to archive_dir() (~/Library/.../R/pressR), a DIFFERENT store from
# pressR_nlp -- no collision with the running wayback re-fetch or the DuckDB
# the dashboard/network analysis reads.
#
# Run:  Rscript nlp/run_scrape_refresh.R
suppressMessages(devtools::load_all("/Users/zaynesember/GitRepos/pressR", quiet = TRUE))
t0 <- Sys.time()
FROM <- as.Date(Sys.getenv("SCRAPE_FROM", "2026-06-15"))  # 5d overlap w/ prior max date

cat(sprintf("== incremental scrape refresh: %s -> %s ==\n", FROM, Sys.Date()))

cat("\n-- House --\n")
h <- scrape_house(from = FROM, fetch_bodies = TRUE, render = "auto",
                  retry_failed = TRUE, log_fails = TRUE,
                  fails_path = "/tmp/scrape_refresh_house_fails.csv", quiet = FALSE)
cat(sprintf("House: %d releases, %d failures\n", nrow(h), nrow(attr(h, "failures") %||% data.frame())))
ah <- archive_releases(h)
cat(sprintf("archived: +%d new, %d updated\n", ah$added, ah$updated))

cat("\n-- Senate --\n")
s <- scrape_senate(from = FROM, fetch_bodies = TRUE, render = "auto",
                   retry_failed = TRUE, log_fails = TRUE,
                   fails_path = "/tmp/scrape_refresh_senate_fails.csv", quiet = FALSE)
cat(sprintf("Senate: %d releases, %d failures\n", nrow(s), nrow(attr(s, "failures") %||% data.frame())))
as_ <- archive_releases(s)
cat(sprintf("archived: +%d new, %d updated\n", as_$added, as_$updated))

cat(sprintf("\n================ REFRESH DONE ================\n"))
cat(sprintf("total archived: +%d new, %d updated\n", ah$added + as_$added, ah$updated + as_$updated))
cat(sprintf("done in %.1f min\n", as.numeric(difftime(Sys.time(), t0, units = "mins"))))
cat("\nNOTE: this updates the on-disk archive only. It is NOT in press.duckdb\n")
cat("until the next fold-in (nlp/run_foldin.sh) -- batch with other pending sources.\n")
