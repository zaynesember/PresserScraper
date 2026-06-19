#' List current U.S. Senators and their websites
#'
#' Parses the Senate's contact-information XML feed (one entry per senator with
#' name, party, state, and website). Senators are statewide, so `district` is
#' `NA`; committee assignments are not in this feed, so `committee` is `NA`.
#' The returned columns mirror [list_members()] so House and Senate results can
#' be combined or scraped with the same machinery.
#'
#' @param url The Senate directory XML (override only for testing).
#' @param committees Whether to enrich each senator with their committee
#'   assignments (a `";"`-delimited string in the `committee` column). Requires
#'   one extra fetch of the public \@@unitedstates congressional dataset
#'   (<https://github.com/unitedstates/congress-legislators>); if it is
#'   unavailable, `committee` is left `NA` (no error).
#' @return A [tibble][tibble::tibble] with columns `name`, `state`, `district`,
#'   `party`, `committee`, `url`, and `chamber` (`"senate"`).
#' @examples
#' \dontrun{
#' senators <- list_senators()
#' }
#' @seealso [list_members()] for the House, [scrape_senate()] to scrape them.
#' @export
list_senators <- function(url = "https://www.senate.gov/general/contact_information/senators_cfm.xml",
                          committees = TRUE) {
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

  if (committees) {
    data <- fetch_committee_data()
    if (!is.null(data)) {
      out$committee <- senate_committee_map(out$bioguide, data$committees, data$membership)
    } else {
      cli::cli_warn("Could not fetch committee data; {.field committee} left NA.")
    }
  }
  out$bioguide <- NULL  # internal join key, not part of the public schema
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
    chamber = "senate",
    bioguide = field("bioguide_id")  # stable id; internal join key for committees
  )
  out <- out[!is.na(out$url) & nzchar(out$url) & is_member_url(out$url), , drop = FALSE]
  out[!duplicated(out$url), , drop = FALSE]
}

# Fetch the @unitedstates congressional committee datasets (committee metadata
# and per-committee membership). Returns list(committees, membership) or NULL.
.us_committees_url <- "https://unitedstates.github.io/congress-legislators/committees-current.json"
.us_membership_url <- "https://unitedstates.github.io/congress-legislators/committee-membership-current.json"

fetch_committee_data <- function() {
  committees <- fetch_json(.us_committees_url)
  membership <- fetch_json(.us_membership_url)
  if (is.null(committees) || is.null(membership)) return(NULL)
  list(committees = committees, membership = membership)
}

# Map a vector of bioguide ids to ";"-delimited Senate committee assignments.
# `committees` is the committees-current data frame (type/thomas_id/name);
# `membership` is the committee-membership list (thomas_id -> members frame).
# Only top-level Senate and joint committees are used (matching the House
# directory's standing-committee granularity; subcommittees are ignored).
senate_committee_map <- function(bioguides, committees, membership) {
  keep <- committees$type %in% c("senate", "joint")
  ids <- committees$thomas_id[keep]
  cnames <- clean_committee_name(committees$name[keep])

  by_bioguide <- list()
  for (i in seq_along(ids)) {
    mem <- membership[[ids[i]]]
    if (is.null(mem) || !is.data.frame(mem) || is.null(mem$bioguide)) next
    for (b in mem$bioguide) by_bioguide[[b]] <- c(by_bioguide[[b]], cnames[i])
  }

  vapply(bioguides, function(b) {
    v <- by_bioguide[[b]]
    if (is.null(v)) NA_character_ else paste(unique(v), collapse = ";")
  }, character(1), USE.NAMES = FALSE)
}

# Trim the boilerplate prefix from a committee name so it reads like the House
# directory's short labels (e.g. "Senate Committee on the Judiciary" ->
# "Judiciary"). Names without the standard prefix (joint committees, caucuses)
# are left as-is.
clean_committee_name <- function(x) {
  sub("^(United States )?(Senate|Joint)( Select| Special)? Committee on (the )?", "", x)
}

# Empty directory tibble with the standard member columns.
empty_member_directory <- function(chamber) {
  tibble::tibble(
    name = character(0), state = character(0), district = character(0),
    party = character(0), committee = character(0), url = character(0),
    chamber = character(0)
  )
}
