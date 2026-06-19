# Extractor for the "GUID-id" vendor template (e.g. norcross.house.gov).
# Press releases are listed at /press-releases as plain <a> links pointing at
# /press-releases?ID=<GUID> item pages, paginated with ?Page=N (1-based). The
# listing has no <meta generator>; it is fingerprinted by those GUID item links.
#
# The quirk this extractor exists to handle: the listing labels each release
# with a *year-less* date ("June 9"), so the year has to be inferred. We assume
# a release is not in the future, then -- because the listing is newest-first --
# enforce a non-increasing date sequence so a year boundary within a page (e.g.
# "... January 5 ... December 20 ...") rolls the older entries back a year.
# Across many pages spanning multiple years this inference can still drift, so
# deep historical scrapes of this vendor are best-effort; recent windows (the
# common case) are accurate.

# A GUID as it appears in the item URLs (8-4-4-4-12 hex).
GUID_RE <- "[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}"

guid_extractor <- function() {
  list(
    list_url   = guid_list_url,
    page_url   = guid_page_url,
    fetch_page = function(list_url, page) get_html(guid_page_url(list_url, page)),
    list_items = guid_list_items,
    item_body  = guid_item_body
  )
}

guid_list_url <- function(home, home_doc) {
  # The path is uniform for this vendor; try it first.
  canonical <- paste0(home, "/press-releases")
  doc <- get_html(canonical)
  if (!is.null(doc) && nrow(guid_list_items(doc, canonical)) > 0) return(canonical)

  # Fall back to a press-releases link from the homepage, with any ?ID=... item
  # query stripped back to the listing base.
  href <- rvest::html_attr(rvest::html_elements(home_doc, "a[href]"), "href")
  href <- href[!is.na(href) & grepl("press-releases", href, ignore.case = TRUE)]
  href <- unique(sub("\\?.*$", "", abs_urls(href, home)))
  for (u in utils::head(href, 4)) {
    doc <- get_html(u)
    if (!is.null(doc) && nrow(guid_list_items(doc, u)) > 0) return(u)
  }
  NULL
}

# Pagination is 1-based via ?Page=N; page 0 (our first page) carries no param.
guid_page_url <- function(list_url, page) {
  if (page == 0) list_url else add_query(list_url, "Page", page + 1)
}

guid_list_items <- function(doc, page_url) {
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
                   url = abs_urls(href[i], page_url), inferred = dt$inferred)
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

# Find a release's date from the markup around its title link. Prefers a full
# date (with year) if the template ever carries one; otherwise infers the year
# for a "Month Day" label. Returns list(date, inferred).
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
