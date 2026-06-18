test_that("normalize_members handles vectors and data frames", {
  v <- normalize_members(c("barrymoore.house.gov", "carbajal.house.gov"))
  expect_true(all(c("name", "url") %in% names(v)))
  expect_equal(v$url, c("https://barrymoore.house.gov", "https://carbajal.house.gov"))

  named <- normalize_members(c(Moore = "barrymoore.house.gov"))
  expect_equal(named$name, "Moore")

  df <- normalize_members(tibble::tibble(name = "Moore", url = "barrymoore.house.gov"))
  expect_equal(df$url, "https://barrymoore.house.gov")
  expect_equal(df$name, "Moore")
})

test_that("normalize_members errors when a data frame lacks a url column", {
  expect_error(normalize_members(tibble::tibble(name = "x")), "url")
})

test_that("order_columns puts metadata before release fields", {
  df <- tibble::tibble(
    date = Sys.Date(), title = "t", body = "b", tags = NA, url = "u",
    cms = "drupal", name = "n", state = "s"
  )
  expect_equal(names(order_columns(df))[1:2], c("name", "state"))
  expect_true(all(c("date", "title", "url", "cms") %in% names(order_columns(df))))
})
