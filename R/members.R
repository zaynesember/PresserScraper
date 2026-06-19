#' List current U.S. House members and their websites
#'
#' Scrapes <https://www.house.gov/representatives>, which lays out one table
#' per state with columns for district, name, party, office, phone, and
#' committees. Returns one row per member with a cleaned homepage URL.
#'
#' @param url The directory page to scrape (override only for testing).
#' @return A [tibble][tibble::tibble] with columns `name`, `state`, `district`,
#'   `party`, `committee`, and `url`. `committee` is a `";"`-delimited string of
#'   committee assignments (`NA` for leadership/vacant seats that list none).
#' @examples
#' \dontrun{
#' members <- list_members()
#' }
#' @export
list_members <- function(url = "https://www.house.gov/representatives") {
  doc <- fetch_html(url)
  if (is.null(doc)) {
    cli::cli_abort("Could not fetch the House members directory at {.url {url}}.")
  }

  tables <- rvest::html_elements(doc, "table")
  rows <- purrr::map(tables, parse_member_table)
  out <- dplyr::bind_rows(rows)

  if (nrow(out) == 0) {
    cli::cli_abort("Parsed the directory but found no members; the page layout may have changed.")
  }

  out <- out[!is.na(out$url) & nzchar(out$url), , drop = FALSE]
  out <- out[is_member_url(out$url), , drop = FALSE]
  out <- out[!is_non_member_host(out$url), , drop = FALSE]
  out <- out[!duplicated(out$url), , drop = FALSE]
  tibble::as_tibble(out)
}

# Administrative *.house.gov hosts that are syntactically valid member URLs but
# are not representatives (they can appear linked from the directory page).
.non_member_hosts <- c(
  "clerk", "speaker", "democraticleader", "republicanleader",
  "majorityleader", "majoritywhip", "democraticwhip", "republicanwhip"
)

is_non_member_host <- function(url) {
  host <- sub("^https://([^.]+)\\.house\\.gov$", "\\1", normalize_home(url))
  host %in% .non_member_hosts
}

# Parse a single state table from the directory into member rows.
# Returns NULL for non-member tables (no .house.gov links).
parse_member_table <- function(table) {
  trs <- rvest::html_elements(table, "tbody tr")
  if (length(trs) == 0) trs <- rvest::html_elements(table, "tr")
  if (length(trs) == 0) return(NULL)

  state <- rvest::html_element(table, "caption") |> rvest::html_text() |> trimws()
  if (is.na(state) || !nzchar(state)) state <- NA_character_

  parsed <- purrr::map(trs, function(tr) parse_member_row(tr, state))
  parsed <- purrr::compact(parsed)
  if (length(parsed) == 0) return(NULL)
  dplyr::bind_rows(parsed)
}

# Parse one <tr> into a member record, or NULL if it has no member link.
parse_member_row <- function(tr, state) {
  link <- rvest::html_element(tr, "a[href*='house.gov']")
  href <- rvest::html_attr(link, "href")
  if (is.na(href)) return(NULL)

  url <- normalize_home(href)
  if (!is_member_url(url)) return(NULL)

  cells <- rvest::html_elements(tr, "td") |> rvest::html_text() |> trimws()
  name <- rvest::html_text(link) |> trimws()
  if (!nzchar(name)) name <- NA_character_

  party <- cells[grepl("^[RDIL]$", cells)][1] %||% NA_character_
  district <- cells[grepl("^([0-9]+(st|nd|rd|th)|At Large|Delegate|Resident)", cells, ignore.case = TRUE)][1] %||% NA_character_

  tibble::tibble(
    name = name,
    state = state,
    district = district,
    party = party,
    committee = parse_committee(cells),
    url = url
  )
}

# The directory's last column is "Committee Assignment" (pipe-delimited, e.g.
# "Agriculture|Judiciary"); normalise to a ";"-delimited string for consistency
# with the release `tags` column. NA for leadership/vacant rows that list none.
parse_committee <- function(cells) {
  if (length(cells) == 0) return(NA_character_)
  raw <- cells[length(cells)]
  is_phone <- grepl("^\\(?[0-9]{3}\\)?[ .-]?[0-9]{3}", raw)
  is_room <- grepl("[A-Z]{2,4}HOB|^[0-9]{3,4}\\s", raw)
  if (!nzchar(raw) || is_phone || is_room) return(NA_character_)
  gsub("\\s*\\|\\s*", ";", trimws(raw))
}
