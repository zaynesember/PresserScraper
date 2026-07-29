#!/usr/bin/env Rscript
# Backfill former-member press releases from the Internet Archive (Wayback).
# Reads a verified target list, enumerates archived press-article URLs (paginated
# CDX, year-chunked to dodge timeouts), throttled-fetches the raw archived HTML,
# generic-extracts title/date/body (works across Drupal/aspx/cfm/generic), gates
# on a real date + body, dedups by article URL, maps to the archive schema with
# source="wayback", and writes external/wayback/ year files. Throttled + resumable
# (per-member cache). HTML CMSes only; WordPress/headless are skipped upstream.
suppressMessages(devtools::load_all("/Users/zaynesember/GitRepos/pressR"))
source("/Users/zaynesember/GitRepos/pressR/nlp/R/00_foundation.R")
suppressMessages({ library(httr2); library(xml2); library(data.table) })
t0 <- Sys.time()
TARGETS <- read.csv(Sys.getenv("WAYBACK_TARGETS",   # roster override for expansion runs;
                    "/Users/zaynesember/GitRepos/pressR/nlp/crosswalks/wayback_targets.csv"),
                    stringsAsFactors = FALSE)   # default: verified pre-2015 House retirees
# NOTE a full (non-VALID) run rewrites external/wayback/ from THIS roster's caches
# only — an expansion roster must therefore include the original 16 members.
ONLY <- Sys.getenv("WAYBACK_ONLY", ""); VALID <- nzchar(ONLY)   # subset run = validation (no write)
if (VALID) TARGETS <- TARGETS[TARGETS$host %in% strsplit(ONLY, ",")[[1]], , drop = FALSE]
CACHE   <- file.path(nlp_out_dir(), if (VALID) "wayback_cache_val" else "wayback_cache")
# Raw-CDX cache is shared by VALID and full runs: the archived URL universe does
# not depend on which mode asked for it, and CDX is the scarce resource.
CDXCACHE <- file.path(nlp_out_dir(), "wayback_cdx_cache")
dir.create(CACHE, showWarnings = FALSE)
MAXART  <- as.integer(Sys.getenv("WAYBACK_MAXART", "220"))
THROTTLE <- as.numeric(Sys.getenv("WAYBACK_THROTTLE", "0.7"))  # raise to be politer under IA rate-limits
UA <- "pressR-research (congressional press-release archive)"
GET <- function(url, to = 60) request(url) |> req_timeout(to) |> req_user_agent(UA) |>
  req_retry(max_tries = 4, backoff = ~ min(30, 3 * 2^.x)) |> req_perform()
LONG_DATE <- "(January|February|March|April|May|June|July|August|September|October|November|December)\\s+[0-9]{1,2},?\\s+[0-9]{4}"

MON_RX <- paste0("(January|February|March|April|May|June|July|August|September|",
                 "October|November|December|Jan|Feb|Mar|Apr|Jun|Jul|Aug|Sept|Sep|Oct|Nov|Dec)")
