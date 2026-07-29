# 14_recollect_feed.R -- re-collect specific feeds by feed_id, after a config or
# walker fix.
#
# Why not just delete the output and rerun 07_collect_feeds.R: that script scans
# a whole config file and collects everything without an output yet. While the
# parallel lanes are mid-run, feeds they have not finished have no output file,
# so a second process would pick them up and two collectors would hit one host.
# This script walks ONLY the feed_ids named on the command line.
#
# The existing output is moved aside to institutional/data/raw_stale/ rather than
# deleted -- institutional/data/ is gitignored and exists in exactly one place.
#
# Run:  Rscript institutional/R/14_recollect_feed.R <feed_id> [<feed_id> ...]

ROOT <- "/Users/zaynesember/GitRepos/pressR"
suppressMessages(devtools::load_all(ROOT, quiet = TRUE))
source(file.path(ROOT, "institutional", "R", "lib_institutional.R"))
RAW   <- file.path(ROOT, "institutional", "data", "raw")
STALE <- file.path(ROOT, "institutional", "data", "raw_stale")
dir.create(STALE, recursive = TRUE, showWarnings = FALSE)
options(pressR.throttle = 30)

R_DIR <- file.path(ROOT, "institutional", "R")
load_cfg <- function(fn) {
  e <- new.env(); sys.source(file.path(R_DIR, fn), envir = e); e$feed_configs()
}
cfg <- rbind(load_cfg("06_feed_configs.R"), load_cfg("11_feed_configs2.R"))

args <- commandArgs(trailingOnly = TRUE)
FORCE <- "--force" %in% args
ids <- args[!grepl("^--", args)]
if (!length(ids)) stop("give one or more feed_ids")

FROM <- as.Date("2000-01-01"); TO <- Sys.Date()

for (id in ids) {
  f <- cfg[cfg$feed_id == id, ]
  if (!nrow(f)) { message("!! no config for ", id); next }
  f <- f[1, ]
  dest <- file.path(RAW, paste0("feed_", gsub("[^a-z0-9#._-]", "_", f$feed_id), ".rds"))

  message("\n===== ", id, "  engine=", f$engine, " party=", f$party)
  t0 <- Sys.time()
  res <- tryCatch({
    if (f$engine == "insti") {
      w <- walk_feed(f$listing, f$item_re, FROM, TO, quiet = TRUE)
      items <- w$items
      if (nrow(items) > 0) items <- insti_fetch_bodies(items)
      list(items = items, status = w$status)
    } else if (f$engine == "sitemap") {
      w <- walk_sitemap_feed(f$listing, f$item_re, FROM, TO, fetch_bodies = TRUE)
      list(items = w$items, status = w$status)
    } else if (f$engine == "guid") {
      w <- walk_guid_feed(f$listing, FROM, TO)
      items <- w$items
      if (nrow(items) > 0) items <- guid_feed_bodies(items)
      list(items = items, status = w$status)
    } else stop("unknown engine: ", f$engine)
  }, error = function(e) list(items = NULL, status = paste("ERROR:", conditionMessage(e))))

  items <- res$items
  if (is.null(items) || !nrow(items)) {
    message("  -> ", res$status, " -- NOTHING collected; leaving the old output in place")
    next
  }

  items$host <- f$host; items$unit <- f$unit; items$type <- f$type
  items$chamber <- f$chamber; items$party_feed <- f$party; items$listing <- f$listing

  nb <- sum(!is.na(items$body) & nchar(items$body) > 200)
  message("  -> ", nrow(items), " items, ", nb, " with a body, ",
          as.character(min(items$date, na.rm = TRUE)), " .. ",
          as.character(max(items$date, na.rm = TRUE)),
          "  (", round(as.numeric(difftime(Sys.time(), t0, units = "mins")), 1), " min)")

  if (file.exists(dest)) {
    old <- tryCatch(readRDS(dest), error = function(e) NULL)
    n_old <- if (is.data.frame(old)) nrow(old) else 0L
    nb_old <- if (is.data.frame(old) && "body" %in% names(old))
      sum(!is.na(old$body) & nchar(old$body) > 200) else 0L
    # Don't let a re-collect quietly REDUCE coverage. Pager detection is a live
    # probe and can come back "none" on a listing that paginated fine earlier,
    # in which case a rerun returns just page 0 -- a silent regression that looks
    # like success. Keep the better haul unless the caller insists.
    if (!FORCE && nrow(items) < 0.9 * n_old && nb_old >= nb) {
      message("     !! REGRESSION: new haul ", nrow(items), " rows / ", nb,
              " bodies vs existing ", n_old, " / ", nb_old,
              " -- keeping the existing output (rerun with --force to override)")
      next
    }
    message("     previous output had ", n_old, " rows (", nb_old,
            " bodies) -> moved to raw_stale/")
    file.rename(dest, file.path(STALE, basename(dest)))
  }
  saveRDS(items, dest)
}
