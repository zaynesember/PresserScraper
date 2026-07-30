# 15_collect_energycommerce.R -- collect what energycommerce.house.gov's API
# will give up.
#
# The majority Energy & Commerce site is a Next.js/Strapi SPA with no sitemap
# and no crawlable listing. Its /api/news returns the NEWEST 9 of (currently) 58
# posts and ignores every pagination and filter parameter we could find --
# page/limit/pageSize/take/per_page, Strapi pagination[], member=, category=,
# and the /_next/data/<buildId>/news.json route behaves identically. The other
# 49 posts are unreachable from the live site; recovering them is a Wayback job.
#
# So this collector banks the reachable posts. Re-running it MERGES new posts
# into the existing output by URL instead of skipping -- the API window slides,
# so unlike the walk-based collectors a re-run genuinely adds rows. The post
# content arrives as markdown, which we keep: it is body text, not markup soup.
#
# Run:  Rscript institutional/R/15_collect_energycommerce.R

ROOT <- "/Users/zaynesember/GitRepos/pressR"
suppressMessages(devtools::load_all(ROOT, quiet = TRUE))
RAW <- file.path(ROOT, "institutional", "data", "raw")
dir.create(RAW, recursive = TRUE, showWarnings = FALSE)

API  <- "https://energycommerce.house.gov/api/news"
dest <- file.path(RAW, "feed_energycommerce.house.gov#maj#api-news.rds")

resp <- httr2::req_perform(httr2::req_timeout(httr2::request(API), 60))
posts <- httr2::resp_body_json(resp)$posts
stopifnot(length(posts) > 0)

# Light markdown cleanup: inline links become their text, emphasis marks drop.
demd <- function(s) {
  s <- gsub("\\[([^]]*)\\]\\([^)]*\\)", "\\1", s)   # [text](url) -> text
  s <- gsub("\\*\\*([^*]*)\\*\\*", "\\1", s)         # **bold**
  s <- gsub("(^|\\s)[*_]([^*_]+)[*_]", "\\1\\2", s)  # *ital* / _ital_
  trimws(gsub("[ \t]+", " ", s))
}

new <- do.call(rbind, lapply(posts, function(p) data.frame(
  date  = as.Date(p$published),
  title = trimws(p$title),
  url   = paste0("https://energycommerce.house.gov/news/", p$slug),
  body  = demd(p$content %||% ""),
  host  = "energycommerce.house.gov",
  unit  = "Energy and Commerce",
  type  = "committee",
  chamber = "house",
  party_feed = "MAJ",             # bare House committee host = majority-at-date
  listing = API,
  stringsAsFactors = FALSE
)))

if (file.exists(dest)) {
  old <- readRDS(dest)
  add <- new[!new$url %in% old$url, , drop = FALSE]
  message(nrow(old), " existing rows; API window holds ", nrow(new),
          " posts, ", nrow(add), " new")
  new <- rbind(old, add)
}

saveRDS(new, dest)
message("wrote ", dest)
message(nrow(new), " rows, ",
        sum(!is.na(new$body) & nchar(new$body) > 200), " with a body >200 chars, ",
        as.character(min(new$date)), " .. ", as.character(max(new$date)))