mdy_try <- function(s) {
  s <- gsub("Sept", "Sep", gsub("\\.", "", s))
  for (f in c("%B %d, %Y", "%B %d %Y", "%b %d, %Y", "%b %d %Y", "%m/%d/%Y", "%m/%d/%y")) {
    d <- suppressWarnings(as.Date(s, format = f)); if (!is.na(d)) return(d)
  }
  as.Date(NA)
}
# Resolve a release date. Old archived templates carry inconsistent datelines, so
# try, in order: an explicit "Month DD, YYYY" (full or abbreviated) near the top
# (the dateline), a numeric m/d/Y, a date-coded URL (/YYYY/MM/<prefix><YYMMDD>),
# a no-year dateline ("Washington, Aug 15 -") paired with the capture year, and
# finally the Wayback capture date itself. A page is always archived on/after
# publication, so any candidate later than the capture timestamp `ts` is rejected
# (it is a future event date in the body, not the dateline); a no-year dateline
# that overshoots the capture rolls back one year.
parse_date2 <- function(txt, url, ts) {
  tsd <- if (nzchar(ts)) suppressWarnings(as.Date(substr(ts, 1, 8), "%Y%m%d")) else as.Date(NA)
  top <- substr(txt, 1, 4000)
  ok   <- function(d) !is.na(d) && (is.na(tsd) || d <= tsd + 2)
  # body prose can cite historical dates ("...dated back to January 16, 1991..."),
  # so a body-extracted date must also be within ~3y before the capture to count.
  okb  <- function(d) ok(d) && (is.na(tsd) || d >= tsd - 1100)
  # A long-form date in DATELINE position (in/just after the title, ahead of the
  # prose) is the publication date even when it long predates the capture:
  # archive-style sites are snapshotted years after publication (waxman's
  # oversight archive was captured in 2012 holding 2005-and-earlier documents,
  # so the tight window silently dated 82% of it to the capture day). Deeper in
  # the body keep the ~3y window, so cited history ("...back to January 16,
  # 1991...") is still not mistaken for a dateline.
  mm <- regexpr(paste0(MON_RX, "\\.?\\s+[0-9]{1,2},?\\s+[0-9]{4}"), top, ignore.case = TRUE)
  if (mm > 0) {
    d <- mdy_try(regmatches(top, mm))
    lim <- if (mm <= 300) 7300 else 1100          # 20y in a dateline, ~3y in prose
    if (ok(d) && (is.na(tsd) || d >= tsd - lim)) return(d)
  }
  m <- regmatches(top, regexpr("[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}", top))
  if (length(m)) { d <- mdy_try(m[1]); if (okb(d)) return(d) }
  um <- regmatches(url, regexpr("/[0-9]{4}/[0-9]{2}/[a-z]+([0-9]{6})", url, ignore.case = TRUE))
  if (length(um)) { dd <- regmatches(um, regexpr("[0-9]{6}", um))
    d <- suppressWarnings(as.Date(dd, "%y%m%d")); if (ok(d)) return(d) }
  # root date-coded filename /MMDDYY[a].htm (early-2000s templates, e.g. cantor)
  um <- regmatches(url, regexpr("/([0-9]{6})[a-z]?[.]s?html?$", url, ignore.case = TRUE))
  if (length(um)) { dd <- regmatches(um, regexpr("[0-9]{6}", um))
    d <- suppressWarnings(as.Date(dd, "%m%d%y")); if (ok(d)) return(d) }
  if (!is.na(tsd)) {
    # no-year dateline ("Washington, Aug 15 -"); skip month-days already trailed by a
    # year (those were an explicit date, tried + rejected above as out-of-window prose).
    m <- regmatches(top, regexpr(paste0("\\b", MON_RX, "\\.?\\s+[0-9]{1,2}\\b(?![,]?\\s*[0-9]{4})"),
                                 top, ignore.case = TRUE, perl = TRUE))
    if (length(m)) { yr <- as.integer(format(tsd, "%Y"))
      d <- mdy_try(paste(m[1], yr)); if (!is.na(d) && d > tsd) d <- mdy_try(paste(m[1], yr - 1))
      if (!is.na(d)) return(d) }
  }
  tsd
}
# reuse the package's content selectors (aspx/drupal/generic) to isolate the
# release from archive-page nav clutter; strip_chrome (inside body_from_selectors)
# drops nav/header/footer/aside.
# known per-CMS content selectors (fast path for templates pressR already handles)
WB_SELECTORS <- c(
  ".bodycopy", "#news_text", ".news_content", "#ctl00_ContentCell",      # aspx
  ".evo-press-release__body", ".field--name-body", ".node__content",     # drupal
  "[class*='press-release']", "[class*='PressRelease']",                  # generic
  "article", "main", "#content", ".content")
