# Extractor for WordPress House sites (~12%). Uses the wp-json REST API rather
# than scraping HTML: press releases live under the "congress_press_release"
# category (a House-wide slug), and each post already carries its title, body,
# date, and link -- so no per-item fetch is needed.

WP_PRESS_SLUG <- "congress_press_release"

# Marks a listing handle as the HTML (Elementor) fallback rather than a REST URL.
WP_HTML_PREFIX <- "html::"

wordpress_extractor <- function() {
  list(
    list_url   = wp_list_url,
    fetch_page = wp_fetch_page,
    list_items = wp_list_items,
    item_body  = wp_item_body
  )
}

# Returns a posts-endpoint base URL (with the press-release category applied
# when resolvable). If the REST API is unavailable (some sites block it with a
# 401/403), falls back to an "html::" handle for the Elementor "Posts" grid.
# NULL only if neither path works.
wp_list_url <- function(home, home_doc) {
  cats <- fetch_json(paste0(home, "/wp-json/wp/v2/categories?slug=", WP_PRESS_SLUG))
  catid <- if (!is.null(cats) && length(cats) > 0 && !is.null(cats$id)) cats$id[1] else NA

  base <- paste0(home, "/wp-json/wp/v2/posts?orderby=date&order=desc&per_page=100&_embed=wp:term")
  if (!is.na(catid)) base <- paste0(base, "&categories=", catid)

  probe <- fetch_json(paste0(base, "&page=1"))
  if (!is.null(probe) && length(probe) > 0) return(base)

  # REST blocked/disabled: look for an Elementor-rendered listing page.
  cands <- paste0(home, c("/press-releases", "/news", "/category/press-releases"))
  href <- rvest::html_attr(rvest::html_elements(home_doc, "a[href]"), "href")
  href <- href[!is.na(href) & grepl("press-release", href, ignore.case = TRUE)]
  cands <- unique(c(cands, sub("\\?.*$", "", abs_urls(href, home))))
  for (u in utils::head(cands, 4)) {
    doc <- get_html(u)
    if (!is.null(doc) && nrow(wp_elementor_items(doc, u)) > 0) {
      return(paste0(WP_HTML_PREFIX, trim_slash(u)))
    }
  }
  NULL
}

# WordPress paginates 1-based; a request past the last page returns HTTP 400,
# which fetch_json() turns into NULL -> walk_listing stops. The Elementor HTML
# fallback paginates by path (/page/N/).
wp_fetch_page <- function(list_url, page) {
  if (startsWith(list_url, WP_HTML_PREFIX)) {
    base <- sub(paste0("^", WP_HTML_PREFIX), "", list_url)
    u <- if (page == 0) paste0(base, "/") else paste0(base, "/page/", page + 1, "/")
    return(get_html(u))
  }
  fetch_json(paste0(list_url, "&page=", page + 1))
}

wp_list_items <- function(page, list_url) {
  # HTML fallback: fetch_page returns a parsed document, not a JSON list.
  if (inherits(page, "xml_document")) {
    return(wp_elementor_items(page, sub(paste0("^", WP_HTML_PREFIX), "", list_url)))
  }
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
    tags = wp_rest_tags(page)
  )
}

# Per-post issue tags from the embedded category/tag terms (?_embed=wp:term).
# Returns one cleaned tag string per post (NA when only type labels remain).
wp_rest_tags <- function(page) {
  n <- length(page$date)
  wt <- page[["_embedded"]][["wp:term"]]
  if (is.null(wt)) return(rep(NA_character_, n))
  vapply(seq_len(n), function(i) {
    entry <- if (length(wt) >= i) wt[[i]] else NULL
    names <- unlist(lapply(entry, function(tf) {
      if (is.data.frame(tf) && nrow(tf) > 0 && !is.null(tf$name)) tf$name else NULL
    }))
    clean_issue_tags(names)
  }, character(1))
}

# Parse an Elementor "Posts" grid listing (article.elementor-post cards). Item
# links are root-level slugs, so the date comes from the card text rather than
# the URL.
wp_elementor_items <- function(doc, base) {
  arts <- rvest::html_elements(doc, "article.elementor-post")
  if (length(arts) == 0) return(empty_items())

  recs <- purrr::map(arts, function(a) {
    link <- rvest::html_element(a, ".elementor-post__title a, h2 a, h3 a")
    href <- rvest::html_attr(link, "href")
    title <- trimws(rvest::html_text(link))
    if (is.na(href) || !nzchar(title)) return(NULL)
    date <- first_date_in_text(rvest::html_text2(a))
    if (is.na(date)) return(NULL)
    tibble::tibble(date = date, title = title, url = abs_urls(href, base))
  })
  recs <- purrr::compact(recs)
  if (length(recs) == 0) return(empty_items())
  out <- dplyr::bind_rows(recs)
  out[!duplicated(out$url), , drop = FALSE]
}

# Body for the HTML fallback (REST items carry their body inline, so this is
# only reached for Elementor item pages).
wp_item_body <- function(doc, url) {
  body <- body_from_selectors(doc, c(
    ".elementor-widget-theme-post-content",
    ".entry-content",
    "article",
    "main"
  ))
  list(body = body, tags = NA_character_)
}
