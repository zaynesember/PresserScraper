# lib_nara.R -- shared plumbing for the NARA webharvest.gov crawler.
#
# Design + probe evidence: SCOPING-nara-crawler.md (repo root); raw probes in
# pressR_nlp/nara_probe_cache/. Operating rules that are BINDING (user decision
# 2026-07-30, scoping doc section 2): single process against this one host,
# Crawl-delay 10s honored exactly, identifying UA with a contact address,
# HTTP 429 -> sleep >= 5 min, ~6k requests/day, stop if NARA/IA object.
#
# Replay model: https://webharvest.gov/congress{N}th/{ts}[id_]/{original_url}
# Any plausible timestamp 302s to the NEAREST real capture, so exact timestamps
# are never needed; the id_ mode serves original bytes without replay chrome.
# Identity is ALWAYS the stripped original URL -- replay URLs never leave this
# layer except as provenance.

suppressMessages({ library(httr2); library(xml2) })

NARA_HOST       <- "https://webharvest.gov"   # www. 302s here; never pay the hop
NARA_UA         <- "pressR-research-crawler (congressional press-release archive; zaynesember@gmail.com)"
NARA_THROTTLE   <- 10     # robots.txt Crawl-delay -- do not lower
NARA_429_SLEEP  <- 300    # measured 429 recovery <= 4 min; 5 min to be safe
NARA_DAY_BUDGET <- as.integer(Sys.getenv("NARA_DAY_BUDGET", "6000"))
NARA_BURST      <- as.integer(Sys.getenv("NARA_BURST", "40"))   # requests between rests
NARA_REST       <- as.numeric(Sys.getenv("NARA_REST", "240"))   # seconds of full silence

# The IA-run limiter does NOT reliably answer 429: on 2026-07-30 it served its
# "Rate limit reached" page with HTTP 200 for 196 straight requests, which a
# status-only guard cached as real content (192 poisoned listing pages, one
# garbage feed walk). Detection must sniff the BODY. Two more measured facts:
# replay paths trip it far sooner than the robots-allowed /collections/ indexes
# (the first replay request after 72 index fetches was already limited), and
# it does not clear while requests keep arriving even at 10s spacing (32 min of
# continuous limiting) -- recovery needs FULL silence, ~4 min in the scoping
# session. Hence: burst-rest pacing plus escalating full-stop on detection.
NARA_LIMIT_RX <- "Rate limit reached|Aitratelimit@archive[.]org"
nara_limited <- function(html)
  is.character(html) && length(html) == 1 && !is.na(html) &&
  grepl(NARA_LIMIT_RX, substr(html, 1, 3000), ignore.case = TRUE)

nara_data_dir   <- function() tools::R_user_dir("pressR_nlp", "data")
NARA_PAGE_CACHE <- file.path(nara_data_dir(), "nara_page_cache")
NARA_OUT        <- "/Users/zaynesember/GitRepos/pressR/nara/data"

# End-of-congress December; the server resolves it to the nearest capture.
nara_ts_guess <- function(congress) sprintf("%d1215000000", 2006 + 2 * (congress - 109L))

nara_replay_url <- function(congress, original, ts = nara_ts_guess(congress), raw = FALSE) {
  paste0(NARA_HOST, "/congress", congress, "th/", ts, if (raw) "id_" else "", "/", original)
}

# Replay URL -> original URL. Handles every prefix token seen in the wild
# (14-digit ts, bare year "2014", crawl id "3"), the two-letter mode suffixes
# (id_/im_/js_/cs_), percent-encoded schemes from abs_urls() resolution, and
# the 109th indexes' scheme-less originals. Vectorized.
nara_strip <- function(u) {
  u <- sub("^https?://(www[.])?webharvest[.]gov/congress[0-9]+th/[0-9]+([a-z]{2}_)?/", "", u)
  u <- sub("^http%3[Aa]//", "http://", u)
  u <- sub("^https%3[Aa]//", "https://", u)
  ifelse(!nzchar(u) | grepl("^https?://", u), u, paste0("http://", u))
}