ndates <- function(x) length(unique(regmatches(x, gregexpr(LONG_DATE, x))[[1]]))
# template-agnostic main-content: the block with the most text and the lowest link
# density (an article is text-heavy/link-sparse; nav/archive lists are link-heavy
# with many datelines). Generalizes across the heterogeneous old CMS templates.
main_content <- function(doc) {
  nodes <- xml_find_all(doc, "//article | //div | //section | //td")
  best <- NA_character_; bestscore <- 0
  for (nd in nodes) {
    txt <- xml2::xml_text(nd); nt <- nchar(txt); if (nt < 400) next
    linktxt <- sum(nchar(xml2::xml_text(xml_find_all(nd, ".//a"))))
    score <- nt * (1 - min(1, linktxt / nt))^2
    if (ndates(txt) > 8) score <- score * 0.15           # demote archive/list blocks
    if (score > bestscore) { bestscore <- score; best <- txt }
  }
  if (is.na(best)) NA_character_ else trimws(best)
}
# A few archived "issue index" pages survive URL filtering; their body is a digest
# of teasers, not one release. Flag them by the repeated teaser markers so the gate
# can drop them.
is_listing <- function(x) {
  if (grepl("Select Press Releases By Issue", x, ignore.case = TRUE)) return(TRUE)
  teasers <- gregexpr("\\.\\.\\.\\s*more|…\\s*more|read more|more\\s*»", x, ignore.case = TRUE)[[1]]
  sum(teasers > 0) >= 8   # a true index lists many dated teasers; a real release's
}                         # related-news sidebar has only a handful -> don't reject it
extract <- function(html, url, ts = "") {
  doc <- tryCatch(read_html(html), error = function(e) NULL); if (is.null(doc)) return(NULL)
  ttl <- xml_text(xml_find_first(doc, "//h1"))
  if (is.na(ttl) || !nzchar(trimws(ttl)) || nchar(ttl) > 300)
    ttl <- sub("\\s*[|].*$", "", xml_text(xml_find_first(doc, "//title")))
  sel <- body_from_selectors(doc, WB_SELECTORS)                          # fast path; chrome stripped
  body <- if (!is.na(sel) && nchar(sel) >= 300 && ndates(sel) <= 6) sel else main_content(doc)
  if (is.na(body) || !nzchar(body)) {                                    # last resort: paragraph concat
    paras <- xml_text(xml_find_all(doc, "//p")); body <- paste(paras[nchar(paras) > 40], collapse = "\n")
  }
  body <- trimws(body %||% "")
  tdt <- xml_attr(xml_find_first(doc, "//time[@datetime]"), "datetime")  # <time>, then dateline/URL/capture
  date <- if (!is.na(tdt) && nchar(tdt) >= 8) suppressWarnings(as.Date(substr(tdt, 1, 10))) else as.Date(NA)
  if (is.na(date)) date <- parse_date2(paste(ttl, body), url, ts)
  list(title = nlp_clean_display(trimws(ttl %||% "")), body = body, date = date,
       n_dates = ndates(body), listing = is_listing(body))
}
# Enumerate individual-release URLs from the full archived universe. The old
# server-side token filter both over-matched (issue-INDEX pages like
# /press-release/<issue>) and under-matched (date-coded .shtml files, Joomla
# index.php?id= articles), so we pull the raw 200/text-html universe and select
# CMS-agnostically: a UNION of individual-release URL shapes (ASP.NET DocumentID,
# /YYYY/MM/<file>.shtml date-path, Joomla view=article&id=, drupal /news/<slug>,
# /node/<n>) minus assets, print duplicates, pagination, directory/issue indexes,
# and Joomla year-index/non-release articles. CMS column is unreliable for the
# archived era (a member's old site often differs from its later one), so we don't
# key on it. Dedup collapses print/Itemid/encoding variants of the same release.
# Raw archived URL universe for a host, CACHED to disk. CDX is the scarce
# resource here (the Internet Archive rate-limits it hard, while the content
# endpoint stays fast), and the raw universe is stable -- it's the *pattern*
# filtering below that we iterate on. Caching the universe means every future
# discovery-pattern change is FREE to re-evaluate instead of re-paying CDX.
# Delete a host's file in wayback_cdx_cache/ to force a refetch.
cdx_raw <- function(host) {
  dir.create(CDXCACHE, showWarnings = FALSE, recursive = TRUE)
  cf <- file.path(CDXCACHE, paste0(gsub("[^a-z0-9]+", "_", tolower(host)), ".rds"))
  if (file.exists(cf)) return(readRDS(cf))
  d <- cdx_fetch(host)
  # only cache a non-empty result: an empty one usually means we were throttled,
  # and caching that would silently poison every later run for this host.
  if (!is.null(d) && nrow(d)) saveRDS(d, cf)
  d
}
cdx_fetch <- function(host) {
  # CDX returns rows in alphabetical urlkey order and caps each response at
  # `limit`. A site with a big block of early-sorting junk (waxman's 7,784
  # /htbin CGI urls) therefore consumes the whole budget and the real releases
  # are NEVER RETURNED -- discovery silently sees nothing. So paginate with
  # showResumeKey until the year-chunk is exhausted. Text output (not JSON):
  # the resume key arrives as a trailing blank line + key, which simplifyVector
  # cannot represent as a matrix.
  LIMIT <- 8000L; MAXPAGE <- 12L
  out <- list()
  for (yr in seq(2005, 2015, by = 2)) {
    rk <- NULL
    for (pg in seq_len(MAXPAGE)) {
      u <- sprintf(paste0("http://web.archive.org/cdx/search/cdx?url=%s/*&collapse=urlkey",
                          "&filter=statuscode:200&filter=mimetype:text/html&fl=timestamp,original",
                          "&from=%d0101&to=%d1231&limit=%d&showResumeKey=true%s"),
                   host, yr, yr + 1, LIMIT,
                   if (is.null(rk)) "" else paste0("&resumeKey=", utils::URLencode(rk, reserved = TRUE)))
      txt <- tryCatch(resp_body_string(GET(u, 120)), error = function(e) "")
      Sys.sleep(max(THROTTLE, 5))   # CDX chokes on sub-second bursts; article fetches don't
      if (!nzchar(txt) || grepl("^\\s*<", txt)) break          # html error page = throttled
      ln <- strsplit(txt, "\n", fixed = TRUE)[[1]]
      ln <- ln[nzchar(trimws(ln))]
      dat <- ln[grepl("^[0-9]{14}\\s", ln)]
      # a trailing non-timestamp line is the resume key for the next page
      tail_ln <- if (length(ln)) ln[length(ln)] else ""
      rk <- if (nzchar(tail_ln) && !grepl("^[0-9]{14}\\s", tail_ln)) trimws(tail_ln) else NULL
      if (length(dat)) {
        sp <- regmatches(dat, regexpr("\\s+", dat), invert = TRUE)
        out[[length(out) + 1]] <- data.frame(
          ts  = vapply(sp, `[`, "", 1),
          url = vapply(sp, `[`, "", 2), stringsAsFactors = FALSE)
      }
      if (is.null(rk)) break
    }
  }
  unique(do.call(rbind, out))
}
# Select individual-release URLs out of the cached raw universe (pattern union
# minus negatives, then dedup). Cheap + offline -> safe to iterate on.
cdx_articles <- function(host) {
  d <- cdx_raw(host); if (is.null(d) || !nrow(d)) return(d)
  p <- sub("^https?://[^/]+", "", d$url)
  asset  <- "[.](pdf|jpe?g|png|gif|css|js|xml|rss|zip|mp[34]|wmv|mov|ico|svg|woff2?)($|[?])"
  # index2.php is Joomla 1.0's template-less popup/print rendering of the SAME
  # article as index.php (?pop=1) -> a duplicate, not a distinct release.
  printv <- "documentprint|[?&]print=|tmpl=component|/print/|format=print|/index2[.]php|[?&]pop=1|do_pdf="
  pagin  <- "[?&]page=|/page/[0-9]|related-news|[?&]start=[0-9]|/feed|/rss"
  diridx <- paste0("/(issues?|press-releases?|news|newsroom|media-center|blog|category|categories|",
                   "topics?|tags?|gallery|photos?|videos?)/?$|/[0-9]{4}/[0-9]{2}/?$|/[0-9]{4}/?$")
  jmidx  <- paste0("[?&]id=[0-9]+(%3a|:)([0-9]{4}-|[a-z0-9-]*-press-releases|[a-z0-9-]*texas-straight-talk|",
                   "press-releases|floor-statements|speeches-and-statements|who-is-|constituent-services)")
  # Joomla admin/constituent-service articles (keyword anywhere in the id slug, e.g.
  # washington-dc-tourism-information, the-congressional-page-program) are not releases.
  jmadm  <- paste0("[?&]id=[0-9]+(%3a|:)[a-z0-9-]*(scheduling|tourism|intern|page-program|art-competition|",
                   "funding-request|academy-nomination|flag-request|casework|request-form|grant-|how-to)")
  # query-string CFM articles (?sectionid=N[.N]&...&itemid=N, bare or via index.cfm;
  # wolf/hall/matheson — matheson uses decimal sectionids like 49.2). option=com_
  # excluded so old-Joomla lookalikes can't slip in through this branch.
  is_cfm <- grepl("^/(index[.]cfm)?[?]", p, ignore.case = TRUE) &
            grepl("[?&]sectionid=[0-9.]+", p, ignore.case = TRUE) &
            grepl("[?&]itemid=[0-9]+", p, ignore.case = TRUE) &
            !grepl("option=com_", p, ignore.case = TRUE)
  # Joomla 1.0 content articles (option=com_content&task=view&id=N) — the older
  # sibling of the view=article form already handled below (murtha-era sites).
  is_joomla1 <- grepl("option=com_content", p, ignore.case = TRUE) &
                grepl("task=view", p, ignore.case = TRUE) &
                grepl("[?&]id=[0-9]+", p, ignore.case = TRUE)
  # Root-level Drupal slugs (/administration-limits-release-presidential-records):
  # release titles slugify long, so require >=5 hyphen-separated words AND >=30
  # chars. That keeps real releases while dropping nav/policy pages (/about-me,
  # /accessibility, /acid-rain-solution-crisis). The date+body gate is the backstop.
  is_rootslug <- grepl("^/[a-z0-9]+(-[a-z0-9]+){4,}$", p, ignore.case = TRUE) & nchar(p) >= 30
  # Legacy House "apps/list" template: /apps/list/press/<district_code>/<file>.shtml
  # (also /speech/, /release/). Widely used across House sites c. 2005-2011.
  is_appslist <- grepl("^/apps/list/(press|speech|release)[a-z0-9_-]*/[^/]+/[^/]+[.](s?html?|asp)$",
                       p, ignore.case = TRUE)
  pos <- grepl("documentid=[0-9]+", p, ignore.case = TRUE) |
         grepl("^/[0-9]{4}/[0-9]{2}/[a-z][^/]*[.](shtml|html?|cfm|aspx?)$", p, ignore.case = TRUE) |
         (grepl("view=article", p, ignore.case = TRUE) & grepl("[?&]id=[0-9]+", p, ignore.case = TRUE)) |
         grepl("/news/[a-z0-9][a-z0-9._%-]*-[a-z0-9._%-]{4,}$", p, ignore.case = TRUE) |
         grepl("/node/[0-9]+$", p, ignore.case = TRUE) |
         grepl("^/[0-9]{6}[a-z]?[.]s?html?$", p, ignore.case = TRUE) |            # root /MMDDYY[a].htm (cantor)
         is_cfm | is_joomla1 | is_rootslug | is_appslist |
         grepl("/pressreleases?/archive/[0-9]{4}/[a-z0-9][a-z0-9._-]*[.]s?html?$", p, ignore.case = TRUE)  # static yearly archive (matheson)
  neg <- grepl(asset, p, ignore.case = TRUE) | grepl(printv, p, ignore.case = TRUE) |
         grepl(pagin, p, ignore.case = TRUE) | grepl(diridx, p, ignore.case = TRUE) |
         grepl(jmidx, p, ignore.case = TRUE) | grepl(jmadm, p, ignore.case = TRUE) |
         grepl("/index[.](s?html?|cfm|php|aspx?)$", p, ignore.case = TRUE)        # dir index files are listings
  d <- d[pos & !neg, , drop = FALSE]; if (!nrow(d)) return(d)
  pf <- sub("^https?://[^/]+", "", d$url)
  # cfm articles are identified by section+item ids, not path (the path is just "/"
  # or /index.cfm, so the query-stripping fallback would collapse them all).
  cfm2 <- grepl("[?&]sectionid=[0-9.]+", pf, ignore.case = TRUE) &
          grepl("[?&]itemid=[0-9]+", pf, ignore.case = TRUE)
  cfmkey <- paste0("cfm", sub(".*[?&]sectionid=([0-9.]+).*", "\\1", tolower(pf)),
                   "_",   sub(".*[?&]itemid=([0-9]+).*",   "\\1", tolower(pf)))
  d$key <- ifelse(grepl("documentid=", pf, ignore.case = TRUE),
                  sub(".*documentid=([0-9]+).*", "doc\\1", tolower(pf)),
           ifelse(cfm2, cfmkey,
           ifelse(grepl("[?&]id=[0-9]+", pf, ignore.case = TRUE),
                  sub(".*[?&]id=([0-9]+).*", "jm\\1", tolower(pf)),
                  sub("[?].*$", "", tolower(pf)))))
  d <- d[!duplicated(d$key), , drop = FALSE]
  # Spread the capped fetch across the member's tenure: CDX returns URLs in
  # alphabetical urlkey order, so head(MAXART) would otherwise skew to a member's
  # earliest paths (e.g. /2002/.. sorts before /2007/..). Infer each release's year
  # (URL date-code if present, else the capture year) and round-robin across years
  # so the first MAXART candidates span all years instead of clustering in one.
  dpath <- sub("^https?://[^/]+", "", d$url)
  uyr <- suppressWarnings(as.integer(sub(".*/([12][0-9]{3})/[0-9]{2}/.*", "\\1", dpath)))
  d$yr <- ifelse(grepl("/[12][0-9]{3}/[0-9]{2}/", dpath), uyr, as.integer(substr(d$ts, 1, 4)))
  d <- d[order(d$yr), , drop = FALSE]
  d$rk <- stats::ave(seq_len(nrow(d)), d$yr, FUN = seq_along)
  d <- d[order(d$rk, d$yr), , drop = FALSE]
  d[, c("ts", "url"), drop = FALSE]
}
backfill_member <- function(M) {
  cf <- file.path(CACHE, paste0(gsub("[^a-z0-9]+", "_", tolower(M$name)), ".rds"))
  if (file.exists(cf)) return(readRDS(cf))
  arts <- cdx_articles(M$host)
  if (is.null(arts) || !nrow(arts)) { saveRDS(data.table(), cf); return(data.table()) }
  arts <- head(arts, MAXART); rows <- vector("list", nrow(arts))
  for (i in seq_len(nrow(arts))) {
    h <- tryCatch(resp_body_string(GET(sprintf("http://web.archive.org/web/%sid_/%s", arts$ts[i], arts$url[i]), 60)),
                  error = function(e) NA_character_)
    Sys.sleep(THROTTLE)
    if (is.na(h) || nchar(h) < 800) next
    ex <- extract(h, arts$url[i], arts$ts[i]); if (is.null(ex)) next
    if (is.na(ex$date) || nchar(ex$body) < 300 || ex$n_dates > 6 || nchar(ex$title) < 1 || isTRUE(ex$listing)) next
    # soft 404s: removed pages archived as HTTP-200 "Page Not Found" templates
    # (word-boundary-safe: a bare "error"/"not found" substring hits "tERRORist" etc.)
    if (grepl("^page not found$|^(404|file) not found|^error( [0-9]{3})?$", trimws(ex$title), ignore.case = TRUE) ||
        grepl("page (you requested )?(was |could )?not (be )?found|file you requested (was|could) not|sorry, the page",
              substr(ex$body, 1, 300), ignore.case = TRUE)) next
    rows[[i]] <- data.table(date = ex$date, title = ex$title, body = ex$body, url = arts$url[i])
  }
  d <- rbindlist(rows)
  # Service-window guard. Host inference is by SURNAME, so a seat inherited by a
  # relative silently serves the successor's releases under the same host
  # (bilirakis.house.gov -> Michael retired Jan 2007, son Gus 2007-; payne.house.gov
  # -> Donald Sr. d.2012, Donald Jr. after). Without this, those get attributed to
  # the departed member. Drop anything published past their exit (+90d for
  # trailing captures). Rosters lacking house_end (the original 16) are unaffected.
  if (nrow(d) && !is.null(M$house_end) && !is.na(M$house_end) && nzchar(as.character(M$house_end))) {
    cutoff <- as.Date(M$house_end) + 90
    n0 <- nrow(d); d <- d[date <= cutoff]
    if (nrow(d) < n0) cat(sprintf("      (service-window: dropped %d of %d past %s)\n",
                                  n0 - nrow(d), n0, format(cutoff)))
  }
  if (nrow(d)) d[, `:=`(tags = NA_character_, cms = M$cms, name = M$name,
    state = M$state, district = as.character(M$district), party = M$party,
    committee = NA_character_, chamber = "house", source = "wayback")]
  saveRDS(d, cf); cat(sprintf("  [%-22s] %-26s -> %d releases\n", M$name, M$host, nrow(d))); d
}

