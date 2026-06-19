#' Detect the content-management system behind a member site
#'
#' Inspects a homepage's `<meta name="generator">` tag and a set of markup
#' fingerprints to classify the site. About 86% of House sites fall into three
#' vendor families (Drupal, ASP.NET, WordPress); everything else is handled by
#' the `"generic"` extractor.
#'
#' @param url Member homepage URL. Ignored if `doc` is supplied.
#' @param doc Optional pre-fetched `xml_document` (avoids a second request).
#' @return One of `"drupal"`, `"aspx"`, `"wordpress"`, `"guid"`, `"generic"`,
#'   or `"unknown"` (when the page could not be fetched).
#' @examples
#' \dontrun{
#' detect_cms("https://barrymoore.house.gov")  # "drupal"
#' detect_cms("https://carbajal.house.gov")    # "aspx"
#' }
#' @export
detect_cms <- function(url, doc = NULL) {
  if (is.null(doc)) doc <- fetch_html(normalize_home(url))
  if (is.null(doc)) return("unknown")

  ev <- cms_markers(doc)

  # Generator tag is the strongest signal.
  if (grepl("drupal", ev$generator, ignore.case = TRUE)) return("drupal")
  if (grepl("wordpress", ev$generator, ignore.case = TRUE)) return("wordpress")

  # ASP.NET "DocumentID" family has an unmistakable URL signature.
  if (ev$aspx) return("aspx")

  # Fall back to markup fingerprints.
  if (ev$wordpress) return("wordpress")
  if (ev$drupal) return("drupal")

  # GUID-id vendor: /press-releases?ID=<GUID> item links and no other signal.
  if (ev$guid) return("guid")

  "generic"
}

# Collect the raw evidence used by detect_cms(). Exposed internally for tests
# and debugging.
cms_markers <- function(doc) {
  html <- as.character(doc)
  gen <- rvest::html_elements(doc, "meta[name='generator'], meta[name='Generator']") |>
    rvest::html_attr("content")
  gen <- paste(unique(stats::na.omit(gen)), collapse = "; ")

  list(
    generator = gen,
    aspx = grepl("documentsingle\\.aspx|documentquery\\.aspx|DocumentID=", html, ignore.case = TRUE),
    wordpress = grepl("/wp-content/|/wp-json/|wp-includes", html, ignore.case = TRUE),
    drupal = grepl("views-row|views-field|/sites/default/files|Drupal\\.settings|drupal-", html, ignore.case = TRUE),
    guid = grepl(paste0("press-releases\\?id=", GUID_RE), html, ignore.case = TRUE)
  )
}
