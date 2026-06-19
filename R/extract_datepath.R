# Shared parsing for the House "press-releases" vendor's date-path item links:
# /YYYY/M/slug URLs (e.g. /2026/5/bost-bill-...). Unlike the GUID variant, the
# publish date is printed in full ("M/D/YY") next to each title, so no year
# inference is needed; the URL's year/month is kept as a fallback.
#
# This layout is shared by two detection outcomes -- sites that also carry a
# ?ID=<GUID> widget on the homepage (routed to the guid extractor) and sites
# that do not (routed to the generic extractor) -- so both extractors call into
# this helper rather than duplicating the logic.

# A /YYYY/M/slug item path (month is 1-2 digits; slug starts alphanumeric).
DATEPATH_RE <- "/([0-9]{4})/([0-9]{1,2})/[a-z0-9][a-z0-9-]*"

datepath_list_items <- function(doc, base) {
  a <- rvest::html_elements(doc, "a[href]")
  href <- rvest::html_attr(a, "href")
  keep <- !is.na(href) & grepl(DATEPATH_RE, href, ignore.case = TRUE)
  a <- a[keep]
  href <- href[keep]
  if (length(a) == 0) return(empty_items())

  recs <- purrr::map(seq_along(a), function(i) {
    title <- trimws(rvest::html_text(a[[i]]))
    if (nchar(title) < 10) return(NULL)  # skip nav/category stubs
    url <- abs_urls(href[i], base)
    date <- datepath_item_date(a[[i]], url)
    if (is.na(date)) return(NULL)
    tibble::tibble(date = date, title = title, url = url)
  })
  recs <- purrr::compact(recs)
  if (length(recs) == 0) return(empty_items())

  out <- dplyr::bind_rows(recs)
  out[!duplicated(out$url), , drop = FALSE]
}

# Date for a date-path item: prefer a full date in the surrounding text (the
# vendor prints "M/D/YY" beside the title); otherwise fall back to the URL's
# year/month with day = 1.
datepath_item_date <- function(link, url) {
  for (lvl in 1:4) {
    anc <- rvest::html_element(link, xpath = sprintf("./ancestor::*[%d]", lvl))
    if (is.na(anc)) break
    d <- first_date_in_text(rvest::html_text2(anc))
    if (!is.na(d)) return(d)
  }
  m <- regmatches(url, regexec(DATEPATH_RE, url, ignore.case = TRUE))[[1]]
  if (length(m) == 3) {
    yr <- suppressWarnings(as.integer(m[2]))
    mo <- suppressWarnings(as.integer(m[3]))
    if (!is.na(yr) && !is.na(mo) && mo >= 1 && mo <= 12) {
      return(as.Date(sprintf("%04d-%02d-01", yr, mo)))
    }
  }
  as.Date(NA)
}
