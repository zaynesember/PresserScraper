# lib_institutional.R -- custom feed walker for institutional hosts the stock
# extractors can't handle.
#
# The stock generic extractor assumes item permalinks live *under* the listing
# path. Committee sites break that: the listing sits at one path (e.g.
# /newsroom/majority-press-releases) and items at another (/newsroom/majority/
# <slug>). This walker takes an explicit listing URL + item-link regex per feed,
# auto-detects the pagination scheme, and falls back to fetching an item's page
# when the listing carries no date. Reuses pressR internals (loaded via
# devtools::load_all) for date parsing and body extraction.

# ---- item-page date/body cache (one fetch per URL across pages) -------------
.insti_cache <- new.env(parent = emptyenv())

insti_item_fetch <- function(url) {
  key <- digest_key(url)
  if (!is.null(.insti_cache[[key]])) return(.insti_cache[[key]])
  doc <- get_html(url)
  out <- if (is.null(doc)) list(date = as.Date(NA), body = NA_character_) else {
    list(date = insti_page_date(doc, url), body = generic_item_body(doc, url)$body)
  }
  .insti_cache[[key]] <- out
  out
}

digest_key <- function(x) paste0("u", substr(gsub("[^A-Za-z0-9]", "", x), 1, 60),
                                 nchar(x))

# Date of a release page: article meta, <time datetime>, /YYYY/MM/ in the URL,
# then the first parseable date in the page text.
insti_page_date <- function(doc, url) {
  meta <- rvest::html_attr(rvest::html_elements(
    doc, "meta[property='article:published_time'], meta[name='date'], meta[name='dcterms.date']"
  ), "content")
  d <- suppressWarnings(as.Date(substr(stats::na.omit(meta), 1, 10)))
  d <- d[!is.na(d)]
  if (length(d) > 0) return(d[1])

  tm <- rvest::html_attr(rvest::html_elements(doc, "time[datetime]"), "datetime")
  d <- suppressWarnings(as.Date(substr(stats::na.omit(tm), 1, 10)))
  d <- d[!is.na(d)]
  if (length(d) > 0) return(d[1])

  m <- regmatches(url, regexec("/((?:19|20)[0-9]{2})/([0-9]{1,2})/", url))[[1]]
  if (length(m) == 3) {
    d <- suppressWarnings(as.Date(paste(m[2], m[3], "15", sep = "-")))
    if (!is.na(d)) return(d)
  }

  first_date_in_text(rvest::html_text2(
    rvest::html_element(doc, "article, main, #content, .content, body")
  ))
}

# ---- listing parsing --------------------------------------------------------
# Anchors on `doc` whose absolute href matches `item_re`; title from anchor
# text; date from surrounding markup, else (when allowed) the item page itself.
insti_feed_items <- function(doc, base, item_re, min_title = 15,
                             date_from_item = TRUE) {
  links <- rvest::html_elements(doc, "a[href]")
  if (length(links) == 0) return(empty_items())

  recs <- purrr::map(links, function(link) {
    href <- rvest::html_attr(link, "href")
    if (is.na(href)) return(NULL)
    url <- abs_urls(href, base)
    if (!grepl(item_re, url, ignore.case = TRUE)) return(NULL)
    title <- strip_leading_date(trimws(gsub("\\s+", " ", rvest::html_text(link))))
    # Card layouts often put the title outside the anchor (empty link text):
    # fall back to aria-label/title attributes, then the nearest ancestor
    # block's heading.
    if (nchar(title) < min_title) {
      for (alt in c(rvest::html_attr(link, "aria-label"), rvest::html_attr(link, "title"))) {
        if (!is.na(alt) && nchar(trimws(alt)) >= min_title) { title <- trimws(alt); break }
      }
    }
    if (nchar(title) < min_title) {
      for (lvl in 1:4) {
        anc <- rvest::html_element(link, xpath = sprintf("./ancestor::*[%d]", lvl))
        if (is.na(anc)) break
        h <- rvest::html_element(anc, "h1, h2, h3, h4, .title, [class*='title']")
        if (!inherits(h, "xml_missing")) {
          cand <- trimws(gsub("\\s+", " ", rvest::html_text(h)))
          if (nchar(cand) >= min_title) { title <- strip_leading_date(cand); break }
        }
      }
    }
    if (nchar(title) < min_title) return(NULL)
    date <- generic_item_date(link)
    tibble::tibble(date = date, title = title, url = url)
  })
  recs <- purrr::compact(recs)
  if (length(recs) == 0) return(empty_items())
  out <- dplyr::bind_rows(recs)
  out <- out[!duplicated(out$url), , drop = FALSE]

  # Listing pages without per-item dates: pull the date (and cache the body)
  # from each item's own page.
  need <- which(is.na(out$date))
  if (date_from_item && length(need) > 0) {
    for (i in need) out$date[i] <- insti_item_fetch(out$url[i])$date
  }
  out[!is.na(out$date), , drop = FALSE]
}

