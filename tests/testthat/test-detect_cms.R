test_that("detect_cms classifies each CMS family from saved homepages", {
  expect_equal(detect_cms(doc = fixture_doc("home_drupal.html")), "drupal")
  expect_equal(detect_cms(doc = fixture_doc("home_aspx.html")), "aspx")
  expect_equal(detect_cms(doc = fixture_doc("home_wordpress.html")), "wordpress")
  # The "generic" homepage must NOT be misread as a known vendor.
  expect_false(detect_cms(doc = fixture_doc("home_generic.html")) %in% c("aspx"))
})

test_that("detect_cms returns 'unknown' when the page can't be fetched", {
  skip_on_cran()
  skip_if_offline()
  expect_equal(detect_cms("https://this-is-not-a-real-member.house.gov", doc = NULL),
               "unknown")
})

test_that("cms_markers extracts the generator tag", {
  ev <- cms_markers(fixture_doc("home_drupal.html"))
  expect_match(ev$generator, "Drupal", ignore.case = TRUE)
})
