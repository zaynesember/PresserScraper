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
    generic   = generic_extractor()
  )
}

# Shared helper: turn a vector of hrefs into absolute URLs against a base.
abs_urls <- function(href, base) {
  rvest::url_absolute(href, base)
}

# Shared helper: extract readable body text from the first selector that
# yields content, used by several extractors.
body_from_selectors <- function(doc, selectors) {
  for (sel in selectors) {
    node <- rvest::html_element(doc, sel)
    if (!is.na(node)) {
      txt <- trimws(rvest::html_text2(node))
      if (nzchar(txt)) return(txt)
    }
  }
  NA_character_
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
