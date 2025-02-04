library(tidyverse)
library(rvest)
library(stringr)


# IDEA FOR IMPROVED LOGIC:
#   Compile list of dropdown elements to directly get link to the press release page
#   Compile list of possible date, title, link, and text elements, try each

scraper(link="https://comer.house.gov", start_date="2024-12-01", end_date="2024-12-31", page_limit=10, debug=T)
# type E but with press-release


link <- "https://comer.house.gov"

page_A <- try(read_html(paste0(link, "/media/press-releases")), 
              silent=T) # Try A
page_B <- try(read_html(paste0(link, "/news/documentquery.aspx?DocumentTypeID=27")), 
              silent=T) # Try B
page_C <- try(read_html(paste0(link, "/category/congress_press_release/")), 
              silent=T) # Try C
page_D <- try(read_html(paste0(link, "/media-center/press-releases")), 
              silent=T) # Try D
page_E <- try(read_html(paste0(link, "/press-releases")), 
              silent=T) # Try E
page_F <- try(read_html(paste0(link, "/newsroom/press-releases")), 
              silent=T) # Try F
page_G <- try(read_html(paste0(link, "/news/press-releases")), 
              silent=T) # Try G
page_H <- try(read_html(paste0(link, "/category/press_release")), 
              silent=T) # Try H
page_I <- try(read_html(paste0(link, "/category/press-releases")), 
              silent=T) # Try I
page_J <- try(read_html(paste0(link, "/press")), 
              silent=T) # Try J

c(length(page_A), length(page_B), length(page_C), 
  length(page_D), length(page_E), length(page_F),
  length(page_G), length(page_H), length(page_I),
  length(page_J))

read_html("https://comer.house.gov/press-release?page=1") %>% html_nodes(".ContentGrid") %>% 
  html_text() %>% str_trim()


link %>% read_html() %>% html_nodes(".nav_media > ul:nth-child(2) > li:nth-child(1) > a:nth-child(1)") %>% html_attr("href")

"https://simon.house.gov/" %>% read_html() %>% 
  html_nodes("#main-menu-link-contentf4653798-f140-476b-9deb-8e6f1ad7984e > a:nth-child(1)") %>% html_attr("href")


read_html("https://simon.house.gov/")


# GPT CODE

# Replace with your target URL
url <- "https://schweikert.house.gov"
page <- read_html(url)

# XPath explanation:
# - //a selects all <a> elements.
# - translate(., 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz') converts the text to lowercase.
# - The first condition checks if the text contains "press release".
# - The second condition checks if the text contains "news" but not "newsletter".
# - The and @href part ensures that only nodes with an href attribute are selected.
link_node <- html_node(
  page,
  xpath = "//a[
    (
      contains(translate(., 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'press release')
      or
      (
        contains(translate(., 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'news')
        and
        not(contains(translate(., 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'newsletter'))
      )
    )
    and @href
  ]"
)

# Extract and print the href attribute if a matching node is found
if (!is.null(link_node)) {
  href_value <- html_attr(link_node, "href")
  print(href_value)
} else {
  message("No relevant link found.")
}

presser_finder <- function(link){
  page <- read_html(link)
  
  # XPath explanation:
  # - //a selects all <a> elements.
  # - translate(., 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz') converts the text to lowercase.
  # - The first condition checks if the text contains "press release".
  # - The second condition checks if the text contains "news" but not "newsletter".
  # - The and @href part ensures that only nodes with an href attribute are selected.
  link_node <- html_node(
    page,
    xpath = "//a[
    (
      contains(translate(., 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'press release')
      or
      (
        contains(translate(., 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'news')
        and
        not(contains(translate(., 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'newsletter'))
      )
    )
    and @href
  ]"
  )
  
  if (!is.null(link_node)) {
    href_value <- html_attr(link_node, "href")
    #print(href_value)
  } else {
    message("No relevant link found.")
  }
  
  return(href_value)
}

# TODO: write code to check whether full URL is provided or not

directories <- data.frame(domain=c(), directory=c())

for(w in websites){
  directories <- bind_rows(directories, data.frame(domain=c(w), directory=c(presser_finder(w))))
}


