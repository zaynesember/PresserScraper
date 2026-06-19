test_that("parse_senators reads the directory XML into the standard schema", {
  doc <- xml2::read_xml(fixture_path("senators.xml"))
  out <- parse_senators(doc)

  expect_s3_class(out, "tbl_df")
  expect_equal(nrow(out), 100)
  expect_named(out, c("name", "state", "district", "party", "committee", "url", "chamber"))
  expect_true(all(out$chamber == "senate"))
  # senators are statewide; no district or committee in this feed
  expect_true(all(is.na(out$district)))
  expect_true(all(is.na(out$committee)))
})

test_that("parse_senators yields normalized, valid, de-duplicated member URLs", {
  out <- parse_senators(xml2::read_xml(fixture_path("senators.xml")))
  expect_true(all(is_member_url(out$url)))
  expect_true(all(grepl("^https://[a-z0-9-]+\\.senate\\.gov$", out$url)))  # no www, no path
  expect_false(any(grepl("^https://www\\.", out$url)))
  expect_equal(anyDuplicated(out$url), 0L)
  expect_true(all(nzchar(out$name)))
})
