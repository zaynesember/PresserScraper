test_that("parse_dates handles dot-separated M.D.Y dates (Senate sites)", {
  expect_equal(parse_dates("06.18.2026"), as.Date("2026-06-18"))
  expect_equal(parse_dates("06.18.26"), as.Date("2026-06-18"))   # 2-digit year
  expect_equal(parse_dates("1.5.2026"), as.Date("2026-01-05"))
})

test_that("expand_2digit_year widens both / and . separators", {
  expect_equal(expand_2digit_year("5/28/26"), "5/28/2026")
  expect_equal(expand_2digit_year("06.18.26"), "06.18.2026")
  expect_equal(expand_2digit_year("not a date"), "not a date")
})

test_that("find_dates_in_text picks up a dot date in running text", {
  expect_equal(first_date_in_text("06.18.2026  Senators Collins, Bennet ..."),
               as.Date("2026-06-18"))
  expect_equal(first_date_in_text("Press Releases 06.11.26 Fourth Icebreaker"),
               as.Date("2026-06-11"))
})

test_that("strip_leading_date removes a date prefix from a title", {
  expect_equal(strip_leading_date("06.18.2026  Senators Collins, Bennet Lead"),
               "Senators Collins, Bennet Lead")
  expect_equal(strip_leading_date("June 18, 2026 - Cruz Remarks"), "Cruz Remarks")
  # a title with no leading date is unchanged
  expect_equal(strip_leading_date("Baldwin Introduces Bill"), "Baldwin Introduces Bill")
  # a title that is only a date falls back to the original (not emptied)
  expect_equal(strip_leading_date("06.18.2026"), "06.18.2026")
})
