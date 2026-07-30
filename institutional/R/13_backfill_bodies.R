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

# Refuse to touch a file whose host a *running* lane may also be hitting.
#
# Blocking every host in the config is too blunt: lanes are partitioned by host
# and finish at different times, so once the lane owning a host has exited that
# host is free. Work out which lane owns each host using the same partition
# 07_collect_feeds.R uses, and block only the hosts owned by lanes still alive.
active_hosts <- character(0)
ps_lines <- tryCatch(system("ps -eo command=", intern = TRUE), error = function(e) character(0))
# Match how R itself launches the script (--file=...), not any command line that
# merely mentions it: a shell one-liner containing both "07_collect_feeds.R" and
# "--lane=" would otherwise be read as a running lane and skew this guard.
coll <- grep("--file=.*07_collect_feeds\\.R", ps_lines, value = TRUE)
if (length(coll)) {
  lanes <- unique(sub(".*--lane=([0-9]+)/([0-9]+).*", "\\1/\\2", grep("--lane=", coll, value = TRUE)))
  cfg_name <- sub(".*--configs=([^ ]+).*", "\\1", grep("--configs=", coll, value = TRUE)[1])
  if (is.na(cfg_name) || !nzchar(cfg_name)) cfg_name <- "11_feed_configs2.R"
  e <- new.env()
  sys.source(file.path(ROOT, "institutional", "R", cfg_name), envir = e)
  cfg <- e$feed_configs()
  if (length(lanes)) {
    N <- as.integer(sub(".*/", "", lanes[1]))
    live <- as.integer(sub("/.*", "", lanes))
    tab <- sort(table(cfg$host), decreasing = TRUE)
    hosts <- names(tab)
    lane_of <- setNames(((seq_along(hosts) - 1L) %% N) + 1L, hosts)
    owned <- names(lane_of)[lane_of %in% live]
    # Ownership alone is still too blunt. A lane walks its feeds sequentially,
    # writes each output on completion, and skips any feed whose output exists --
    # so once every feed on a host has an output, the lane will never touch that
    # host again even though the process is alive (it is off working its other
    # hosts). Block only owned hosts that still have an uncollected feed; the
    # feed a lane is walking right now has no output yet, so its host stays
    # blocked. Pending work only ever shrinks, so this cannot race the lane onto
    # a freed host.
    dest <- file.path(RAW, paste0("feed_", gsub("[^a-z0-9#._-]", "_", cfg$feed_id), ".rds"))
    pending_hosts <- unique(cfg$host[!file.exists(dest)])
    active_hosts <- intersect(owned, pending_hosts)
    message(length(live), " lane(s) of ", N, " still running (", paste(sort(live), collapse = ","),
            "); ", length(active_hosts), " of ", length(owned),
            " owned hosts still have pending feeds and are off limits")
  } else {
    # A collector is running but not lane-partitioned: block the whole config.
    active_hosts <- unique(cfg$host)
    message("un-partitioned collector running; ", length(active_hosts), " hosts off limits")
  }
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

  # Boilerplate guard. On some hosts the extractor returns the SAME string for
  # every release -- intelligence.senate.gov yields an identical 224-char
  # "Intelligence Authorization Act ..." block, so a naive backfill would store
  # 1,057 copies of it, which is worse than leaving those rows body-less. Refuse
  # a candidate that duplicates a body already present in this file, and bail out
  # of the file entirely once that keeps happening.
  seen <- new.env(parent = emptyenv())
  for (bb in x$body[has_body(x$body)]) {
    key <- substr(bb, 1, 400)
    assign(key, (if (is.null(seen[[key]])) 0L else seen[[key]]) + 1L, envir = seen)
  }

  filled <- 0L; dup_skipped <- 0L
  for (k in seq_along(need)) {
    i <- need[k]
    doc <- get_html(x$url[i])
    if (!is.null(doc)) {
      b <- tryCatch(insti_item_body(doc, x$url[i]), error = function(e) NA_character_)
      if (has_body(b)) {
        key <- substr(b, 1, 400)
        n_same <- if (is.null(seen[[key]])) 0L else seen[[key]]
        if (n_same >= 2L) {
          dup_skipped <- dup_skipped + 1L
        } else {
          x$body[i] <- b; filled <- filled + 1L
          assign(key, n_same + 1L, envir = seen)
        }
      }
    }
    if (k %% 100 == 0)
      message("   ", k, "/", length(need), "  filled ", filled,
              if (dup_skipped) paste0("  (", dup_skipped, " boilerplate skipped)") else "")
    # If nearly everything is a duplicate, this host returns one canned block.
    if (dup_skipped >= 25L && dup_skipped > 3L * filled) {
      message("   !! ABORTING ", basename(f), ": ", dup_skipped,
              " duplicate bodies vs ", filled, " real ones -- this host returns",
              " boilerplate, leaving the remaining rows body-less")
      break
    }
  }
  if (dup_skipped)
    message("   ", dup_skipped, " candidate bodies skipped as duplicates of existing text")

  tmp <- paste0(f, ".tmp")
  saveRDS(x, tmp); file.rename(tmp, f)
  message("== ", basename(f), " done: filled ", filled, " of ", length(need),
          "; coverage now ", round(100 * mean(has_body(x$body)), 1), "%")
}