# Scheme-insensitive key for dedup/anti-joins: the same page can be captured as
# http:// in one harvest and https:// in a later one. Host lowercased, path and
# query untouched (case can be significant there).
nara_url_key <- function(u) {
  u <- sub("^https?://", "", u)
  host <- sub("/.*$", "", u)
  paste0(tolower(host), substr(u, nchar(host) + 1, nchar(u)))
}

nara_capture_ts <- function(effective) {
  ok <- !is.na(effective) & grepl("/congress[0-9]+th/[0-9]{14}", effective)
  ifelse(ok, sub(".*?/congress[0-9]+th/([0-9]{14}).*", "\\1", effective), NA_character_)
}

# Cache filename: full sanitized URL when it fits, head+tail when it does not
# (ids live at the END of query strings -- a head-only truncation collides,
# which is exactly how lib_institutional's digest_key would fail here). The
# nchar suffix disambiguates the truncated case further.
nara_cache_key <- function(congress, original, raw) {
  san <- gsub("[^A-Za-z0-9._-]+", "_", original)
  if (nchar(san) > 180)
    san <- paste0(substr(san, 1, 90), "__", substr(san, nchar(san) - 80, nchar(san)))
  sprintf("c%d_%s_%s_%d.html", congress, if (raw) "raw" else "rw", san, nchar(original))
}

# ---- the one fetch path ------------------------------------------------------
# Everything network goes through nara_fetch: one global throttle with jitter,
# burst-rest pacing (NARA_BURST requests, then NARA_REST seconds of silence),
# limiter detection by body OR status, escalating full-stop recovery, a request
# counter against the daily budget, and 200-and-clean-only caching (a cached
# error silently poisons every later run -- this bit twice already).
.nara <- new.env(parent = emptyenv())
.nara$last <- 0; .nara$n <- 0; .nara$since_rest <- 0; .nara$trips <- 0

nara_requests_made <- function() .nara$n
nara_budget_left   <- function() NARA_DAY_BUDGET - .nara$n

nara_fetch <- function(url, cache_file, max_tries = 5) {
  dir.create(NARA_PAGE_CACHE, showWarnings = FALSE, recursive = TRUE)
  meta_file <- sub("[.]html$", ".meta", cache_file)
  if (file.exists(cache_file)) {
    return(list(html = readChar(cache_file, file.size(cache_file)),
                effective = if (file.exists(meta_file)) readLines(meta_file, warn = FALSE)[1]
                            else NA_character_,
                status = 200L, from_cache = TRUE))
  }
  if (nara_budget_left() <= 0) {
    return(list(html = NA_character_, effective = NA_character_,
                status = -2L, from_cache = FALSE))   # budget exhausted: resume tomorrow
  }
  for (i in seq_len(max_tries)) {
    if (.nara$since_rest >= NARA_BURST) {
      message(sprintf("    [pacing] %d requests since last rest -- resting %ds (total %d)",
                      .nara$since_rest, NARA_REST, .nara$n))
      Sys.sleep(NARA_REST); .nara$since_rest <- 0
    }
    wait <- NARA_THROTTLE + stats::runif(1, 0, 3) - (as.numeric(Sys.time()) - .nara$last)
    if (wait > 0) Sys.sleep(wait)
    .nara$last <- as.numeric(Sys.time())
    .nara$n <- .nara$n + 1; .nara$since_rest <- .nara$since_rest + 1
    resp <- tryCatch(
      request(url) |> req_user_agent(NARA_UA) |> req_timeout(90) |>
        req_error(is_error = function(r) FALSE) |> req_perform(),
      error = function(e) NULL)
    if (is.null(resp)) { Sys.sleep(30 * i); next }                      # transport error
    code <- resp_status(resp)
    html <- if (code == 200L) tryCatch(resp_body_string(resp), error = function(e) NA_character_)
            else NA_character_
    if (code == 429L || nara_limited(html)) {
      # Full silence is the only thing that clears it; requests at 10s spacing
      # kept it pinned for 32 straight minutes on 2026-07-30. Escalate, and log
      # the burst position so the trip threshold becomes measurable.
      .nara$trips <- .nara$trips + 1
      rest <- min(1800, NARA_429_SLEEP * 2^(i - 1))
      message(sprintf("    [limited] request %d (%d into burst, trip #%d, http %d) -- full stop %ds",
                      .nara$n, .nara$since_rest, .nara$trips, code, rest))
      Sys.sleep(rest); .nara$since_rest <- 0
      next
    }
    if (code >= 500L) { Sys.sleep(30 * i); next }
    if (code != 200L)
      return(list(html = NA_character_, effective = resp_url(resp),
                  status = code, from_cache = FALSE))
    if (is.na(html) || nchar(html) < 200)
      return(list(html = NA_character_, effective = resp_url(resp),
                  status = 200L, from_cache = FALSE))
    writeChar(html, cache_file, eos = NULL)
    writeLines(resp_url(resp), meta_file)
    return(list(html = html, effective = resp_url(resp), status = 200L,
                from_cache = FALSE))
  }
  # All tries burned. -3 = the limiter never released across every escalating
  # rest: callers must HARD-STOP the run (grinding on collects nothing and
  # keeps the penalty pinned); -1 = repeated transport/5xx errors.
  list(html = NA_character_, effective = NA_character_,
       status = if (.nara$trips > 0) -3L else -1L, from_cache = FALSE)
}

