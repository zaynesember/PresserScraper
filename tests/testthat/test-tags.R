rj <- function(f) {
  jsonlite::fromJSON(
    paste(readLines(fixture_path(f), warn = FALSE), collapse = "\n"),
    simplifyVector = TRUE
  )
}

test_that("clean_issue_tags drops type/admin labels and keeps issue areas", {
  expect_equal(
    clean_issue_tags(c("Press Release", "Energy and Environment", "119th Congress", "Transportation")),
    "Energy and Environment;Transportation"
  )
  expect_true(is.na(clean_issue_tags(c("Press", "In the News", "Uncategorized"))))
  expect_true(is.na(clean_issue_tags(character(0))))
  expect_equal(clean_issue_tags(c("Veterans", "Veterans")), "Veterans")  # de-duped
})

test_that("body_from_selectors strips breadcrumb/nav chrome (generic)", {
  body <- generic_item_body(fixture_doc("item_generic_breadcrumb.html"), "x")$body
  expect_gt(nchar(body), 200)
  expect_false(grepl("^\\s*(Home|HomeMedia|Skip to|Menu)", body))
})

test_that("WordPress per-post tags come from embedded terms", {
  page <- rj("wp_posts_embed.json")
  items <- wp_list_items(page, "https://schweikert.house.gov/wp-json/wp/v2/posts?x")
  expect_true("tags" %in% names(items))
  expect_true(any(!is.na(items$tags)))
  # type labels must not survive
  expect_false(any(grepl("Press Release|In The News", items$tags, ignore.case = TRUE), na.rm = TRUE))
})

test_that("wp_rest_tags prefers categories, falls back to post_tags", {
  mk <- function(cat, tag) {
    list(
      date = "2026-01-01",
      `_embedded` = list(`wp:term` = list(list(
        data.frame(name = cat, taxonomy = rep("category", length(cat)), stringsAsFactors = FALSE),
        data.frame(name = tag, taxonomy = rep("post_tag", length(tag)), stringsAsFactors = FALSE)
      )))
    )
  }
  # substantive category present -> use it, ignore noisy post_tags
  p1 <- mk(c("Press Release", "Energy and Environment"), c("Lyft", "Uber"))
  expect_equal(wp_rest_tags(p1), "Energy and Environment")
  # category is only a type label -> fall back to post_tags (issues filed there)
  p2 <- mk(c("Press Release"), c("Transportation", "Healthcare"))
  expect_equal(wp_rest_tags(p2), "Transportation;Healthcare")
})

test_that("nextwp per-post tags come from WordPress categories", {
  j <- rj("gql_nextwp_cats.json")
  items <- nextwp_nodes_to_items(j$data$posts$nodes)
  expect_true("tags" %in% names(items))
  expect_true(any(items$tags == "Ending Poverty", na.rm = TRUE))  # an issue category
  expect_false(any(items$tags == "Press", na.rm = TRUE))          # type label dropped
})

test_that("guid emits no tags (its issue links are navigation, not per-release)", {
  res <- guid_extractor()$item_body(fixture_doc("item_guid.html"), "x")
  expect_true(is.na(res$tags))
})
