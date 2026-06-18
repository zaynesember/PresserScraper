# Extractor for WordPress House sites (~12%). Uses the wp-json REST API rather
# than scraping HTML: press releases live under the "congress_press_release"
# category (a House-wide slug), and each post already carries its title, body,
# date, and link -- so no per-item fetch is needed.

WP_PRESS_SLUG <- "congress_press_release"

wordpress_extractor <- function() {
  list(
    list_url   = wp_list_url,
    fetch_page = wp_fetch_page,
    list_items = wp_list_items,
    item_body  = function(doc, url) list(body = NA_character_, tags = NA_character_)
  )
}

# Returns a posts-endpoint base URL (with the press-release category applied
# when resolvable), or NULL if the site has no usable REST API.
wp_list_url <- function(home, home_doc) {
  cats <- fetch_json(paste0(home, "/wp-json/wp/v2/categories?slug=", WP_PRESS_SLUG))
  catid <- if (!is.null(cats) && length(cats) > 0 && !is.null(cats$id)) cats$id[1] else NA

  base <- paste0(home, "/wp-json/wp/v2/posts?orderby=date&order=desc&per_page=100")
  if (!is.na(catid)) base <- paste0(base, "&categories=", catid)

  probe <- fetch_json(paste0(base, "&page=1"))
  if (is.null(probe) || length(probe) == 0) return(NULL)
  base
}

# WordPress paginates 1-based; a request past the last page returns HTTP 400,
# which fetch_json() turns into NULL -> walk_listing stops.
wp_fetch_page <- function(list_url, page) {
  fetch_json(paste0(list_url, "&page=", page + 1))
}

wp_list_items <- function(page, list_url) {
  if (is.null(page) || length(page) == 0) return(empty_items())
  if (is.null(page$date) || is.null(page$link)) return(empty_items())

  dates <- as.Date(substr(page$date, 1, 10))
  titles <- html_to_text(page$title$rendered)
  bodies <- html_to_text(page$content$rendered)

  tibble::tibble(
    date = dates,
    title = titles,
    url = page$link,
    body = bodies,
    tags = NA_character_
  )
}
