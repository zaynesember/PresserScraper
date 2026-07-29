# 02_classify_cms.R -- clean the enumerated host list and classify each host's CMS.
#
# Reads institutional/data/hosts.csv (from 01), drops senator member sites that
# the senate.gov committee directory links (chair/ranking-member contact links),
# fixes joint/caucus classifications, then runs pressR::detect_cms() over every
# resolving host. Writes institutional/data/hosts_clean.csv.
#
# Run:  Rscript institutional/R/02_classify_cms.R

ROOT <- "/Users/zaynesember/GitRepos/pressR-sources"
suppressMessages(devtools::load_all(ROOT, quiet = TRUE))

OUT <- file.path(ROOT, "institutional", "data")
hosts <- read.csv(file.path(OUT, "hosts.csv"), stringsAsFactors = FALSE)

## ------------------------------------------------------------------ cleanup
# Senator member sites carry "(R-ME)"-style unit text from the directory page.
member_row <- grepl("\\([DRI]+-[A-Z]{2}\\)", hosts$unit)
message("Dropping ", sum(member_row), " senator member sites from the committee directory.")
hosts <- hosts[!member_row, ]

# Non-resolving hosts are recorded but excluded from classification.
hosts$resolves <- !is.na(hosts$status) & hosts$status < 400

# Joint committees and senate caucuses mislabeled by the directory sweep.
joint_units <- grepl("^Joint|Joint Economic|Joint Committee", hosts$unit, ignore.case = TRUE)
hosts$chamber[joint_units] <- "joint"
hosts$type[grepl("drugcaucus", hosts$host)] <- "caucus"
hosts$unit[grepl("drugcaucus", hosts$host)] <- "Caucus on International Narcotics Control"

# Normalize unit text (the directory page embeds newlines in multi-word names).
hosts$unit <- gsub("[[:space:]]+", " ", hosts$unit)

## ------------------------------------------------------------- CMS detection
message("Classifying CMS for ", sum(hosts$resolves), " hosts ...")
hosts$cms <- NA_character_
for (i in seq_len(nrow(hosts))) {
  if (!hosts$resolves[i]) next
  url <- paste0("https://", hosts$host[i])
  doc <- fetch_html(url)
  hosts$cms[i] <- if (is.null(doc)) "unknown" else detect_cms(doc = doc)
  message(sprintf("  [%3d/%3d] %-45s %s", i, nrow(hosts), hosts$host[i], hosts$cms[i]))
}

write.csv(hosts, file.path(OUT, "hosts_clean.csv"), row.names = FALSE)
message("\nCMS mix by type:")
print(table(hosts$cms, hosts$type, useNA = "ifany"))
message("\nCMS mix by chamber:")
print(table(hosts$cms, hosts$chamber, useNA = "ifany"))
