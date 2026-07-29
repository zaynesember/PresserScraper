# 04_diagnose_failures.R -- per-host diagnosis of the 16 spot-test failures.
#
# For each failing host: fetch the homepage, rank press-link candidates the way
# generic_list_url does, try each as a listing, and report what list_items
# returns (count, sample dates/titles). For hosts that found a listing but had
# zero items in window, walk page 0 and show the parsed dates.
#
# Run:  Rscript institutional/R/04_diagnose_failures.R

ROOT <- "/Users/zaynesember/GitRepos/pressR-sources"
suppressMessages(devtools::load_all(ROOT, quiet = TRUE))

OUT <- file.path(ROOT, "institutional", "data")
spot <- read.csv(file.path(OUT, "spot_results.csv"), stringsAsFactors = FALSE)
fails <- spot[spot$n_90d == 0, ]

message("chromote available: ", requireNamespace("chromote", quietly = TRUE))

for (i in seq_len(nrow(fails))) {
  host <- fails$host[i]
  home <- paste0("https://", host)
  cat("\n============================================================\n")
  cat(host, " (cms:", fails$cms[i], ")\n")

  home_doc <- fetch_html(home)
  if (is.null(home_doc)) { cat("  homepage fetch FAILED\n"); next }

  href <- rvest::html_elements(home_doc, "a[href]") |> rvest::html_attr("href")
  txt  <- rvest::html_elements(home_doc, "a[href]") |> rvest::html_text() |> trimws()
  href_abs <- pressR:::abs_urls(href, home)
  press_idx <- grepl("press|news|media", href_abs, ignore.case = TRUE) |
               grepl("press|news", txt, ignore.case = TRUE)
  cands <- unique(href_abs[press_idx])
  cands <- cands[!is.na(cands)]
  cat("  press-ish nav links (up to 10):\n")
  for (u in utils::head(cands, 10)) cat("    ", u, "\n")

  # Try each candidate + the standard fallbacks as a generic listing.
  probe_paths <- unique(c(utils::head(cands, 6),
                          paste0(home, c("/press-releases", "/newsroom",
                                         "/news/press-releases", "/media/press-releases",
                                         "/public/index.cfm/press-releases",
                                         "/press/releases"))))
  for (u in probe_paths) {
    doc <- fetch_html(u)
    if (is.null(doc)) { cat("    [dead] ", u, "\n"); next }
    items <- tryCatch(pressR:::generic_list_items(doc, paste0(u, "PAGER")),
                      error = function(e) NULL)
    n <- if (is.null(items)) 0 else nrow(items)
    cat(sprintf("    [%3d items] %s\n", n, u))
    if (n > 0) {
      shown <- utils::head(items, 3)
      for (j in seq_len(nrow(shown))) {
        cat(sprintf("        %s | %s | %s\n", shown$date[j],
                    substr(shown$title[j], 1, 60), substr(shown$url[j], 1, 80)))
      }
      break
    }
  }
}
