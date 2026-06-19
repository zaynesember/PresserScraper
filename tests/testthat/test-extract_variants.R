# Tests for vendor-template variants surfaced by the full-chamber run.

# --- Cluster D: generic trailing-slash listing path (castro) ----------------
test_that("generic handles a listing href with a trailing slash", {
  items <- generic_list_items(
    fixture_doc("list_generic_slash.html"),
    "https://castro.house.gov/media-center/press-releases/"
  )
  expect_gt(nrow(items), 0)
  expect_true(all(!is.na(items$date)))
  expect_true(all(grepl("/media-center/press-releases/", items$url)))
})

# --- Cluster E: GUID vendor on a /media-center base (desjarlais) -------------
test_that("detect_cms recognizes the GUID vendor on /media-center", {
  expect_equal(detect_cms(doc = fixture_doc("home_guid_mediacenter.html")), "guid")
})

test_that("guid extractor parses /media-center?ID= items", {
  items <- guid_extractor()$list_items(
    fixture_doc("list_guid_mediacenter.html"),
    "https://desjarlais.house.gov/media-center"
  )
  expect_gt(nrow(items), 0)
  expect_true(all(!is.na(items$date)))
  expect_true(all(grepl("media-center\\?ID=", items$url, ignore.case = TRUE)))
})

# --- Cluster B: Drupal variants ---------------------------------------------
test_that("drupal parses the /news-releases path variant (amodei)", {
  items <- drupal_list_items(
    fixture_doc("list_drupal_newsreleases.html"),
    "https://amodei.house.gov/news-releases"
  )
  expect_gt(nrow(items), 0)
  expect_true(all(!is.na(items$date)))
})

test_that("drupal parses the newer Evo card markup (meeks)", {
  items <- drupal_list_items(
    fixture_doc("list_drupal_evo.html"),
    "https://meeks.house.gov/media/press-releases"
  )
  expect_gt(nrow(items), 0)
  expect_true(all(!is.na(items$date)))
  expect_true(all(nzchar(items$title)))
})

test_that("drupal_item_date reads the date from an item page", {
  expect_equal(
    drupal_item_date(fixture_doc("item_drupal_dateless.html")),
    as.Date("2026-06-18")
  )
})

test_that("drupal back-fills dates for a date-less listing (lofgren)", {
  testthat::local_mocked_bindings(
    get_html = function(url, timeout = 30) fixture_doc("item_drupal_dateless.html")
  )
  items <- drupal_list_items(
    fixture_doc("list_drupal_dateless.html"),
    "https://lofgren.house.gov/media/press-releases"
  )
  expect_gt(nrow(items), 0)
  expect_true(all(!is.na(items$date)))
  expect_true(all(grepl("/media/press-releases/", items$url)))
})

# --- Cluster C: ASP.NET variants --------------------------------------------
test_that("aspx derives dates from item markup when there are no <time> tags (chrissmith)", {
  items <- aspx_list_items(
    fixture_doc("list_aspx_notime.html"),
    "https://chrissmith.house.gov/news/documentquery.aspx"
  )
  expect_gt(nrow(items), 0)
  expect_true(all(!is.na(items$date)))
  expect_true(all(grepl("documentsingle\\.aspx", items$url, ignore.case = TRUE)))
})

test_that("aspx infers year-less span.date labels newest-first (houlahan)", {
  items <- aspx_list_items(
    fixture_doc("list_aspx_spandate.html"),
    "https://houlahan.house.gov/news/documentquery.aspx?DocumentTypeID=27"
  )
  expect_gt(nrow(items), 0)
  expect_true(all(!is.na(items$date)))
  expect_true(all(diff(items$date) <= 0))  # newest-first, year-boundary safe
})
