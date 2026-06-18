test_that("drupal list_items parses rows with dates, titles, and urls", {
  ex <- drupal_extractor()
  items <- ex$list_items(
    fixture_doc("list_drupal.html"),
    "https://barrymoore.house.gov/media/press-releases"
  )
  expect_gt(nrow(items), 0)
  expect_named(items, c("date", "title", "url"))
  expect_s3_class(items$date, "Date")
  expect_true(all(!is.na(items$date)))
  expect_true(all(grepl("^https://barrymoore\\.house\\.gov/media/press-releases/", items$url)))
  expect_true(all(nzchar(items$title)))
})

test_that("drupal item_body extracts non-trivial text", {
  ex <- drupal_extractor()
  res <- ex$item_body(fixture_doc("item_drupal.html"), "x")
  expect_type(res, "list")
  expect_true(nchar(res$body) > 200)
})

test_that("drupal page_url builds 0-based pagination", {
  ex <- drupal_extractor()
  base <- "https://x.house.gov/media/press-releases"
  expect_equal(ex$page_url(base, 0), base)
  expect_equal(ex$page_url(base, 2), paste0(base, "?page=2"))
})
