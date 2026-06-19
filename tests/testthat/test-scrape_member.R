# A minimal extractor stub for walk_listing: `pages` is a list of items
# tibbles, one per 0-based page; fetch_page returns NULL past the end.
fake_extractor <- function(pages) {
  list(
    fetch_page = function(list_url, page) if (page + 1L <= length(pages)) page + 1L else NULL,
    list_items = function(page_obj, list_url) pages[[page_obj]]
  )
}

test_that("walk_listing reports saw_items when releases exist but none in range", {
  old <- tibble::tibble(date = as.Date("2020-01-01"), title = "t", url = "u")
  ex <- fake_extractor(list(old))
  out <- walk_listing(ex, "L", as.Date("2026-01-01"), as.Date("2026-12-31"),
                      10, "h.house.gov", quiet = TRUE)
  expect_equal(nrow(out), 0)
  expect_true(attr(out, "saw_items"))
})

test_that("walk_listing reports saw_items = FALSE for an empty listing", {
  ex <- fake_extractor(list(empty_items()))
  out <- walk_listing(ex, "L", as.Date("2026-01-01"), Sys.Date(),
                      10, "h.house.gov", quiet = TRUE)
  expect_equal(nrow(out), 0)
  expect_false(attr(out, "saw_items"))
})

test_that("walk_listing collects in-range items and reports saw_items", {
  pg <- tibble::tibble(date = as.Date("2026-03-01"), title = "t", url = "u")
  ex <- fake_extractor(list(pg))
  out <- walk_listing(ex, "L", as.Date("2026-01-01"), as.Date("2026-12-31"),
                      10, "h.house.gov", quiet = TRUE)
  expect_equal(nrow(out), 1)
  expect_true(attr(out, "saw_items"))
})

test_that("needs_render fires only when no releases were parseable", {
  seen_in_range <- with_status(tibble::tibble(date = Sys.Date()),
    found_home = TRUE, found_listing = TRUE, saw_items = TRUE)
  expect_false(needs_render(seen_in_range))

  empty_range <- with_status(empty_member_result(),
    found_home = TRUE, found_listing = TRUE, saw_items = TRUE)
  expect_false(needs_render(empty_range))  # releases seen, just none in window

  no_home <- with_status(empty_member_result(),
    found_home = FALSE, found_listing = FALSE, saw_items = FALSE)
  expect_true(needs_render(no_home))

  no_listing <- with_status(empty_member_result(),
    found_home = TRUE, found_listing = FALSE, saw_items = FALSE)
  expect_true(needs_render(no_listing))

  unparseable <- with_status(empty_member_result(),
    found_home = TRUE, found_listing = TRUE, saw_items = FALSE)
  expect_true(needs_render(unparseable))
})

test_that("strip_status removes internal attributes", {
  df <- with_status(empty_member_result(),
    found_home = TRUE, found_listing = TRUE, saw_items = TRUE, cms_detected = "drupal")
  clean <- strip_status(df)
  expect_null(attr(clean, "found_home"))
  expect_null(attr(clean, "saw_items"))
  expect_null(attr(clean, "cms_detected"))
})
