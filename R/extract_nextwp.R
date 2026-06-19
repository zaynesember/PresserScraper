# Extractor for headless WordPress sites fronted by a Next.js SPA (the IndiGov
# vendor used by a cluster of House offices, e.g. tlaib, gottheimer, owens).
# Their public pages render releases client-side as anchor-less cards, so HTML
# scraping (even after a headless render) finds nothing. Instead the releases
# are read from the site's public WPGraphQL endpoint at /graphql, which exposes
# the full archive via cursor pagination. Releases live at /posts/<slug> and
# carry their body inline, so no per-item fetch is needed.

NEXTWP_PER_PAGE <- 50

# Cursor state for GraphQL pagination, keyed by endpoint URL. walk_listing()
# fetches pages 0,1,2,... in order, so we stash each page's endCursor here and
# read it back on the next call (page 0 resets it).
.nextwp_cursors <- new.env(parent = emptyenv())

nextwp_extractor <- function() {
  list(
    list_url   = nextwp_list_url,
    fetch_page = nextwp_fetch_page,
    list_items = nextwp_list_items,
    item_body  = function(doc, url) list(body = NA_character_, tags = NA_character_)
  )
}

# Confirm the GraphQL endpoint works (and thus this is the headless-WP family),
# returning it as the listing handle. NULL if /graphql yields no posts.
nextwp_list_url <- function(home, home_doc) {
  endpoint <- paste0(home, "/graphql")
  probe <- nextwp_gql_page(endpoint, NULL, first = 1L)
  if (!is.null(probe) && nrow(probe$items) > 0) return(endpoint)
  NULL
}

nextwp_fetch_page <- function(list_url, page) {
  if (page == 0L) assign(list_url, NULL, envir = .nextwp_cursors)
  after <- if (page == 0L) NULL else get0(list_url, envir = .nextwp_cursors, ifnotfound = NULL)
  if (page > 0L && is.null(after)) return(NULL)  # no further pages

  res <- nextwp_gql_page(list_url, after, first = NEXTWP_PER_PAGE)
  if (is.null(res)) return(NULL)
  assign(list_url, if (isTRUE(res$has_next)) res$end_cursor else NULL, envir = .nextwp_cursors)
  res$items
}

# fetch_page already returns a fully-formed items tibble (with inline body/tags);
# list_items just passes it through.
nextwp_list_items <- function(page, list_url) {
  if (is.null(page) || !is.data.frame(page) || nrow(page) == 0) return(empty_items())
  page
}

# Fetch one GraphQL page (posts newest-first). Returns
# list(items = <tibble date,title,url,body,tags>, has_next, end_cursor) or NULL.
nextwp_gql_page <- function(endpoint, after, first = NEXTWP_PER_PAGE) {
  afterval <- if (is.null(after)) "null" else paste0('"', after, '"')
  query <- sprintf(
    paste0("query{posts(first:%d,after:%s,where:{orderby:{field:DATE,order:DESC}})",
           "{pageInfo{hasNextPage endCursor} nodes{date title link uri content}}}"),
    as.integer(first), afterval
  )
  j <- nextwp_gql_post(endpoint, query)
  posts <- tryCatch(j$data$posts, error = function(e) NULL)
  nodes <- tryCatch(posts$nodes, error = function(e) NULL)
  if (is.null(nodes) || length(nodes) == 0) return(NULL)
  if (is.data.frame(nodes) && nrow(nodes) == 0) return(NULL)

  list(
    items = nextwp_nodes_to_items(nodes),
    has_next = isTRUE(posts$pageInfo$hasNextPage),
    end_cursor = posts$pageInfo$endCursor %||% NULL
  )
}

# POST a GraphQL query and return the parsed (simplified) response, or NULL.
# Reuses the package's configured request (UA, throttle, retry, timeout).
nextwp_gql_post <- function(endpoint, query) {
  req <- httr2::req_body_json(.build_request(endpoint), list(query = query))
  resp <- tryCatch(httr2::req_perform(req), error = function(e) NULL)
  if (is.null(resp) || httr2::resp_status(resp) >= 400) return(NULL)
  tryCatch(httr2::resp_body_json(resp, simplifyVector = TRUE), error = function(e) NULL)
}

# Map a GraphQL posts node frame to the standard items tibble (inline body).
nextwp_nodes_to_items <- function(nodes) {
  dates <- as.Date(substr(nodes$date, 1, 10))
  titles <- html_to_text(nodes$title)
  urls <- if (!is.null(nodes$link)) nodes$link else nodes$uri
  bodies <- if (!is.null(nodes$content)) html_to_text(nodes$content) else NA_character_

  keep <- !is.na(dates) & !is.na(urls) & nzchar(urls)
  tibble::tibble(
    date = dates[keep],
    title = titles[keep],
    url = urls[keep],
    body = bodies[keep],
    tags = NA_character_
  )
}
