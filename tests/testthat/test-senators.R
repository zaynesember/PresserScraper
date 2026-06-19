test_that("parse_senators reads the directory XML into the standard schema", {
  doc <- xml2::read_xml(fixture_path("senators.xml"))
  out <- parse_senators(doc)

  expect_s3_class(out, "tbl_df")
  expect_equal(nrow(out), 100)
  expect_true(all(c("name", "state", "district", "party", "committee", "url", "chamber") %in% names(out)))
  expect_true(all(out$chamber == "senate"))
  expect_true(all(nzchar(out$bioguide)))  # internal join key for committees
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

test_that("clean_committee_name trims the boilerplate prefix", {
  expect_equal(clean_committee_name("Senate Committee on the Judiciary"), "Judiciary")
  expect_equal(clean_committee_name("Senate Committee on Agriculture, Nutrition, and Forestry"),
               "Agriculture, Nutrition, and Forestry")
  expect_equal(clean_committee_name("Senate Select Committee on Intelligence"), "Intelligence")
  expect_equal(clean_committee_name("Senate Special Committee on Aging"), "Aging")
  expect_equal(clean_committee_name("Joint Committee on Taxation"), "Taxation")
  expect_equal(clean_committee_name("Joint Economic Committee"), "Joint Economic Committee")  # no prefix
})

test_that("senate_committee_map joins by bioguide over Senate/joint committees only", {
  committees <- data.frame(
    type = c("senate", "senate", "joint", "house"),
    thomas_id = c("SSJU", "SSAS", "JSTX", "HSAG"),
    name = c("Senate Committee on the Judiciary", "Senate Committee on Armed Services",
             "Joint Committee on Taxation", "House Committee on Agriculture"),
    stringsAsFactors = FALSE
  )
  membership <- list(
    SSJU = data.frame(bioguide = c("A1", "B2"), stringsAsFactors = FALSE),
    SSAS = data.frame(bioguide = c("A1"), stringsAsFactors = FALSE),
    JSTX = data.frame(bioguide = c("B2"), stringsAsFactors = FALSE),
    HSAG = data.frame(bioguide = c("C3"), stringsAsFactors = FALSE)  # house: ignored
  )
  out <- senate_committee_map(c("A1", "B2", "C3", "Z9"), committees, membership)
  expect_equal(out[1], "Judiciary;Armed Services")  # A1: two senate committees
  expect_equal(out[2], "Judiciary;Taxation")         # B2: senate + joint
  expect_true(is.na(out[3]))                          # C3: only a House committee -> none
  expect_true(is.na(out[4]))                          # Z9: not on any committee
})
