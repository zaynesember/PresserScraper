test_that("datepath_list_items parses /YYYY/M/slug items with full dates", {
  items <- datepath_list_items(fixture_doc("list_datepath.html"),
                               "https://bost.house.gov/press-releases")
  expect_gt(nrow(items), 0)
  expect_named(items, c("date", "title", "url"))
  expect_s3_class(items$date, "Date")
  expect_true(all(!is.na(items$date)))
  expect_true(all(nzchar(items$title)))
  expect_true(all(grepl("/[0-9]{4}/[0-9]{1,2}/", items$url)))
  # full dates from the listing text (not month-only), so days vary
  expect_gt(length(unique(format(items$date, "%d"))), 1)
})

test_that("the guid extractor handles a date-path listing too", {
  ex <- guid_extractor()
  items <- ex$list_items(fixture_doc("list_datepath.html"),
                         "https://bost.house.gov/press-releases")
  expect_gt(nrow(items), 0)
  expect_true(all(grepl("/[0-9]{4}/[0-9]{1,2}/", items$url)))
})

test_that("the generic extractor falls back to date-path items", {
  ex <- generic_extractor()
  items <- ex$list_items(fixture_doc("list_datepath.html"),
                         "https://bost.house.gov/press-releases")
  expect_gt(nrow(items), 0)
  expect_true(all(grepl("/[0-9]{4}/[0-9]{1,2}/", items$url)))
})

test_that("datepath_item_date falls back to the URL's year/month", {
  # an item link with no date in surrounding text -> URL year/month, day 1
  frag <- rvest::read_html('<div><a href="/2026/3/some-release-title">x</a></div>')
  link <- rvest::html_element(frag, "a")
  d <- datepath_item_date(link, "https://x.house.gov/2026/3/some-release-title")
  expect_equal(d, as.Date("2026-03-01"))
})

test_that("guid item_body extracts the release text on a date-path site", {
  ex <- guid_extractor()
  res <- ex$item_body(fixture_doc("item_datepath.html"), "x")
  expect_gt(nchar(res$body), 200)
  expect_false(grepl("^\\?xml|Skip to|^Menu", res$body))
})
