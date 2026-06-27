# Extractor interface
# -------------------
# Each CMS family implements an "extractor": a named list of functions with a
# common signature, so scrape_member() can stay CMS-agnostic. The interface
# supports both HTML-paginated sites and JSON/API-based ones (WordPress).
#
#   list_url(home, home_doc)   -> character(1) URL/handle for the press-release
#                                 listing, or NULL if none can be found.
#   fetch_page(list_url, page) -> a "page object" for 0-based page index `page`
#                                 (page 0 == first page): an xml_document for
#                                 HTML sites, a parsed data.frame for APIs, or
#                                 NULL when there are no more pages.
#   list_items(page, list_url) -> tibble(date <Date>, title <chr>, url <chr>)
#                                 of releases on one page. May additionally
#                                 carry `body`/`tags` columns, in which case
#                                 scrape_member() skips the per-item fetch.
#   item_body(doc, url)        -> list(body <chr>, tags <chr>) for an individual
#                                 release page (HTML sites only).
#
# Extractors are registered in extractor_registry(); get_extractor() resolves a
# CMS name (from detect_cms()) to its implementation.

# Resolve a CMS name to an extractor, falling back to the generic one.
get_extractor <- function(cms) {
  reg <- extractor_registry()
  if (!is.null(reg[[cms]])) return(reg[[cms]])
  reg[["generic"]]
}

extractor_registry <- function() {
  list(
    drupal    = drupal_extractor(),
    aspx      = aspx_extractor(),
    wordpress = wordpress_extractor(),
    guid      = guid_extractor(),
    nextwp    = nextwp_extractor(),
    generic   = generic_extractor()
  )
}

# Shared helper: turn a vector of hrefs into absolute URLs against a base.
# Hrefs are trimmed first: some templates emit leading/trailing whitespace
# (e.g. " /news/documentsingle.aspx?..."), which url_absolute() turns into NA.
abs_urls <- function(href, base) {
  rvest::url_absolute(trimws(href), base)
}

# Shared helper: extract readable body text from the first selector that
# yields content, used by several extractors. Navigation chrome (breadcrumbs,
# menus, headers/footers, scripts) inside the chosen node is removed first so a
# broad fallback selector like "main"/"#content" doesn't pollute the body.
body_from_selectors <- function(doc, selectors) {
  for (sel in selectors) {
    node <- rvest::html_element(doc, sel)
    if (!is.na(node)) {
      strip_chrome(node)
      txt <- trimws(rvest::html_text2(node))
      if (nzchar(txt)) return(txt)
    }
  }
  NA_character_
}

# Remove navigation/chrome descendants from a node in place (mutates the parsed
# document, which is fine: item bodies are parsed fresh per release).
strip_chrome <- function(node) {
  junk <- rvest::html_elements(node, paste0(
    "nav, header, footer, aside, script, style, form, noscript, ",
    ".breadcrumb, .breadcrumbs, [class*='breadcrumb'], [aria-label*='readcrumb'], ",
    ".sr-only, [class*='social-share'], [class*='share-'], [class*='skip-link']"
  ))
  if (length(junk) > 0) xml2::xml_remove(junk)
  invisible(node)
}

# Normalise a set of taxonomy/category labels into an issue-tag string, dropping
# release-type and administrative labels (e.g. "Press Release", "In the News",
# "119th Congress"). Returns NA when nothing substantive remains.
.tag_type_labels <- c(
  "press release", "press releases", "press", "in the news", "in news",
  "uncategorized", "news", "featured", "newsroom", "media", "media center",
  "statement", "statements", "all"
)
clean_issue_tags <- function(x) {
  x <- trimws(decode_entities(x[!is.na(x) & nzchar(trimws(x))]))
  x <- x[!(tolower(x) %in% .tag_type_labels)]
  x <- x[!grepl("^[0-9]+(st|nd|rd|th)\\s+congress$", x, ignore.case = TRUE)]
  x <- unique(x[nzchar(x)])
  if (length(x) == 0) return(NA_character_)
  paste(x, collapse = ";")
}

# Decode the handful of HTML entities that show up in JSON-sourced term names
# (REST/GraphQL), which -- unlike HTML-scraped text -- arrive still encoded.
decode_entities <- function(x) {
  x <- gsub("&amp;|&#0*38;", "&", x)
  x <- gsub("&#0*39;|&#8217;|&#0*146;|&rsquo;|&lsquo;", "'", x)
  x <- gsub("&quot;|&#0*34;", '"', x)
  x <- gsub("&#8211;|&ndash;", "-", x)
  x <- gsub("&nbsp;|&#0*160;", " ", x)
  x <- gsub("&lt;", "<", x, fixed = TRUE)
  x <- gsub("&gt;", ">", x, fixed = TRUE)
  x
}

# Shared helper: collect tag/issue text from the first selector that matches.
tags_from_selectors <- function(doc, selectors) {
  for (sel in selectors) {
    nodes <- rvest::html_elements(doc, sel)
    if (length(nodes) > 0) {
      txt <- trimws(rvest::html_text(nodes))
      txt <- unique(txt[nzchar(txt)])
      if (length(txt) > 0) return(paste(txt, collapse = ";"))
    }
  }
  NA_character_
}
