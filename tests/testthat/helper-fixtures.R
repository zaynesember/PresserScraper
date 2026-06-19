# Read a saved HTML fixture as a parsed document.
fixture_doc <- function(name) {
  path <- testthat::test_path("..", "fixtures", name)
  rvest::read_html(path)
}

fixture_path <- function(name) {
  testthat::test_path("..", "fixtures", name)
}
