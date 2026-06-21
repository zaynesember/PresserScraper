# Parse two external congressional press-release datasets into the archive schema
# (plus a `source` provenance column) so they can be folded into the DuckDB store
# and re-run through the NLP layers. Both predate/overlap the scraped 2010-2026
# corpus and extend history back to ~2005.
#   - Stout: 114th-117th master CSV (House-only). Source lineage: Garcia, Stout &
#     Tate (2025), "Black Voices in the Halls of Power", Cambridge UP.
#   - Wang & Tucker (2020), American Politics Research: per-member Press.txt
#     (109th-115th, both chambers). doi:10.1177/1532673X20939498.
#
# Output schema (matches the scraped archive + `source`):
#   date,title,body,tags,url,cms,name,state,district,party,committee,chamber,source
# tags=NA, committee=NA, cms="external", url synthetic+unique, source in
# {stout, wangtucker}. Names are formatted "Last, First" to match the scraped
# convention; Stout names come from the Voteview roster, W&T from the dir slug.
suppressMessages({ library(data.table); library(stringi) })

SCHEMA_COLS <- c("date","title","body","tags","url","cms","name","state",
                 "district","party","committee","chamber","source")

# Drop invalid bytes, collapse whitespace (the Stout CSV has stray non-UTF8 bytes).
nlp_scrub_text <- function(x) {
  x <- ifelse(is.na(x), "", x)
  x <- iconv(x, from = "UTF-8", to = "UTF-8", sub = " ")
  x <- stri_replace_all_regex(x, "\\s+", " ")
  stri_trim_both(x)
}

# Title-case, capitalizing the first letter after a start, space, or hyphen
# (so "diaz-balart" -> "Diaz-Balart", "mike dennis" -> "Mike Dennis").
.cap1 <- function(s) {
  s <- tolower(stri_trim_both(s))
  gsub("(^|[ -])([a-z])", "\\1\\U\\2", s, perl = TRUE)
}
# "ROGERS, Mike Dennis" -> "Rogers, Mike Dennis"
nlp_titlecase_bioname <- function(bn) {
  parts <- strsplit(bn, ",", fixed = TRUE)[[1]]
  if (length(parts) >= 2)
    paste0(.cap1(parts[1]), ", ", .cap1(paste(parts[-1], collapse = ",")))
  else .cap1(bn)
}

# Voteview HSall_members.csv -> named map "congress state district" -> "Last, First"
nlp_voteview_namemap <- function(csv_path) {
  v <- fread(csv_path, select = c("congress","chamber","state_abbrev",
                                   "district_code","bioname"), showProgress = FALSE)
  v <- v[chamber == "House"]
  v <- v[!duplicated(paste(congress, state_abbrev, district_code))]
  nm <- vapply(v$bioname, nlp_titlecase_bioname, character(1), USE.NAMES = FALSE)
  setNames(nm, paste(v$congress, v$state_abbrev, v$district_code))
}

# ---- STOUT (114-117 master CSV, House) ---------------------------------------
nlp_parse_stout <- function(csv_path, namemap, nrows = Inf) {
  d <- fread(csv_path, showProgress = FALSE, nrows = nrows,
             select = c("state","district","title","day","month","year",
                        "democrat","congress","pressrelease"),
             colClasses = list(character = c("state","district")))
  d[, row := .I]
  d[, url := sprintf("stout:%06d", row)]
  # coerce numerics; corrupt CSV rows become NA and are dropped below
  num <- function(x) suppressWarnings(as.integer(round(as.numeric(x))))
  d[, `:=`(yr = num(year), mo = num(month), dy = num(day),
           dist = suppressWarnings(as.integer(district)),
           cong = num(congress), dem = num(democrat))]
  d[, title := nlp_scrub_text(title)]
  d[, body  := nlp_scrub_text(pressrelease)]
  ok <- d[, !is.na(yr) & yr >= 2014 & yr <= 2024 &
            nchar(state) == 2L & state == toupper(state) &
            !is.na(dist) & dist >= 0L &
            dem %in% c(0L, 1L) & nzchar(body)]
  d <- d[ok]
  # date: swap month/day if month looks like a day; fall back to day=1 on overflow
  swap <- !is.na(d$mo) & !is.na(d$dy) & d$mo > 12 & d$dy >= 1 & d$dy <= 12
  mm <- ifelse(swap, d$dy, d$mo); dd <- ifelse(swap, d$mo, d$dy)
  mm <- ifelse(is.na(mm) | mm < 1 | mm > 12, 1L, mm)
  dd <- ifelse(is.na(dd) | dd < 1 | dd > 31, 1L, dd)
  dt <- as.Date(sprintf("%04d-%02d-%02d", d$yr, mm, dd))
  bad <- is.na(dt)
  dt[bad] <- as.Date(sprintf("%04d-%02d-01", d$yr[bad], mm[bad]))
  key <- paste(d$cong, d$state, d$dist)
  nm  <- unname(namemap[key])
  nm[is.na(nm)] <- paste0(d$state[is.na(nm)], "-", d$dist[is.na(nm)])  # DC delegate etc.
  data.table(
    date = dt, title = d$title, body = d$body, tags = NA_character_,
    url = d$url, cms = "external", name = nm, state = d$state,
    district = d$dist, party = ifelse(d$dem == 1L, "D", "R"),
    committee = NA_character_, chamber = "house", source = "stout")
}

