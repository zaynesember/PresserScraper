# Generic heuristic extractor for the long tail (~14%) that isn't Drupal,
# ASP.NET, or WordPress. Many of these run a common vendor template with
# heading-link titles, the publish date as the leading text of each item block,
# and "?PageNum_rs=N" style pagination. The extractor discovers the pagination
# parameter from the page's own pager rather than guessing it.

# Separator used to pack the listing URL and its pager param into one handle
# string (the interface passes a single character `list_url`).
GENERIC_SEP <- "PAGER"

generic_extractor <- function() {
  list(
    list_url   = generic_list_url,
    fetch_page = generic_fetch_page,
    list_items = generic_list_items,
    item_body  = generic_item_body
  )
}

generic_list_url <- function(home, home_doc) {
  href <- home_doc |> rvest::html_elements("a[href]") |> rvest::html_attr("href")
  txt <- home_doc |> rvest::html_elements("a[href]") |> rvest::html_text() |> trimws()
  href <- abs_urls(href, home)

  # Rank candidates: explicit press-releases paths first, then press/news/media.
  score <- rep(0L, length(href))
  score[grepl("press-release", href, ignore.case = TRUE)] <- 3L
  score[grepl("press", txt, ignore.case = TRUE) & score == 0L] <- 2L
  score[grepl("/news|/media", href, ignore.case = TRUE) & score == 0L] <- 1L
  cand <- unique(href[score > 0][order(-score[score > 0])])
  cand <- cand[!is.na(cand)]
  # Drop single-item permalinks (?ID=<GUID>): they parse as a 1-item "listing"
  # and would be wrongly accepted ahead of the real listing page.
  cand <- cand[!grepl(paste0("\\?id=", GUID_RE), cand, ignore.case = TRUE)]
  if (length(cand) == 0) return(NULL)

  for (url in utils::head(cand, 6)) {
    doc <- get_html(url)
    if (is.null(doc)) next
    if (nrow(generic_list_items(doc, url)) > 0) {
      param <- generic_find_pager(doc)
      return(paste0(url, GENERIC_SEP, param %||% ""))
    }
  }
  NULL
}

# Discover the pagination query-parameter name from a listing page's pager.
generic_find_pager <- function(doc) {
  links <- rvest::html_elements(doc, ".pager a, .pagination a, nav a, a[rel='next']")
  if (length(links) == 0) links <- rvest::html_elements(doc, "a[href]")
  href <- rvest::html_attr(links, "href")
  txt <- tolower(trimws(rvest::html_text(links)))

  # Try "next"-labelled links first, then any pager link.
  ord <- order(!grepl("next", txt))
  for (h in href[ord]) {
    if (is.na(h)) next
    m <- regmatches(h, regexec("[?&]([A-Za-z_][A-Za-z0-9_]*)=[0-9]+", h))[[1]]
    if (length(m) == 2) return(m[2])
  }
  NA_character_
}

generic_fetch_page <- function(list_url, page) {
  parts <- strsplit(list_url, GENERIC_SEP, fixed = TRUE)[[1]]
  base <- parts[1]
  param <- if (length(parts) > 1) parts[2] else ""

  if (page == 0) return(get_html(base))
  if (!nzchar(param)) return(NULL)  # single-page site
  get_html(add_query(base, param, page + 1))
}

generic_list_items <- function(doc, list_url) {
  base <- strsplit(list_url, GENERIC_SEP, fixed = TRUE)[[1]][1]
  # Strip query and any trailing slash: a listing href like ".../press-releases/"
  # must still match item links ".../press-releases/<slug>" in the filter below.
  listing_path <- sub("/+$", "", sub("\\?.*$", "", sub("^https?://[^/]+", "", base)))

  # Primary: heading-link titles (clean, low false-positive).
  out <- generic_items_from_links(
    rvest::html_elements(doc, "h2 a, h3 a, h2.title a, h3.title a"),
    base, listing_path, min_title = 1
  )
  if (nrow(out) > 0) return(out)

  # Fallback: any in-listing link with substantial anchor text. Catches sites
  # whose item links aren't headings and/or use query-style item URLs.
  out <- generic_items_from_links(
    rvest::html_elements(doc, "a[href]"),
    base, listing_path, min_title = 25
  )
  if (nrow(out) > 0) return(out)

  # Last resort: date-path item links (/YYYY/M/slug). These live off the listing
  # path so the in-listing filter above misses them; the date is in the URL and
  # adjacent text. Shared with the press-releases vendor extractor.
  datepath_list_items(doc, base)
}

# Build an items tibble from candidate anchor nodes that descend from the
# listing path (by sub-path "/x" or query "?..."), excluding the "/table/" view.
generic_items_from_links <- function(links, base, listing_path, min_title) {
  if (length(links) == 0) return(empty_items())
  in_listing <- paste0(listing_path, "(/[^/]|\\?)")

  recs <- purrr::map(links, function(link) {
    href <- rvest::html_attr(link, "href")
    if (is.na(href)) return(NULL)
    url <- abs_urls(href, base)
    if (!grepl(in_listing, url) || grepl("/table/?$", url)) return(NULL)

    # Normalise whitespace and drop a leading date prefix some sites bake into
    # the title anchor (e.g. "06.18.2026  Senators Collins, Bennet ...").
    title <- strip_leading_date(trimws(gsub("\\s+", " ", rvest::html_text(link))))
    if (nchar(title) < min_title) return(NULL)

    date <- generic_item_date(link)
    if (is.na(date)) return(NULL)

    tibble::tibble(date = date, title = title, url = url)
  })
  recs <- purrr::compact(recs)
  if (length(recs) == 0) return(empty_items())
  out <- dplyr::bind_rows(recs)
  out[!duplicated(out$url), , drop = FALSE]
}

# Find a title link's publish date. Prefer the nearest date appearing *before*
# the title in document order (robust to flat markup where the date is a sibling
# rather than an ancestor); fall back to climbing ancestor blocks.
generic_item_date <- function(link) {
  preceding <- rvest::html_elements(link, xpath = "./preceding::text()")
  if (length(preceding) > 0) {
    txts <- rvest::html_text(preceding)
    for (t in rev(txts)) {
      d <- first_date_in_text(t)
      if (!is.na(d)) return(d)
    }
  }
  for (lvl in 1:6) {
    anc <- rvest::html_element(link, xpath = sprintf("./ancestor::*[%d]", lvl))
    if (is.na(anc)) break
    d <- first_date_in_text(rvest::html_text2(anc))
    if (!is.na(d)) return(d)
  }
  as.Date(NA)
}

generic_item_body <- function(doc, url) {
  body <- body_from_selectors(doc, c(
    ".evo-press-release__body",
    ".field--name-body",
    "[class*='press-release']",
    "article",
    "main",
    "#content",
    ".content"
  ))
  list(body = body, tags = NA_character_)
}
