#' pressR: Scrape Press Releases from U.S. House Members' Websites
#'
#' Collects press releases from U.S. House of Representatives members'
#' `.house.gov` sites over a date range. The package detects the
#' content-management system behind each site and routes to a dedicated
#' extractor. See [scrape_pressers()] for the main entry point.
#'
#' @keywords internal
"_PACKAGE"

# Null-coalescing operator: return `y` when `x` is NULL or empty.
`%||%` <- function(x, y) {
  if (is.null(x) || length(x) == 0) y else x
}

# Strip a trailing slash (or several) from a URL.
trim_slash <- function(x) sub("/+$", "", x)

# Normalise a member homepage to its bare `https://name.house.gov` form.
# Vectorised over `url`.
normalize_home <- function(url) {
  url <- trimws(as.character(url))
  needs <- !is.na(url) & !grepl("^https?://", url)
  url[needs] <- paste0("https://", url[needs])
  # Drop anything tacked on after the house.gov host.
  url <- sub("(house\\.gov).*", "\\1", url)
  trim_slash(url)
}

# TRUE for a syntactically valid member homepage.
is_member_url <- function(url) {
  grepl("^https://[a-zA-Z0-9-]+\\.house\\.gov$", normalize_home(url))
}

# Extract `https://host` from a full URL.
url_origin <- function(url) {
  m <- regmatches(url, regexpr("^https?://[^/]+", url))
  if (length(m) == 0) url else m
}

# Append (or replace) a query parameter on a URL.
add_query <- function(url, key, value) {
  sep <- if (grepl("\\?", url)) "&" else "?"
  paste0(url, sep, key, "=", value)
}

# Convert an HTML fragment (e.g. a WordPress content.rendered string) to plain,
# entity-decoded text. Vectorised; returns NA for empty input.
html_to_text <- function(x) {
  vapply(x, function(s) {
    if (is.na(s) || !nzchar(s)) return(NA_character_)
    doc <- tryCatch(rvest::read_html(paste0("<div>", s, "</div>")), error = function(e) NULL)
    if (is.null(doc)) return(NA_character_)
    trimws(rvest::html_text2(doc))
  }, character(1), USE.NAMES = FALSE)
}

# First element of `x` for which `parse_dates` yields a non-NA date, else NA.
first_parseable_date <- function(x) {
  x <- x[!is.na(x) & nzchar(x)]
  if (length(x) == 0) return(as.Date(NA))
  d <- parse_dates(x)
  hit <- which(!is.na(d))
  if (length(hit) == 0) as.Date(NA) else d[hit[1]]
}
