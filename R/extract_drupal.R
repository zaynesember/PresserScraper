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
  # The official template is uniform; try the canonical path first.
  canonical <- paste0(home, "/media/press-releases")
  if (!is.null(get_html(canonical))) return(canonical)

  # Fall back to a press-releases link discovered on the homepage.
  href <- home_doc |>
    rvest::html_elements("a[href*='press-releases'], a[href*='press-release']") |>
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
    link <- rvest::html_element(row, ".h3 a, .font-weight-bold a, h3 a, h2 a")
    href <- rvest::html_attr(link, "href")
    title <- trimws(rvest::html_text(link))
    if (is.na(href) || !nzchar(title)) return(NULL)

    date_text <- row |>
      rvest::html_elements(".col-auto, time, .date, .datetime") |>
      rvest::html_text() |>
      trimws()
    date_attr <- row |> rvest::html_elements("time") |> rvest::html_attr("datetime")
    date <- first_parseable_date(c(date_attr, date_text))
    if (is.na(date)) return(NULL)

    tibble::tibble(date = date, title = title, url = abs_urls(href, page_url))
  })
  recs <- purrr::compact(recs)
  if (length(recs) == 0) return(empty_items())
  dplyr::bind_rows(recs)
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
