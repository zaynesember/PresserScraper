test_that("normalize_home handles House and Senate hosts (and www/paths)", {
  expect_equal(normalize_home("barrymoore.house.gov"), "https://barrymoore.house.gov")
  expect_equal(normalize_home("https://www.baldwin.senate.gov/"), "https://baldwin.senate.gov")
  expect_equal(normalize_home("https://alsobrooks.senate.gov/news/press-releases/x"),
               "https://alsobrooks.senate.gov")
  expect_equal(normalize_home("https://www.cruz.senate.gov"), "https://cruz.senate.gov")
})

test_that("is_member_url accepts House and Senate, rejects others", {
  expect_true(is_member_url("https://barrymoore.house.gov"))
  expect_true(is_member_url("https://www.baldwin.senate.gov/"))
  expect_true(is_member_url("cruz.senate.gov"))
  expect_false(is_member_url("https://www.house.gov"))      # chamber root, not a member
  expect_false(is_member_url("https://example.com"))
})

test_that("is_non_member_host flags administrative house.gov hosts", {
  expect_true(is_non_member_host("https://clerk.house.gov"))
  expect_true(is_non_member_host("speaker.house.gov"))
  expect_false(is_non_member_host("https://norcross.house.gov"))
  expect_false(is_non_member_host("barrymoore.house.gov"))
})

# Mirror the directory table layout: District | Name | Party | Office | Phone | Committee
member_row <- function(committee_cell) {
  html <- sprintf(paste0(
    '<table><tbody><tr><td>1st</td>',
    '<td><a href="https://barrymoore.house.gov">Moore, Barry</a></td>',
    '<td>R</td><td>1511 LHOB</td><td>(202) 225-2901</td><td>%s</td></tr></tbody></table>'
  ), committee_cell)
  rvest::html_element(rvest::read_html(html), "tr")
}

test_that("parse_member_row extracts pipe-delimited committees as ';'-delimited", {
  row <- parse_member_row(member_row("Agriculture|Judiciary"), "Alabama")
  expect_equal(row$committee, "Agriculture;Judiciary")
  expect_equal(row$url, "https://barrymoore.house.gov")
  expect_equal(row$party, "R")
})

test_that("a blank committee cell (leadership/vacant) becomes NA", {
  row <- parse_member_row(member_row(""), "Alabama")
  expect_true(is.na(row$committee))
})

test_that("parse_committee ignores a trailing phone/room cell", {
  expect_true(is.na(parse_committee(c("1st", "R", "1511 LHOB"))))      # room last
  expect_true(is.na(parse_committee(c("1st", "R", "(202) 225-2901")))) # phone last
  expect_equal(parse_committee(c("1st", "R", "Armed Services")), "Armed Services")
})
