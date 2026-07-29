# 01_enumerate_hosts.R -- build the candidate host list for institutional
# (committee + leadership) press-release sources.
#
# Outputs institutional/data/hosts.csv with one row per resolving host:
#   host, unit, type (committee|leadership|caucus), chamber (house|senate|joint),
#   party_site (majority|minority|democrat|republican|nonpartisan|NA),
#   status (http status of GET /), final_url (after redirects), directory_source
#
# Run from the worktree root:  Rscript institutional/R/01_enumerate_hosts.R

suppressPackageStartupMessages({
  library(rvest)
  library(httr2)
})

ROOT <- "/Users/zaynesember/GitRepos/pressR-sources"
OUT  <- file.path(ROOT, "institutional", "data")
dir.create(OUT, recursive = TRUE, showWarnings = FALSE)

UA <- "pressR/0.1 (R package; academic research; +https://github.com/zaynesember/pressR)"

polite_get <- function(url, timeout = 20) {
  req <- request(url) |>
    req_user_agent(UA) |>
    req_timeout(timeout) |>
    req_throttle(capacity = 20, fill_time_s = 60) |>
    req_error(is_error = function(resp) FALSE)
  tryCatch(req_perform(req), error = function(e) NULL)
}

probe <- function(url) {
  resp <- polite_get(url)
  if (is.null(resp)) return(list(status = NA_integer_, final_url = NA_character_))
  list(status = resp_status(resp), final_url = resp_url(resp))
}

host_of <- function(url) sub("^https?://([^/]+).*$", "\\1", url)

## ---------------------------------------------------------------- House committees
message("Fetching house.gov/committees ...")
house_dir <- read_html("https://www.house.gov/committees")
house_links <- html_elements(house_dir, "a")
house_df <- data.frame(
  text = trimws(html_text2(house_links)),
  href = html_attr(house_links, "href"),
  stringsAsFactors = FALSE
)
house_df <- house_df[!is.na(house_df$href), ]
# committee sites are <name>.house.gov subdomains that are not utility hosts
house_df <- house_df[grepl("^https?://[a-z0-9-]+\\.house\\.gov/?$", house_df$href, ignore.case = TRUE), ]
house_df$host <- tolower(host_of(house_df$href))
drop_hosts <- c("www.house.gov", "clerk.house.gov")
house_df <- house_df[!house_df$host %in% drop_hosts, ]
house_df <- house_df[!duplicated(house_df$host), ]
message("  house committee hosts from directory: ", nrow(house_df))

house_committees <- data.frame(
  host = house_df$host,
  unit = house_df$text,
  type = "committee",
  chamber = "house",
  party_site = "majority",
  directory_source = "house.gov/committees",
  stringsAsFactors = FALSE
)

## ------------------------------------------------- House minority-site variants
# Minority committee sites live on prefixed hosts (e.g. democrats-agriculture.house.gov).
# Probe democrats-, republicans-, and gop- prefixes for every committee host.
message("Probing House minority-site variants ...")
minority_rows <- list()
for (i in seq_len(nrow(house_committees))) {
  base <- sub("\\.house\\.gov$", "", house_committees$host[i])
  for (pfx in c("democrats-", "republicans-", "gop-")) {
    cand <- paste0(pfx, base, ".house.gov")
    pr <- probe(paste0("https://", cand))
    if (!is.na(pr$status) && pr$status < 400 &&
        grepl(cand, pr$final_url, fixed = TRUE)) {
      minority_rows[[length(minority_rows) + 1]] <- data.frame(
        host = cand,
        unit = house_committees$unit[i],
        type = "committee",
        chamber = "house",
        party_site = if (pfx == "democrats-") "democrat" else "republican",
        directory_source = "probe:minority-prefix",
        stringsAsFactors = FALSE
      )
      message("  found: ", cand)
    }
  }
}
house_minority <- if (length(minority_rows)) do.call(rbind, minority_rows) else NULL