# Replay fetch by (congress, original URL). raw = TRUE -> id_ mode.
nara_get <- function(congress, original, raw = FALSE, ts = nara_ts_guess(congress)) {
  cf <- file.path(NARA_PAGE_CACHE, nara_cache_key(congress, original, raw))
  nara_fetch(nara_replay_url(congress, original, ts, raw), cf)
}

nara_read <- function(html) {
  if (is.na(html)) return(NULL)
  tryCatch(xml2::read_html(html), error = function(e) NULL)
}

# ---- listing-side helpers ----------------------------------------------------
# Item rows on a replayed listing page: resolve hrefs against the page's own
# replay URL (links are rewritten, so resolution stays inside the archive),
# strip to original for identity, match item_re against the ORIGINAL form.
# Titles are best-effort (longest anchor text per URL); 04 refines from pages.
nara_listing_items <- function(doc, base_replay, item_re) {
  links <- rvest::html_elements(doc, "a[href]")
  if (!length(links)) return(data.frame(url = character(0), url_replay = character(0),
                                        title = character(0)))
  href <- rvest::html_attr(links, "href")
  url  <- abs_urls(href, base_replay)
  orig <- nara_strip(url)
  ttl  <- vapply(links, function(l) trimws(gsub("\\s+", " ", rvest::html_text(l))), "")
  keep <- !is.na(orig) & nzchar(orig) & grepl(item_re, orig, ignore.case = TRUE)
  d <- data.frame(url = orig[keep], url_replay = url[keep], title = ttl[keep],
                  stringsAsFactors = FALSE)
  if (!nrow(d)) return(d)
  d <- d[order(-nchar(d$title)), , drop = FALSE]     # keep the informative anchor
  d[!duplicated(d$url), , drop = FALSE]
}

# Pager detection against the archive. Mirrors insti_detect_pager's candidate
# logic but fetches through nara_get -- insti's version calls get_html and
# would walk out of the archive onto the live web.
nara_detect_pager <- function(congress, listing, page0_doc, item_re, base_replay) {
  urls0 <- nara_listing_items(page0_doc, base_replay, item_re)$url
  probe <- function(orig_url) {
    r <- nara_get(congress, orig_url)
    doc <- nara_read(r$html)
    if (is.null(doc)) return(FALSE)
    u <- nara_listing_items(doc, r$effective %||% nara_replay_url(congress, orig_url), item_re)$url
    length(u) > 0 && length(setdiff(u, urls0)) > 0
  }
  param <- tryCatch(generic_find_pager(page0_doc), error = function(e) NA_character_)
  cands <- unique(c(param[!is.na(param)], "page", "PageNum_rs", "pagenum_rs"))
  for (p in cands) {
    if (probe(add_query(listing, p, 1))) return(list(mode = "query0", param = p))
    if (probe(add_query(listing, p, 2))) return(list(mode = "query1", param = p))
  }
  if (probe(paste0(trim_slash(listing), "/page/2/"))) return(list(mode = "wp", param = NA_character_))
  list(mode = "none", param = NA_character_)
}

