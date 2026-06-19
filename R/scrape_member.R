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
#' @param render Headless-browser policy for JS-rendered sites. `"auto"` (the
#'   default) does a static pass and, only if it finds *no* parseable releases
#'   at all, retries once through a headless browser (when the suggested
#'   \pkg{chromote} package is installed). `"never"` disables the fallback;
#'   `"always"` renders from the start. The auto fallback does not fire merely
#'   because a site has no releases in the date window.
#' @param quiet Suppress progress messages.
#' @return A [tibble][tibble::tibble] with columns `date`, `title`, `body`,
#'   `tags`, `url`, `cms`. Zero rows if nothing falls in range.
#' @export
scrape_member <- function(url, from, to = Sys.Date(), cms = NULL,
                          page_limit = 100, fetch_bodies = TRUE,
                          render = c("auto", "never", "always"), quiet = FALSE) {
  render <- match.arg(render)
  from <- as.Date(from)
  to <- as.Date(to)
  if (from > to) cli::cli_abort("{.arg from} ({from}) is after {.arg to} ({to}).")

  home <- normalize_home(url)
  if (!is_member_url(home)) {
    cli::cli_abort("{.val {url}} is not a valid '*.house.gov' member URL.")
  }

  have_chromote <- requireNamespace("chromote", quietly = TRUE)
  if (render == "always" && !have_chromote) {
    cli::cli_abort("{.arg render = \"always\"} needs the {.pkg chromote} package; install it first.")
  }

  # Static pass (or a forced render pass).
  res <- if (render == "always") {
    with_render(scrape_member_core(home, from, to, cms, page_limit, fetch_bodies, quiet))
  } else {
    scrape_member_core(home, from, to, cms, page_limit, fetch_bodies, quiet)
  }

  # Auto fallback: if a static pass turned up no parseable releases at all, the
  # site likely renders its listing client-side -- retry once with a browser.
  if (render == "auto" && needs_render(res) && have_chromote) {
    if (!quiet) cli::cli_alert_info("{home}: nothing found statically; retrying with JS rendering.")
    res2 <- with_render(scrape_member_core(home, from, to, cms, page_limit, fetch_bodies, quiet))
    if (nrow(res2) > 0 || !needs_render(res2)) res <- res2
  }

  # Generic fallback: a vendor extractor that returned nothing may be pointed at
  # the wrong source (e.g. a stale REST feed while the live releases sit in an
  # HTML /newsroom). Retry once with the generic extractor before giving up.
  if (nrow(res) == 0 && !identical(attr(res, "cms_detected"), "generic")) {
    res2 <- scrape_member_core(home, from, to, "generic", page_limit, fetch_bodies, quiet)
    if (nrow(res2) > 0) res <- res2
  }

  # Surface hard failures the way the static implementation always has, then
  # drop the internal status attributes before returning.
  if (!isTRUE(attr(res, "found_home"))) {
    cli::cli_abort("Could not fetch homepage {.url {home}}.")
  }
  if (!isTRUE(attr(res, "found_listing"))) {
    cli::cli_abort(
      "Could not locate a press-release listing for {.url {home}} (cms: {attr(res, 'cms_detected')})."
    )
  }
  strip_status(res)
}

# One end-to-end pass over a member site (static or, under with_render(), via a
# browser). Never aborts: instead it tags the result with status attributes
# (found_home, found_listing, saw_items, cms_detected) so the caller can decide
# whether to retry, abort, or accept an empty result.
scrape_member_core <- function(home, from, to, cms, page_limit, fetch_bodies, quiet) {
  home_doc <- get_html(home)
  if (is.null(home_doc)) {
    return(with_status(empty_member_result(),
                       found_home = FALSE, found_listing = FALSE,
                       saw_items = FALSE, cms_detected = cms))
  }

  if (is.null(cms)) cms <- detect_cms(doc = home_doc)
  ex <- get_extractor(cms)

  list_url <- ex$list_url(home, home_doc)
  if (is.null(list_url)) {
    return(with_status(empty_member_result(),
                       found_home = TRUE, found_listing = FALSE,
                       saw_items = FALSE, cms_detected = cms))
  }

  items <- walk_listing(ex, list_url, from, to, page_limit, home, quiet)
  saw_items <- isTRUE(attr(items, "saw_items"))
  if (nrow(items) == 0) {
    return(with_status(empty_member_result(),
                       found_home = TRUE, found_listing = TRUE,
                       saw_items = saw_items, cms_detected = cms))
  }

  # API extractors return body/tags inline; HTML extractors need a per-item fetch.
  if ("body" %in% names(items)) {
    body <- items$body
    tags <- if ("tags" %in% names(items)) items$tags else rep(NA_character_, nrow(items))
  } else if (fetch_bodies) {
    bodies <- purrr::map(items$url, function(u) {
      doc <- get_html(u)
      if (is.null(doc)) list(body = NA_character_, tags = NA_character_) else ex$item_body(doc, u)
    })
    body <- purrr::map_chr(bodies, "body")
    tags <- purrr::map_chr(bodies, "tags")
  } else {
    body <- rep(NA_character_, nrow(items))
    tags <- rep(NA_character_, nrow(items))
  }

  out <- tibble::tibble(
    date = items$date,
    title = items$title,
    body = body,
    tags = tags,
    url = items$url,
    cms = cms
  )
  with_status(out, found_home = TRUE, found_listing = TRUE,
              saw_items = TRUE, cms_detected = cms)
}

# TRUE when a pass found no parseable releases at all (no homepage, no listing,
# or a listing that yielded zero items) -- the signal that a JS render might
# help. A site with releases that simply fall outside the date window does not
# count, so the fallback never fires for the common "nothing in range" case.
needs_render <- function(res) {
  !isTRUE(attr(res, "found_home")) ||
    !isTRUE(attr(res, "found_listing")) ||
    !isTRUE(attr(res, "saw_items"))
}

# Tag a result tibble with internal status attributes.
with_status <- function(df, ...) {
  status <- list(...)
  for (nm in names(status)) attr(df, nm) <- status[[nm]]
  df
}

# Remove the internal status attributes before returning to the user.
strip_status <- function(df) {
  for (nm in c("found_home", "found_listing", "saw_items", "cms_detected")) {
    attr(df, nm) <- NULL
  }
  df
}

# Walk listing pages newest-first, collecting items within [from, to].
# Stops once a page's oldest in-range candidate falls before `from`.
walk_listing <- function(ex, list_url, from, to, page_limit, home, quiet) {
  collected <- list()
  prev_urls <- character(0)
  saw_items <- FALSE
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
    saw_items <- TRUE  # the listing yielded parseable releases (any date)

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

  out <- if (length(collected) == 0) {
    empty_items()
  } else {
    full <- dplyr::bind_rows(collected)
    full[!duplicated(full$url), , drop = FALSE]
  }
  # Report whether the listing produced any releases at all, so scrape_member()
  # can tell "nothing in range" (releases seen) from "nothing parseable"
  # (a likely JS-rendered or unsupported site).
  attr(out, "saw_items") <- saw_items
  out
}

empty_member_result <- function() {
  tibble::tibble(
    date = as.Date(character(0)),
    title = character(0),
    body = character(0),
    tags = character(0),
    url = character(0),
    cms = character(0)
  )
}
