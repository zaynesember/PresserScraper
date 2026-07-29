# 12_diagnose_thin_feeds.R -- diagnose feeds whose collected output is empty or
# implausibly thin.
#
# Why this exists: the collectors write an RDS even when a walk returns nothing,
# and both collectors skip a feed whose output already exists. So a *failed*
# walk is indistinguishable from a genuinely empty feed and is never retried.
# This script re-probes a feed's listing and reports where the walk dies:
#
#   listing unreachable  -> the listing URL is wrong (moved/404)
#   0 anchors match      -> item_re is wrong (item permalinks changed path)
#   pager mode "none"    -> pagination never engaged; haul is one listing page
#   matches but 0 bodies -> item pages fetch/extract fails
#
# It prints the dominant href prefixes on the listing, which is what you need to
# rewrite a stale item_re. Read-only: it never touches data/raw.
#
# Run:  Rscript institutional/R/12_diagnose_thin_feeds.R [feed_id ...]
#       (no args = the built-in list of known-thin feeds)

ROOT <- "/Users/zaynesember/GitRepos/pressR"
suppressMessages(devtools::load_all(ROOT, quiet = TRUE))
source(file.path(ROOT, "institutional", "R", "lib_institutional.R"))

R_DIR <- file.path(ROOT, "institutional", "R")
load_cfg <- function(fn) {
  e <- new.env(); sys.source(file.path(R_DIR, fn), envir = e)
  d <- e$feed_configs(); d$cfgfile <- fn; d
}
cfg <- rbind(load_cfg("06_feed_configs.R"), load_cfg("11_feed_configs2.R"))

args <- commandArgs(trailingOnly = TRUE)
targets <- if (length(args)) args else c(
  "ethics.house.gov#np#press-releases",        # 0 rows
  "rules.senate.gov#d#minority-news",          # 0 rows
  "drugcaucus.senate.gov#np#press-releases",   # 6 rows, 0 bodies
  "rules.senate.gov#r#majority-news",          # 12 rows over 13 years
  "ethics.senate.gov#np#pressreleases",        # 16 rows, 2 bodies
  "aging.senate.gov#r#majority",               # tail stops 2016-04
  "aging.senate.gov#d#minority",
  "aging.senate.gov#np#joint"
)

# Every same-origin anchor with a plausible title, grouped by path prefix. This
# is the ground truth for what the listing actually links to.
listing_anatomy <- function(doc, base) {
  a <- rvest::html_elements(doc, "a[href]")
  href <- abs_urls(rvest::html_attr(a, "href"), base)
  txt <- trimws(gsub("\\s+", " ", rvest::html_text(a)))
  lab <- rvest::html_attr(a, "aria-label")
  txt <- ifelse(nchar(txt) < 25 & !is.na(lab), lab, txt)
  keep <- !is.na(href) & grepl(url_origin(base), href, fixed = TRUE)
  data.frame(href = href[keep], txt = txt[keep], stringsAsFactors = FALSE)
}

for (t in targets) {
  f <- cfg[cfg$feed_id == t, ]
  cat("\n\n================================================================\n")
  if (!nrow(f)) { cat("!! no config for ", t, "\n", sep = ""); next }
  f <- f[1, ]
  cat(t, "  [", f$cfgfile, "]\n", sep = "")
  cat("  listing : ", f$listing, "\n", sep = "")
  cat("  item_re : ", f$item_re, "\n", sep = "")
  cat("  engine  : ", f$engine, "\n", sep = "")

  doc <- get_html(f$listing)
  if (is.null(doc)) {
    cat("  VERDICT : LISTING UNREACHABLE -- the listing URL is dead.\n")
    next
  }
  cat("  listing fetched ok (", nchar(as.character(doc)), " chars)\n", sep = "")

  an <- listing_anatomy(doc, f$listing)
  cat("  same-origin anchors: ", nrow(an), "\n", sep = "")

  hit <- grepl(f$item_re, an$href)
  cat("  anchors matching item_re: ", sum(hit), "\n", sep = "")

  # What the walker itself extracts from page 0 (no item fetches -- fast).
  it <- insti_feed_items(doc, f$listing, f$item_re, date_from_item = FALSE)
  cat("  walker items on page 0: ", nrow(it), "\n", sep = "")

  if (sum(hit) == 0) {
    cat("  VERDICT : ITEM_RE MATCHES NOTHING. Dominant prefixes on the listing:\n")
    pre <- sub("/[^/]+/?$", "/", sub("\\?.*$", "?", an$href))
    tab <- sort(table(pre), decreasing = TRUE)
    for (i in seq_len(min(8, length(tab))))
      cat(sprintf("            %5d  %s\n", as.integer(tab)[i], names(tab)[i]))
    cat("  sample titled anchors:\n")
    s <- an[nchar(an$txt) >= 25, ]
    for (i in seq_len(min(6, nrow(s))))
      cat("            ", substr(s$txt[i], 1, 60), " -> ", s$href[i], "\n", sep = "")
    next
  }

  cat("  sample matched:\n")
  for (i in seq_len(min(4, nrow(it))))
    cat("            ", as.character(it$date[i]), "  ", substr(it$title[i], 1, 55), "\n", sep = "")

  pager <- insti_detect_pager(f$listing, doc, f$item_re)
  cat("  pager detected: ", pager$mode, " ", pager$param %||% "", "\n", sep = "")
  if (identical(pager$mode, "none"))
    cat("  VERDICT : PAGINATION NEVER ENGAGED -- haul is capped at one listing page.\n")

  # Body extraction on one item: distinguishes walk failure from body failure.
  # tryCatch because an item page is exactly where a walk-killing error surfaces
  # (a non-ISO <time datetime> used to throw here) -- we want it reported per
  # feed, not aborting the sweep.
  if (nrow(it) > 0) {
    cat("  body probe on ", it$url[1], "\n", sep = "")
    got <- tryCatch(insti_item_fetch(it$url[1]),
                    error = function(e) { cat("  VERDICT : ITEM FETCH THROWS -- ",
                                              conditionMessage(e), "\n", sep = ""); NULL })
    if (!is.null(got)) {
      # A failed body extraction comes back NA, and nchar(NA_character_) is NA,
      # not 0 -- so normalise before comparing.
      nb <- got$body
      nb <- if (is.null(nb) || length(nb) == 0 || is.na(nb)) 0L else nchar(nb)
      cat("            item-page date: ", as.character(got$date %||% NA), "\n", sep = "")
      cat("            body chars: ", nb, if (identical(nb, 0L)) " (NA/empty)" else "", "\n", sep = "")
      if (nb < 200)
        cat("  VERDICT : BODY EXTRACTION FAILS on item pages.\n")
    }
  }
}
cat("\n")