# ---- WANG & TUCKER (per-member Press.txt, both chambers) ----------------------
.wt_name_from_slug <- function(slug) {
  parts <- strsplit(slug, "_", fixed = TRUE)[[1]]
  first <- .cap1(parts[1])
  last  <- .cap1(paste(parts[-1], collapse = " "))
  paste0(last, ", ", first)
}
.wt_parse_date <- function(date1) {
  p <- strsplit(date1, ".", fixed = TRUE)
  out <- as.Date(rep(NA, length(p)))
  for (i in seq_along(p)) {
    z <- suppressWarnings(as.integer(p[[i]]))
    if (length(z) != 3 || anyNA(z)) next
    m <- z[1]; dd <- z[2]; y <- z[3]
    if (y < 100) y <- if (y < 50) 2000L + y else 1900L + y
    if (m < 1 || m > 12 || dd < 1 || dd > 31 || y < 2004 || y > 2025) next
    d <- as.Date(sprintf("%04d-%02d-%02d", y, m, dd))
    if (is.na(d)) d <- as.Date(sprintf("%04d-%02d-01", y, m))
    out[i] <- d
  }
  out
}
nlp_parse_wt <- function(base_dir, max_dirs = Inf) {
  dirs <- list.dirs(base_dir, recursive = FALSE)
  if (is.finite(max_dirs)) dirs <- head(dirs, max_dirs)
  out <- vector("list", length(dirs))
  for (i in seq_along(dirs)) {
    dd <- dirs[i]
    f <- list.files(dd, pattern = "Press[.]txt$", full.names = TRUE)
    if (!length(f)) next
    slug <- basename(dd)
    L <- readLines(f[1], warn = FALSE)
    L <- iconv(L, from = "UTF-8", to = "UTF-8", sub = " ")   # drop bad bytes, KEEP tabs
    L <- L[!is.na(L) & nzchar(trimws(L))]
    if (!length(L)) next
    tab   <- regexpr("\t", L, fixed = TRUE)                  # split on the tab FIRST
    date1 <- trimws(ifelse(tab > 0, substr(L, 1L, tab - 1L), NA_character_))
    rest  <- ifelse(tab > 0, substr(L, tab + 1L, nchar(L)), L)
    # strip the leading repeated MM.DD.YY[YY] token from the text after the tab
    rest  <- stri_replace_first_regex(rest, "^[0-9]{1,2}[.][0-9]{1,2}[.][0-9]{2,4}\\s+", "")
    body  <- nlp_scrub_text(rest)                            # collapse whitespace AFTER split
    dt   <- .wt_parse_date(date1)
    keep <- !is.na(dt) & nzchar(body)
    if (!any(keep)) next
    body <- body[keep]; dt <- dt[keep]; Lk <- L[keep]
    # title = first ~14 words of the (title+body) text
    title <- vapply(strsplit(substr(body, 1, 300), " ", fixed = TRUE),
                    function(w) paste(head(w[nzchar(w)], 14), collapse = " "), character(1))
    # member-level party/state from inline "(D-CA)" tokens (modal)
    ps <- regmatches(Lk, regexpr("\\(([DRI])-([A-Z]{2})\\)", Lk))
    party <- NA_character_; st <- NA_character_
    if (length(ps)) {
      tab_ps <- sort(table(ps), decreasing = TRUE)
      top <- names(tab_ps)[1]                              # e.g. "(D-CA)"
      party <- substr(top, 2, 2); st <- substr(top, 4, 5)
    }
    # chamber from honorific majority across the member's releases
    nsen <- sum(stri_detect_regex(body, "Senator"))
    nrep <- sum(stri_detect_regex(body, "Rep[.]|Congress(man|woman)|Representative"))
    chamber <- if (nsen > nrep) "senate" else "house"
    out[[i]] <- data.table(
      date = dt, title = title, body = body, tags = NA_character_,
      url = sprintf("wt:%s:%05d", slug, seq_along(body)), cms = "external",
      name = .wt_name_from_slug(slug), state = st, district = NA_integer_,
      party = party, committee = NA_character_, chamber = chamber,
      source = "wangtucker")
  }
  rbindlist(out)
}

# ---- write combined external rows as year-partitioned RDS --------------------
nlp_write_external_years <- function(df, dir) {
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  df$year <- as.integer(format(df$date, "%Y"))
  df <- df[!is.na(df$year), ]
  for (y in sort(unique(df$year))) {
    sub <- as.data.frame(df[df$year == y, SCHEMA_COLS, with = FALSE])
    saveRDS(sub, file.path(dir, sprintf("releases-%04d.rds", y)))
  }
  invisible(table(df$year))
}