# ---- pagination -------------------------------------------------------------
# Detect how a listing paginates by probing. Returns list(mode, param):
#   query0 : base?param=N   with N = page index (page 0 is the bare base)
#   query1 : base?param=N   with N = page number (page 1 is the bare base)
#   wp     : base/page/N/
#   none   : single page
insti_detect_pager <- function(base, page0_doc, item_re) {
  urls0 <- insti_feed_items(page0_doc, base, item_re, date_from_item = FALSE)$url
  differs <- function(doc) {
    if (is.null(doc)) return(FALSE)
    u <- insti_feed_items(doc, base, item_re, date_from_item = FALSE)$url
    length(u) > 0 && length(setdiff(u, urls0)) > 0
  }

  param <- generic_find_pager(page0_doc)
  cands <- unique(c(param[!is.na(param)], "page", "PageNum_rs", "pagenum_rs"))
  for (p in cands) {
    if (differs(get_html(add_query(base, p, 1)))) return(list(mode = "query0", param = p))
    if (differs(get_html(add_query(base, p, 2)))) return(list(mode = "query1", param = p))
  }
  if (differs(get_html(paste0(trim_slash(base), "/page/2/")))) {
    return(list(mode = "wp", param = NA_character_))
  }
  list(mode = "none", param = NA_character_)
}

insti_fetch_page <- function(base, pager, page) {
  if (page == 0) return(get_html(base))
  switch(pager$mode,
    query0 = get_html(add_query(base, pager$param, page)),
    query1 = get_html(add_query(base, pager$param, page + 1)),
    wp     = get_html(paste0(trim_slash(base), "/page/", page + 1, "/")),
    none   = NULL
  )
}

# ---- the walk ---------------------------------------------------------------
# Walk one feed newest-first, collecting items in [from, to]. Stops past the
# window start, on repeated pages, on empty pages, or at page_limit.
walk_feed <- function(listing, item_re, from, to, page_limit = 1500,
                      date_from_item = TRUE, quiet = TRUE) {
  page0 <- get_html(listing)
  if (is.null(page0)) return(list(items = empty_items(), status = "listing unreachable"))

  pager <- insti_detect_pager(listing, page0, item_re)
  if (!quiet) message("  pager: ", pager$mode, " ", pager$param %||% "")

  collected <- list()
  prev_urls <- character(0)
  page <- 0L
  saw_any <- FALSE
  repeat {
    if (page > page_limit) break
    doc <- if (page == 0) page0 else insti_fetch_page(listing, pager, page)
    if (is.null(doc)) break

    items <- insti_feed_items(doc, listing, item_re, date_from_item = date_from_item)
    if (nrow(items) == 0) break
    saw_any <- TRUE
    if (identical(items$url, prev_urls)) break
    prev_urls <- items$url

    in_range <- items[items$date >= from & items$date <= to, , drop = FALSE]
    if (nrow(in_range) > 0) collected[[length(collected) + 1]] <- in_range

    oldest <- suppressWarnings(min(items$date, na.rm = TRUE))
    if (is.finite(oldest) && oldest < from) break
    page <- page + 1L
    if (!quiet && page %% 10 == 0) message("  page ", page, " (", sum(vapply(collected, nrow, 1L)), " items)")
  }

  out <- if (length(collected) == 0) empty_items() else {
    full <- dplyr::bind_rows(collected)
    full[!duplicated(full$url), , drop = FALSE]
  }
  list(items = out,
       status = if (nrow(out) > 0) "ok" else if (saw_any) "no items in window" else "no parseable items")
}

# Fetch bodies for walked items (cache-aware: date_from_item fetches already
# stored bodies for their URLs).
insti_fetch_bodies <- function(items) {
  if (nrow(items) == 0) { items$body <- character(0); return(items) }
  items$body <- vapply(items$url, function(u) insti_item_fetch(u)$body,
                       character(1), USE.NAMES = FALSE)
  items
}

# ---- guid-engine feeds (CFM ?id=<GUID> sites, e.g. sbc.senate.gov) ----------
# Reuses the package guid extractor with an explicit listing URL.
walk_guid_feed <- function(listing, from, to, page_limit = 1500) {
  doc <- get_html(listing)
  if (is.null(doc)) return(list(items = empty_items(), status = "listing unreachable"))
  # Follow any redirect the listing performs (e.g. *-redirect paths) by using
  # the URL the items resolve against as-is; guid_list_items works on the doc.
  if (nrow(guid_list_items(doc, listing)) == 0) {
    return(list(items = empty_items(), status = "no guid items"))
  }
  param <- guid_discover_pager(listing, doc)
  handle <- paste0(listing, GUID_SEP, param %||% "")
  ex <- guid_extractor()
  items <- walk_listing(ex, handle, from, to, page_limit, listing, quiet = TRUE)
  list(items = items, status = if (nrow(items) > 0) "ok" else "no items in window")
}

guid_feed_bodies <- function(items) {
  if (nrow(items) == 0) { items$body <- character(0); return(items) }
  items$body <- vapply(items$url, function(u) {
    doc <- get_html(u)
    if (is.null(doc)) NA_character_ else guid_item_body(doc, u)$body
  }, character(1), USE.NAMES = FALSE)
  items
}
