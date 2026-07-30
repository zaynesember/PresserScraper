#!/usr/bin/env Rscript
# 01_discover.R -- build the units table from webharvest.gov's collection
# indexes: 10 congresses x 2 chambers x 4 categories = 80 static pages, all
# robots-ALLOWED (the Disallow covers only replay paths). Entry format on every
# page: <h3>Name</h3> followed by one <a> whose href is the replay link and
# whose text is the original URL.
#
# Output: nara/data/units.rds
#   congress, chamber, category, name, original (stripped URL), host,
#   replay_href (as published -- token form varies by vintage, do not parse it)
#
# Idempotent + cheap to rerun: every index page is cached, so only the first
# run pays the ~14 min of network.
#
# Run:  Rscript nara/R/01_discover.R

ROOT <- "/Users/zaynesember/GitRepos/pressR"
suppressMessages(devtools::load_all(ROOT, quiet = TRUE))
source(file.path(ROOT, "nara", "R", "lib_nara.R"))

CATS <- c("members_alpha", "leadership", "committees", "organizations")

rows <- list()
for (congress in 109:118) {
  for (chamber in c("house", "senate")) {
    for (cat in CATS) {
      url <- sprintf("%s/collections/congress%dth/%s_%s.html",
                     NARA_HOST, congress, chamber, cat)
      cf  <- file.path(NARA_PAGE_CACHE,
                       sprintf("index_c%d_%s_%s.html", congress, chamber, cat))
      r <- nara_fetch(url, cf)
      if (r$status != 200L || is.na(r$html)) {
        message(sprintf("  MISSING index c%d %s %s (status %s)",
                        congress, chamber, cat, r$status))
        next
      }
      doc <- nara_read(r$html)
      if (is.null(doc)) next
      h3s <- rvest::html_elements(doc, "h3")
      for (h in h3s) {
        a <- xml2::xml_find_first(h, "following-sibling::a[1]")
        if (inherits(a, "xml_missing") || is.na(xml2::xml_attr(a, "href"))) next
        href <- xml2::xml_attr(a, "href")
        if (!grepl("/congress[0-9]+th/", href)) next   # nav links, not entries
        orig <- nara_strip(href)
        rows[[length(rows) + 1]] <- data.frame(
          congress = congress, chamber = chamber, category = cat,
          name = trimws(xml2::xml_text(h)),
          original = orig,
          host = sub("^https?://", "", sub("^(https?://[^/]+).*$", "\\1", orig)),
          replay_href = href, stringsAsFactors = FALSE)
      }
      message(sprintf("  c%d %s %-13s %4d entries%s", congress, chamber, cat,
                      length(h3s), if (r$from_cache) "  (cache)" else ""))
    }
  }
}

units <- do.call(rbind, rows)
dir.create(NARA_OUT, showWarnings = FALSE, recursive = TRUE)
saveRDS(units, file.path(NARA_OUT, "units.rds"))

cat(sprintf("\n%d unit entries -> nara/data/units.rds\n", nrow(units)))
print(table(units$congress, units$chamber))
cat(sprintf("requests this run: %d\n", nara_requests_made()))
