#!/usr/bin/env Rscript
# 04_extract.R -- offline extraction over the page cache. No network.
#
# Cascade (proven on cached probes, SCOPING-nara-crawler.md section 3):
#   title  insti_page_title (og:title -> h1 -> <title>), cleaned
#   date   insti_page_date FIRST (meta/<time>/JSON-LD/URL/first-parseable-text;
#          it handled the ordinal "September 27th, 2006" and the Aug-2014-
#          content-in-a-2018-capture cases that parse_date2 misdated), then
#          parse_date2 with ordinal suffixes stripped, capture ts last and
#          FLAGGED (date_src="capture") -- never silently.
#   body   wayback extract() body, replaced by insti_item_body when the latter
#          is non-NA and >= 300 chars (it is prose-gated, so it never carries
#          the Dynamic-Drive JS junk that main_content picked up on gordon).
#   gates  date present, body >= 300 chars, n_dates <= 6, not a listing,
#          soft-404 scrub (word-boundary-safe).
#
# Output: nara/data/extracted/<feed_id>.rds + a QA block per feed on stdout.
# VERIFY BY READING the printed date-vs-body samples before staging (05).
#
# Run:  Rscript nara/R/04_extract.R

ROOT <- "/Users/zaynesember/GitRepos/pressR"

# run_wayback.R's functions without its backfill: everything before the
# "== Wayback backfill ==" banner is definitions + cheap setup (it also does
# load_all and sources 00_foundation for nlp_clean_display).
wb <- readLines(file.path(ROOT, "nlp", "run_wayback.R"))
stop_at <- grep("^message\\(sprintf\\(\"== Wayback backfill", wb)[1]
stopifnot(is.finite(stop_at))
tmp <- tempfile(fileext = ".R"); writeLines(wb[1:(stop_at - 1)], tmp); source(tmp)

source(file.path(ROOT, "institutional", "R", "lib_institutional.R"))
source(file.path(ROOT, "nara", "R", "lib_nara.R"))
source(file.path(ROOT, "nara", "R", "02_feed_configs.R"))
suppressMessages(library(data.table))

WALK_DIR <- file.path(NARA_OUT, "walk")
EXT_DIR  <- file.path(NARA_OUT, "extracted")
dir.create(EXT_DIR, recursive = TRUE, showWarnings = FALSE)

cfgs <- nara_feed_configs()
for (i in seq_len(nrow(cfgs))) {
  cfg <- cfgs[i, ]
  wf <- file.path(WALK_DIR, paste0(gsub("[^A-Za-z0-9#._-]+", "_", cfg$feed_id), ".rds"))
  if (!file.exists(wf)) { cat(sprintf("\n[%s] no walk output yet\n", cfg$feed_id)); next }
  w <- readRDS(wf)
  if (!nrow(w$items)) { cat(sprintf("\n[%s] walk empty (status: %s)\n", cfg$feed_id, w$status)); next }

  rows <- vector("list", nrow(w$items)); drops <- character(0)
  for (j in seq_len(nrow(w$items))) {
    it <- nara_extract_item(cfg$congress, w$items$url[j])
    if (it$status != "ok") { drops <- c(drops, it$status); next }
    rows[[j]] <- data.table(
      date = it$date, date_src = it$date_src, title = it$title, body = it$body,
      url = w$items$url[j], url_replay = it$url_replay, capture_ts = it$capture_ts,
      feed_id = cfg$feed_id, congress = cfg$congress,
      unit = cfg$unit, name = cfg$name, type = cfg$type, chamber = cfg$chamber,
      party_feed = cfg$party_feed)
  }
  d <- rbindlist(rows)
  saveRDS(d, file.path(EXT_DIR, paste0(gsub("[^A-Za-z0-9#._-]+", "_", cfg$feed_id), ".rds")))

  cat(sprintf("\n================ %s ================\n", cfg$feed_id))
  cat(sprintf("items %d -> extracted %d | drops: %s\n", nrow(w$items), nrow(d),
              if (length(drops)) paste(names(table(drops)), table(drops), collapse = ", ") else "none"))
  if (nrow(d)) {
    cat("by year: "); print(table(format(d$date, "%Y")))
    cat("date_src: "); print(table(d$date_src))
    # date-vs-body spot check: deterministic sample, read these before staging
    idx <- order(vapply(d$url, function(u) sum(utf8ToInt(substr(u, 1, 50))), 1))[
      seq_len(min(4, nrow(d)))]
    for (k in idx)
      cat(sprintf("  SAMPLE %s [%s] %s\n    body: %s\n", format(d$date[k]), d$date_src[k],
                  substr(d$title[k], 1, 70), substr(gsub("\\s+", " ", d$body[k]), 1, 160)))
  }
}
cat("\nnext: review the QA above, then Rscript nara/R/05_stage.R\n")
