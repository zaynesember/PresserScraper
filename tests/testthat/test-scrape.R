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

test_that("scrape_pressers retries a transient error failure and recovers it", {
  calls <- new.env(); calls$n <- 0L
  testthat::local_mocked_bindings(
    scrape_member = function(url, from, to = Sys.Date(), cms = NULL, page_limit = 100,
                             fetch_bodies = TRUE, render = c("auto", "never", "always"),
                             quiet = FALSE) {
      calls$n <- calls$n + 1L
      if (calls$n == 1L) stop("transient timeout")          # first attempt fails
      tibble::tibble(date = as.Date("2026-03-01"), title = "t", body = "b",
                     tags = NA_character_, url = paste0(url, "/x"), cms = "generic")
    }
  )
  res <- scrape_pressers("x.house.gov", from = "2026-01-01", quiet = TRUE)
  expect_equal(nrow(res), 1L)                                # recovered on retry
  expect_equal(nrow(attr(res, "failures")), 0L)
  expect_equal(calls$n, 2L)                                  # one retry
})

test_that("scrape_pressers does not retry an empty (in-range) result", {
  calls <- new.env(); calls$n <- 0L
  testthat::local_mocked_bindings(
    scrape_member = function(url, from, to = Sys.Date(), cms = NULL, page_limit = 100,
                             fetch_bodies = TRUE, render = c("auto", "never", "always"),
                             quiet = FALSE) {
      calls$n <- calls$n + 1L
      empty_member_result()                                  # 0 rows, "empty" stage
    }
  )
  res <- scrape_pressers("x.house.gov", from = "2026-01-01", quiet = TRUE)
  expect_equal(attr(res, "failures")$stage, "empty")
  expect_equal(calls$n, 1L)                                  # empties are not retried
})

test_that("retry_failed = FALSE disables the retry pass", {
  calls <- new.env(); calls$n <- 0L
  testthat::local_mocked_bindings(
    scrape_member = function(url, from, to = Sys.Date(), cms = NULL, page_limit = 100,
                             fetch_bodies = TRUE, render = c("auto", "never", "always"),
                             quiet = FALSE) {
      calls$n <- calls$n + 1L; stop("boom")
    }
  )
  res <- scrape_pressers("x.house.gov", from = "2026-01-01", retry_failed = FALSE, quiet = TRUE)
  expect_equal(calls$n, 1L)                                  # no retry
  expect_equal(attr(res, "failures")$stage, "error")
})
