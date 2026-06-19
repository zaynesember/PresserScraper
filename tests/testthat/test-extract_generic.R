test_that("generic list_items extracts dated title links", {
  ex <- generic_extractor()
  handle <- paste0("https://frost.house.gov/media/press-releases", GENERIC_SEP, "PageNum_rs")
  items <- ex$list_items(fixture_doc("list_generic.html"), handle)

  expect_gt(nrow(items), 0)
  expect_named(items, c("date", "title", "url"))
  expect_s3_class(items$date, "Date")
  expect_true(all(!is.na(items$date)))
  expect_true(all(grepl("/media/press-releases/", items$url)))
  expect_false(any(grepl("/table/?$", items$url)))
  # Flat markup must not collapse every item onto one date.
  expect_gt(length(unique(items$date)), 1)
})

test_that("generic_find_pager detects the pagination parameter", {
  expect_equal(generic_find_pager(fixture_doc("list_generic.html")), "PageNum_rs")
})

test_that("generic_fetch_page stops paging when no pager param is known", {
  ex <- generic_extractor()
  handle <- paste0("https://x.house.gov/news/press-releases", GENERIC_SEP, "")
  expect_null(ex$fetch_page(handle, 1))
})
