# Extractor for the Drupal-based House template (~54% of member sites).
# Listing lives at /media/press-releases with 10 .views-row items per page and
# standard Drupal ?page=N pagination (0-based).

drupal_extractor <- function() {
  list(
    list_url   = drupal_list_url,
    page_url   = drupal_page_url,
    fetch_page = function(list_url, page) get_html(drupal_page_url(list_url, page)),
    list_items = drupal_list_items,
    item_body  = drupal_item_body
  )
}

drupal_list_url <- function(home, home_doc) {
  # Try canonical paths, accepting one only if it actually yields parsed items
  # (a bare 200 is not enough; some sites 200 on the wrong page). Covers the
  # usual /media/press-releases plus the /news-releases variant (e.g. amodei).
  for (path in c("/media/press-releases", "/news-releases", "/press-releases")) {
    cand <- paste0(home, path)
    doc <- get_html(cand)
    if (!is.null(doc) && nrow(drupal_list_items(doc, cand)) > 0) return(cand)
  }

  # Fall back to a press/news-releases link discovered on the homepage.
  href <- home_doc |>
    rvest::html_elements(paste0(
      "a[href*='press-releases'], a[href*='press-release'], ",
      "a[href*='news-releases'], a[href*='news-release']"
    )) |>
    rvest::html_attr("href")
  href <- href[!is.na(href)]
  if (length(href) == 0) return(NULL)
  abs_urls(href[1], home)
}

drupal_page_url <- function(list_url, page) {
  if (page == 0) list_url else add_query(list_url, "page", page)
}

drupal_list_items <- function(doc, page_url) {
  rows <- rvest::html_elements(doc, ".views-row")
  if (length(rows) == 0) return(empty_items())

  recs <- purrr::map(rows, function(row) {
    # Prefer the row's real item-path link. Some templates render a styled
    # "featured" heading anchor with an EMPTY href next to the real (class-less)
    # link (e.g. lofgren), so target anchors whose href points under the listing
    # path and, among those, take the longest-text one (the title, not "Read more").
    anchors <- rvest::html_elements(row, "a[href]")
    hrefs <- rvest::html_attr(anchors, "href")
    is_item <- !is.na(hrefs) & nzchar(trimws(hrefs)) &
      grepl("/(press-releases|news-releases)/[^/?#]", hrefs)
    if (any(is_item)) {
      cand <- anchors[is_item]
      link <- cand[[which.max(nchar(trimws(rvest::html_text(cand))))]]
    } else {
      # `.evo-card-title a` covers the newer Drupal "Evo" card markup (e.g. meeks).
      link <- rvest::html_element(row, ".evo-card-title a, .h3 a, .font-weight-bold a, h3 a, h2 a")
    }
    href <- rvest::html_attr(link, "href")
    title <- trimws(rvest::html_text(link))
    if (is.na(href) || !nzchar(trimws(href)) || !nzchar(title)) return(NULL)

    date_text <- row |>
      rvest::html_elements(".evo-card-date, .col-auto, time, .date, .datetime") |>
      rvest::html_text() |>
      trimws()
    date_attr <- row |> rvest::html_elements("time") |> rvest::html_attr("datetime")
    date <- first_parseable_date(c(date_attr, date_text))
    # Keep undated rows for now; their date is back-filled from the item page below.
    tibble::tibble(date = date, title = title, url = abs_urls(href, page_url))
  })
  recs <- purrr::compact(recs)
  if (length(recs) == 0) return(empty_items())

  out <- dplyr::bind_rows(recs)
  out <- out[!duplicated(out$url), , drop = FALSE]

  # Date-less listing variant (e.g. lofgren): the row carries no date at all, so
  # back-fill each missing date from its item page (date lives in .col-auto there).
  na_date <- which(is.na(out$date))
  for (i in na_date) {
    idoc <- get_html(out$url[i])
    if (!is.null(idoc)) out$date[i] <- drupal_item_date(idoc)
  }
  out[!is.na(out$date), , drop = FALSE]
}

# Publish date from an individual release page (used to back-fill date-less
# listing rows). The date sits in a .col-auto cell alongside a "Press Release"
# label, which first_parseable_date() skips over.
drupal_item_date <- function(doc) {
  first_parseable_date(trimws(rvest::html_text(
    rvest::html_elements(doc, ".evo-card-date, .col-auto, time, .date, .datetime")
  )))
}

drupal_item_body <- function(doc, url) {
  body <- body_from_selectors(doc, c(
    ".evo-press-release__body",
    ".field--name-body",
    ".node__content",
    "article",
    "main"
  ))
  tags <- tags_from_selectors(doc, c(
    ".field--name-field-issues a",
    ".views-field-field-issues a",
    ".field--type-entity-reference a"
  ))
  list(body = body, tags = tags)
}

# Canonical empty listing tibble.
empty_items <- function() {
  tibble::tibble(
    date = as.Date(character(0)),
    title = character(0),
    url = character(0)
  )
}