message(sprintf("== Wayback backfill over %d verified targets ==", nrow(TARGETS)))
all <- rbindlist(lapply(seq_len(nrow(TARGETS)), function(i) backfill_member(TARGETS[i, ])), fill = TRUE)
SCHEMA <- c("date","title","body","tags","url","cms","name","state","district","party","committee","chamber","source")
if (!nrow(all) || !"date" %in% names(all)) { cat("\nNo releases recovered.\n"); quit(save = "no") }
all <- all[!is.na(date) & nchar(body) >= 300 & nchar(title) > 0]
all <- all[!duplicated(url)]
all[, year := as.integer(format(date, "%Y"))]
all <- all[year >= 2005 & year <= 2016]
if (!VALID) {
  dir <- file.path(nlp_external_dir(create = TRUE), "wayback"); dir.create(dir, showWarnings = FALSE)
  old <- list.files(dir, pattern = "releases-[0-9]{4}\\.rds$", full.names = TRUE); if (length(old)) file.remove(old)
  for (y in sort(unique(all$year))) saveRDS(as.data.frame(all[year == y, ..SCHEMA]),
    file.path(dir, sprintf("releases-%04d.rds", y)))
}

cat(sprintf("\n================ WAYBACK BACKFILL ================\n"))
cat(sprintf("recovered releases: %s | members: %s | years: %d-%d\n",
  format(nrow(all), big.mark = ","), uniqueN(all$name), min(all$year), max(all$year)))
cat("by year:\n"); print(table(all$year))
cat("by member:\n"); print(all[, .N, by = name][order(-N)])
cat(sprintf("done in %.1f min\n", as.numeric(difftime(Sys.time(), t0, units = "mins"))))
