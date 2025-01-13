library(tidyverse)
library(rvest)
library(stringr)


link <- "https://mikethompson.house.gov"

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
              silent=T) # Try E

page_lengths <- c(length(page_A), length(page_B), length(page_C), 
                  length(page_D), length(page_E), length(page_F))

page_lengths

# Page F

# Name
read_html(link) %>% html_nodes(xpath="/html/head/meta[2]") %>% html_attr("content")

# Dates
dates <- page_F %>% html_nodes(xpath="//*[contains(concat( \" \", @class, \" \" ), concat( \" \", \"col-auto\", \" \" ))]") %>% 
  html_text() %>% str_trim

dates[c(T, F)]

# Links
page_F %>% 
  html_nodes(".font-weight-bold a") %>% 
  html_attr("href")

# Titles
# need to work more on to avoid getting extra junk
titles <- page_F %>% 
  html_nodes(".font-weight-bold") %>% html_text() %>% str_trim

titles

