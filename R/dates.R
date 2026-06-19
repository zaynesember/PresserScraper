# Candidate date formats, ordered most- to least-specific so that a fuller
# pattern is preferred when several would parse. Ported and trimmed from the
# original detect_date_formats() in the legacy notebook.
.date_formats <- c(
  "%Y-%m-%dT%H:%M:%S",   # ISO 8601 with T separator
  "%Y-%m-%d %H:%M:%S",   # datetime, space separator
  "%Y-%m-%d",            # ISO date
  "%m/%d/%Y %H:%M:%S",
  "%m/%d/%Y",
  "%m/%d/%y",             # 2-digit year, e.g. "5/28/26"
  "%d/%m/%Y",
  "%Y/%m/%d",
  "%B %d, %Y %H:%M:%S",  # "September 23, 2020 14:00:00"
  "%B %d, %Y",           # "September 23, 2020"
  "%B %d %Y",            # "September 23 2020"
  "%b %d, %Y %H:%M:%S",  # "Sep 23, 2021 ..."
  "%b %d, %Y",           # "Sep 23, 2021"
  "%b. %d, %Y",          # "Sep. 23, 2021"
  "%b %d %Y"
)

# Remove ordinal suffixes ("21st" -> "21") and collapse whitespace.
clean_date_string <- function(x) {
  x <- gsub("\\s+", " ", x)
  x <- gsub("(\\d{1,2})(st|nd|rd|th)\\b", "\\1", x, perl = TRUE, ignore.case = TRUE)
  trimws(x)
}

# Expand a bare M/D/YY date to a 4-digit year so "%Y" parsing can't read the
# 2-digit year as year 26. Follows strptime's %y pivot (00-68 -> 2000s).
expand_2digit_year <- function(s) {
  m <- regmatches(s, regexec("^(\\d{1,2})/(\\d{1,2})/(\\d{2})$", s))[[1]]
  if (length(m) != 4) return(s)
  yy <- as.integer(m[4])
  yyyy <- if (yy <= 68) 2000L + yy else 1900L + yy
  sprintf("%s/%s/%d", m[2], m[3], yyyy)
}

# Detect the first candidate format that parses a single string, else NA.
detect_date_format <- function(x) {
  x <- clean_date_string(x)
  if (is.na(x) || !nzchar(x)) return(NA_character_)
  for (fmt in .date_formats) {
    parsed <- suppressWarnings(as.Date(strptime(x, format = fmt, tz = "UTC")))
    if (!is.na(parsed)) return(fmt)
  }
  NA_character_
}

#' Parse a vector of heterogeneous date strings to `Date`
#'
#' Tries a battery of common formats seen across House member sites,
#' stripping ordinal suffixes first. Strings that match no format become `NA`.
#'
#' @param x Character vector of raw date strings.
#' @return A `Date` vector the same length as `x`.
#' @export
parse_dates <- function(x) {
  x <- as.character(x)
  out <- as.Date(rep(NA, length(x)), origin = "1970-01-01")
  for (i in seq_along(x)) {
    s <- expand_2digit_year(clean_date_string(x[i]))
    if (is.na(s) || !nzchar(s)) next
    for (fmt in .date_formats) {
      parsed <- suppressWarnings(as.Date(strptime(s, format = fmt, tz = "UTC")))
      if (!is.na(parsed)) {
        out[i] <- parsed
        break
      }
    }
  }
  out
}

# Heuristic: does this short string look like it could be a date? Used to drop
# obvious non-date junk before parsing (longest normal date ~ "September 31, 2025").
looks_dateish <- function(x) {
  !is.na(x) & nchar(x) <= 25 & grepl("[0-9]{4}|[0-9]{1,2}/[0-9]{1,2}", x)
}

# Date-shaped substrings to pull out of free-running text (e.g. a listing block
# whose first line is the publish date).
.date_regexes <- c(
  "(?:January|February|March|April|May|June|July|August|September|October|November|December)\\.?\\s+\\d{1,2}(?:st|nd|rd|th)?,?\\s+\\d{4}",
  "(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Sept|Oct|Nov|Dec)\\.?\\s+\\d{1,2}(?:st|nd|rd|th)?,?\\s+\\d{4}",
  "\\d{1,2}/\\d{1,2}/\\d{2,4}",
  "\\d{4}-\\d{2}-\\d{2}"
)

# All date-shaped substrings in `text`, parsed to Date (in order of appearance).
find_dates_in_text <- function(text) {
  if (is.na(text) || !nzchar(text)) return(as.Date(character(0)))
  pat <- paste(.date_regexes, collapse = "|")
  m <- regmatches(text, gregexpr(pat, text, perl = TRUE, ignore.case = TRUE))[[1]]
  if (length(m) == 0) return(as.Date(character(0)))
  d <- parse_dates(m)
  d[!is.na(d)]
}

# First date-shaped substring in `text`, or NA.
first_date_in_text <- function(text) {
  d <- find_dates_in_text(text)
  if (length(d) == 0) as.Date(NA) else d[1]
}
