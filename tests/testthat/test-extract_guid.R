test_that("detect_cms identifies the guid vendor from its homepage", {
  expect_equal(detect_cms(doc = fixture_doc("home_guid.html")), "guid")
})

test_that("guid list_items parses dated, titled, GUID-url items newest-first", {
  testthat::local_mocked_bindings(guid_today = function() as.Date("2026-06-18"))
  ex <- guid_extractor()
  items <- ex$list_items(fixture_doc("list_guid.html"),
                         "https://norcross.house.gov/press-releases")
  expect_gt(nrow(items), 0)
  expect_named(items, c("date", "title", "url"))
  expect_s3_class(items$date, "Date")
  expect_true(all(!is.na(items$date)))
  expect_true(all(nzchar(items$title)))
  expect_true(all(grepl("press-releases\\?ID=", items$url, ignore.case = TRUE)))
  # listing is newest-first, so inferred dates must be non-increasing
  expect_true(all(diff(items$date) <= 0))
  # most recent item should infer the current year, not a past one
  expect_equal(items$date[1], as.Date("2026-06-09"))
})

test_that("guid item_body extracts the release text, not the page chrome", {
  ex <- guid_extractor()
  res <- ex$item_body(fixture_doc("item_guid.html"), "x")
  expect_type(res, "list")
  expect_gt(nchar(res$body), 200)
  # the body should start with the release dateline, not the site nav
  expect_false(grepl("^\\?xml|Menu|Skip to", res$body))
})

test_that("guid fetch_page uses the embedded pager param, 1-based", {
  calls <- new.env()
  testthat::local_mocked_bindings(get_html = function(url, timeout = 30) {
    calls$url <- url
    NULL
  })
  ex <- guid_extractor()
  handle <- paste0("https://x.house.gov/press-releases", GUID_SEP, "page")
  ex$fetch_page(handle, 0)
  expect_equal(calls$url, "https://x.house.gov/press-releases")
  ex$fetch_page(handle, 2)
  expect_equal(calls$url, "https://x.house.gov/press-releases?page=3")
})

test_that("guid fetch_page stops paging when no pager param was found", {
  ex <- guid_extractor()
  handle <- paste0("https://x.house.gov/press-releases", GUID_SEP, "")
  expect_null(ex$fetch_page(handle, 1))  # single-page listing
})

test_that("guid_infer_yearless picks the most recent non-future year", {
  today <- as.Date("2026-06-18")
  expect_equal(guid_infer_yearless("June 9 something", today), as.Date("2026-06-09"))
  # a month/day later in the year than today must belong to the previous year
  expect_equal(guid_infer_yearless("December 20", today), as.Date("2025-12-20"))
  expect_true(is.na(guid_infer_yearless("no date here", today)))
})

test_that("guid_minus_year rolls a date back exactly one year", {
  expect_equal(guid_minus_year(as.Date("2026-03-15")), as.Date("2025-03-15"))
})
