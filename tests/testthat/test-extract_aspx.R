test_that("aspx list_items pairs dates with documentsingle titles", {
  ex <- aspx_extractor()
  items <- ex$list_items(
    fixture_doc("list_aspx.html"),
    "https://carbajal.house.gov/news/documentquery.aspx?DocumentTypeID=27"
  )
  expect_gt(nrow(items), 0)
  expect_named(items, c("date", "title", "url"))
  expect_s3_class(items$date, "Date")
  expect_true(all(!is.na(items$date)))
  expect_true(all(grepl("documentsingle\\.aspx\\?DocumentID=", items$url)))
  expect_false(any(grepl("read more", items$title, ignore.case = TRUE)))
})

test_that("aspx item_body extracts the release text", {
  ex <- aspx_extractor()
  res <- ex$item_body(fixture_doc("item_aspx.html"), "x")
  expect_true(nchar(res$body) > 200)
})

test_that("aspx page_url uses 1-based &Page", {
  ex <- aspx_extractor()
  base <- "https://x.house.gov/news/documentquery.aspx?DocumentTypeID=27"
  expect_equal(ex$page_url(base, 0), base)
  expect_equal(ex$page_url(base, 1), paste0(base, "&Page=2"))
})
