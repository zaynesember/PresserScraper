#!/usr/bin/env Rscript
# 03_walk.R -- the network stage of the tier-A pilot. Two passes:
#
#   1. Walk each configured feed's listing pages (rewritten mode -- links are
#      needed) and collect item URLs. Output nara/data/walk/<feed_id>.rds with
#      an EXPLICIT status field: a zero-row file with status != "ok" is
#      re-walked next run, so a failed feed can never masquerade as an empty
#      one (the skip-if-exists trap from the institutional round).
#   2. Union all items, dedup by scheme-insensitive URL key preferring the
#      NEWEST congress, and fetch each item page once in id_ (raw) mode into
#      the page cache. Extraction (04) then runs entirely offline.
#
# Politeness is enforced in lib_nara: 10s global throttle, 429 -> 5 min sleep,
# and a daily budget -- when it runs out this script exits cleanly and the next
# run resumes from the caches.
#
# Run:  Rscript nara/R/03_walk.R        (single process; never run two)

ROOT <- "/Users/zaynesember/GitRepos/pressR"
suppressMessages(devtools::load_all(ROOT, quiet = TRUE))
source(file.path(ROOT, "nara", "R", "lib_nara.R"))
source(file.path(ROOT, "nara", "R", "02_feed_configs.R"))

WALK_DIR <- file.path(NARA_OUT, "walk")
dir.create(WALK_DIR, recursive = TRUE, showWarnings = FALSE)
t0 <- Sys.time()

# ---- engines -----------------------------------------------------------------
# Both return list(items = df(url, url_replay, title), status, pages).

walk_pager_feed <- function(cfg) {
  r0 <- nara_get(cfg$congress, cfg$listing)
  doc0 <- nara_read(r0$html)
  if (is.null(doc0)) return(list(items = NULL, status = paste0("listing unreachable (", r0$status, ")"), pages = 0L))
  base0 <- r0$effective %||% nara_replay_url(cfg$congress, cfg$listing)

  pager <- nara_detect_pager(cfg$congress, cfg$listing, doc0, cfg$item_re, base0)
  message(sprintf("    pager: %s %s", pager$mode, pager$param %||% ""))

  seen <- character(0); out <- list(); empty_run <- 0L; page <- 0L
  repeat {
    if (page > cfg$page_limit) break
    if (page == 0) { doc <- doc0; base <- base0 } else {
      orig <- nara_page_original(cfg$listing, pager, page)
      if (is.na(orig)) break
      r <- nara_get(cfg$congress, orig)
      if (r$status == -2L) return(list(items = bind_items(out), status = "budget exhausted mid-walk", pages = page))
      if (r$status == -3L) return(list(items = bind_items(out), status = "rate-limited persistently", pages = page))
      doc <- nara_read(r$html)
      if (is.null(doc)) break
      base <- r$effective %||% nara_replay_url(cfg$congress, orig)
    }
    items <- nara_listing_items(doc, base, cfg$item_re)
    fresh <- items[!(items$url %in% seen), , drop = FALSE]
    if (nrow(items) == 0 || nrow(fresh) == 0) {
      empty_run <- empty_run + 1L
      if (empty_run >= 2L || pager$mode == "none") break
    } else {
      empty_run <- 0L
      seen <- c(seen, fresh$url)
      out[[length(out) + 1]] <- fresh
    }
    if (pager$mode == "none") break
    page <- page + 1L
    if (page %% 10 == 0) message(sprintf("    page %d (%d items)", page, length(seen)))
  }
  list(items = bind_items(out),
       status = if (length(seen)) "ok" else "no items matched",
       pages = page)
}

# CFM archives (aging) tease only recent releases on the landing page and
# filter by &Month=&Year= -- enumerate the configured years explicitly instead
# of trusting a pager probe. Months with zero items are normal (recesses);
# the per-year tally printed at the end is the health signal.
walk_cfm_monthyear <- function(cfg) {
  yrs <- nara_config_years(cfg)
  seen <- character(0); out <- list(); by_year <- integer(0); pages <- 0L
  for (y in yrs) {
    n_y <- 0L
    for (m in 1:12) {
      orig <- add_query(add_query(cfg$listing, "Month", m), "Year", y)
      r <- nara_get(cfg$congress, orig)
      if (r$status == -2L) return(list(items = bind_items(out), status = "budget exhausted mid-walk", pages = pages))
      if (r$status == -3L) return(list(items = bind_items(out), status = "rate-limited persistently", pages = pages))
      pages <- pages + 1L
      doc <- nara_read(r$html)
      if (is.null(doc)) next
      items <- nara_listing_items(doc, r$effective %||% nara_replay_url(cfg$congress, orig), cfg$item_re)
      fresh <- items[!(items$url %in% seen), , drop = FALSE]
      if (nrow(fresh)) { seen <- c(seen, fresh$url); out[[length(out) + 1]] <- fresh; n_y <- n_y + nrow(fresh) }
    }
    by_year[as.character(y)] <- n_y
    message(sprintf("    %d: %d items", y, n_y))
  }
  list(items = bind_items(out),
       status = if (length(seen)) "ok" else "no items matched",
       pages = pages)
}

