test_that("wordpress list_items parses REST posts with inline body", {
  ex <- wordpress_extractor()
  posts <- jsonlite::fromJSON(fixture_path("posts_wordpress.json"), simplifyVector = TRUE)
  items <- ex$list_items(posts, "https://schweikert.house.gov/wp-json/wp/v2/posts")

  expect_gt(nrow(items), 0)
  expect_true(all(c("date", "title", "url", "body") %in% names(items)))
  expect_s3_class(items$date, "Date")
  expect_true(all(!is.na(items$date)))
  expect_true(all(grepl("^https?://", items$url)))
  # Body is decoded to plain text (no raw HTML tags).
  expect_false(any(grepl("<p>|</p>", items$body)))
  expect_true(any(nchar(items$body) > 200))
})

test_that("wordpress list_items handles empty input", {
  ex <- wordpress_extractor()
  expect_equal(nrow(ex$list_items(list(), "x")), 0)
})
