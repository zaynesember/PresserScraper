# 05_collect_worker.R -- Tier-1 collection worker: full-history scrape of the
# institutional hosts the unmodified package already handles.
#
# Usage:  Rscript institutional/R/05_collect_worker.R <worker_id> <n_workers>
#
# Hosts that yielded releases in the spot test are striped across workers by
# index (host i goes to worker i %% n_workers). Each host's result is saved to
# institutional/data/raw/<host>.rds as soon as it finishes, so a crashed or
# killed worker loses at most one host. Hosts with an existing output file are
# skipped, making the worker safely re-runnable.

args <- commandArgs(trailingOnly = TRUE)
worker_id <- as.integer(args[1])
n_workers <- as.integer(args[2])

ROOT <- "/Users/zaynesember/GitRepos/pressR-sources"
suppressMessages(devtools::load_all(ROOT, quiet = TRUE))

OUT <- file.path(ROOT, "institutional", "data")
RAW <- file.path(OUT, "raw")
dir.create(RAW, recursive = TRUE, showWarnings = FALSE)

# A slightly higher polite ceiling than the default 20/min: institutional sites
# are high-capacity, and each worker touches one host at a time.
options(pressR.throttle = 30)

spot <- read.csv(file.path(OUT, "spot_results.csv"), stringsAsFactors = FALSE)
work <- spot[spot$n_90d > 0, ]
work <- work[order(-work$n_90d), ]           # big hosts first, spread across workers
mine <- work[seq_len(nrow(work)) %% n_workers == (worker_id %% n_workers), ]

FROM <- as.Date("2000-01-01")
TO   <- Sys.Date()

message(sprintf("[worker %d/%d] %d hosts: %s", worker_id, n_workers, nrow(mine),
                paste(mine$host, collapse = ", ")))

on_domain <- grepl("\\.(house|senate)\\.gov$", mine$host)

for (i in seq_len(nrow(mine))) {
  host <- mine$host[i]
  dest <- file.path(RAW, paste0(gsub("[^a-z0-9.-]", "_", host), ".rds"))
  if (file.exists(dest)) { message("SKIP (exists): ", host); next }

  message(sprintf("[worker %d] START %s (%s, %d in 90d)", worker_id, host,
                  mine$cms[i], mine$n_90d[i]))
  t0 <- Sys.time()
  url <- paste0("https://", host)

  res <- tryCatch({
    if (on_domain[i]) {
      scrape_member(url, from = FROM, to = TO, page_limit = 1500,
                    fetch_bodies = TRUE, quiet = TRUE)
    } else {
      r <- scrape_member_core(url, FROM, TO, cms = NULL, page_limit = 1500,
                              fetch_bodies = TRUE, quiet = TRUE)
      if (nrow(r) == 0 && !identical(attr(r, "cms_detected"), "generic")) {
        r2 <- scrape_member_core(url, FROM, TO, "generic", 1500, TRUE, TRUE)
        if (nrow(r2) > 0) r <- r2
      }
      strip_status(r)
    }
  }, error = function(e) {
    message(sprintf("[worker %d] ERROR %s: %s", worker_id, host, conditionMessage(e)))
    NULL
  })

  mins <- round(as.numeric(difftime(Sys.time(), t0, units = "mins")), 1)
  if (is.null(res)) {
    saveRDS(list(host = host, error = TRUE, n = 0L), dest)
    message(sprintf("[worker %d] FAIL  %s (%.1f min)", worker_id, host, mins))
  } else {
    res$host <- host
    res$unit <- mine$unit[i]
    res$type <- mine$type[i]
    res$chamber <- mine$chamber[i]
    res$party_site <- mine$party_site[i]
    saveRDS(res, dest)
    message(sprintf("[worker %d] DONE  %s: %d releases %s..%s (%.1f min)",
                    worker_id, host, nrow(res),
                    if (nrow(res)) min(res$date) else NA,
                    if (nrow(res)) max(res$date) else NA, mins))
  }
}
message(sprintf("[worker %d] ALL DONE", worker_id))
