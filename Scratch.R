library(tidyverse)
library(rvest)
library(stringr)

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
