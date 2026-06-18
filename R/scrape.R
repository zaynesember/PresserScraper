#' Scrape press releases for many members
#'
#' Runs [scrape_member()] across a set of member sites, isolating failures so
#' one broken site doesn't stop the run. Member metadata (name, state, etc.) is
#' carried through when `members` is a data frame such as that from
#' [list_members()].
#'
#' @param members Either a character vector of member URLs (optionally named,
#'   in which case names become the `name` column) or a data frame with a `url`
#'   column plus any metadata columns to carry through (e.g. from
#'   [list_members()]).
#' @param from,to Inclusive date range. `to` defaults to today.
#' @param fetch_bodies Whether to fetch each release's body text.
#' @param page_limit Per-member maximum listing pages to walk.
#' @param log_fails If `TRUE`, write the failures table to `fails_path`.
#' @param fails_path Path for the failures CSV when `log_fails = TRUE`.
#' @param quiet Suppress per-member progress messages.
#' @return A [tibble][tibble::tibble] of releases (member metadata columns,
#'   then `date`, `title`, `body`, `tags`, `url`, `cms`). A `failures` tibble
#'   (`url`, `stage`, `message`) is attached as an attribute; retrieve it with
#'   `attr(result, "failures")`.
#' @seealso [scrape_house()] to scrape the whole chamber.
#' @export
scrape_pressers <- function(members, from, to = Sys.Date(),
                            fetch_bodies = TRUE, page_limit = 100,
                            log_fails = FALSE, fails_path = "fails.csv",
                            quiet = FALSE) {
  from <- as.Date(from)
  to <- as.Date(to)
  if (from > to) cli::cli_abort("{.arg from} ({from}) is after {.arg to} ({to}).")

  meta <- normalize_members(members)
  n <- nrow(meta)
  if (n == 0) cli::cli_abort("No members to scrape.")

  results <- vector("list", n)
  fails <- list()

  for (i in seq_len(n)) {
    url <- meta$url[i]
    if (!quiet) cli::cli_alert_info("[{i}/{n}] {url}")

    res <- tryCatch(
      scrape_member(url, from = from, to = to, page_limit = page_limit,
                    fetch_bodies = fetch_bodies, quiet = TRUE),
      error = function(e) e
    )

    if (inherits(res, "error")) {
      fails[[length(fails) + 1]] <- tibble::tibble(
        url = url, stage = "error", message = conditionMessage(res)
      )
    } else if (nrow(res) == 0) {
      fails[[length(fails) + 1]] <- tibble::tibble(
        url = url, stage = "empty", message = "no releases in date range"
      )
    } else {
      # Attach this member's metadata (release `url`/`cms` take precedence).
      meta_cols <- setdiff(names(meta), c("url", names(res)))
      for (col in meta_cols) res[[col]] <- meta[[col]][i]
      results[[i]] <- res
    }
  }

  out <- dplyr::bind_rows(purrr::compact(results))
  failures <- if (length(fails)) dplyr::bind_rows(fails) else
    tibble::tibble(url = character(0), stage = character(0), message = character(0))

  if (nrow(out) > 0) out <- order_columns(out)

  if (log_fails) {
    utils::write.csv(failures, fails_path, row.names = FALSE)
    cli::cli_alert_info("Logged {nrow(failures)} failure(s) to {.path {fails_path}}.")
  }

  if (!quiet) {
    cli::cli_alert_success(
      "Scraped {nrow(out)} release(s) from {n - nrow(failures)}/{n} member(s); {nrow(failures)} failure(s)."
    )
  }

  attr(out, "failures") <- failures
  out
}

#' Scrape press releases for the whole U.S. House
#'
#' Convenience wrapper that pulls the current member directory with
#' [list_members()] and scrapes it with [scrape_pressers()].
#'
#' @inheritParams scrape_pressers
#' @param max_members Optionally cap the number of members (e.g. for a quick
#'   sample); `NULL` scrapes everyone.
#' @return See [scrape_pressers()].
#' @export
scrape_house <- function(from, to = Sys.Date(), max_members = NULL,
                         fetch_bodies = TRUE, page_limit = 100,
                         log_fails = FALSE, fails_path = "fails.csv",
                         quiet = FALSE) {
  members <- list_members()
  if (!is.null(max_members)) members <- utils::head(members, max_members)
  scrape_pressers(members, from = from, to = to, fetch_bodies = fetch_bodies,
                  page_limit = page_limit, log_fails = log_fails,
                  fails_path = fails_path, quiet = quiet)
}

# Coerce the `members` argument into a metadata tibble with a `url` column.
normalize_members <- function(members) {
  if (is.data.frame(members)) {
    if (!"url" %in% names(members)) cli::cli_abort("{.arg members} data frame needs a {.field url} column.")
    members$url <- normalize_home(members$url)
    return(tibble::as_tibble(members))
  }
  urls <- normalize_home(as.character(members))
  tibble::tibble(name = names(members) %||% rep(NA_character_, length(urls)), url = urls)
}

# Put member metadata first, then the release fields.
order_columns <- function(df) {
  release_cols <- c("date", "title", "body", "tags", "url", "cms")
  meta_cols <- setdiff(names(df), release_cols)
  dplyr::relocate(df, dplyr::all_of(meta_cols))
}