## --------------------------------------------------------------- Senate committees
message("Fetching senate.gov committee directory ...")
sen_dir <- read_html("https://www.senate.gov/committees/index.htm")
sen_links <- html_elements(sen_dir, "a")
sen_df <- data.frame(
  text = trimws(html_text2(sen_links)),
  href = html_attr(sen_links, "href"),
  stringsAsFactors = FALSE
)
sen_df <- sen_df[!is.na(sen_df$href), ]
sen_df <- sen_df[grepl("^https?://[a-z0-9.-]+\\.senate\\.gov", sen_df$href, ignore.case = TRUE), ]
sen_df$host <- tolower(host_of(sen_df$href))
sen_df <- sen_df[!sen_df$host %in% c("www.senate.gov", "senate.gov"), ]
# member offices (e.g. thune.senate.gov) shouldn't appear on this page, but guard anyway:
sen_df <- sen_df[nzchar(sen_df$text), ]
sen_df <- sen_df[!duplicated(sen_df$host), ]
message("  senate committee hosts from directory: ", nrow(sen_df))

senate_committees <- data.frame(
  host = sen_df$host,
  unit = sen_df$text,
  type = "committee",
  chamber = ifelse(grepl("joint", sen_df$text, ignore.case = TRUE), "joint", "senate"),
  party_site = "majority",   # senate minority pages usually share the host; refine later
  directory_source = "senate.gov/committees",
  stringsAsFactors = FALSE
)

## ------------------------------------------------------------------- Leadership
# Candidate list (2026, 119th Congress): House + Senate leadership and party
# conference/caucus sites. Probed; only resolving hosts are kept.
leadership_cands <- data.frame(
  host = c(
    # House leadership
    "www.speaker.gov", "www.majorityleader.gov", "www.democraticleader.gov",
    "www.republicanleader.gov", "www.majoritywhip.gov", "www.democraticwhip.gov",
    "www.republicanwhip.gov",
    # House party conferences / caucuses
    "www.gop.gov", "www.dems.gov", "housedemocrats.gov",
    # Senate floor leadership + conferences
    "www.republicanleader.senate.gov", "www.democraticleader.senate.gov",
    "www.democrats.senate.gov", "www.republicans.senate.gov",
    "www.src.senate.gov", "www.dpcc.senate.gov", "www.rpc.senate.gov",
    "www.democraticwhip.senate.gov", "www.republicanwhip.senate.gov"
  ),
  unit = c(
    "Speaker of the House", "House Majority Leader", "House Democratic Leader",
    "House Republican Leader", "House Majority Whip", "House Democratic Whip",
    "House Republican Whip",
    "House Republican Conference", "House Democratic Caucus", "House Democratic Caucus (alt)",
    "Senate Republican Leader", "Senate Democratic Leader",
    "Senate Democratic Caucus", "Senate Republican Conference",
    "Senate Republican Conference (src)", "Senate Democratic Policy & Communications Committee",
    "Senate Republican Policy Committee",
    "Senate Democratic Whip", "Senate Republican Whip"
  ),
  chamber = c(rep("house", 10), rep("senate", 9)),
  party_site = c(
    "republican", "republican", "democrat", "republican", "republican", "democrat",
    "republican", "republican", "democrat", "democrat",
    "republican", "democrat", "democrat", "republican", "republican", "democrat",
    "republican", "democrat", "republican"
  ),
  stringsAsFactors = FALSE
)
leadership_cands$type <- ifelse(grepl("Conference|Caucus|Policy", leadership_cands$unit),
                                "caucus", "leadership")
leadership_cands$directory_source <- "probe:leadership-candidates"

## --------------------------------------------------------- Probe everything once
all_hosts <- rbind(
  house_committees,
  house_minority,
  senate_committees,
  leadership_cands[, names(house_committees)]
)
all_hosts <- all_hosts[!duplicated(all_hosts$host), ]

message("Probing ", nrow(all_hosts), " hosts ...")
all_hosts$status <- NA_integer_
all_hosts$final_url <- NA_character_
for (i in seq_len(nrow(all_hosts))) {
  pr <- probe(paste0("https://", all_hosts$host[i]))
  all_hosts$status[i] <- pr$status
  all_hosts$final_url[i] <- pr$final_url
  message(sprintf("  [%3d/%3d] %-45s %s", i, nrow(all_hosts), all_hosts$host[i],
                  ifelse(is.na(pr$status), "FAIL", pr$status)))
}

write.csv(all_hosts, file.path(OUT, "hosts.csv"), row.names = FALSE)
ok <- !is.na(all_hosts$status) & all_hosts$status < 400
message("\nResolving hosts: ", sum(ok), " / ", nrow(all_hosts))
print(table(all_hosts$type[ok], all_hosts$chamber[ok]))