nara_page_original <- function(listing, pager, page) {
  if (page == 0) return(listing)
  switch(pager$mode,
    query0 = add_query(listing, pager$param, page),
    query1 = add_query(listing, pager$param, page + 1),
    wp     = paste0(trim_slash(listing), "/page/", page + 1, "/"),
    none   = NA_character_)
}

`%||%` <- function(a, b) if (is.null(a) || (length(a) == 1 && is.na(a))) b else a

# ---- extraction cascade -------------------------------------------------------
# Requires, AT CALL TIME (not source time): pressR internals via load_all,
# run_wayback.R's functions (extract/parse_date2/ndates/is_listing --
# partial-source the file up to its "== Wayback backfill" banner), and
# institutional/R/lib_institutional.R (insti_page_date/_title/_body).
# Cascade rationale + probe evidence: SCOPING-nara-crawler.md section 3.

nara_strip_ordinals <- function(x) gsub("\\b([0-9]{1,2})(st|nd|rd|th)\\b", "\\1", x)

nara_soft404 <- function(title, body)
  grepl("^page not found$|^(404|file) not found|^error( [0-9]{3})?$", trimws(title), ignore.case = TRUE) ||
  grepl("page (you requested )?(was |could )?not (be )?found|file you requested (was|could) not|sorry, the page",
        substr(body, 1, 300), ignore.case = TRUE)

nara_extract_item <- function(congress, url) {
  cf <- file.path(NARA_PAGE_CACHE, nara_cache_key(congress, url, raw = TRUE))
  if (!file.exists(cf)) return(list(status = "no page cached"))
  html <- readChar(cf, file.size(cf))
  mf <- sub("[.]html$", ".meta", cf)
  eff <- if (file.exists(mf)) readLines(mf, warn = FALSE)[1] else NA_character_
  ts  <- nara_capture_ts(eff); if (is.na(ts)) ts <- ""

  doc <- nara_read(html)
  if (is.null(doc)) return(list(status = "unparseable"))

  ex <- extract(html, url, ts)              # wayback stack: title/body/date/flags
  if (is.null(ex)) return(list(status = "unparseable"))
  # insti_item_body is prose-gated, so when it fires it is clean (never the
  # Dynamic-Drive JS junk main_content picked up on gordon); when it returns NA
  # (2006 table layouts) the wayback body stands.
  ib <- tryCatch(insti_item_body(rvest::read_html(html), url), error = function(e) NA_character_)
  body <- if (!is.na(ib) && nchar(ib) >= 300) ib else ex$body

  ttl <- tryCatch(insti_page_title(rvest::read_html(html)), error = function(e) NA_character_)
  if (is.na(ttl) || nchar(trimws(ttl)) < 1) ttl <- ex$title
  ttl <- nlp_clean_display(trimws(ttl))

  # Dates: insti_page_date FIRST (it got the ordinal dateline and the
  # old-content-late-capture cases right where parse_date2 fell back to the
  # capture day), then parse_date2 over ordinal-stripped text, capture last
  # and always FLAGGED.
  d1 <- tryCatch(insti_page_date(doc, url), error = function(e) as.Date(NA))
  tsd <- if (nzchar(ts)) suppressWarnings(as.Date(substr(ts, 1, 8), "%Y%m%d")) else as.Date(NA)
  if (!is.na(d1)) { date <- d1; src <- "page" }
  else {
    d2 <- parse_date2(nara_strip_ordinals(paste(ttl, body)), url, ts)
    date <- d2
    src <- if (is.na(d2)) NA_character_ else if (!is.na(tsd) && d2 == tsd) "capture" else "dateline"
  }

  gate_fail <-
    if (is.na(date)) "no date" else
    if (is.na(body) || nchar(body) < 300) "body < 300" else
    if (ndates(body) > 6) "too many datelines" else
    if (isTRUE(ex$listing) || is_listing(body)) "listing page" else
    if (nara_soft404(ttl, body)) "soft 404" else NA_character_

  list(status = if (is.na(gate_fail)) "ok" else gate_fail,
       date = date, date_src = src, title = ttl, body = body, capture_ts = ts,
       url_replay = eff)
}
