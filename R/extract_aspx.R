# Extractor for the ASP.NET "DocumentID" House template (~20% of sites).
# Listing lives at /news/documentquery.aspx?DocumentTypeID=27. Each page lists
# 10 releases as documentsingle.aspx?DocumentID=N links paired positionally
# with <time> elements; pagination is &Page=N (1-based).

aspx_extractor <- function() {
  list(
    list_url   = aspx_list_url,
    page_url   = aspx_page_url,
    fetch_page = function(list_url, page) fetch_html(aspx_page_url(list_url, page)),
    list_items = aspx_list_items,
    item_body  = aspx_item_body
  )
}

aspx_list_url <- function(home, home_doc) {
  # DocumentTypeID=27 is this vendor's usual press-release type, but some sites
  # use a different id (e.g. 2235), so fall back to discovery.
  canonical <- paste0(home, "/news/documentquery.aspx?DocumentTypeID=27")
  if (aspx_is_listing(canonical)) return(canonical)

  # Discover documentquery links from the homepage (case-insensitive: some sites
  # write "DocumentQuery.aspx"). Prefer ones labelled "press release".
  a <- rvest::html_elements(home_doc, "a[href]")
  href <- rvest::html_attr(a, "href")
  txt <- tolower(trimws(rvest::html_text(a)))
  isq <- !is.na(href) & grepl("documentquery\\.aspx", href, ignore.case = TRUE)
  if (!any(isq)) return(NULL)

  cand <- abs_urls(href[isq], home)
  ord <- order(!grepl("press release", txt[isq]))  # press-release links first
  for (u in unique(cand[ord])) {
    if (aspx_is_listing(u)) return(u)
  }
  NULL
}

# TRUE if a URL fetches to a page containing documentsingle item links.
aspx_is_listing <- function(url) {
  doc <- fetch_html(url)
  !is.null(doc) && length(aspx_item_links(doc)) > 0
}

# Anchor nodes pointing at individual releases (documentsingle.aspx), matched
# case-insensitively since some sites capitalise the path.
aspx_item_links <- function(doc) {
  a <- rvest::html_elements(doc, "a[href]")
  href <- rvest::html_attr(a, "href")
  a[!is.na(href) & grepl("documentsingle\\.aspx", href, ignore.case = TRUE)]
}

aspx_page_url <- function(list_url, page) {
  if (page == 0) list_url else add_query(list_url, "Page", page + 1)
}

aspx_list_items <- function(doc, page_url) {
  a <- aspx_item_links(doc)
  txt <- trimws(rvest::html_text(a))
  href <- rvest::html_attr(a, "href")
  keep <- !is.na(href) & nzchar(txt) & !grepl("read more", txt, ignore.case = TRUE)
  titles <- txt[keep]
  urls <- abs_urls(href[keep], page_url)

  dates <- parse_dates(trimws(rvest::html_text(rvest::html_elements(doc, "time"))))
  dates <- dates[!is.na(dates)]

  n <- min(length(titles), length(dates))
  if (n == 0) return(empty_items())

  tibble::tibble(
    date = dates[seq_len(n)],
    title = titles[seq_len(n)],
    url = urls[seq_len(n)]
  )
}

aspx_item_body <- function(doc, url) {
  body <- body_from_selectors(doc, c(
    ".bodycopy",
    "#news_text",
    ".news_content",
    "#ctl00_ContentCell"
  ))
  tags <- tags_from_selectors(doc, c(
    ".issues a",
    ".tags a",
    "a[href*='IssueID']"
  ))
  list(body = body, tags = tags)
}
