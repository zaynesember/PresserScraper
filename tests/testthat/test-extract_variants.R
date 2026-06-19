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

# --- WordPress Elementor HTML fallback when REST is blocked (clyburn) --------
test_that("wp_elementor_items parses an Elementor Posts grid", {
  items <- wp_elementor_items(
    fixture_doc("list_wp_elementor.html"),
    "https://clyburn.house.gov/press-releases"
  )
  expect_gt(nrow(items), 0)
  expect_true(all(!is.na(items$date)))
  expect_true(all(nzchar(items$title)))
})

test_that("wp_list_items routes an HTML document to the Elementor parser", {
  items <- wp_list_items(
    fixture_doc("list_wp_elementor.html"),
    "html::https://clyburn.house.gov/press-releases"
  )
  expect_gt(nrow(items), 0)
})

test_that("wp_item_body extracts the Elementor post content", {
  res <- wp_item_body(fixture_doc("item_wp_elementor.html"), "x")
  expect_gt(nchar(res$body), 200)
})

# --- Senate WordPress custom post type discovery -----------------------------
test_that("wp_press_post_type picks the press-release type, not op-eds/news-clips", {
  testthat::local_mocked_bindings(fetch_json = function(url, timeout = 30) list(
    post = list(rest_base = "posts"),
    `press-releases` = list(rest_base = "press_releases"),
    in_the_news = list(rest_base = "in_the_news"),
    op_eds = list(rest_base = "op_eds")
  ))
  expect_equal(wp_press_post_type("https://x.senate.gov"), "press_releases")
})

test_that("wp_press_post_type falls back to a 'news' type", {
  testthat::local_mocked_bindings(fetch_json = function(url, timeout = 30) list(
    post = list(rest_base = "posts"),
    news = list(rest_base = "news"),
    in_the_news = list(rest_base = "in_the_news")
  ))
  expect_equal(wp_press_post_type("https://x.senate.gov"), "news")
})

test_that("wp_press_post_type returns NULL when there is no press type (House)", {
  testthat::local_mocked_bindings(fetch_json = function(url, timeout = 30) list(
    post = list(rest_base = "posts"), page = list(rest_base = "pages")
  ))
  expect_null(wp_press_post_type("https://x.house.gov"))
})

# --- generic canonical-path listing fallback (lee-style) ---------------------
test_that("generic_try_listing returns a handle when a probed path has items", {
  testthat::local_mocked_bindings(
    get_html = function(url, timeout = 30) fixture_doc("list_datepath.html")
  )
  h <- generic_try_listing("https://x.senate.gov/press-releases")
  expect_false(is.null(h))
  expect_true(startsWith(h, "https://x.senate.gov/press-releases"))
})

test_that("generic_try_listing returns NULL when a probed path has no items", {
  testthat::local_mocked_bindings(
    get_html = function(url, timeout = 30) rvest::read_html("<html><body><nav>nav</nav></body></html>")
  )
  expect_null(generic_try_listing("https://x.senate.gov/news"))
})
