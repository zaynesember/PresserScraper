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


test <- try(read_html("https://simon.house.gov/") %>% html_node("potato")) %>% html_text()


# Replace with your target URL
link <- "https://schweikert.house.gov/"
pressers_link <- "press_releases/"


if (!grepl("^https?://", pressers_link)) {
  # Remove trailing slashes from link
  base_link <- sub("/+$", "", link)
  # Remove leading slashes from pressers_link
  relative_link <- sub("^/+", "", pressers_link)
  
  # Combine with a single slash between them
  pressers_link <- paste0(base_link, "/", relative_link)
}

print(pressers_link)


