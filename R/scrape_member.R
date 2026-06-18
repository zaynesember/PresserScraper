#' Scrape one member's press releases within a date range
#'
#' Detects the member site's CMS, finds its press-release listing, walks the
#' listing pages newest-first until it passes the start of the window, and
#' fetches the body of each release in range.
#'
#' @param url Member homepage (e.g. `"barrymoore.house.gov"`).
#' @param from,to Date range (inclusive). Character `"YYYY-MM-DD"` or `Date`.
#'   `to` defaults to today.
#' @param cms Optional CMS override (`"drupal"`, `"aspx"`, `"wordpress"`,
#'   `"generic"`); detected automatically when `NULL`.
#' @param page_limit Maximum listing pages to walk (safety bound).
#' @param fetch_bodies If `FALSE`, skip fetching each release's body text
#'   (faster; `body`/`tags` come back `NA`).
#' @param quiet Suppress progress messages.
#' @return A [tibble][tibble::tibble] with columns `date`, `title`, `body`,
#'   `tags`, `url`, `cms`. Zero rows if nothing falls in range.
#' @export
scrape_member <- function(url, from, to = Sys.Date(), cms = NULL,
                          page_limit = 100, fetch_bodies = TRUE, quiet = FALSE) {
  from <- as.Date(from)
  to <- as.Date(to)
  if (from > to) cli::cli_abort("{.arg from} ({from}) is after {.arg to} ({to}).")

  home <- normalize_home(url)
  if (!is_member_url(home)) {
    cli::cli_abort("{.val {url}} is not a valid '*.house.gov' member URL.")
  }

  home_doc <- fetch_html(home)
  if (is.null(home_doc)) cli::cli_abort("Could not fetch homepage {.url {home}}.")

  if (is.null(cms)) cms <- detect_cms(doc = home_doc)
  ex <- get_extractor(cms)

  list_url <- ex$list_url(home, home_doc)
  if (is.null(list_url)) {
    cli::cli_abort("Could not locate a press-release listing for {.url {home}} (cms: {cms}).")
  }

  items <- walk_listing(ex, list_url, from, to, page_limit, home, quiet)
  if (nrow(items) == 0) {
    return(empty_member_result(cms))
  }

  # API extractors return body/tags inline; HTML extractors need a per-item fetch.
  if ("body" %in% names(items)) {
    body <- items$body
    tags <- if ("tags" %in% names(items)) items$tags else rep(NA_character_, nrow(items))
  } else if (fetch_bodies) {
    bodies <- purrr::map(items$url, function(u) {
      doc <- fetch_html(u)
      if (is.null(doc)) list(body = NA_character_, tags = NA_character_) else ex$item_body(doc, u)
    })
    body <- purrr::map_chr(bodies, "body")
    tags <- purrr::map_chr(bodies, "tags")
  } else {
    body <- rep(NA_character_, nrow(items))
    tags <- rep(NA_character_, nrow(items))
  }

  tibble::tibble(
    date = items$date,
    title = items$title,
    body = body,
    tags = tags,
    url = items$url,
    cms = cms
  )
}

# Walk listing pages newest-first, collecting items within [from, to].
# Stops once a page's oldest in-range candidate falls before `from`.
walk_listing <- function(ex, list_url, from, to, page_limit, home, quiet) {
  collected <- list()
  prev_urls <- character(0)
  page <- 0L
  repeat {
    if (page > page_limit) {
      if (!quiet) cli::cli_warn("Hit page limit ({page_limit}) for {.url {home}}.")
      break
    }
    if (!quiet) cli::cli_alert_info("{home}: page {page}")

    page_obj <- ex$fetch_page(list_url, page)
    if (is.null(page_obj)) break

    items <- ex$list_items(page_obj, list_url)
    if (nrow(items) == 0) break

    # Guard against broken pagination that keeps returning the same page.
    if (identical(items$url, prev_urls)) break
    prev_urls <- items$url

    newest <- max(items$date, na.rm = TRUE)
    oldest <- min(items$date, na.rm = TRUE)

    in_range <- items[items$date >= from & items$date <= to, , drop = FALSE]
    if (nrow(in_range) > 0) collected[[length(collected) + 1]] <- in_range

    # Once the page reaches back past the window's start, we're done.
    if (oldest < from) break
    # If the whole page is newer than the window, keep paging back; otherwise
    # we've collected what we can and the next page is older still.
    page <- page + 1L
  }

  if (length(collected) == 0) return(empty_items())
  out <- dplyr::bind_rows(collected)
  out[!duplicated(out$url), , drop = FALSE]
}

empty_member_result <- function(cms) {
  tibble::tibble(
    date = as.Date(character(0)),
    title = character(0),
    body = character(0),
    tags = character(0),
    url = character(0),
    cms = character(0)
  )
}
