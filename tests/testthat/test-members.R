test_that("is_non_member_host flags administrative house.gov hosts", {
  expect_true(is_non_member_host("https://clerk.house.gov"))
  expect_true(is_non_member_host("speaker.house.gov"))
  expect_false(is_non_member_host("https://norcross.house.gov"))
  expect_false(is_non_member_host("barrymoore.house.gov"))
})
