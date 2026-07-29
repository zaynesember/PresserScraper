# 09_assemble.R -- bind the per-host / per-feed raw RDS files into one staging
# dataset with the proposed institutional schema, plus a coverage summary.
#
# Writes institutional/data/institutional_releases.rds and prints the summary.
# Safe to run while collection is still going (it reports what exists so far).
#
# Run:  Rscript institutional/R/09_assemble.R

ROOT <- "/Users/zaynesember/GitRepos/pressR"   # consolidated onto the `corpus` branch (was the pressR-sources worktree)
OUT  <- file.path(ROOT, "institutional", "data")
RAW  <- file.path(OUT, "raw")
source(file.path(ROOT, "institutional", "R", "lib_party.R"))   # chamber_majority()

files <- list.files(RAW, pattern = "\\.rds$", full.names = TRUE)
# Feed files first: they carry explicit party attribution, so when a release
# was also swept up by a Tier-1 host walk the feed row wins the URL dedupe.
files <- files[order(!grepl("/feed_", files))]
# Mirror hosts serve identical content under two domains; keep the canonical one.
mirrors <- c("www.republicanleader.gov", "www.republicanwhip.gov", "www.src.senate.gov",
             "republicans-cha.house.gov", "www.democraticleader.senate.gov",
             "www.dpcc.senate.gov")
message(length(files), " raw files")

pieces <- list()
for (f in files) {
  x <- readRDS(f)
  if (is.list(x) && isTRUE(x$error)) { message("  [error host] ", x$host); next }
  if (!is.data.frame(x) || nrow(x) == 0) next
  df <- as.data.frame(x, stringsAsFactors = FALSE)
  if (df$host[1] %in% mirrors) { message("  [mirror skipped] ", df$host[1]); next }
  # Tier-1 files carry party_site; Tier-2 files carry party_feed + listing.
  if (is.null(df$party_feed)) {
    df$party_feed <- switch(df$party_site[1],
      democrat = "D", republican = "R", majority = "MAJ", NA_character_)
  }
  if (is.null(df$listing)) df$listing <- NA_character_
  keep <- c("date", "title", "body", "tags", "url", "cms", "host", "unit",
            "type", "chamber", "party_feed", "listing")
  for (k in setdiff(keep, names(df))) df[[k]] <- NA_character_
  pieces[[f]] <- df[, keep]
}

all <- do.call(rbind, pieces)
rownames(all) <- NULL

# Resolve party BEFORE the URL dedupe.
#
# Some committees list one release under several party-branded feeds: an Aging
# or Small Business release can appear in the majority, minority *and* joint
# listings at the same permalink. Deduping on URL alone kept whichever row came
# first, and because `files` is sorted alphabetically that meant the "#d#" feed
# won every time -- all 101 conflicting URLs in the collection so far were
# silently stamped "D". That is a filename artifact, not evidence about the
# release, and it lands in exactly the column partisan analyses key on.
#
# A release carried by feeds of differing party branding belongs to neither, so
# attribute it to NP. Only non-NA labels count as disagreement: a Tier-1 host
# row contributes party NA, and there the feed row's real label should win the
# dedupe (feed files are ordered first for that reason), not be washed out.
n_party <- tapply(all$party_feed, all$url,
                  function(p) length(unique(p[!is.na(p)])))
conflict <- names(n_party)[n_party > 1]
all$multi_feed <- all$url %in% conflict
if (length(conflict)) {
  was <- table(all$party_feed[all$multi_feed])
  all$party_feed[all$multi_feed] <- "NP"
  message("  [party conflict] ", length(conflict),
          " urls listed under feeds of differing party -> NP (was: ",
          paste(sprintf("%s=%d", names(was), as.integer(was)), collapse = " "), ")")
}

all <- all[!duplicated(all$url), ]
all$date <- as.Date(all$date)

# Proposed-schema fields. `party_feed` stays as collected -- it is the audit
# trail for the attribution -- and `party` is the resolved column analyses use.
#
# Majority-branded feeds (party_feed "MAJ") carry no party of their own: the bare
# House committee host is whichever party holds the chamber, and it swaps when
# control flips. Resolve them from the chamber majority ON THE RELEASE DATE.
# Roughly 44% of these rows are MAJ, so skipping this leaves nearly half the
# institutional corpus with no usable party.
all$party <- all$party_feed
maj <- !is.na(all$party_feed) & all$party_feed == "MAJ"
all$party[maj] <- chamber_majority(all$date[maj], all$chamber[maj])
all$party[!is.na(all$party) & all$party == "NP"] <- NA_character_
if (any(maj)) {
  res <- table(all$party[maj], useNA = "ifany")
  message("  [MAJ resolved] ", sum(maj), " majority-branded rows -> ",
          paste(sprintf("%s=%d", names(res), as.integer(res)), collapse = " "))
}

all$source <- all$type
all$name <- ifelse(all$type == "committee",
                   paste(ifelse(all$chamber == "senate", "Senate Committee on",
                          ifelse(all$chamber == "house", "House Committee on", "Joint Committee on")),
                         all$unit),
                   all$unit)

saveRDS(all, file.path(OUT, "institutional_releases.rds"))

message("\n== TOTALS ==")
message("releases: ", nrow(all), "   hosts: ", length(unique(all$host)),
        "   date range: ", min(all$date, na.rm = TRUE), " .. ", max(all$date, na.rm = TRUE))
message("with body: ", sum(!is.na(all$body) & nzchar(all$body)),
        sprintf(" (%.1f%%)", 100 * mean(!is.na(all$body) & nzchar(all$body))))
message("\nby type x chamber:")
print(table(all$type, all$chamber))
message("\nby party_feed (raw feed branding, audit trail):")
print(table(all$party_feed, useNA = "ifany"))
message("\nby party (resolved -- what analyses key on):")
print(table(all$party, useNA = "ifany"))
message("\nby year:")
print(table(format(all$date, "%Y")))
message("\ntop 15 hosts:")
print(utils::head(sort(table(all$host), decreasing = TRUE), 15))
