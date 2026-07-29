# 10_qa_thin_hosts.R -- QA the Tier-1 collection: flag hosts whose full-history
# haul looks like a single listing page (pagination never engaged) or whose
# archive starts implausibly late, then probe each flagged host's nav for
# party-tagged feed listings and the dominant item-link prefix on each.
#
# Prints a curation-ready digest; feeds get hand-added to 06_feed_configs.R.
#
# Run:  Rscript institutional/R/10_qa_thin_hosts.R

ROOT <- "/Users/zaynesember/GitRepos/pressR-sources"
suppressMessages(devtools::load_all(ROOT, quiet = TRUE))

OUT <- file.path(ROOT, "institutional", "data")
RAW <- file.path(OUT, "raw")
spot <- read.csv(file.path(OUT, "spot_results.csv"), stringsAsFactors = FALSE)

files <- list.files(RAW, pattern = "^[^f].*\\.rds$", full.names = TRUE)  # tier-1 only
summ <- do.call(rbind, lapply(files, function(f) {
  x <- readRDS(f)
  if (is.list(x) && isTRUE(x$error)) {
    return(data.frame(host = x$host, n = 0L, dmin = NA, dmax = NA))
  }
  data.frame(host = x$host[1], n = nrow(x),
             dmin = as.character(min(x$date)), dmax = as.character(max(x$date)))
}))
summ <- merge(summ, spot[, c("host", "n_90d", "cms", "type", "chamber")], by = "host")

# Thin = full history barely exceeds the 90-day window haul, or starts recently.
summ$years <- pmax(1, as.numeric(as.Date(summ$dmax) - as.Date(summ$dmin)) / 365)
summ$thin <- summ$n < pmax(3 * summ$n_90d, 60) | (summ$n / summ$years) < 0.5 * (summ$n_90d * 4)
summ <- summ[order(-summ$thin, summ$n), ]
cat("== Tier-1 per-host summary (thin first) ==\n")
print(summ[, c("host", "cms", "n", "n_90d", "dmin", "dmax", "thin")], row.names = FALSE)

thin <- summ$host[summ$thin]
cat("\n", length(thin), "thin hosts\n")

# For each thin host: nav feed candidates + dominant item prefix per candidate.
dominant_prefix <- function(listing) {
  doc <- get_html(listing)
  if (is.null(doc)) return(NULL)
  a <- rvest::html_elements(doc, "a[href]")
  href <- abs_urls(rvest::html_attr(a, "href"), listing)
  txt <- trimws(gsub("\\s+", " ", rvest::html_text(a)))
  lab <- rvest::html_attr(a, "aria-label")
  txt <- ifelse(nchar(txt) < 25 & !is.na(lab), lab, txt)
  keep <- !is.na(href) & nchar(txt) >= 25 & grepl(url_origin(listing), href, fixed = TRUE)
  href <- href[keep]
  if (length(href) < 3) return(NULL)
  # prefix = everything up to the last path segment / query
  pre <- ifelse(grepl("\\?", href), sub("\\?.*$", "?", href), sub("/[^/]+/?$", "/", href))
  tab <- sort(table(pre), decreasing = TRUE)
  data.frame(prefix = names(tab)[1:min(3, length(tab))],
             count = as.integer(tab)[1:min(3, length(tab))])
}

for (h in thin) {
  cat("\n==============================", h, "\n")
  doc <- fetch_html(paste0("https://", h))
  if (is.null(doc)) { cat("  homepage unreachable\n"); next }
  href <- abs_urls(rvest::html_attr(rvest::html_elements(doc, "a[href]"), "href"),
                   paste0("https://", h))
  txt <- trimws(rvest::html_text(rvest::html_elements(doc, "a[href]")))
  partyish <- grepl("majority|minority|republican|democrat|chair|ranking|rep-|dem-|/rep/|/dem/",
                    paste(href, txt), ignore.case = TRUE)
  pressish <- grepl("press|news|media|release", paste(href, txt), ignore.case = TRUE)
  cands <- unique(href[partyish & pressish & !is.na(href)])
  cands <- cands[!grepl("\\?id=|/20[0-9][0-9]/|contact", cands, ignore.case = TRUE)]
  if (length(cands) == 0) {
    # fall back to plain press listings
    cands <- unique(href[pressish & !is.na(href)])
    cands <- utils::head(cands[!grepl("\\?id=|contact|#", cands, ignore.case = TRUE)], 4)
  }
  for (u in utils::head(cands, 6)) {
    cat("  feed candidate:", u, "\n")
    dp <- dominant_prefix(u)
    if (!is.null(dp)) for (j in seq_len(nrow(dp))) {
      cat(sprintf("      items %3d x %s\n", dp$count[j], dp$prefix[j]))
    }
  }
}
