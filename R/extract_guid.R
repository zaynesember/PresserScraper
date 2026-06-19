# Extractor for the House "press-releases" vendor (e.g. norcross, bost). These
# sites share a /press-releases listing on the same platform (body text in
# .post-body, a "month/year" layout) but encode item links two ways:
#
#   * GUID:      /press-releases?ID=<GUID>, with a *year-less* date ("June 9")
#   * date-path: /YYYY/M/slug, with a full "M/D/YY" date in the listing text
#
# The homepage almost always carries a ?ID=<GUID> "latest" widget, so detect_cms
# fingerprints the family on that; the listing itself may use either encoding.
# This extractor handles both: it parses GUID items (inferring the year) and, if
# none are present, falls back to the shared date-path parser. Pagination uses a
# Page/page query param whose exact name is discovered by probing.
#
# Year inference for the GUID variant: a release is assumed not to be in the
# future, and -- because the listing is newest-first -- a monotonic pass rolls
# any entry that sits above its predecessor back a year. Deep multi-year history
# can still drift; recent windows (the common case) are accurate.

# A GUID as it appears in the item URLs (8-4-4-4-12 hex).
GUID_RE <- "[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}"

# Packs the listing URL and its discovered pager param into one handle string.
GUID_SEP <- "::PR_PAGER::"

guid_extractor <- function() {
  list(
    list_url   = guid_list_url,
    fetch_page = guid_fetch_page,
    list_items = guid_list_items,
    item_body  = guid_item_body
  )
}

guid_list_url <- function(home, home_doc) {
  cands <- paste0(home, "/press-releases")
  # Also try press-release links found on the homepage, stripped of any ?ID=.
  href <- rvest::html_attr(rvest::html_elements(home_doc, "a[href]"), "href")
  href <- href[!is.na(href) & grepl("press-release", href, ignore.case = TRUE)]
  cands <- unique(c(cands, sub("\\?.*$", "", abs_urls(href, home))))

  for (base in utils::head(cands, 4)) {
    doc <- get_html(base)
    if (is.null(doc) || nrow(guid_list_items(doc, base)) == 0) next
    param <- guid_discover_pager(base, doc)
    return(paste0(base, GUID_SEP, param %||% ""))
  }
  NULL
}

# Find the pagination query param by probing: page 2 fetched with the right
# param returns items not on page 1. NA when the listing is single-page.
guid_discover_pager <- function(base, page1_doc) {
  p1 <- guid_list_items(page1_doc, base)$url
  for (param in c("page", "Page")) {
    d2 <- get_html(add_query(base, param, 2))
    if (is.null(d2)) next
    u2 <- guid_list_items(d2, base)$url
    if (length(u2) > 0 && length(setdiff(u2, p1)) > 0) return(param)
  }
  NA_character_
}

guid_fetch_page <- function(list_url, page) {
  parts <- strsplit(list_url, GUID_SEP, fixed = TRUE)[[1]]
  base <- parts[1]
  param <- if (length(parts) > 1) parts[2] else ""
  if (page == 0) return(get_html(base))
  if (!nzchar(param)) return(NULL)            # single-page listing
  get_html(add_query(base, param, page + 1))  # 1-based pagination
}

guid_list_items <- function(doc, list_url) {
  base <- strsplit(list_url, GUID_SEP, fixed = TRUE)[[1]][1]
  out <- guid_id_items(doc, base)        # ?ID=<GUID> scheme (year inferred)
  if (nrow(out) > 0) return(out)
  datepath_list_items(doc, base)         # /YYYY/M/slug scheme (full date)
}

# Parse ?ID=<GUID> item links, inferring the year for their year-less dates.
guid_id_items <- function(doc, base) {
  a <- rvest::html_elements(doc, "a[href]")
  href <- rvest::html_attr(a, "href")
  is_item <- !is.na(href) & grepl(paste0("press-releases\\?id=", GUID_RE), href, ignore.case = TRUE)
  a <- a[is_item]
  href <- href[is_item]
  if (length(a) == 0) return(empty_items())

  recs <- purrr::map(seq_along(a), function(i) {
    title <- trimws(rvest::html_text(a[[i]]))
    if (!nzchar(title)) return(NULL)
    dt <- guid_item_date(a[[i]])
    if (is.na(dt$date)) return(NULL)
    tibble::tibble(date = dt$date, title = title,
                   url = abs_urls(href[i], base), inferred = dt$inferred)
  })
  recs <- purrr::compact(recs)
  if (length(recs) == 0) return(empty_items())

  out <- dplyr::bind_rows(recs)
  out <- out[!duplicated(out$url), , drop = FALSE]

  # Enforce newest-first ordering for the year-inferred dates: any inferred date
  # that sits above its predecessor crossed a year boundary, so roll it back.
  if (nrow(out) > 1) {
    for (i in 2:nrow(out)) {
      while (out$inferred[i] && out$date[i] > out$date[i - 1]) {
        out$date[i] <- guid_minus_year(out$date[i])
      }
    }
  }
  out$inferred <- NULL
  out
}

# Find a GUID release's date from the markup around its title link. Prefers a
# full date (with year) if present; otherwise infers the year for a "Month Day"
# label. Returns list(date, inferred).
guid_item_date <- function(link) {
  for (lvl in 1:4) {
    anc <- rvest::html_element(link, xpath = sprintf("./ancestor::*[%d]", lvl))
    if (is.na(anc)) break
    txt <- rvest::html_text2(anc)

    full <- first_date_in_text(txt)
    if (!is.na(full)) return(list(date = full, inferred = FALSE))

    inf <- guid_infer_yearless(txt)
    if (!is.na(inf)) return(list(date = inf, inferred = TRUE))
  }
  list(date = as.Date(NA), inferred = FALSE)
}

# Parse a year-less "Month Day" (e.g. "June 9") to a Date, inferring the year as
# the most recent one that does not put the date in the future. NA if no
# month/day token is present.
guid_infer_yearless <- function(text, today = guid_today()) {
  if (is.na(text) || !nzchar(text)) return(as.Date(NA))
  months <- paste0(
    "January|February|March|April|May|June|July|August|September|October|",
    "November|December|Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Sept|Oct|Nov|Dec"
  )
  pat <- paste0("(?:", months, ")\\.?\\s+\\d{1,2}(?:st|nd|rd|th)?")
  m <- regmatches(text, regexpr(pat, text, perl = TRUE, ignore.case = TRUE))
  if (length(m) == 0 || !nzchar(m)) return(as.Date(NA))

  yr <- as.integer(format(today, "%Y"))
  d <- parse_dates(paste(m, yr))
  if (is.na(d)) return(as.Date(NA))
  if (d > today) d <- parse_dates(paste(m, yr - 1L))
  d
}

# Subtract one calendar year from a Date (keeps month/day).
guid_minus_year <- function(d) {
  lt <- as.POSIXlt(d)
  lt$year <- lt$year - 1L
  as.Date(lt)
}

# Indirection over Sys.Date() so tests can pin "today" for year inference.
guid_today <- function() Sys.Date()

guid_item_body <- function(doc, url) {
  body <- body_from_selectors(doc, c(
    ".post-body",
    ".post-content",
    ".nodecontents",
    "article",
    "main"
  ))
  tags <- tags_from_selectors(doc, c(
    ".issues a",
    "a[href*='IssueID']",
    "a[href*='issues']"
  ))
  list(body = body, tags = tags)
}
