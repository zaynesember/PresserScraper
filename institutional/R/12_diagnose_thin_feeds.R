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

# --sweep: rank every collected feed by how suspicious its haul looks, so the
# next round of thin feeds is found by one command instead of by noticing a log
# line. Flags are heuristics, not verdicts -- diagnose a flagged feed before
# changing its config.
if ("--sweep" %in% args) {
  RAW <- file.path(ROOT, "institutional", "data", "raw")
  files <- list.files(RAW, pattern = "\\.rds$", full.names = TRUE)
  d <- do.call(rbind, lapply(files, function(f) {
    x <- tryCatch(readRDS(f), error = function(e) NULL)
    if (!is.data.frame(x) || !nrow(x)) {
      return(data.frame(file = basename(f), n = 0L, bodies = 0L, dmin = NA,
                        dmax = NA, yrs = NA, per_yr = NA, stringsAsFactors = FALSE))
    }
    b <- if ("body" %in% names(x)) x$body else rep(NA_character_, nrow(x))
    dn <- suppressWarnings(min(x$date, na.rm = TRUE))
    dx <- suppressWarnings(max(x$date, na.rm = TRUE))
    yrs <- max(0.1, as.numeric(dx - dn) / 365.25)
    data.frame(file = basename(f), n = nrow(x),
               bodies = sum(!is.na(b) & nchar(b) > 200),
               dmin = as.character(dn), dmax = as.character(dx),
               yrs = round(yrs, 1), per_yr = round(nrow(x) / yrs, 1),
               stringsAsFactors = FALSE)
  }))
  d$body_pct <- round(100 * d$bodies / pmax(d$n, 1), 1)

  # A thin Tier-1 host file is usually *expected*: round 2 exists precisely
  # because the stock extractor could only see one listing page on those hosts,
  # and the curated feed for the same host now carries the real haul (the rows
  # dedupe on URL at assembly). Only a thin *feed* is a genuine failure, so
  # separate the two or the real signal drowns in 15 rows of noise.
  d$kind <- ifelse(grepl("^feed_", d$file), "feed", "tier1")
  feed_hosts <- unique(sub("#.*$", "", sub("^feed_", "", d$file[d$kind == "feed"])))
  bare <- sub("\\.rds$", "", sub("^www\\.", "", d$file))
  d$covered <- d$kind == "tier1" & bare %in% feed_hosts

  # A committee feed walked over full history should clear a few dozen rows and
  # span years. Very few rows, a span of months, or no bodies all mean "look".
  d$flag <- ifelse(d$n == 0, "EMPTY",
            ifelse(d$n < 25, "THIN",
            ifelse(d$yrs < 1.5, "SHORT-SPAN",
            ifelse(d$body_pct < 50, "NO-BODIES", ""))))
  d$flag[d$covered & d$flag %in% c("THIN", "SHORT-SPAN", "EMPTY")] <- "superseded"
  sus <- d[d$flag != "", ]
  sus <- sus[order(match(sus$flag, c("EMPTY", "THIN", "SHORT-SPAN", "NO-BODIES",
                                     "superseded")), sus$n), ]
  n_real <- sum(sus$flag != "superseded")
  cat("== ", nrow(d), " outputs; ", n_real, " need attention, ",
      sum(sus$flag == "superseded"), " superseded Tier-1 (expected) ==\n", sep = "")
  cat(sprintf("%-46s %-10s %6s %6s %11s %11s %6s\n",
              "output", "flag", "rows", "body%", "from", "to", "yrs"))
  for (i in seq_len(nrow(sus))) {
    s <- sus[i, ]
    nm <- sub("\\.rds$", "", sub("^feed_", "", s$file))
    if (nchar(nm) > 46) nm <- paste0(substr(nm, 1, 43), "...")
    cat(sprintf("%-46s %-10s %6d %6.1f %11s %11s %6.1f\n",
                nm, s$flag, s$n, s$body_pct,
                ifelse(is.na(s$dmin), "-", s$dmin), ifelse(is.na(s$dmax), "-", s$dmax),
                ifelse(is.na(s$yrs), 0, s$yrs)))
  }
  cat("\ntotal rows: ", sum(d$n), "   bodies: ", sum(d$bodies),
      sprintf(" (%.1f%%)", 100 * sum(d$bodies) / sum(d$n)), "\n", sep = "")
  cat("\nDiagnose a flagged feed with:  Rscript institutional/R/12_diagnose_thin_feeds.R <feed_id>\n")
  quit(save = "no")
}

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
