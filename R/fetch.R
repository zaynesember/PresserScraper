.user_agent <- paste0(
  "pressR/0.1 (R package; academic research; ",
  "+https://github.com/zaynesember/pressR)"
)

# Render mode flag. When active, get_html() routes through render_html() (a
# headless browser) instead of a static fetch, so scrape_member() can retry a
# JS-rendered site without the extractors knowing the difference.
.pressR_render <- new.env(parent = emptyenv())
.pressR_render$on <- FALSE

# Evaluate `expr` with render mode enabled, restoring the previous mode after
# (even on error). Used by scrape_member() for its JS fallback pass.
with_render <- function(expr) {
  old <- .pressR_render$on
  .pressR_render$on <- TRUE
  on.exit(.pressR_render$on <- old, add = TRUE)
  expr
}

# Internal HTML fetcher used by the extractors. Honors the active render mode:
# a static httr2 fetch normally, or a headless-browser render during a fallback
# pass. Keeping this seam internal lets fetch_html() stay a pure static fetch.
get_html <- function(url, timeout = 30) {
  if (isTRUE(.pressR_render$on)) render_html(url) else fetch_html(url, timeout)
}

# Build a configured httr2 request: identity UA, timeout, polite throttle,
# retry on transient failures, and optional on-disk caching for development.
.build_request <- function(url, timeout = 30) {
  req <- httr2::request(url)
  req <- httr2::req_user_agent(req, .user_agent)
  req <- httr2::req_timeout(req, timeout)
  req <- httr2::req_throttle(req, capacity = getOption("pressR.throttle", 20), fill_time_s = 60)
  req <- httr2::req_retry(req, max_tries = 3, retry_on_failure = TRUE)
  cache_dir <- getOption("pressR.cache_dir", NULL)
  if (!is.null(cache_dir)) req <- httr2::req_cache(req, path = cache_dir)
  # Don't let a 404 throw; callers decide what an error status means.
  req <- httr2::req_error(req, is_error = function(resp) FALSE)
  req
}

#' Fetch a URL and return its parsed HTML, or `NULL` on failure
#'
#' Static fetch via httr2 with retry/throttle. Returns `NULL` for network
#' errors or non-2xx responses so callers can fall back gracefully.
#'
#' @param url URL to fetch.
#' @param timeout Per-request timeout in seconds.
#' @return An `xml_document` (from [rvest::read_html()]) or `NULL`.
#' @export
fetch_html <- function(url, timeout = 30) {
  resp <- tryCatch(
    httr2::req_perform(.build_request(url, timeout)),
    error = function(e) NULL
  )
  if (is.null(resp) || httr2::resp_status(resp) >= 400) return(NULL)
  body <- tryCatch(httr2::resp_body_string(resp), error = function(e) NULL)
  if (is.null(body) || !nzchar(body)) return(NULL)
  tryCatch(rvest::read_html(body), error = function(e) NULL)
}

#' Fetch a URL and return parsed JSON, or `NULL` on failure
#'
#' @inheritParams fetch_html
#' @return A parsed list/data.frame, or `NULL`.
#' @export
fetch_json <- function(url, timeout = 30) {
  resp <- tryCatch(
    httr2::req_perform(.build_request(url, timeout)),
    error = function(e) NULL
  )
  if (is.null(resp) || httr2::resp_status(resp) >= 400) return(NULL)
  tryCatch(httr2::resp_body_json(resp, simplifyVector = TRUE), error = function(e) NULL)
}

#' Render a URL with a headless browser (JS fallback)
#'
#' Lazily uses the suggested \pkg{chromote} package. Only needed for the small
#' tail of sites that render their press list client-side. Returns `NULL` if
#' chromote is unavailable or rendering fails.
#'
#' @param url URL to render.
#' @param wait Seconds to wait for client-side rendering before reading the DOM.
#' @return An `xml_document` or `NULL`.
#' @export
render_html <- function(url, wait = 2) {
  if (!requireNamespace("chromote", quietly = TRUE)) {
    cli::cli_warn("Package {.pkg chromote} is required for JS rendering; install it to scrape {.url {url}}.")
    return(NULL)
  }
  out <- tryCatch({
    b <- chromote::ChromoteSession$new()
    on.exit(b$close(), add = TRUE)
    b$Page$navigate(url)
    b$Page$loadEventFired(wait_ = TRUE)
    Sys.sleep(wait)
    doc <- b$Runtime$evaluate("document.documentElement.outerHTML")$result$value
    rvest::read_html(doc)
  }, error = function(e) NULL)
  out
}
