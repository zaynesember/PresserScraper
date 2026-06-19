test_that("parse_dates handles common House date formats", {
  x <- c(
    "September 23, 2020",
    "Sep. 3, 2021",
    "Sep 3, 2021",
    "2025-01-15",
    "03/05/2025",
    "2025-03-05T14:30:00",
    "March 21st, 2024"
  )
  out <- parse_dates(x)
  expect_s3_class(out, "Date")
  expect_equal(out, as.Date(c(
    "2020-09-23", "2021-09-03", "2021-09-03", "2025-01-15",
    "2025-03-05", "2025-03-05", "2024-03-21"
  )))
})

test_that("parse_dates returns NA for unparseable strings", {
  expect_true(all(is.na(parse_dates(c("not a date", "", NA, "lorem ipsum")))))
})

test_that("clean_date_string strips ordinals and collapses whitespace", {
  expect_equal(clean_date_string("March  21st,  2024"), "March 21, 2024")
})