bind_items <- function(out) {
  if (!length(out)) return(data.frame(url = character(0), url_replay = character(0),
                                      title = character(0)))
  d <- do.call(rbind, out)
  d[!duplicated(d$url), , drop = FALSE]
}

# ---- pass 1: listings ----------------------------------------------------------
cfgs <- nara_feed_configs()
message(sprintf("== tier-A walk over %d feeds ==", nrow(cfgs)))
for (i in seq_len(nrow(cfgs))) {
  cfg <- cfgs[i, ]
  f <- file.path(WALK_DIR, paste0(gsub("[^A-Za-z0-9#._-]+", "_", cfg$feed_id), ".rds"))
  if (file.exists(f)) {
    prev <- readRDS(f)
    if (nrow(prev$items) > 0 || identical(prev$status, "ok")) {
      message(sprintf("  [%s] cached: %d items (%s)", cfg$feed_id, nrow(prev$items), prev$status))
      next
    }
    message(sprintf("  [%s] previous run was '%s' -- re-walking", cfg$feed_id, prev$status))
  }
  message(sprintf("  [%s] %s engine=%s", cfg$feed_id, cfg$listing, cfg$engine))
  res <- switch(cfg$engine,
    walk          = walk_pager_feed(cfg),
    cfm_monthyear = walk_cfm_monthyear(cfg),
    stop("unknown engine: ", cfg$engine))
  res$feed_id <- cfg$feed_id; res$congress <- cfg$congress; res$walked <- Sys.time()
  saveRDS(res, f)
  message(sprintf("  [%s] -> %d items, %d listing pages, status=%s (%d requests so far)",
                  cfg$feed_id, nrow(res$items), res$pages, res$status, nara_requests_made()))
  if (grepl("rate-limited persistently|unreachable [(]-3", res$status)) {
    message("HARD STOP: the limiter never released -- do not grind. Investigate before rerunning.")
    quit(save = "no", status = 3)
  }
  if (nara_budget_left() <= 0) { message("daily budget exhausted -- stopping listings pass"); break }
}

# ---- pass 2: item pages ---------------------------------------------------------
# Union across feeds, scheme-insensitive dedup, newest congress first (its
# capture is most complete). Every fetch is cache-checked, so reruns only pay
# for what is still missing.
walks <- lapply(list.files(WALK_DIR, pattern = "[.]rds$", full.names = TRUE), readRDS)
allit <- do.call(rbind, lapply(walks, function(w)
  if (nrow(w$items)) cbind(w$items, congress = w$congress, feed_id = w$feed_id) else NULL))
if (is.null(allit) || !nrow(allit)) { message("no items collected; nothing to fetch"); quit(save = "no") }

allit <- allit[order(-allit$congress), ]
allit <- allit[!duplicated(nara_url_key(allit$url)), , drop = FALSE]
message(sprintf("\n== fetching %d unique item pages (raw id_ mode) ==", nrow(allit)))

fetched <- 0L; failed <- 0L; hit <- 0L
for (i in seq_len(nrow(allit))) {
  r <- nara_get(allit$congress[i], allit$url[i], raw = TRUE)
  if (r$status == -2L) { message(sprintf("daily budget exhausted at item %d/%d -- rerun to resume", i, nrow(allit))); break }
  if (r$status == -3L) { message(sprintf("HARD STOP at item %d/%d: limiter never released -- rerun resumes from cache", i, nrow(allit))); quit(save = "no", status = 3) }
  if (r$from_cache) hit <- hit + 1L
  else if (r$status == 200L && !is.na(r$html)) fetched <- fetched + 1L
  else failed <- failed + 1L
  if (i %% 50 == 0) message(sprintf("    %d/%d (fetched %d, cache %d, failed %d, requests %d)",
                                    i, nrow(allit), fetched, hit, failed, nara_requests_made()))
}
message(sprintf("\nitem pages: %d fetched, %d already cached, %d failed of %d",
                fetched, hit, failed, nrow(allit)))
message(sprintf("total requests this run: %d | %.1f min",
                nara_requests_made(), as.numeric(difftime(Sys.time(), t0, units = "mins"))))
message("next: Rscript nara/R/04_extract.R   (offline)")
