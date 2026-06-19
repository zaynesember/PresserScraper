test_that("get_html uses the static fetcher outside render mode", {
  testthat::local_mocked_bindings(
    fetch_html = function(url, timeout = 30) "static",
    render_html = function(url, wait = 2) "rendered"
  )
  expect_equal(get_html("https://x.house.gov"), "static")
})

test_that("with_render routes get_html through render_html", {
  testthat::local_mocked_bindings(
    fetch_html = function(url, timeout = 30) "static",
    render_html = function(url, wait = 2) "rendered"
  )
  expect_equal(with_render(get_html("https://x.house.gov")), "rendered")
})

test_that("with_render restores the previous mode, even on error", {
  testthat::local_mocked_bindings(
    fetch_html = function(url, timeout = 30) "static",
    render_html = function(url, wait = 2) "rendered"
  )
  expect_error(with_render(stop("boom")), "boom")
  # mode must be back off afterwards
  expect_equal(get_html("https://x.house.gov"), "static")
})

test_that("with_render nests without leaking render mode", {
  testthat::local_mocked_bindings(
    fetch_html = function(url, timeout = 30) "static",
    render_html = function(url, wait = 2) "rendered"
  )
  out <- with_render({
    inner <- get_html("a")          # rendered
    c(inner, get_html("b"))         # still rendered
  })
  expect_equal(out, c("rendered", "rendered"))
  expect_equal(get_html("c"), "static")  # restored
})
