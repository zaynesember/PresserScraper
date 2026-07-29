# 08_probe_stragglers.R -- targeted probes for the feeds still failing after
# the first Tier-2 pass: what do their listing pages actually contain?

ROOT <- "/Users/zaynesember/GitRepos/pressR-sources"
suppressMessages(devtools::load_all(ROOT, quiet = TRUE))

show_links <- function(url, pattern, n = 8) {
  cat("\n==", url, "\n")
  doc <- fetch_html(url)
  if (is.null(doc)) { cat("   FETCH FAILED\n"); return(invisible()) }
  a <- rvest::html_elements(doc, "a[href]")
  href <- rvest::html_attr(a, "href")
  txt <- trimws(gsub("\\s+", " ", rvest::html_text(a)))
  keep <- grepl(pattern, href, ignore.case = TRUE)
  cat("   anchors:", length(a), "| matching:", sum(keep), "\n")
  for (i in utils::head(which(keep), n)) {
    cat(sprintf("   %-70s | %s\n", substr(href[i], 1, 70), substr(txt[i], 1, 50)))
  }
  # any date-ish text on the page?
  body_txt <- rvest::html_text2(doc)
  cat("   has 2026 in text:", grepl("2026", body_txt), "\n")
  invisible(doc)
}

show_links("https://www.hsgac.senate.gov/media/majority-news/current-congress", "media/rep|media/dem|media/majority")
show_links("https://www.rules.senate.gov/news/minority-news", "minority-news/")
show_links("https://www.sbc.senate.gov/public/index.cfm/democraticpressreleases", "id=")
show_links("https://www.sbc.senate.gov/public/index.cfm/republicanpressreleases-redirect", "id=")
show_links("https://www.ethics.senate.gov/public/index.cfm/pressreleases", "id=|press")
show_links("https://www.drugcaucus.senate.gov/media-center/press-releases/", "press|release|20[0-9][0-9]")

# WP REST probes for the conference sites
for (h in c("https://www.republicans.senate.gov", "https://www.src.senate.gov",
            "https://www.rpc.senate.gov", "https://www.drugcaucus.senate.gov")) {
  cat("\n== wp-json probe:", h, "\n")
  types <- fetch_json(paste0(h, "/wp-json/wp/v2/types"))
  cat("   types:", if (is.null(types)) "NULL" else paste(utils::head(names(types), 12), collapse = ", "), "\n")
  posts <- fetch_json(paste0(h, "/wp-json/wp/v2/posts?per_page=3&orderby=date&order=desc"))
  if (!is.null(posts) && length(posts) > 0 && !is.null(posts$date)) {
    cat("   latest posts:", paste(substr(posts$date, 1, 10), collapse = ", "), "\n")
  } else cat("   posts: none/blocked\n")
}

# Energy & Commerce GraphQL probe (nextwp family)
cat("\n== graphql probe: energycommerce.house.gov\n")
for (h in c("https://energycommerce.house.gov", "https://democrats-energycommerce.house.gov")) {
  p <- tryCatch(pressR:::nextwp_gql_page(paste0(h, "/graphql"), NULL, first = 3L),
                error = function(e) NULL)
  if (is.null(p)) cat("   ", h, ": NULL\n") else {
    cat("   ", h, ":", nrow(p$items), "items; latest:",
        as.character(utils::head(p$items$date, 3)), "\n")
  }
}
