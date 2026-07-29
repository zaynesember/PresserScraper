#!/usr/bin/env Rscript
# Regenerate the "What's in the archive" block in README.md from the on-disk
# published archive (the package's year-partitioned RDS files). Rewrites the
# text between the archive-stats markers in place; run after any archive update:
#   Rscript tools/update_readme_stats.R
# Reads the archive files directly (never the analysis DuckDB, which may be
# locked by a writer), one year at a time to keep memory flat.
suppressMessages(devtools::load_all("/Users/zaynesember/GitRepos/pressR"))
README <- "/Users/zaynesember/GitRepos/pressR/README.md"

files <- pressR:::archive_files(pressR:::archive_dir())
stopifnot(length(files) > 0)
n <- 0L; members <- character(0); dmin <- as.Date(NA); dmax <- as.Date(NA)
for (f in files) {
  d <- readRDS(f)
  n <- n + nrow(d)
  members <- unique(c(members, paste(d$name, d$chamber, sep = "\r")))
  dd <- suppressWarnings(as.Date(d$date))
  dmin <- min(c(dmin, dd), na.rm = TRUE); dmax <- max(c(dmax, dd), na.rm = TRUE)
  rm(d); gc(FALSE)
}
ch <- sub("^.*\r", "", members)
block <- c(
  "## What's in the archive",
  "",
  sprintf(paste0("The published archive currently holds **%s press releases** from **%d members**",
                 " (%d House, %d Senate), spanning **%s &ndash; %s** (as of %s)."),
          format(n, big.mark = ","), length(unique(sub("\r.*$", "", members))),
          sum(ch == "house"), sum(ch == "senate"),
          format(dmin, "%B %Y"), format(dmax, "%B %Y"), format(Sys.Date(), "%Y-%m-%d")),
  "",
  "<sub>Auto-generated &mdash; regenerate with `Rscript tools/update_readme_stats.R`</sub>")

txt <- readLines(README, warn = FALSE)
i0 <- grep("^<!-- archive-stats:start -->$", txt)
i1 <- grep("^<!-- archive-stats:end -->$", txt)
stopifnot(length(i0) == 1, length(i1) == 1, i0 < i1)
txt <- c(txt[1:i0], block, txt[i1:length(txt)])
writeLines(txt, README)
cat(sprintf("README stats updated: %s releases | %d members (%d house, %d senate) | %s - %s\n",
            format(n, big.mark = ","), length(unique(sub("\r.*$", "", members))),
            sum(ch == "house"), sum(ch == "senate"), format(dmin, "%Y-%m"), format(dmax, "%Y-%m")))
