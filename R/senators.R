#' List current U.S. Senators and their websites
#'
#' Parses the Senate's contact-information XML feed (one entry per senator with
#' name, party, state, and website). Senators are statewide, so `district` is
#' `NA`; committee assignments are not in this feed, so `committee` is `NA`.
#' The returned columns mirror [list_members()] so House and Senate results can
#' be combined or scraped with the same machinery.
#'
#' @param url The Senate directory XML (override only for testing).
#' @return A [tibble][tibble::tibble] with columns `name`, `state`, `district`,
#'   `party`, `committee`, `url`, and `chamber` (`"senate"`).
#' @examples
#' \dontrun{
#' senators <- list_senators()
#' }
#' @seealso [list_members()] for the House, [scrape_senate()] to scrape them.
#' @export
list_senators <- function(url = "https://www.senate.gov/general/contact_information/senators_cfm.xml") {
  resp <- tryCatch(httr2::req_perform(.build_request(url)), error = function(e) NULL)
  if (is.null(resp) || httr2::resp_status(resp) >= 400) {
    cli::cli_abort("Could not fetch the Senate directory at {.url {url}}.")
  }
  doc <- tryCatch(xml2::read_xml(httr2::resp_body_string(resp)), error = function(e) NULL)
  if (is.null(doc)) cli::cli_abort("Could not parse the Senate directory XML at {.url {url}}.")

  out <- parse_senators(doc)
  if (nrow(out) == 0) {
    cli::cli_abort("Parsed the Senate directory but found no senators; the feed format may have changed.")
  }
  out
}

# Parse the senators XML document into a member tibble (separated for testing).
parse_senators <- function(doc) {
  mem <- xml2::xml_find_all(doc, ".//member")
  if (length(mem) == 0) return(empty_member_directory("senate"))

  field <- function(tag) {
    trimws(xml2::xml_text(xml2::xml_find_first(mem, paste0("./", tag))))
  }
  last <- field("last_name")
  first <- field("first_name")
  name <- ifelse(
    nzchar(last) & nzchar(first), paste0(last, ", ", first),
    ifelse(nzchar(last), last, NA_character_)
  )

  out <- tibble::tibble(
    name = name,
    state = field("state"),
    district = NA_character_,
    party = field("party"),
    committee = NA_character_,
    url = normalize_home(field("website")),
    chamber = "senate"
  )
  out <- out[!is.na(out$url) & nzchar(out$url) & is_member_url(out$url), , drop = FALSE]
  out[!duplicated(out$url), , drop = FALSE]
}

# Empty directory tibble with the standard member columns.
empty_member_directory <- function(chamber) {
  tibble::tibble(
    name = character(0), state = character(0), district = character(0),
    party = character(0), committee = character(0), url = character(0),
    chamber = character(0)
  )
}
