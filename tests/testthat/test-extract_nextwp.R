test_that("nextwp parses a WPGraphQL posts response into items with inline body", {
  j <- jsonlite::fromJSON(
    paste(readLines(fixture_path("gql_nextwp.json"), warn = FALSE), collapse = "\n"),
    simplifyVector = TRUE
  )
  items <- nextwp_nodes_to_items(j$data$posts$nodes)
  expect_gt(nrow(items), 0)
  expect_named(items, c("date", "title", "url", "body", "tags"))
  expect_s3_class(items$date, "Date")
  expect_true(all(!is.na(items$date)))
  expect_true(all(grepl("/posts/", items$url)))
  expect_true(all(nzchar(items$title)))
  expect_true(all(!is.na(items$body)))  # body comes back inline
})

test_that("nextwp_list_items passes a parsed page through unchanged", {
  page <- tibble::tibble(date = Sys.Date(), title = "t", url = "u", body = "b", tags = NA)
  expect_identical(nextwp_list_items(page, "x"), page)
  expect_equal(nrow(nextwp_list_items(NULL, "x")), 0)
})

test_that("detect_cms routes a Next.js SPA to nextwp", {
  doc <- rvest::read_html('<html><head></head><body><script id="__NEXT_DATA__">{}</script></body></html>')
  expect_equal(detect_cms(doc = doc), "nextwp")
})

test_that("stronger CMS markers win over the Next.js fingerprint", {
  # A real WordPress page that also ships __NEXT_DATA__ must stay wordpress.
  wp <- rvest::read_html('<html><body><link href="/wp-content/x.css"><script id="__NEXT_DATA__">{}</script></body></html>')
  expect_equal(detect_cms(doc = wp), "wordpress")

  dr <- rvest::read_html('<html><body><div class="views-row"></div><script id="__NEXT_DATA__">{}</script></body></html>')
  expect_equal(detect_cms(doc = dr), "drupal")
})
