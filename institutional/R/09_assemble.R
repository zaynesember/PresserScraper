# 09_assemble.R -- bind the per-host / per-feed raw RDS files into one staging
# dataset with the proposed institutional schema, plus a coverage summary.
#
# Writes institutional/data/institutional_releases.rds and prints the summary.
# Safe to run while collection is still going (it reports what exists so far).
#
# Run:  Rscript institutional/R/09_assemble.R

ROOT <- "/Users/zaynesember/GitRepos/pressR-sources"
OUT  <- file.path(ROOT, "institutional", "data")
RAW  <- file.path(OUT, "raw")

files <- list.files(RAW, pattern = "\\.rds$", full.names = TRUE)
message(length(files), " raw files")

pieces <- list()
for (f in files) {
  x <- readRDS(f)
  if (is.list(x) && isTRUE(x$error)) { message("  [error host] ", x$host); next }
  if (!is.data.frame(x) || nrow(x) == 0) next
  df <- as.data.frame(x, stringsAsFactors = FALSE)
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
all <- all[!duplicated(all$url), ]
all$date <- as.Date(all$date)

# Proposed-schema fields (party resolution for MAJ feeds happens at fold-in
# with a majority-control lookup; here we keep the raw feed branding).
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
message("\nby party_feed:")
print(table(all$party_feed, useNA = "ifany"))
message("\nby year:")
print(table(format(all$date, "%Y")))
message("\ntop 15 hosts:")
print(utils::head(sort(table(all$host), decreasing = TRUE), 15))
