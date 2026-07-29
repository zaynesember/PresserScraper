# 13_backfill_bodies.R -- fill in missing bodies on already-collected raw files
# WITHOUT re-walking the listings.
#
# Why: ~11% of the collected institutional rows had no body, almost all of it
# one root cause -- the Elementor page builder (hsgac, commerce, drugcaucus)
# emits no <article>/<main>/.content wrapper, so the stock body extractor
# returned NA for every item. The walk itself was fine: dates, titles and URLs
# are all correct. Re-collecting those feeds would re-fetch thousands of listing
# pages to rediscover items we already have, so backfill the bodies in place.
#
# Only rows whose body is missing/short are fetched, so this is re-runnable and
# resumable. The file is rewritten atomically (temp + rename) at the end of each
# file, and a `.bak` copy is kept the first time a file is touched --
# institutional/data/ is gitignored and exists in exactly one place.
#
# Run:  Rscript institutional/R/13_backfill_bodies.R <file.rds> [<file.rds> ...]
#       Rscript institutional/R/13_backfill_bodies.R --list
#
# Pass ONE HOST per process if you parallelise, so no host sees two processes.

ROOT <- "/Users/zaynesember/GitRepos/pressR"
suppressMessages(devtools::load_all(ROOT, quiet = TRUE))
source(file.path(ROOT, "institutional", "R", "lib_institutional.R"))
RAW <- file.path(ROOT, "institutional", "data", "raw")
options(pressR.throttle = 30)

MIN_BODY <- 200
args <- commandArgs(trailingOnly = TRUE)

has_body <- function(b) !is.na(b) & nchar(b) > MIN_BODY

coverage <- function() {
  fs <- list.files(RAW, pattern = "\\.rds$", full.names = TRUE)
  do.call(rbind, lapply(fs, function(f) {
    x <- tryCatch(readRDS(f), error = function(e) NULL)
    if (!is.data.frame(x) || !nrow(x)) return(NULL)
    b <- if ("body" %in% names(x)) x$body else rep(NA_character_, nrow(x))
    data.frame(file = basename(f), n = nrow(x), nbody = sum(has_body(b)),
               pct = round(100 * mean(has_body(b)), 1), stringsAsFactors = FALSE)
  }))
}

if ("--list" %in% args) {
  d <- coverage(); d <- d[order(d$pct, -d$n), ]
  cat("== body coverage, worst first ==\n")
  print(utils::head(d, 25), row.names = FALSE)
  cat("\nmissing bodies overall: ", sum(d$n - d$nbody), " of ", sum(d$n), "\n", sep = "")
  quit(save = "no")
}

targets <- args[!grepl("^--", args)]
if (!length(targets)) stop("give one or more raw .rds filenames, or --list")

# Refuse to touch a file whose host an active collector may also be writing:
# the lanes only ever write feeds from the round-2 config, so that is the guard.
active_hosts <- character(0)
if (any(grepl("07_collect_feeds.R", system("ps -eo command=", intern = TRUE)))) {
  e <- new.env()
  sys.source(file.path(ROOT, "institutional", "R", "11_feed_configs2.R"), envir = e)
  active_hosts <- unique(e$feed_configs()$host)
  message("collector running; ", length(active_hosts), " hosts are off limits")
}

for (t in targets) {
  f <- if (file.exists(t)) t else file.path(RAW, t)
  if (!file.exists(f)) { message("!! missing: ", t); next }
  x <- readRDS(f)
  if (!is.data.frame(x) || !nrow(x)) { message("!! not a data frame with rows: ", t); next }
  if (!"body" %in% names(x)) x$body <- NA_character_

  host <- x$host[1]
  if (host %in% active_hosts) {
    message("!! SKIP ", basename(f), " -- host ", host,
            " is in the active collector's config; rerun when it finishes")
    next
  }

  need <- which(!has_body(x$body))
  message("\n== ", basename(f), ": ", nrow(x), " rows, ", length(need), " missing a body")
  if (!length(need)) next

  bak <- paste0(f, ".bak")
  if (!file.exists(bak)) file.copy(f, bak)

  filled <- 0L
  for (k in seq_along(need)) {
    i <- need[k]
    doc <- get_html(x$url[i])
    if (!is.null(doc)) {
      b <- tryCatch(insti_item_body(doc, x$url[i]), error = function(e) NA_character_)
      if (has_body(b)) { x$body[i] <- b; filled <- filled + 1L }
    }
    if (k %% 100 == 0) message("   ", k, "/", length(need), "  filled ", filled)
  }

  tmp <- paste0(f, ".tmp")
  saveRDS(x, tmp); file.rename(tmp, f)
  message("== ", basename(f), " done: filled ", filled, " of ", length(need),
          "; coverage now ", round(100 * mean(has_body(x$body)), 1), "%")
}
