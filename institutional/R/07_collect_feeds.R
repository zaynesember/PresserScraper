# 07_collect_feeds.R -- Tier-2 collection: walk the hand-configured feeds.
#
# Usage:  Rscript institutional/R/07_collect_feeds.R [--test] [--configs=<file.R>]
#
# --test walks each feed over the last 60 days without bodies and prints a
# per-feed summary (fast sanity pass). The full run collects since 2000 with
# bodies and writes institutional/data/raw/feed_<feed_id>.rds per feed.
# Existing outputs are skipped, so the script is safely re-runnable.
# --configs points at an alternative file defining feed_configs() (defaults to
# 06_feed_configs.R).

args <- commandArgs(trailingOnly = TRUE)
TEST <- "--test" %in% args
cfg_file <- sub("^--configs=", "", grep("^--configs=", args, value = TRUE))

ROOT <- "/Users/zaynesember/GitRepos/pressR-sources"
suppressMessages(devtools::load_all(ROOT, quiet = TRUE))
source(file.path(ROOT, "institutional", "R", "lib_institutional.R"))
if (length(cfg_file) == 1) {
  source(file.path(ROOT, "institutional", "R", cfg_file))
} else {
  source(file.path(ROOT, "institutional", "R", "06_feed_configs.R"))
}

OUT <- file.path(ROOT, "institutional", "data")
RAW <- file.path(OUT, "raw")
dir.create(RAW, recursive = TRUE, showWarnings = FALSE)
options(pressR.throttle = 30)

cfg <- feed_configs()
FROM <- if (TEST) Sys.Date() - 60 else as.Date("2000-01-01")
TO   <- Sys.Date()

for (i in seq_len(nrow(cfg))) {
  f <- cfg[i, ]
  dest <- file.path(RAW, paste0("feed_", gsub("[^a-z0-9#._-]", "_", f$feed_id), ".rds"))
  if (!TEST && file.exists(dest)) { message("SKIP (exists): ", f$feed_id); next }
  message(sprintf("[%2d/%2d] %-45s engine=%-7s party=%s",
                  i, nrow(cfg), f$feed_id, f$engine, f$party))
  t0 <- Sys.time()

  res <- tryCatch({
    if (f$engine == "insti") {
      w <- walk_feed(f$listing, f$item_re, FROM, TO, quiet = TRUE)
      items <- w$items
      if (!TEST && nrow(items) > 0) items <- insti_fetch_bodies(items)
      list(items = items, status = w$status)
    } else if (f$engine == "sitemap") {
      w <- walk_sitemap_feed(f$listing, f$item_re, FROM, TO, fetch_bodies = !TEST)
      list(items = w$items, status = w$status)
    } else if (f$engine == "guid") {
      w <- walk_guid_feed(f$listing, FROM, TO)
      items <- w$items
      if (!TEST && nrow(items) > 0) items <- guid_feed_bodies(items)
      list(items = items, status = w$status)
    } else {  # package
      r <- tryCatch(
        scrape_member(f$listing, from = FROM, to = TO, page_limit = 1500,
                      fetch_bodies = !TEST, quiet = TRUE),
        error = function(e) { message("    package: ", conditionMessage(e)); NULL }
      )
      list(items = if (is.null(r)) empty_items() else r,
           status = if (is.null(r)) "package abort" else "ok")
    }
  }, error = function(e) list(items = empty_items(), status = conditionMessage(e)))

  items <- res$items
  mins <- round(as.numeric(difftime(Sys.time(), t0, units = "mins")), 1)
  message(sprintf("        -> %4d items  [%s]  %s..%s  (%.1f min)",
                  nrow(items), res$status,
                  if (nrow(items)) as.character(min(items$date, na.rm = TRUE)) else "",
                  if (nrow(items)) as.character(max(items$date, na.rm = TRUE)) else "", mins))

  if (!TEST) {
    if (nrow(items) > 0) {
      items$host <- f$host; items$unit <- f$unit; items$type <- f$type
      items$chamber <- f$chamber; items$party_feed <- f$party
      items$listing <- f$listing
    }
    saveRDS(items, dest)
  }
}
message("FEEDS PASS COMPLETE")
