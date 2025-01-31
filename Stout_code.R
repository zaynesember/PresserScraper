

library(rvest)
library(dplyr)
library(stringr)

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".internal-content .container") %>% html_text() %>%str_trim
return(press_info)}
state="AK"
district="1"

youngpr=data.frame()

for(page_result in seq(from = 0 , to = 2, by = 1))
{
link= paste0("https://peltola.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)


name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://peltola.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
youngpr=rbind(youngpr, data.frame(name, date, prpage))
print(paste("Page:", page_result))  
}

 write.csv(youngpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/youngak1.csv")




get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
return(press_info)}
state="AL"
district="1"

carlpr=data.frame()

for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= paste0("https://carl.house.gov/media/press-releases?page=", page_result)
page=read_html(link)

name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://carl.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
carlpr=rbind(carlpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))  
}

 write.csv(carlpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/carlal1.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
return(press_info)}


moorepr=data.frame()
state="AL"
district=2

for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= paste0("https://barrymoore.house.gov/media/press-releases?page=", page_result)
page=read_html(link)

name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://barrymoore.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
moorepr=rbind(moorepr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))  
}

 write.csv(moorepr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/mooreal2.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page %>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}
state="AL"
district="3"

rogerspr=data.frame()

for(page_result in seq(from = 0, to = 15, by =1))
{
link=paste0("https://mikerogers.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)

name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://mikerogers.house.gov/news/", ., sep="")
date=page %>% html_nodes("#newsdoclist time") %>% html_text()
prpage=sapply(links, FUN=get_main)
rogerspr=rbind(rogerspr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}

 write.csv(rogerspr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/rogersal3.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>%html_nodes(".field-type-text-with-summary .even") %>% html_text() %>%str_trim
return(press_info)
}

state="AL"
district="4"

aderholtpr=data.frame()

for(page_result in seq(from = 0, to = 15, by = 1))
{
link=paste0("https://aderholt.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)


name= page%>% html_nodes(".views-field-title a") %>% html_text()
links=page%>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://aderholt.house.gov", ., sep="")
date= page%>% html_nodes(".views-field-created .field-content")%>% html_text()
prpage=sapply(links, FUN=get_main)
aderholtpr=rbind(aderholtpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}

write.csv(aderholtpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/aderholtal4.csv")




get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>%html_nodes(".even") %>% html_text() %>%str_trim
return(press_info)
}
state="AL"
district="5"

brookspr=data.frame()

for(page_result in seq(from = 0, to = 15, by = 1))
{
link=paste0("https://brooks.house.gov/media-center/news-releases?page=", page_result)
page=read_html(link)

name= page%>% html_nodes(".views-field-title a") %>% html_text()
links=page%>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://brooks.house.gov", ., sep="")
date= page%>% html_nodes(".views-field-created .field-content")%>% html_text()
prpage=sapply(links, FUN=get_main)
brookspr=rbind(brookspr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}

write.csv(brookspr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/brooksal5.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>%html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
return(press_info)
}
state="AL"
district="6"

palmerpr=data.frame()

for(page_result in seq(from = 0, to = 15, by = 1))
{
link=paste0("https://palmer.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)

name= page%>% html_nodes(".font-weight-bold a") %>% html_text()
links=page%>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://palmer.house.gov", ., sep="")
date= page%>% html_nodes(".col-auto:nth-child(1)")%>% html_text()
prpage=sapply(links, FUN=get_main)
palmerpr=rbind(palmerpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}

write.csv(palmerpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/palmeral6.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>%html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)
}
state="AL"
district="7"

sewellpr=data.frame()

for(page_result in seq(from = 0, to = 15, by = 1))
{
link=paste0("https://sewell.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)

name= page%>% html_nodes("#block-system-main .views-field-title a") %>% html_text()
links=page%>% html_nodes("#block-system-main .views-field-title a") %>% html_attr("href") %>% paste("https://sewell.house.gov", ., sep="")
date= page%>% html_nodes(".views-field-created .field-content")%>% html_text()
prpage=sapply(links, FUN=get_main)
sewellpr=rbind(sewellpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}

write.csv(sewellpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/sewellal7.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}

ohallaranpr=data.frame()
state="AZ"
district=1

for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= paste0("https://ohalleran.house.gov/media/press-releases?page=", page_result)
page=read_html(link)



name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://ohalleran.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)

ohallaranpr=rbind(ohallaranpr, data.frame(state, district, name, date, prpage))
 
}

 write.csv(ohallaranpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/ohallaranpraz1.csv")



get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".content") %>% html_text() %>%str_trim
return(press_info)}


state="AZ"
district="2"

kirkpatrickpraz2=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://kirkpatrick.house.gov/category/press-release/page/", page_result)
page=read_html(link)



name=page%>%html_nodes("#main h2") %>% html_text()
links=page%>%html_nodes("#main .btn") %>% html_attr("href") %>% paste("", ., sep="")
date=page%>%html_nodes(".date") %>% html_text()
prpage=sapply(links, FUN=get_main)
kirkpatrickpraz2=rbind(kirkpatrickpraz2, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(kirkpatrickpraz2, "C:/Users/bestf/OneDrive/Desktop/Press Releases/kirkpatrickpraz2.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page %>% html_nodes(".news-info__content") %>% html_text() %>% str_trim
return(press_info)}

state="AZ"
district=3
grijalvapr=data.frame()


for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= paste0("https://grijalva.house.gov/category/congress_press_release/page/", page_result)
page=read_html(link)



name=page %>% html_nodes(".info-title") %>% html_text()
links=page %>% html_nodes(".btn") %>% html_attr("href") %>% paste("", ., sep="")
date=page %>% html_nodes(".info-date") %>% html_text()
prpage=sapply(links, FUN=get_main)

grijalvapr=rbind(grijalvapr, data.frame(state, district, name, date, prpage))
 
}

 write.csv(grijalvapr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/grijalvapraz3.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}

gosarpr=data.frame()
state="AZ"
district=4

for(page_result in seq(from = 0, to = 15, by = 1))
{
link= paste0("https://gosar.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)



name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://gosar.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)

gosarpr=rbind(gosarpr, data.frame(state, district, name, date, prpage))
 
}

 write.csv(gosarpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/gosarpraz4.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-content") %>% html_text() %>%str_trim
return(press_info)}

biggspr=data.frame()
state="AZ"
district=5

for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= paste0("https://biggs.house.gov/media/press-releases?page=", page_result)
page=read_html(link)



name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://biggs.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)

biggspr=rbind(biggspr, data.frame(state, district, name, date, prpage))
 
}

 write.csv(biggspr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/biggsprpraz5.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".content") %>% html_text() %>%str_trim
return(press_info)}

schweikertpr=data.frame()
state="AZ"
district=6

for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= paste0("https://schweikert.house.gov/category/congress_press_release/page/", page_result)
page=read_html(link)



name=page %>% html_nodes(".title span") %>% html_text()
links=page %>% html_nodes("#main .btn") %>% html_attr("href") %>% paste("", ., sep="")
date=page %>%html_nodes(".date ") %>% html_text()
prpage=sapply(links, FUN=get_main)

schweikertpr=rbind(schweikertpr, data.frame(state, district, name, date, prpage))
}

write.csv(schweikertpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/ schweikertpr.csv")



get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
return(press_info)}

state="AZ"
district="7"

gallegopr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://rubengallego.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)

name=page%>%html_nodes(".font-weight-bold a") %>% html_text()
links=page%>%html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://rubengallego.house.gov/", ., sep="")
date=page%>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
gallegopr=rbind(gallegopr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(gallegopr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/gallegopraz7.csv")




get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}

state="AZ"
district="8"

leskopr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://lesko.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)

name=page%>%html_nodes(".newsie-titler a") %>% html_text()
links=page%>%html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://lesko.house.gov/news/", ., sep="")
date=page%>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
leskopr=rbind(leskopr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(leskopr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/leskopraz8.csv")



get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes("#content") %>% html_text() %>%str_trim
return(press_info)}

state="AZ"
district="9"

stantonpr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://stanton.house.gov/press-releases?page=", page_result)
page=read_html(link)

name=page%>%html_nodes(".ContentGrid") %>% html_text()
links=page%>%html_nodes(".ContentGrid") %>% html_attr("href") %>% paste("https://stanton.house.gov", ., sep="")
date=page%>%html_nodes(".recordListDate") %>% html_text()
prpage=sapply(links, FUN=get_main)
stantonpr=rbind(stantonpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(stantonpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/stantonaz9.csv")






get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}

state="AR"
district="2"

hillpr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://hill.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".newsie-titler a") %>% html_text()
links=page%>%html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://hill.house.gov/news/", ., sep="")
date=page%>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
hillpr=rbind(hillpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(hillpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/hillar2.csv")

get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}

state="AR"
district="3"
womackpr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://womack.house.gov/news/documentquery.aspx?DocumentTypeID=2067&Page=", page_result)
page=read_html(link)

name=page%>%html_nodes(".newsie-titler a") %>% html_text()
links=page%>%html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://womack.house.gov/news/", ., sep="")
date=page%>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
womackpr=rbind(womackpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(womackpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/womackprar3.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-content") %>% html_text() %>%str_trim
return(press_info)}

state="AR"
district=4

westermanpr=data.frame()

for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= paste0("https://westerman.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)



name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://westerman.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)

westermanpr=rbind(westermanpr, data.frame(state, district, name, date, prpage))
 
}

 write.csv(westermanpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/westermanprar4.csv")




get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}

state="CA"
district=1

lamalfapr=data.frame()

for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= paste0("https://lamalfa.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)



name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://lamalfa.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)

lamalfapr=rbind(lamalfapr, data.frame(state, district, name, date, prpage))
 
}

 write.csv(lamalfapr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/lamalfaprca1.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#main_column") %>% html_text() %>%str_trim
return(press_info)}

state="CA"
district=2

huffmanpr=data.frame()

for(page_result in seq(from = 1, to = 15, by = 1))
{
link= paste0("https://huffman.house.gov/media-center/press-releases?PageNum_rs=", page_result)
page=read_html(link)



name=page %>% html_nodes(".media__link") %>% html_text()
links=page %>% html_nodes(".media__link") %>% html_attr("href") %>% paste("https://huffman.house.gov", ., sep="")
date=page %>%html_nodes("#press .black") %>% html_text()
prpage=sapply(links, FUN=get_main)

huffmanpr=rbind(huffmanpr, data.frame(state, district, name, date, prpage))
 
}

 write.csv(huffmanpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/huffmanprca2.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}

state="CA"
district=3

garamendipr=data.frame()

for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= paste0("https://garamendi.house.gov/media/press-releases?page=", page_result)
page=read_html(link)



name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://garamendi.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)

garamendipr=rbind(garamendipr, data.frame(state, district, name, date, prpage))
 
}

 write.csv(garamendipr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/garamendiprca3.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}

state="CA"
district=4

mcclintockpr=data.frame()

for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= paste0("https://mcclintock.house.gov/newsroom/press-releases?page=", page_result)
page=read_html(link)



name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://mcclintock.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)

mcclintockpr=rbind(mcclintockpr, data.frame(state, district, name, date, prpage))
 
}

 write.csv(mcclintockpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/mcclintockprca4.csv")





get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}


state="CA"
district="5"

mthompsonpr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://mikethompson.house.gov/newsroom/press-releases?page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".views-field-title a") %>% html_text()
links=page%>%html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://mikethompson.house.gov", ., sep="")
date=page%>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
mthompsonpr=rbind(mthompsonpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(mthompsonpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/mthompsonprca5.csv")




get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
return(press_info)}


state="CA"
district="6"

matsuipr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://matsui.house.gov/media/press-releases?page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".font-weight-bold a") %>% html_text()
links=page%>%html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://matsui.house.gov", ., sep="")
date=page%>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
matsuipr=rbind(matsuipr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
} 
write.csv(matsuipr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/matsuiprca6.csv")



get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}


state="CA"
district="7"

berapr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://bera.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".views-field-title a") %>% html_text()
links=page%>%html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://bera.house.gov", ., sep="")
date=page%>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
berapr=rbind(berapr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(berapr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/beraprca7.csv")


get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".evo-content") %>% html_text() %>%str_trim
return(press_info)}


state="CA"
district="8"

obernoltepr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://obernolte.house.gov/media/press-releases?page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".font-weight-bold a") %>% html_text()
links=page%>%html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://obernolte.house.gov", ., sep="")
date=page%>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
obernoltepr=rbind(obernoltepr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(obernoltepr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/obernolteprca8.csv")








get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}


state="CA"
district="9"

mcnerneypr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://mcnerney.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".views-field-title a") %>% html_text()
links=page%>%html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://mcnerney.house.gov", ., sep="")
date=page%>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
mcnerneypr=rbind(mcnerneypr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(mcnerneypr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/mcnerneyprca9.csv")




get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
return(press_info)}


state="CA"
district="10"

harderpr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://harder.house.gov/media/press-releases?page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".font-weight-bold a") %>% html_text()
links=page%>%html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://harder.house.gov", ., sep="")
date=page%>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
harderpr=rbind(harderpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
} 
write.csv(harderpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/harderprca10.csv")

get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}

state="CA"
district="11"
desaulnierprca11=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://desaulnier.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)

name=page%>%html_nodes(".views-field-title a") %>% html_text()
links=page%>%html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://desaulnier.house.gov", ., sep="")
date=page%>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
desaulnierprca11=rbind(desaulnierprca11, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(desaulnierprca11, "C:/Users/bestf/OneDrive/Desktop/Press Releases/ desaulnierprca11.csv")





get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}

state="CA"
district="12"
pelosiprca12=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://pelosi.house.gov/news/press-releases?page=", page_result)
page=read_html(link)

name=page%>%html_nodes(".views-field-title a") %>% html_text()
links=page%>%html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://pelosi.house.gov", ., sep="")
date=page%>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
pelosiprca12=rbind(pelosiprca12, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(pelosiprca12, "C:/Users/bestf/OneDrive/Desktop/Press Releases/pelosiprca12.csv")



get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes("#newscontent") %>% html_text() %>%str_trim
return(press_info)}


state="CA"
district="13"

leepr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://lee.house.gov/news/press-releases?PageNum_rs=", page_result)
page=read_html(link)



name=page%>%html_nodes(".title a") %>% html_text()
links=page%>%html_nodes(".title a") %>% html_attr("href") %>% paste("https://lee.house.gov/", ., sep="")
date=page%>%html_nodes(".black") %>% html_text()
prpage=sapply(links, FUN=get_main)
leepr=rbind(leepr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(leepr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/leeprCA13.csv")



get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".content") %>% html_text() %>%str_trim
return(press_info)}


state="CA"
district="14"

speierpr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://speier.house.gov/press-releases?page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".ContentGrid") %>% html_text()
links=page%>%html_nodes(".ContentGrid") %>% html_attr("href") %>% paste("https://speier.house.gov/", ., sep="")
date=page%>%html_nodes(".recordListDate") %>% html_text()
prpage=sapply(links, FUN=get_main)
speierpr=rbind(speierpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(speierpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/speierprCA14.csv")


get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}


state="CA"
district="15"

swalwellpr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://swalwell.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".views-field-title a") %>% html_text()
links=page%>%html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://swalwell.house.gov/", ., sep="")
date=page%>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
swalwellpr=rbind(swalwellpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(swalwellpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/swalwellprCA15.csv")




get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes("p") %>% html_text() %>%str_trim
return(press_info)}


state="CA"
district="16"

costapr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://costa.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".views-field-title a") %>% html_text()
links=page%>%html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://costa.house.gov/", ., sep="")
date=page%>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
costapr=rbind(costapr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(costapr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/costaprCA16.csv")



get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}


state="CA"
district="17"

khannapr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://khanna.house.gov/media/press-releases?page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".views-field-title a") %>% html_text()
links=page%>%html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://khanna.house.gov/", ., sep="")
date=page%>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
khannapr=rbind(khannapr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(khannapr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/khannaprCA17.csv")



get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}


state="CA"
district="18"

eshoopr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://eshoo.house.gov/media/press-releases?page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".views-field-title a") %>% html_text()
links=page%>%html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://eshoo.house.gov/", ., sep="")
date=page%>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
eshoopr=rbind(eshoopr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(eshoopr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/eshooprCA18.csv")


get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}


state="CA"
district="19"

lofgrenpr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://lofgren.house.gov/media/press-releases?page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".views-field-title a") %>% html_text()
links=page%>%html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://lofgren.house.gov/", ., sep="")
date=page%>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
lofgrenpr=rbind(lofgrenpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(lofgrenpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/lofgrenprCA19.csv")


get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}


state="CA"
district="20"

panettapr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://panetta.house.gov/media/press-releases?page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".views-field-title a") %>% html_text()
links=page%>%html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://panetta.house.gov/", ., sep="")
date=page%>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
panettapr=rbind(panettapr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(panettapr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/panettaprCA20.csv")



get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}


state="CA"
district="21"

valadaopr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://valadao.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".newsie-titler a") %>% html_text()
links=page%>%html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://valadao.house.gov/news/", ., sep="")
date=page%>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
valadaopr=rbind(valadaopr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(valadaopr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/valadaoprCA21.csv")





get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}


state="CA"
district="23"

kevinmccarthypr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://kevinmccarthy.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".views-field-title a") %>% html_text()
links=page%>%html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://kevinmccarthy.house.gov/", ., sep="")
date=page%>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
kevinmccarthypr=rbind(kevinmccarthypr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(kevinmccarthypr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/kevinmccarthyprCA23.csv")


get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}


state="CA"
district="24"

carbajalpr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://carbajal.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".newsie-titler a") %>% html_text()
links=page%>%html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://carbajal.house.gov/news/", ., sep="")
date=page%>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
carbajalpr=rbind(carbajalpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(carbajalpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/carbajalprCA24.csv")



get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}


state="CA"
district="25"

mikegarciapr=data.frame()

for(page_result in seq (from=0, to=15, by=1))
{
link=paste0("https://mikegarcia.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".newsie-titler a") %>% html_text()
links=page%>%html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://mikegarcia.house.gov/news/", ., sep="")
date=page%>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
mikegarciapr=rbind(mikegarciapr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(mikegarciapr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/mikegarciaprCA25.csv")


get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes("#main .clearfix") %>% html_text() %>%str_trim
return(press_info)}


state="CA"
district="26"

juliabrownleypr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://juliabrownley.house.gov/category/press-releases/page/", page_result)
page=read_html(link)



name=page%>%html_nodes("h2 a") %>% html_text()
links=page%>%html_nodes("h2 a") %>% html_attr("href") %>% paste("", ., sep="")
date=page%>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
juliabrownleypr=rbind(juliabrownleypr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(juliabrownleypr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/juliabrownleyprCA26.csv")



get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}


state="CA"
district="27"

chupr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://chu.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".views-field-title a") %>% html_text()
links=page%>%html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://chu.house.gov/", ., sep="")
date=page%>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
chupr=rbind(chupr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(chupr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/chuprCA27.csv")



get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes("#press") %>% html_text() %>%str_trim
return(press_info)}


state="CA"
district="28"

schiffpr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://schiff.house.gov/news/press-releases?PageNum_rs=", page_result)
page=read_html(link)



name=page%>%html_nodes(".title a") %>% html_text()
links=page%>%html_nodes(".title a") %>% html_attr("href") %>% paste("https://schiff.house.gov/", ., sep="")
date=page%>%html_nodes(".black") %>% html_text()
prpage=sapply(links, FUN=get_main)
schiffpr=rbind(schiffpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(schiffpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/schiffprCA28.csv")




get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes("#press") %>% html_text() %>%str_trim
return(press_info)}


state="CA"
district="29"

cardenaspr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://cardenas.house.gov/media-center/press-releases?PageNum_rs=", page_result)
page=read_html(link)



name=page%>%html_nodes(".title a") %>% html_text()
links=page%>%html_nodes(".title a") %>% html_attr("href") %>% paste("https://cardenas.house.gov/", ., sep="")
date=page%>%html_nodes(".black") %>% html_text()
prpage=sapply(links, FUN=get_main)
cardenaspr=rbind(cardenaspr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(cardenaspr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/cardenasprCA29.csv")




get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}


state="CA"
district="30"

shermanpr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://sherman.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".views-field-title a") %>% html_text()
links=page%>%html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://sherman.house.gov/", ., sep="")
date=page%>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
shermanpr=rbind(shermanpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(shermanpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/shermanprCA30.csv")





get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".content") %>% html_text() %>%str_trim
return(press_info)}


state="CA"
district="31"

aguilarpr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://aguilar.house.gov/category/congress_press_release/page/", page_result)
page=read_html(link)



name=page%>%html_nodes("h2 a") %>% html_text()
links=page%>%html_nodes("h2 a") %>% html_attr("href") %>% paste("https://aguilar.house.gov/", ., sep="")
date=page%>%html_nodes(".date") %>% html_text()
prpage=sapply(links, FUN=get_main)
aguilarpr=rbind(aguilarpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(aguilarpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/aguilarprCA31.csv")




get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}



get_maind=function(links){
press_paged=read_html(links)
press_infod=press_paged %>% html_nodes(".topnewstext b") %>% html_text() %>%str_trim
return(press_infod)}



get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}


state="CA"
district="32"

napolitanopr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://napolitano.house.gov/media/press-releases?page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".views-field-title a") %>% html_text()
links=page%>%html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://napolitano.house.gov/", ., sep="")
date=page%>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
napolitanopr=rbind(napolitanopr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(napolitanopr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/napolitanoprCA32.csv")







get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}


state="CA"
district="33"

lieupr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://lieu.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".views-field-title a") %>% html_text()
links=page%>%html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://lieu.house.gov/", ., sep="")
date=page%>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
lieupr=rbind(lieupr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(lieupr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/lieuprCA33.csv")



get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}


state="CA"
district="34"

gomezpr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://gomez.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".newsie-titler a") %>% html_text()
links=page%>%html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://gomez.house.gov/news/", ., sep="")
date=page%>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
gomezpr=rbind(gomezpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(gomezpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/gomezprCA34.csv")




get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}


state="CA"
district="35"

torrespr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://torres.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".views-field-title a") %>% html_text()
links=page%>%html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://torres.house.gov", ., sep="")
date=page%>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
torrespr=rbind(torrespr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(torrespr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/torresprCA35.csv")




get_main=function(links){
press_page=read_html(links)
press_info=press_page%>%html_nodes("#zone-content")%>%html_text()
return(press_info)}

state="CA"
district=36

ruizpr=data.frame()

for(page_result in seq (from=0, to=15, by=1))

{
link=paste0("https://ruiz.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)

name=page%>%html_nodes(".views-field-title a")%>%html_text()
links=page%>%html_nodes(".views-field-title a")%>%html_attr("href")%>%paste("https://ruiz.house.gov", ., sep="")
date=page%>%html_nodes(".views-field-created .field-content")%>%html_text()
prpage=sapply(links, FUN=get_main)
ruizpr=rbind(ruizpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(ruizpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/ruizprCA36.csv")





get_main=function(links){
press_page=read_html(links)
press_info=press_page%>%html_nodes("#block-system-main")%>%html_text()
return(press_info)}

state="CA"
district=37

basspr=data.frame()

for(page_result in seq (from=0, to=15, by=1))

{
link=paste0("https://bass.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)

name=page%>%html_nodes(".views-field-title a")%>%html_text()
links=page%>%html_nodes(".views-field-title a")%>%html_attr("href")%>%paste("https://bass.house.gov", ., sep="")
date=page%>%html_nodes(".views-field-created .field-content")%>%html_text()
prpage=sapply(links, FUN=get_main)
basspr=rbind(basspr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(basspr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/bassprCA37.csv")




get_main=function(links){
press_page=read_html(links)
press_info=press_page%>%html_nodes("#block-system-main")%>%html_text()
return(press_info)}

state="CA"
district=38

sanchezpr=data.frame()

for(page_result in seq (from=0, to=15, by=1))

{
link=paste0("https://lindasanchez.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)

name=page%>%html_nodes(".views-field-title a")%>%html_text()
links=page%>%html_nodes(".views-field-title a")%>%html_attr("href")%>%paste("https://lindasanchez.house.gov", ., sep="")
date=page%>%html_nodes(".views-field-created .field-content")%>%html_text()
prpage=sapply(links, FUN=get_main)
sanchezpr=rbind(sanchezpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(sanchezpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/sanchezprCA38.csv")






get_main=function(links){
press_page=read_html(links)
press_info=press_page%>%html_nodes(".evo-press-release__body")%>%html_text()
return(press_info)}

state="CA"
district=39

youngkimpr=data.frame()

for(page_result in seq (from=0, to=15, by=1))

{
link=paste0("https://youngkim.house.gov/media/press-releases?page=", page_result)
page=read_html(link)

name=page%>%html_nodes(".font-weight-bold a")%>%html_text()
links=page%>%html_nodes(".font-weight-bold a")%>%html_attr("href")%>%paste("https://youngkim.house.gov", ., sep="")
date=page%>%html_nodes(".col-auto:nth-child(1)")%>%html_text()
prpage=sapply(links, FUN=get_main)
youngkimpr=rbind(youngkimpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(youngkimpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/youngkimprCA39.csv")





get_main=function(links){
press_page=read_html(links)
press_info=press_page%>%html_nodes(".buffer")%>%html_text()
return(press_info)}

get_maind=function(links){
press_paged=read_html(links)
press_infod=press_paged%>%html_nodes(".middleheadline+.topnewsbar b")%>%html_text()
return(press_infod)}

state="CA"
district=40

roybalallardpr=data.frame()

for(page_result in seq (from=0, to=15, by=1))

{
link=paste0("https://roybal-allard.house.gov/news/documentquery.aspx?DocumentTypeID=1465&Page=", page_result)
page=read_html(link)

name=page%>%html_nodes(".middleheadline")%>%html_text()
links=page%>%html_nodes(".middleheadline")%>%html_attr("href")%>%paste("https://roybal-allard.house.gov/news/", ., sep="")
date=sapply(links, FUN=get_maind)
prpage=sapply(links, FUN=get_main)
roybalallardpr=rbind(roybalallardpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(roybalallardpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/roybalallardprCA40.csv")


get_main=function(links){
press_page=read_html(links)
press_info=press_page%>%html_nodes("#press")%>%html_text()
return(press_info)}

state="CA"
district=41

takanopr=data.frame()

for(page_result in seq (from=1, to=15, by=1))

{
link=paste0("https://takano.house.gov/newsroom/press-releases?PageNum_rs=", page_result)
page=read_html(link)

name=page%>%html_nodes(".title a")%>%html_text()
links=page%>%html_nodes(".title a")%>%html_attr("href")%>%paste("https://takano.house.gov", ., sep="")
date=page%>%html_nodes("#press .black")%>%html_text()
prpage=sapply(links, FUN=get_main)
takanopr=rbind(takanopr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(takanopr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/takanoprCA41.csv")




get_main=function(links){
press_page=read_html(links)
press_info=press_page%>%html_nodes(".field-label-hidden .even ")%>%html_text()
return(press_info)}

state="CA"
district=42

calvertpr=data.frame()

for(page_result in seq (from=0, to=15, by=1))

{
link=paste0("https://calvert.house.gov/media/press-releases?page=", page_result)
page=read_html(link)

name=page%>%html_nodes(".views-field-title a")%>%html_text()
links=page%>%html_nodes(".views-field-title a")%>%html_attr("href")%>%paste("https://calvert.house.gov", ., sep="")
date=page%>%html_nodes(".views-field-created .field-content")%>%html_text()
prpage=sapply(links, FUN=get_main)
calvertpr=rbind(calvertpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(calvertpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/calvertprCA42.csv")





get_main=function(links){
press_page=read_html(links)
press_info=press_page%>%html_nodes("#block-system-main")%>%html_text()
return(press_info)}

state="CA"
district=43

waterspr=data.frame()

for(page_result in seq (from=0, to=15, by=1))

{
link=paste0("https://waters.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)

name=page%>%html_nodes(".views-field-title a")%>%html_text()
links=page%>%html_nodes(".views-field-title a")%>%html_attr("href")%>%paste("https://waters.house.gov", ., sep="")
date=page%>%html_nodes(".views-field-created .field-content")%>%html_text()
prpage=sapply(links, FUN=get_main)
waterspr=rbind(waterspr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(waterspr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/watersprCA43.csv")




get_main=function(links){
press_page=read_html(links)
press_info=press_page%>%html_nodes(".content")%>%html_text()
return(press_info)}

state="CA"
district=44

barraganpr=data.frame()

for(page_result in seq (from=1, to=15, by=1))

{
link=paste0("https://barragan.house.gov/category/press-releases/page/", page_result)
page=read_html(link)

name=page%>%html_nodes(".info h2")%>%html_text()
links=page%>%html_nodes("#main .btn")%>%html_attr("href")%>%paste("", ., sep="")
prpage=sapply(links, FUN=get_main)
date=page%>%html_nodes(".date")%>%html_text()
barraganpr=rbind(barraganpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(barraganpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/barraganprCA44.csv")







get_main=function(links){
press_page=read_html(links)
press_info=press_page%>%html_nodes("#block-system-main p")%>%html_text()
return(press_info)}

state="CA"
district="45"

porterpr=data.frame()

for(page_result in seq (from=0, to=15, by=1))

{
link=paste0("https://porter.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)

name=page%>%html_nodes(".newsie-titler a")%>%html_text()
links=page%>%html_nodes(".newsie-titler a")%>%html_attr("href")%>%paste("https://porter.house.gov/news/", ., sep="")
date=page%>%html_nodes("time")%>%html_text()
prpage=sapply(links, FUN=get_main)
porterpr=rbind(porterpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(porterpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/porterprCA45.csv")







get_main=function(links){
press_page=read_html(links)
press_info=press_page%>%html_nodes("#main_column")%>%html_text()
return(press_info)}

state="CA"
district=46

correapr=data.frame()

for(page_result in seq (from=1, to=15, by=1))

{
link=paste0("https://correa.house.gov/press?PageNum_rs=", page_result)
page=read_html(link)

name=page%>%html_nodes(".title a")%>%html_text()
links=page%>%html_nodes(".title a")%>%html_attr("href")%>%paste("https://correa.house.gov", ., sep="")
date=page%>%html_nodes("#press .black")%>%html_text()
prpage=sapply(links, FUN=get_main)
correapr=rbind(correapr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(correapr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/correaprCA46.csv")




get_main=function(links){
press_page=read_html(links)
press_info=press_page%>%html_nodes("#block-system-main")%>%html_text()
return(press_info)}

state="CA"
district=47

lowenthalpr=data.frame()

for(page_result in seq (from=0, to=15, by=1))

{
link=paste0("https://lowenthal.house.gov/media/press-releases?page=", page_result)
page=read_html(link)

name=page%>%html_nodes(".views-field-title a")%>%html_text()
links=page%>%html_nodes(".views-field-title a")%>%html_attr("href")%>%paste("https://lowenthal.house.gov", ., sep="")
date=page%>%html_nodes(".views-field-created .field-content")%>%html_text()
prpage=sapply(links, FUN=get_main)
lowenthalpr=rbind(lowenthalpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(lowenthalpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/lowenthalprCA47.csv")

get_main=function(links){
press_page=read_html(links)
press_info=press_page%>%html_nodes(".evo-press-release__body")%>%html_text()
return(press_info)}

state="CA"
district=48

steelpr=data.frame()

for(page_result in seq (from=0, to=15, by=1))

{
link=paste0("https://steel.house.gov/media/press-releases?page=", page_result)
page=read_html(link)

name=page%>%html_nodes(".font-weight-bold a")%>%html_text()
links=page%>%html_nodes(".font-weight-bold a")%>%html_attr("href")%>%paste("https://steel.house.gov", ., sep="")
date=page%>%html_nodes(".col-auto:nth-child(1)")%>%html_text()
prpage=sapply(links, FUN=get_main)
steelpr=rbind(steelpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(steelpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/steelprCA48.csv")



get_main=function(links){
press_page=read_html(links)
press_info=press_page%>%html_nodes("#main_column")%>%html_text()
return(press_info)}

state="CA"
district=49

mikelevinpr=data.frame()

for(page_result in seq (from=1, to=15, by=1))

{
link=paste0("https://mikelevin.house.gov/media/press-releases?PageNum_rs=", page_result)
page=read_html(link)

name=page%>%html_nodes(".title a")%>%html_text()
links=page%>%html_nodes(".title a")%>%html_attr("href")%>%paste("https://mikelevin.house.gov", ., sep="")
date=page%>%html_nodes(".black")%>%html_text()
prpage=sapply(links, FUN=get_main)
mikelevinpr=rbind(mikelevinpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(mikelevinpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/mikelevinprCA49.csv")






get_main=function(links){
press_page=read_html(links)
press_info=press_page%>%html_nodes(".evo-content")%>%html_text()
return(press_info)}

state="CA"
district=50

issapr=data.frame()

for(page_result in seq (from=0, to=15, by=1))

{
link=paste0("https://issa.house.gov/media/press-releases?page=", page_result)
page=read_html(link)

name=page%>%html_nodes(".font-weight-bold a")%>%html_text()
links=page%>%html_nodes(".font-weight-bold a")%>%html_attr("href")%>%paste("https://issa.house.gov", ., sep="")
date=page%>%html_nodes(".col-auto:nth-child(1)")%>%html_text()
prpage=sapply(links, FUN=get_main)
issapr=rbind(issapr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(issapr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/prsample/issaprCA50.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".even") %>% html_text() %>%str_trim
return(press_info)}

state="CA"
district=51

vargaspr=data.frame()

for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= paste0("https://vargas.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)



name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://vargas.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)

vargaspr=rbind(vargaspr, data.frame(state, district, name, date, prpage))
 
}

 write.csv(vargaspr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/vargasprca51.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".even") %>% html_text() %>%str_trim
return(press_info)}

state="CA"
district=52

scottpeterspr=data.frame()

for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= paste0("https://scottpeters.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)



name=page %>% html_nodes("#block-system-main .views-field-title a") %>% html_text()
links=page %>% html_nodes("#block-system-main .views-field-title a") %>% html_attr("href") %>% paste("https://scottpeters.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)

scottpeterspr=rbind(scottpeterspr, data.frame(state, district, name, date, prpage))
 
}

 write.csv(scottpeterspr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/scottpetersprca52.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}

state="CA"
district=53

sarajacobspr=data.frame()

for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= paste0("https://sarajacobs.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://sarajacobs.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)

sarajacobspr=rbind(sarajacobspr, data.frame(state, district, name, date, prpage))
 
}

 write.csv(sarajacobspr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/sarajacobsprca53.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".even") %>% html_text() %>%str_trim
return(press_info)}

state="CO"
district=1

degettepr=data.frame()

for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= paste0("https://degette.house.gov/newsroom/press-releases?page=", page_result)
page=read_html(link)



name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://degette.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)

degettepr=rbind(degettepr, data.frame(state, district, name, date, prpage))
 
}

 write.csv(degettepr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/degetteprco1.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#main_column") %>% html_text() %>%str_trim
return(press_info)}

state="CO"
district=2

negusepr=data.frame()

for(page_result in seq(from = 1 , to = 15, by = 1))
{
link= paste0("https://neguse.house.gov/media/press-releases?PageNum_rs=", page_result)
page=read_html(link)



name=page %>% html_nodes(".title a") %>% html_text()
links=page %>% html_nodes(".title a") %>% html_attr("href") %>% paste("https://neguse.house.gov", ., sep="")
date=page %>%html_nodes(".black") %>% html_text()
prpage=sapply(links, FUN=get_main)

negusepr=rbind(negusepr, data.frame(state, district, name, date, prpage))
 
}

 write.csv(negusepr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/neguseprco2.csv")




get_main=function(links){
press_page=read_html(links)
press_info=press_page%>%html_nodes(".evo-content")%>%html_text()
return(press_info)}

state="CO"
district=3

boebertpr=data.frame()

for(page_result in seq (from=1, to=15, by=1))

{
link=paste0("https://boebert.house.gov/media/press-releases?page=", page_result)
page=read_html(link)

name=page%>%html_nodes(".font-weight-bold a")%>%html_text()
links=page%>%html_nodes(".font-weight-bold a")%>%html_attr("href")%>%paste("https://boebert.house.gov", ., sep="")
date=page%>%html_nodes(".col-auto:nth-child(1)")%>%html_text()
prpage=sapply(links, FUN=get_main)
boebertpr=rbind(boebertpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(boebertpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/boebertprCO3.csv")



get_main=function(links){
press_page=read_html(links)
press_info=press_page%>%html_nodes("p:nth-child(1)")%>%html_text()
return(press_info)}

state="CO"
district=4

buckpr=data.frame()

for(page_result in seq (from=0, to=15, by=1))

{
link=paste0("https://buck.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)

name=page%>%html_nodes(".views-field-title a")%>%html_text()
links=page%>%html_nodes(".views-field-title a")%>%html_attr("href")%>%paste("https://buck.house.gov", ., sep="")
date=page%>%html_nodes(".views-field-created .field-content")%>%html_text()
prpage=sapply(links, FUN=get_main)
buckpr=rbind(buckpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(buckpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/buckprCO4.csv")




get_main=function(links){
press_page=read_html(links)
press_info=press_page%>%html_nodes("#block-system-main")%>%html_text()
return(press_info)}

state="CO"
district=5

lambornpr=data.frame()

for(page_result in seq (from=0, to=15, by=1))

{
link=paste0("https://lamborn.house.gov/media/press-releases?page=", page_result)
page=read_html(link)

name=page%>%html_nodes(".views-field-title a")%>%html_text()
links=page%>%html_nodes(".views-field-title a")%>%html_attr("href")%>%paste("https://lamborn.house.gov", ., sep="")
date=page%>%html_nodes(".views-field-created .field-content")%>%html_text()
prpage=sapply(links, FUN=get_main)
lambornpr=rbind(lambornpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(lambornpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/lambornprCO5.csv")





get_main=function(links){
press_page=read_html(links)
press_info=press_page%>%html_nodes(".evo-content")%>%html_text()
return(press_info)}

state="CO"
district=6

crowpr=data.frame()

for(page_result in seq (from=0, to=15, by=1))

{
link=paste0("https://crow.house.gov/media/press-releases?page=", page_result)
page=read_html(link)

name=page%>%html_nodes(".font-weight-bold a")%>%html_text()
links=page%>%html_nodes(".font-weight-bold a")%>%html_attr("href")%>%paste("https://crow.house.gov", ., sep="")
date=page%>%html_nodes(".col-auto:nth-child(1)")%>%html_text()
prpage=sapply(links, FUN=get_main)
crowpr=rbind(crowpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(crowpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/crowprCO6.csv")


get_main=function(links){
press_page=read_html(links)
press_info=press_page%>%html_nodes(".bodycopy")%>%html_text()
return(press_info)}

state="CO"
district=7

perlmutterpr=data.frame()

for(page_result in seq (from=1, to=15, by=1))

{
link=paste0("https://perlmutter.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)

name=page%>%html_nodes(".newsie-titler a")%>%html_text()
links=page%>%html_nodes(".newsie-titler a")%>%html_attr("href")%>%paste("https://perlmutter.house.gov/news/", ., sep="")
date=page%>%html_nodes("#newsdoclist time")%>%html_text()
prpage=sapply(links, FUN=get_main)
perlmutterpr=rbind(perlmutterpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(perlmutterpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/perlmutterprCO7.csv")





get_main=function(links){
press_page=read_html(links)
press_info=press_page%>%html_nodes(".bodycopy")%>%html_text()
return(press_info)}

state="DE"
district=1

bluntrochesterpr=data.frame()

for(page_result in seq (from=1, to=15, by=1))

{
link=paste0("https://bluntrochester.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)

name=page%>%html_nodes(".newsie-titler a")%>%html_text()
links=page%>%html_nodes(".newsie-titler a")%>%html_attr("href")%>%paste("https://bluntrochester.house.gov/news/", ., sep="")
date=page%>%html_nodes("time")%>%html_text()
prpage=sapply(links, FUN=get_main)
bluntrochesterpr=rbind(bluntrochesterpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(bluntrochesterpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/bluntrochesterprDE1.csv")



get_main=function(links){
press_page=read_html(links)
press_info=press_page%>%html_nodes("#block-system-main")%>%html_text()
return(press_info)}

state="DC"
district=1

nortonpr=data.frame()

for(page_result in seq (from=1, to=15, by=1))

{
link=paste0("https://norton.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)

name=page%>%html_nodes(".views-field-title a")%>%html_text()
links=page%>%html_nodes(".views-field-title a")%>%html_attr("href")%>%paste("https://norton.house.gov/", ., sep="")
date=page%>%html_nodes(".views-field-created .field-content")%>%html_text()
prpage=sapply(links, FUN=get_main)
nortonpr=rbind(nortonpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(nortonpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/nortonprDC1.csv")


get_main=function(links){
press_page=read_html(links)
press_info=press_page%>%html_nodes("#block-system-main")%>%html_text()
return(press_info)}

state="FL"
district=1

gaetzpr=data.frame()

for(page_result in seq (from=1, to=15, by=1))

{
link=paste0("https://gaetz.house.gov/media/press-releases?page=", page_result)
page=read_html(link)

name=page%>%html_nodes(".views-field-title a")%>%html_text()
links=page%>%html_nodes(".views-field-title a")%>%html_attr("href")%>%paste("https://gaetz.house.gov/", ., sep="")
date=page%>%html_nodes(".views-field-created .field-content")%>%html_text()
prpage=sapply(links, FUN=get_main)
gaetzpr=rbind(gaetzpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(gaetzpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/gaetzprFL1.csv")

get_main=function(links){
press_page=read_html(links)
press_info=press_page%>%html_nodes(".post-content")%>%html_text()
return(press_info)}

state="FL"
district=2

dunnpr=data.frame()

for(page_result in seq (from=1, to=15, by=1))

{
link=paste0("https://dunn.house.gov/press-releases?page=", page_result)
page=read_html(link)

name=page%>%html_nodes(".ContentGrid")%>%html_text()
links=page%>%html_nodes(".ContentGrid")%>%html_attr("href")%>%paste("https://dunn.house.gov/", ., sep="")
date=page%>%html_nodes(".recordListDate")%>%html_text()
prpage=sapply(links, FUN=get_main)
dunnpr=rbind(dunnpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(dunnpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/dunnprFL2.csv")


get_main=function(links){
press_page=read_html(links)
press_info=press_page%>%html_nodes(".evo-press-release__body")%>%html_text()
return(press_info)}

state="FL"
district=3

cammackpr=data.frame()

for(page_result in seq (from=1, to=15, by=1))

{
link=paste0("https://cammack.house.gov/media/press-releases?page=", page_result)
page=read_html(link)

name=page%>%html_nodes(".font-weight-bold a")%>%html_text()
links=page%>%html_nodes(".font-weight-bold a")%>%html_attr("href")%>%paste("https://cammack.house.gov/", ., sep="")
date=page%>%html_nodes(".col-auto:nth-child(1)")%>%html_text()
prpage=sapply(links, FUN=get_main)
cammackpr=rbind(cammackpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(cammackpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/cammackprFL3.csv")



get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}


state="GA"
district="11"

loudermilkpr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://loudermilk.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".middleheadline b") %>% html_text()
links=page%>%html_nodes(".middlelinks") %>% html_attr("href") %>% paste("https://loudermilk.house.gov/news/", ., sep="")
date=page%>%html_nodes("br+ b") %>% html_text()
prpage=sapply(links, FUN=get_main)
loudermilkpr=rbind(loudermilkpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(loudermilkpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/loudermilkprGA11.csv")


get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}


state="HI"
district="1"

casepr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://case.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".newsie-titler a") %>% html_text()
links=page%>%html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://case.house.gov/news/", ., sep="")
date=page%>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
casepr=rbind(casepr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(casepr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/caseprHI1.csv")


get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}


state="NC"
district="1"

butterfieldpr=data.frame()

for(page_result in seq (from= 1, to=15, by=1))
{
link=paste0("https://butterfield.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".views-field-title a") %>% html_text()
links=page%>%html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://butterfield.house.gov/", ., sep="")
date=page%>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
butterfieldpr=rbind(butterfieldpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(butterfieldpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/butterfieldprNC1.csv")

press_page=read_html(links)
press_info=press_page %>% html_nodes(".even") %>% html_text() %>%str_trim
return(press_info)}


state="NC"
district="4"

pricepr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://price.house.gov/newsroom/press-releases?page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".views-field-title a") %>% html_text()
links=page%>%html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://price.house.gov/", ., sep="")
date=page%>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
pricepr=rbind(pricepr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(pricepr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/priceprNC4.csv")


get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}


state="NC"
district="5"

foxxpr=data.frame()

for(page_result in seq (from= 1, to=15, by=1))
{
link=paste0("https://foxx.house.gov/news/documentquery.aspx?DocumentTypeID=2367&Page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".newsie-titler a") %>% html_text()
links=page%>%html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://foxx.house.gov/news/", ., sep="")
date=page%>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
foxxpr=rbind(foxxpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(foxxpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/foxxprNC5.csv")

get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}


state="NY"
district="1"

zeldinpr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://zeldin.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".views-field-title a") %>% html_text()
links=page%>%html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://zeldin.house.gov/", ., sep="")
date=page%>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
zeldinpr=rbind(zeldinpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(zeldinpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/zeldinprNY1.csv")





get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".field-type-text-with-summary .even") %>% html_text() %>%str_trim
return(press_info)}


state="TN"
district="8"

kustoffpr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://kustoff.house.gov/media/press-releases?page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".views-field-title a") %>% html_text()
links=page%>%html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://kustoff.house.gov/", ., sep="")
date=page%>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
kustoffpr=rbind(kustoffpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(kustoffpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/kustoffprTN8.csv")





get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes("#content") %>% html_text() %>%str_trim
return(press_info)}


state="TN"
district="7"

markgreenpr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://markgreen.house.gov/press-releases?page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".ContentGrid") %>% html_text()
links=page%>%html_nodes(".ContentGrid") %>% html_attr("href") %>% paste("https://markgreen.house.gov/", ., sep="")
date=page%>%html_nodes(".recordListDate") %>% html_text()
prpage=sapply(links, FUN=get_main)
markgreenpr=rbind(markgreenpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(markgreenpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/markgreenprTN7.csv")




get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}


state="TX"
district="1"

gohmertpr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://gohmert.house.gov/news/documentquery.aspx?DocumentTypeID=1954&Page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".newsie-titler a") %>% html_text()
links=page%>%html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://gohmert.house.gov/news/", ., sep="")
date=page%>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
gohmertpr=rbind(gohmertpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(gohmertpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/gohmertprTX1.csv")




get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}


state="TX"
district="3"

vantaylorpr=data.frame()

for(page_result in seq (from= 0, to=16, by=1))
{
link=paste0("https://vantaylor.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".news-title a") %>% html_text()
links=page%>%html_nodes(".news-title a") %>% html_attr("href") %>% paste("https://vantaylor.house.gov/", ., sep="")
date=page%>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
vantaylorpr=rbind(vantaylorpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(vantaylorpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/vantaylorprTX3.csv")


https://williams.house.gov/media-center/press-releases?page=



get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}


state="TX"
district="25"

williamspr=data.frame()

for(page_result in seq (from= 1, to=15, by=1))
{
link=paste0("https://williams.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".views-field-title a") %>% html_text()
links=page%>%html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://williams.house.gov/", ., sep="")
date=page%>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
williamspr=rbind(williamspr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(williamspr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/williamsprTX25.csv")






get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}


state="TX"
district="25"

cloudpr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://cloud.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".newsie-titler a") %>% html_text()
links=page%>%html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://cloud.house.gov/news/", ., sep="")
date=page%>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
cloudpr=rbind(cloudpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(cloudpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/cloudprTX25.csv")





get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}


state="TX"
district="33"

veaseypr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://veasey.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".views-field-title a") %>% html_text()
links=page%>%html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://veasey.house.gov", ., sep="")
date=page%>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
veaseypr=rbind(veaseypr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(veaseypr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/veaseyprTX33.csv")



get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes("td") %>% html_text() %>%str_trim
return(press_info)}


state="VA"
district="1"

wittmanpr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://wittman.house.gov/news/documentquery.aspx?DocumentTypeID=2670&Page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".newsie-titler a") %>% html_text()
links=page%>%html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://wittman.house.gov/news/", ., sep="")
date=page%>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
wittmanpr=rbind(wittmanpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(wittmanpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/wittmanprVA1.csv")



get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
return(press_info)}


state="VA"
district="6"

clinepr=data.frame()

for(page_result in seq (from= 1, to=15, by=1))
{
link=paste0("https://cline.house.gov/media/press-releases?page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".font-weight-bold a") %>% html_text()
links=page%>%html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://cline.house.gov", ., sep="")
date=page%>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
clinepr=rbind(clinepr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(clinepr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/clineprVA6.csv")





get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".evo-content") %>% html_text() %>%str_trim
return(press_info)}


state="WA"
district="4"

newhousepr=data.frame()

for(page_result in seq (from= 1, to=15, by=1))
{
link=paste0("https://newhouse.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".font-weight-bold a") %>% html_text()
links=page%>%html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://newhouse.house.gov", ., sep="")
date=page%>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
newhousepr=rbind(newhousepr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(newhousepr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/newhouseprWA4.csv")




get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes("#newscontent") %>% html_text() %>%str_trim
return(press_info)}


state="WA"
district="6"

kilmerpr=data.frame()

for(page_result in seq (from= 0, to=12, by=1))
{
link=paste0("https://kilmer.house.gov/news/press-releases?PageNum_rs=", page_result)
page=read_html(link)



name=page%>%html_nodes(".title a") %>% html_text()
links=page%>%html_nodes(".title a") %>% html_attr("href") %>% paste("https://kilmer.house.gov", ., sep="")
date=page%>%html_nodes("#press .black") %>% html_text()
prpage=sapply(links, FUN=get_main)
kilmerpr=rbind(kilmerpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(kilmerpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/kilmerprWA6.csv")




get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".post-content") %>% html_text() %>%str_trim
return(press_info)}

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}

state="CA"
district=3

garamendipr=data.frame()

for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= paste0("https://garamendi.house.gov/media/press-releases?page=", page_result)
page=read_html(link)



name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://garamendi.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)

garamendipr=rbind(garamendipr, data.frame(state, district, name, date, prpage))
 
}

 write.csv(garamendipr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/garamendiprca3.csv")








get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes("#main_column") %>% html_text() %>%str_trim
return(press_info)}


state="CA"
district="46"

correapr=data.frame()

for(page_result in seq (from= 0, to=16, by=1))
{
link=paste0("https://correa.house.gov/press?PageNum_rs=", page_result)
page=read_html(link)



name=page%>%html_nodes(".title a") %>% html_text()
links=page%>%html_nodes(".title a") %>% html_attr("href") %>% paste("https://correa.house.gov", ., sep="")
date=page%>%html_nodes("#press .black") %>% html_text()
prpage=sapply(links, FUN=get_main)
correapr=rbind(correapr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(correapr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/correaprCA46.csv")

get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}

get_maind=function(links){
press_paged=read_html(links)
press_infod=press_paged %>% html_nodes(".middleheadline+ .topnewsbar b") %>% html_text() %>%str_trim
return(press_infod)}


state="FL"
district="21"

frankelpr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://frankel.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".middleheadline") %>% html_text()
links=page%>%html_nodes(".middleheadline") %>% html_attr("href") %>% paste("https://frankel.house.gov/news/", ., sep="")
date=page%>%html_nodes(".news_date_int") %>% html_text()
prpage=sapply(links, FUN=get_main)
date=sapply(links, FUN=get_maind)
frankelpr=rbind(frankelpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(frankelpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/frankelprFL21.csv")




get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".page-content") %>% html_text() %>%str_trim
return(press_info)}


state="IL"
district="17"

bustospr=data.frame()

for(page_result in seq (from= 1, to=15, by=1))
{
link=paste0("https://bustos.house.gov/category/press-release/page/", page_result)
page=read_html(link)



name=page%>%html_nodes("h2 a") %>% html_text()
links=page%>%html_nodes("h2 a") %>% html_attr("href") %>% paste("", ., sep="")
date=page%>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
bustospr=rbind(bustospr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(bustospr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/bustosprIL17.csv")




get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".clearfix") %>% html_text() %>%str_trim
return(press_info)}


state="IL"
district="18"

lahoodpr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://lahood.house.gov/press-releases?page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".ContentGrid") %>% html_text()
links=page%>%html_nodes(".ContentGrid") %>% html_attr("href") %>% paste("https://lahood.house.gov", ., sep="")
date=page%>%html_nodes(".recordListDate") %>% html_text()
prpage=sapply(links, FUN=get_main)
lahoodpr=rbind(lahoodpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(lahoodpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/lahoodprIL18.csv")





get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".content") %>% html_text() %>%str_trim
return(press_info)}


state="KY"
district="6"

barrpr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://barr.house.gov/press-releases?page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".ContentGrid") %>% html_text()
links=page%>%html_nodes(".ContentGrid") %>% html_attr("href") %>% paste("https://barr.house.gov", ., sep="")
date=page%>%html_nodes(".recordListDate") %>% html_text()
prpage=sapply(links, FUN=get_main)
barrpr=rbind(barrpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(barrpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/barrprKY6.csv")





get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}


state="MI"
district="1"

bergmanpr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://bergman.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".newsie-titler a") %>% html_text()
links=page%>%html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://bergman.house.gov/news/", ., sep="")
date=page%>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
bergmanpr=rbind(bergmanpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(bergmanpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/bergmanprMI1.csv")




get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}


state="MS"
district="1"

trentkellypr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://trentkelly.house.gov/newsroom/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".middleheadline a") %>% html_text()
links=page%>%html_nodes(".middleheadline a") %>% html_attr("href") %>% paste("https://trentkelly.house.gov/news/", ., sep="")
date=page%>%html_nodes("#newsdoclist time") %>% html_text()
prpage=sapply(links, FUN=get_main)
trentkellypr=rbind(trentkellypr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(trentkellypr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/trentkellyprMS1.csv")




get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".content") %>% html_text() %>%str_trim
return(press_info)}


state="NC"
district="7"

rouzerpr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://rouzer.house.gov/press-releases?page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".ContentGrid") %>% html_text()
links=page%>%html_nodes(".ContentGrid") %>% html_attr("href") %>% paste("https://rouzer.house.gov/", ., sep="")
date=page%>%html_nodes(".recordListDate") %>% html_text()
prpage=sapply(links, FUN=get_main)
rouzerpr=rbind(rouzerpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(rouzerpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/rouzerprNC7.csv")






get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}


state="NC"
district="13"

buddpr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://budd.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".newsie-titler a") %>% html_text()
links=page%>%html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://budd.house.gov/news/", ., sep="")
date=page%>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
buddpr=rbind(buddpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(buddpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/buddprNC13.csv")




get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}


state="NE"
district="2"

baconpr=data.frame()

for(page_result in seq (from=1, to=15, by=1))
{
link=paste0("https://bacon.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".newsie-titler a") %>% html_text()
links=page%>%html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://bacon.house.gov/news/", ., sep="")
date=page%>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
baconpr=rbind(baconpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(baconpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/baconprNE2.csv")




get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}


state="NE"
district="3"

adriansmithpr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://adriansmith.house.gov/newsroom/press-releases?page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".views-field-title a") %>% html_text()
links=page%>%html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://adriansmith.house.gov", ., sep="")
date=page%>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
adriansmithpr=rbind(adriansmithpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(adriansmithpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/adriansmithprNE3.csv")


https://watsoncoleman.house.gov/newsroom/documentquery.aspx?DocumentTypeID=27




get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}


state="NJ"
district="12"

watsoncolemanpr=data.frame()

for(page_result in seq (from=1, to=15, by=1))
{
link=paste0("https://watsoncoleman.house.gov/newsroom/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)


name=page%>%html_nodes("#ctl00_ContentCell h2") %>% html_text()
links=page%>%html_nodes(".UnorderedNewsList a") %>% html_attr("href") %>% paste("https://watsoncoleman.house.gov/newsroom/", ., sep="")
date=page%>%html_nodes(".date") %>% html_text()
prpage=sapply(links, FUN=get_main)
watsoncolemanpr=rbind(watsoncolemanpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(watsoncolemanpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/watsoncolemanprNj12.csv")





get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}


state="NY"
district="20"

tonkopr=data.frame()

for(page_result in seq (from= 0, to=15, by=1))
{
link=paste0("https://tonko.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)


name=page%>%html_nodes(".newsie-titler a") %>% html_text()
links=page%>%html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://tonko.house.gov/news/", ., sep="")
date=page%>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
tonkopr=rbind(tonkopr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(tonkopr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/tonkoprNY20.csv")




get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes("#content") %>% html_text() %>%str_trim
return(press_info)}


state="OH"
district="8"

davidsonpr=data.frame()

for(page_result in seq (from=1, to=15, by=1))
{
link=paste0("https://davidson.house.gov/press-releases?page=", page_result)
page=read_html(link)

name=page%>%html_nodes(".ContentGrid") %>% html_text()
links=page%>%html_nodes(".ContentGrid") %>% html_attr("href") %>% paste("https://davidson.house.gov", ., sep="")
date=page%>%html_nodes(".recordListDate") %>% html_text()
prpage=sapply(links, FUN=get_main)
davidsonpr=rbind(davidsonpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(davidsonpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/davidsonprOH8.csv")





get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes("#content") %>% html_text() %>%str_trim
return(press_info)}


state="OH"
district="8"

davidsonpr=data.frame()

for(page_result in seq (from=1, to=15, by=1))
{
link=paste0("https://davidson.house.gov/press-releases?page=", page_result)
page=read_html(link)

name=page%>%html_nodes(".ContentGrid") %>% html_text()
links=page%>%html_nodes(".ContentGrid") %>% html_attr("href") %>% paste("https://davidson.house.gov", ., sep="")
date=page%>%html_nodes(".recordListDate") %>% html_text()
prpage=sapply(links, FUN=get_main)
davidsonpr=rbind(davidsonpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(davidsonpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/davidsonprOH8.csv")




get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}


state="PA"
district="5"

thompsonpr=data.frame()

for(page_result in seq (from=1, to=15, by=1))
{
link=paste0("https://thompson.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)

name=page%>%html_nodes(".views-field-title a") %>% html_text()
links=page%>%html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://thompson.house.gov", ., sep="")
date=page%>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
thompsonpr=rbind(thompsonpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(thompsonpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/thompsonprPA15.csv")













get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
hollingsworthin9pr=data.frame()
state="IN"
district=9
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://hollingsworth.house.gov/news/documentquery.aspx?DocumentTypeID=27", 
page_result)
page=read_html(link)
name=page %>% html_nodes("h2 a") %>% html_text()
links=page %>% html_nodes("h2 a") %>% html_attr("href") %>% 
paste("https://hollingsworth.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
hollingsworthin9pr=rbind(hollingsworthin9pr, data.frame(state, district, name, date, prpage))
}
View(hollingsworthin9pr)

write.csv(hollingsworthin9pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/hollingsworthin9pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
hinsonia1pr=data.frame()
state="IA"
district=1
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://hinson.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://hinson.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
hinsonia1pr=rbind(hinsonia1pr, data.frame(state, district, name, date, prpage))
}
View(hinsonia1pr)

write.csv(hinsonia1pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/hinsonia1pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
millermeeksia2pr=data.frame()
state="IA"
district=2
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://millermeeks.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://millermeeks.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
millermeeksia2pr=rbind(millermeeksia2pr, data.frame(state, district, name, date, prpage))
}
View(millermeeksia2pr)

write.csv(millermeeksia2pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/millermeeksia2pr.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".pane-node-body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
axneia3pr=data.frame()
state="IA"
district=3
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://axne.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://axne.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
axneia3pr=rbind(axneia3pr, data.frame(state, district, name, date, prpage))
}
View(axneia3pr)

write.csv(axneia3pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/axneia3.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
feenstraia4pr=data.frame()
state="IA"
district=4
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://feenstra.house.gov/media/press-releases?page=1", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://feenstra.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
feenstraia4pr=rbind(feenstraia4pr, data.frame(state, district, name, date, prpage))
}
View(feenstraia4pr)

write.csv(feenstraia4pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/feenstraia4pr.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
mannks1pr=data.frame()
state="KS"
district=1
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://mann.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://mann.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
mannks1pr=rbind(mannks1pr, data.frame(state, district, name, date, prpage))
}
View(mannks1pr)

write.csv(mannks1pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/mannks1pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
laturnerks2pr=data.frame()
state="KS"
district=2
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://laturner.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://laturner.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
laturnerks2pr=rbind(laturnerks2pr, data.frame(state, district, name, date, prpage))
}
View(laturnerks2pr)

write.csv(laturnerks2pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/laturnerks2pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-label-hidden .even") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
davidsks3pr=data.frame()
state="KS"
district=3
for(page_result in seq(from = 1, to = 15, by = 1))
{
link= 
paste0("https://davids.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://davids.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
davidsks3pr=rbind(davidsks3pr, data.frame(state, district, name, date, prpage))
}
View(davidsks3pr)

write.csv(davidsks3pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/davidsks3pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
estesks4pr=data.frame()
state="KS"
district=4
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://estes.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://estes.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
estesks4pr=rbind(estesks4pr, data.frame(state, district, name, date, prpage))
}
View(estesks4pr)

write.csv(estesks4pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/estesks4pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".content") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
comerky1pr=data.frame()
state="KY"
district=1
for(page_result in seq(from = 1, to = 15, by = 1))
{
link= 
paste0("https://comer.house.gov/press-release?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".ContentGrid") %>% html_text()
links=page %>% html_nodes(".ContentGrid") %>% html_attr("href") %>% 
paste("https://comer.house.gov", ., sep="")
date=page %>%html_nodes(".recordListDate") %>% html_text()
prpage=sapply(links, FUN=get_main)
comerky1pr=rbind(comerky1pr, data.frame(state, district, name, date, prpage))
}
View(comerky1pr)

write.csv(comerky1pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/comerky1pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
guthrieky2pr=data.frame()
state="KY"
district=2
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://guthrie.house.gov/news/documentquery.aspx?DocumentTypeID=2381&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://guthrie.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
guthrieky2pr=rbind(guthrieky2pr, data.frame(state, district, name, date, prpage))
}
View(guthrieky2pr)

write.csv(guthrieky2pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/guthrieky2pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
yarmuthky3pr=data.frame()
state="KY"
district=3
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://yarmuth.house.gov/press?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://yarmuth.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
yarmuthky3pr=rbind(yarmuthky3pr, data.frame(state, district, name, date, prpage))
}
View(yarmuthky3pr)

write.csv(yarmuthky3pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/yarmuthky3pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
massieky4pr=data.frame()
state="KY"
district=4
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://massie.house.gov/news/documentquery.aspx?DocumentTypeID=2362&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://massie.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
massieky4pr=rbind(massieky4pr, data.frame(state, district, name, date, prpage))
}
View(massieky4pr)

write.csv(massieky4pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/massieky4pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".content") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
rogersky5pr=data.frame()
state="KY"
district=5
for(page_result in seq(from = 1, to = 15, by = 1))
{
link= 
paste0("https://halrogers.house.gov/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".ContentGrid") %>% html_text()
links=page %>% html_nodes(".ContentGrid") %>% html_attr("href") %>% 
paste("https://halrogers.house.gov", ., sep="")
date=page %>%html_nodes(".recordListDate") %>% html_text()
prpage=sapply(links, FUN=get_main)
rogersky5pr=rbind(rogersky5pr, data.frame(state, district, name, date, prpage))
}
View(rogersky5pr)

write.csv(rogersky5pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/rogersky5pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".content") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
barrky6pr=data.frame()
state="KY"
district=6
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://barr.house.gov/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".ContentGrid") %>% html_text()
links=page %>% html_nodes(".ContentGrid") %>% html_attr("href") %>% 
paste("https://barr.house.gov", ., sep="")
date=page %>%html_nodes(".recordListDate") %>% html_text()
prpage=sapply(links, FUN=get_main)
barrky6pr=rbind(barrky6pr, data.frame(state, district, name, date, prpage))
}
View(barrky6pr)

write.csv(barrky6pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/barrky6pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#block-system-main") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
scalisela1pr=data.frame()
state="LA"
district=1
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://scalise.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://scalise.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
scalisela1pr=rbind(scalisela1pr, data.frame(state, district, name, date, prpage))
}
View(scalisela1pr)

write.csv(scalisela1pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/scalisela1pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
carterla2pr=data.frame()
state="LA"
district=2
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://troycarter.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://troycarter.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
carterla2pr=rbind(carterla2pr, data.frame(state, district, name, date, prpage))
}
View(carterla2pr)

write.csv(carterla2pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/carterla2pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("p:nth-child(1)") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
higginsla3pr=data.frame()
state="LA"
district=3
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://clayhiggins.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://clayhiggins.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
higginsla3pr=rbind(higginsla3pr, data.frame(state, district, name, date, prpage))
}
View(higginsla3pr)

write.csv(higginsla3pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/higginsla3pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
johnsonla4pr=data.frame()
state="LA"
district=4
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://mikejohnson.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://mikejohnson.house.gov/news/", ., sep="")
date=page %>%html_nodes("#newsdoclist time") %>% html_text()
prpage=sapply(links, FUN=get_main)
johnsonla4pr=rbind(johnsonla4pr, data.frame(state, district, name, date, prpage))
}
View(johnsonla4pr)

write.csv(johnsonla4pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/johnsonla4pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
letlowla5pr=data.frame()
state="LA"
district=5
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://letlow.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://letlow.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
letlowla5pr=rbind(letlowla5pr, data.frame(state, district, name, date, prpage))
}
View(letlowla5pr)

write.csv(letlowla5pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/letlowla5pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-label-hidden .even") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
gravesla6pr=data.frame()
state="LA"
district=6
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://garretgraves.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://garretgraves.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
gravesla6pr=rbind(gravesla6pr, data.frame(state, district, name, date, prpage))
}
View(gravesla6pr)

write.csv(gravesla6pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/gravesla6pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
pingreeme1pr=data.frame()
state="ME"
district=1
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://pingree.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://pingree.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
pingreeme1pr=rbind(pingreeme1pr, data.frame(state, district, name, date, prpage))
}
View(pingreeme1pr)

write.csv(pingreeme1pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/pingreeme1pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
goldenme2pr=data.frame()
state="ME"
district=2
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://golden.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://golden.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
goldenme2pr=rbind(goldenme2pr, data.frame(state, district, name, date, prpage))
}
View(goldenme2pr)

write.csv(goldenme2pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/goldenme2pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body ") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
harrismd1pr=data.frame()
state="MD"
district=1
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://harris.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a")%>% html_attr("href") %>% 
paste("https://harris.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
harrismd1pr=rbind(harrismd1pr, data.frame(state, district, name, date, prpage))
}
View(harrismd1pr)

write.csv(harrismd1pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/harrismd1pr.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#block-system-main") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
ruppersbergermd2pr=data.frame()
state="MD"
district=3
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://ruppersberger.house.gov/news-room/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://ruppersberger.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
ruppersbergermd2pr=rbind(ruppersbergermd2pr, data.frame(state, district, name, date, prpage))
}
View(ruppersbergermd2pr)

write.csv(ruppersbergermd2pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/ruppersbergermd2pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#block-system-main") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
sarbanesmd3pr=data.frame()
state="MD"
district=3
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://sarbanes.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".field-content a") %>% html_text()
links=page %>% html_nodes(".field-content a") %>% html_attr("href") %>% 
paste("https://sarbanes.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
sarbanesmd3pr=rbind(sarbanesmd3pr, data.frame(state, district, name, date, prpage))
}
View(sarbanesmd3pr)

write.csv(sarbanesmd3pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/sarbanesmd3pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
brownmd4pr=data.frame()
state="MD"
district=4
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://anthonybrown.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://anthonybrown.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
brownmd4pr=rbind(brownmd4pr, data.frame(state, district, name, date, prpage))
}
View(brownmd4pr)

write.csv(brownmd4pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/brownmd4pr.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".content") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
tronemd6pr=data.frame()
state="MD"
district=6
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://trone.house.gov/category/congress_press_release/", page_result)
page=read_html(link)
name=page %>% html_nodes("h2") %>% html_text()
links=page %>% html_nodes("h2") %>% html_attr("href") %>% 
paste("https://trone.house.gov/", ., sep="")
date=page %>%html_nodes(".date") %>% html_text()
prpage=sapply(links, FUN=get_main)
tronemd6pr=rbind(tronemd6pr, data.frame(state, district, name, date, prpage))
}
View(tronemd6pr)

write.csv(tronemd6pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/tronemd6pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".pane-node-body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
mfumemd7pr=data.frame()
state="MD"
district=7
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://mfume.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://mfume.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
mfumemd7pr=rbind(mfumemd7pr, data.frame(state, district, name, date, prpage))
}
View(mfumemd7pr)

write.csv(mfumemd7pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/mfumemd7pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".content") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
raskinmd8pr=data.frame()
state="MD"
district=8
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://raskin.house.gov/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".ContentGrid") %>% html_text()
links=page %>% html_nodes(".ContentGrid") %>% html_attr("href") %>% 
paste("https://raskin.house.gov", ., sep="")
date=page %>%html_nodes(".recordListDate") %>% html_text()
prpage=sapply(links, FUN=get_main)
raskinmd8pr=rbind(raskinmd8pr, data.frame(state, district, name, date, prpage))
}
View(raskinmd8pr)

write.csv(raskinmd8pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/raskinmd8pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
nealma1pr=data.frame()
state="MA"
district=1
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://neal.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://neal.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
nealma1pr=rbind(nealma1pr, data.frame(state, district, name, date, prpage))
}
View(nealma1pr)

write.csv(nealma1pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/nealma1pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("p") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
mcgovernma2pr=data.frame()
state="MA"
district=2
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://mcgovern.house.gov/news/documentquery.aspx?DocumentTypeID=2472&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".middleheadline") %>% html_text()
links=page %>% html_nodes(".middleheadline") %>% html_attr("href") %>% 
paste("https://mcgovern.house.gov", ., sep="")
date=page %>%html_nodes(" ") %>% html_text()
prpage=sapply(links, FUN=get_main)
mcgovernma2pr=rbind(mcgovernma2pr, data.frame(state, district, name, date, prpage))
}
View(mcgovernma2pr)

write.csv(mcgovernma2pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/mcgovernma2pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
trahanma3pr=data.frame()
state="MA"
district=3
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://trahan.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://trahan.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
trahanma3pr=rbind(trahanma3pr, data.frame(state, district, name, date, prpage))
}
View(trahanma3pr)

write.csv(trahanma3pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/trahanma3pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
auchinclossma4pr=data.frame()
state="MA"
district=4
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://auchincloss.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://auchincloss.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
auchinclossma4pr=rbind(auchinclossma4pr, data.frame(state, district, name, date, prpage))
}
View(auchinclossma4pr)

write.csv(auchinclossma4pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/auchinclossma4pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".post-content") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
clarkma5pr=data.frame()
state="MA"
district=5
for(page_result in seq(from = 1, to = 15, by = 1))
{
link= 
paste0("https://katherineclark.house.gov/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".ContentGrid") %>% html_text()
links=page %>% html_nodes(".ContentGrid") %>% html_attr("href") %>% 
paste("https://katherineclark.house.gov", ., sep="")
date=page %>%html_nodes(".recordListDate") %>% html_text()
prpage=sapply(links, FUN=get_main)
clarkma5pr=rbind(clarkma5pr, data.frame(state, district, name, date, prpage))
}
View(clarkma5pr)

write.csv(clarkma5pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/clarkma5pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#press") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
moultonma6pr=data.frame()
state="MA"
district=6
for(page_result in seq(from = 1, to = 15, by = 1))
{
link= 
paste0("https://moulton.house.gov/media/press-releases?PageNum_rs=", page_result)
page=read_html(link)
name=page %>% html_nodes(".title a") %>% html_text()
links=page %>% html_nodes(".title a") %>% html_attr("href") %>% 
paste("https://moulton.house.gov", ., sep="")
date=page %>%html_nodes(".black") %>% html_text()
prpage=sapply(links, FUN=get_main)
moultonma6pr=rbind(moultonma6pr, data.frame(state, district, name, date, prpage))
}
View(moultonma6pr)

write.csv(moultonma6pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/moultonma6pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-type-text-with-summary .even") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
pressleyma7pr=data.frame()
state="MA"
district=7
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://pressley.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://pressley.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
pressleyma7pr=rbind(pressleyma7pr, data.frame(state, district, name, date, prpage))
}
View(pressleyma7pr)

write.csv(pressleyma7pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/pressleyma7pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".content") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
lynchma8pr=data.frame()
state="MA"
district=8
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://lynch.house.gov/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".ContentGrid") %>% html_text()
links=page %>% html_nodes(".ContentGrid") %>% html_attr("href") %>% 
paste("https://lynch.house.gov", ., sep="")
date=page %>%html_nodes(".recordListDate") %>% html_text()
prpage=sapply(links, FUN=get_main)
lynchma8pr=rbind(lynchma8pr, data.frame(state, district, name, date, prpage))
}
View(lynchma8pr)

write.csv(lynchma8pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/lynchma8pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-label-hidden .even") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
keatingma9pr=data.frame()
state="MA"
district=9
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://keating.house.gov/media-center/press-releases", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://keating.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
keatingma9pr=rbind(keatingma9pr, data.frame(state, district, name, date, prpage))
}
View(keatingma9pr)

write.csv(keatingma9pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/keatingma9pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
bergmanmi1pr=data.frame()
state="MI"
district=1
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://bergman.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://bergman.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
bergmanmi1pr=rbind(bergmanmi1pr, data.frame(state, district, name, date, prpage))
}
View(bergmanmi1pr)

write.csv(bergmanmi1pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/bergmanmi1pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
huizengami2pr=data.frame()
state="MI"
district=2
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://huizenga.house.gov/news/documentquery.aspx?DocumentTypeID=2041&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://huizenga.house.gov/news/", ., sep="")
date=page %>%html_nodes("#newsdoclist time") %>% html_text()
prpage=sapply(links, FUN=get_main)
huizengami2pr=rbind(huizengami2pr, data.frame(state, district, name, date, prpage))
}
View(huizengami2pr)

write.csv(huizengami2pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/huizengami2pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
meijerrmi3pr=data.frame()
state="MI"
district=3
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://meijer.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://meijer.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
meijerrmi3pr=rbind(meijerrmi3pr, data.frame(state, district, name, date, prpage))
}
View(meijerrmi3pr)

write.csv(meijerrmi3pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/meijerrmi3pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#block-system-main p") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
moolenaarmi4pr=data.frame()
state="MI"
district=4
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://moolenaar.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://moolenaar.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
moolenaarmi4pr=rbind(moolenaarmi4pr, data.frame(state, district, name, date, prpage))
}
View(moolenaarmi4pr)

write.csv(moolenaarmi4pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/moolenaarmi4pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-type-text-with-summary .even") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
kildeemi5pr=data.frame()
state="MI"
district=5
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://dankildee.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://dankildee.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
kildeemi5pr=rbind(kildeemi5pr, data.frame(state, district, name, date, prpage))
}
View(kildeemi5pr)

write.csv(kildeemi5pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/kildeemi5pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
uptonmi6pr=data.frame()
state="MI"
district=6
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://upton.house.gov/news/documentquery.aspx?DocumentTypeID=1828&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://upton.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
uptonmi6pr=rbind(uptonmi6pr, data.frame(state, district, name, date, prpage))
}
View(uptonmi6pr)

write.csv(uptonmi6pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/uptonmi6pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-type-text-with-summary") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
walbergmi7pr=data.frame()
state="MI"
district=7
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://walberg.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://walberg.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
walbergmi7pr=rbind(walbergmi7pr, data.frame(state, district, name, date, prpage))
}
View(walbergmi7pr)

write.csv(walbergmi7pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/walbergmi7pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
slotkinmi8pr=data.frame()
state="MI"
district=8
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://slotkin.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://slotkin.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
slotkinmi8pr=rbind(slotkinmi8pr, data.frame(state, district, name, date, prpage))
}
View(slotkinmi8pr)

write.csv(slotkinmi8pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/slotkinmi8pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
levinmi9pr=data.frame()
state="MI"
district=9
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://andylevin.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://andylevin.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
levinmi9pr=rbind(levinmi9pr, data.frame(state, district, name, date, prpage))
}
View(levinmi9pr)

write.csv(levinmi9pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/levinmi9pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
mcclainmi10pr=data.frame()
state="MI"
district=10
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://mcclain.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://mcclain.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
mcclainmi10pr=rbind(mcclainmi10pr, data.frame(state, district, name, date, prpage))
}
View(mcclainmi10pr)

write.csv(mcclainmi10pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/mcclainmi10pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-content") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
stevensmi11pr=data.frame()
state="MI"
district=11
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://stevens.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://stevens.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
stevensmi11pr=rbind(stevensmi11pr, data.frame(state, district, name, date, prpage))
}
View(stevensmi11pr)

write.csv(stevensmi11pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/stevensmi11pr.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
dingellmi12pr=data.frame()
state="MI"
district=12
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://debbiedingell.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://debbiedingell.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
dingellmi12pr=rbind(dingellmi12pr, data.frame(state, district, name, date, prpage))
}
View(dingellmi12pr)

write.csv(dingellmi12pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/dingellmi12pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-label-hidden .even") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
tlaibmi13pr=data.frame()
state="MI"
district=13
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://tlaib.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://tlaib.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
tlaibmi13pr=rbind(tlaibmi13pr, data.frame(state, district, name, date, prpage))
}
View(tlaibmi13pr)

write.csv(tlaibmi13pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/tlaibmi13pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-label-hidden .even") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
lawrencemi14pr=data.frame()
state="MI"
district=14
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://lawrence.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://lawrence.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
lawrencemi14pr=rbind(lawrencemi14pr, data.frame(state, district, name, date, prpage))
}
View(lawrencemi14pr)

write.csv(lawrencemi14pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/lawrencemi14pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("p") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
hagedornmn1pr=data.frame()
state="MN"
district=1
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://hagedorn.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://hagedorn.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
hagedornmn1pr=rbind(hagedornmn1pr, data.frame(state, district, name, date, prpage))
}
View(hagedornmn1pr)

write.csv(hagedornmn1pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/hagedornmn1pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-type-text-with-summary .even") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
craigmn2pr=data.frame()
state="MN"
district=2
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://craig.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://craig.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
craigmn2pr=rbind(craigmn2pr, data.frame(state, district, name, date, prpage))
}
View(craigmn2pr)

write.csv(craigmn2pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/craigmn2pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
phillipsmn3pr=data.frame()
state="MN"
district=3
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://phillips.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://phillips.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
phillipsmn3pr=rbind(phillipsmn3pr, data.frame(state, district, name, date, prpage))
}
View(phillipsmn3pr)

write.csv(phillipsmn3pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/phillipsmn3pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-type-text-with-summary .even") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
mccollummn4pr=data.frame()
state="MN"
district=4
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://mccollum.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://mccollum.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
mccollummn4pr=rbind(mccollummn4pr, data.frame(state, district, name, date, prpage))
}
View(mccollummn4pr)

write.csv(mccollummn4pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/mccollummn4pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".even") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
omarmn5pr=data.frame()
state="MN"
district=5
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://omar.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://omar.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
omarmn5pr=rbind(omarmn5pr, data.frame(state, district, name, date, prpage))
}
View(omarmn5pr)

write.csv(omarmn5pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/omarmn5pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".content") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
emmermn6pr=data.frame()
state="MN"
district=6
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://emmer.house.gov/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".ContentGrid") %>% html_text()
links=page %>% html_nodes(".ContentGrid") %>% html_attr("href") %>% 
paste("https://emmer.house.gov", ., sep="")
date=page %>%html_nodes(".recordListDate") %>% html_text()
prpage=sapply(links, FUN=get_main)
emmermn6pr=rbind(emmermn6pr, data.frame(state, district, name, date, prpage))
}
View(emmermn6pr)

write.csv(emmermn6pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/emmermn6pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".content") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
fischbachmn7pr=data.frame()
state="MN"
district=7
for(page_result in seq(from = 1, to = 15, by = 1))
{
link= 
paste0("https://fischbach.house.gov/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".ContentGrid") %>% html_text()
links=page %>% html_nodes(".ContentGrid") %>% html_attr("href") %>% 
paste("https://fischbach.house.gov", ., sep="")
date=page %>%html_nodes(".recordListDate") %>% html_text()
prpage=sapply(links, FUN=get_main)
fischbachmn7pr=rbind(fischbachmn7pr, data.frame(state, district, name, date, prpage))
}
View(fischbachmn7pr)

write.csv(fischbachmn7pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/fischbachmn7pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".pane-node-body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
staubermn8pr=data.frame()
state="MN"
district=8
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://stauber.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://stauber.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
staubermn8pr=rbind(staubermn8pr, data.frame(state, district, name, date, prpage))
}
View(staubermn8pr)

write.csv(staubermn8pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/staubermn8pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
kellyms1pr=data.frame()
state="MS"
district=1
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://trentkelly.house.gov/newsroom/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".middleheadline a") %>% html_text()
links=page %>% html_nodes(".middleheadline a") %>% html_attr("href") %>% 
paste("https://trentkelly.house.gov/newsroom/", ., sep="")
date=page %>%html_nodes("#newsdoclist time") %>% html_text()
prpage=sapply(links, FUN=get_main)
kellyms1pr=rbind(kellyms1pr, data.frame(state, district, name, date, prpage))
}
View(kellyms1pr)

write.csv(kellyms1pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/kellyms1pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-type-text-with-summary .even") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
thompsonms2pr=data.frame()
state="MS"
district=2
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://benniethompson.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://benniethompson.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
thompsonms2pr=rbind(thompsonms2pr, data.frame(state, district, name, date, prpage))
}
View(thompsonms2pr)

write.csv(thompsonms2pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/thompsonms2pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
guestms3pr=data.frame()
state="MS"
district=3
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://guest.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://guest.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
guestms3pr=rbind(guestms3pr, data.frame(state, district, name, date, prpage))
}
View(guestms3pr)

write.csv(guestms3pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/guestms3pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy p") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
palazzoms4pr=data.frame()
state="MS"
district=4
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://palazzo.house.gov/news/documentquery.aspx?DocumentTypeID=2519&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://palazzo.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
palazzoms4pr=rbind(palazzoms4pr, data.frame(state, district, name, date, prpage))
}
View(palazzoms4pr)

write.csv(palazzoms4pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/palazzoms4pr.csv")
get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("span") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
bushmo1pr=data.frame()
state="MO"
district=1
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://bush.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".title a") %>% html_text()
links=page %>% html_nodes(".title a") %>% html_attr("href") %>% 
paste("https://bush.house.gov", ., sep="")
date=page %>%html_nodes(".black") %>% html_text()
prpage=sapply(links, FUN=get_main)
bushmo1pr=rbind(bushmo1pr, data.frame(state, district, name, date, prpage))
}
View(bushmo1pr)

write.csv(bushmo1pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/bushmo1pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
hollingsworthin9pr=data.frame()
state="IN"
district=9
for(page_result in seq(from = , to = 15, by = 1))
{
link= 
paste0(https://hollingsworth.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=, page_result)
page=read_html(link)
name=page %>% html_nodes("h2 a") %>% html_text()
links=page %>% html_nodes("h2 a") %>% html_attr("href") %>% 
paste("https://hollingsworth.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
hollingsworthin9pr=rbind(hollingsworthin9pr, data.frame(state, district, name, date, prpage))
}
View(hollingsworthin9pr)

write.csv(hollingsworthin9pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/hollingsworthin9pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
joyceoh14=data.frame()
state="OH"
district=14
for(page_result in seq(from =1 , to = 15, by = 1))
{
link= 
paste0(https://hollingsworth.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=, page_result)
page=read_html(link)
name=page %>% html_nodes("h2 a") %>% html_text()
links=page %>% html_nodes("h2 a") %>% html_attr("href") %>% 
paste("https://hollingsworth.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
joyceoh14=rbind(joyceoh14, data.frame(state, district, name, date, prpage))
}
View(joyceoh14)

write.csv(joyceoh14, "C:/Users/bestf/OneDrive/Desktop/Press Releases/ joyceoh14.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".content") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
tronemd6pr=data.frame()
state="MD"
district=6
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://trone.house.gov/category/congress_press_release/page/", page_result)
page=read_html(link)
name=page %>% html_nodes("h2") %>% html_text()
links=page %>% html_nodes(".btn") %>% html_attr("href") %>% 
paste("", ., sep="")
date=page %>%html_nodes(".date") %>% html_text()
prpage=sapply(links, FUN=get_main)
tronemd6pr=rbind(tronemd6pr, data.frame(state, district, name, date, prpage))
}
View(tronemd6pr)

write.csv(tronemd6pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/tronemd6pr.csv")write.csv(tronemd6pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/tronemd6pr.csv")




get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)
}

get_maindate=function(links) {
press_page2=read_html(links)
press_infodate=press_page2%>% html_nodes(".middleheadline+ .topnewsbar b") %>% html_text() %>% 
paste(collapse=",")
return(press_infodate)
}


mcgovernma2pr=data.frame()
state="MA"
district=2
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://mcgovern.house.gov/news/documentquery.aspx?DocumentTypeID=2472&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".middleheadline") %>% html_text()
links=page %>% html_nodes(".middleheadline") %>% html_attr("href") %>% 
paste("https://mcgovern.house.gov/news/", ., sep="")

prpage=sapply(links, FUN=get_main)
prpagedate=sapply(links, FUN=get_maindate)
mcgovernma2pr=rbind(mcgovernma2pr, data.frame(state, district, name, prpagedate, prpage))
}
View(mcgovernma2pr)

write.csv(mcgovernma2pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/mcgovernma2pr.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-label-hidden .even") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
lawrencemi14pr=data.frame()
state="MI"
district=14
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://lawrence.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://lawrence.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
lawrencemi14pr=rbind(lawrencemi14pr, data.frame(state, district, name, date, prpage))
}
View(lawrencemi14pr)

write.csv(lawrencemi14pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/lawrencemi14pr.csv")write.csv(lawrencemi14pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/lawrencemi14pr.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#block-system-main div") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
omarmn5=data.frame()
state="MN"
district=5
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://omar.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://omar.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
omarmn5=rbind(omarmn5, data.frame(state, district, name, date, prpage))
}
View(omarmn5)

write.csv(omarmn5, "C:/Users/bestf/OneDrive/Desktop/Press Releases/omarmn5.csv")write.csv(omarmn5, "C:/Users/bestf/OneDrive/Desktop/Press Releases/omarmn5.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy p") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}

palazzoms4=data.frame()
state="MS"
district=4
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://palazzo.house.gov/news/documentquery.aspx?DocumentTypeID=2519&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes("h2 a") %>% html_text()
links=page %>% html_nodes("h2 a") %>% html_attr("href") %>% 
paste("https://palazzo.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
palazzoms4=rbind(palazzoms4, data.frame(state, district, name, date, prpage))
}
View(palazzoms4)

write.csv(palazzoms4, "C:/Users/bestf/OneDrive/Desktop/Press Releases/palazzoms4.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-type-text-with-summary .even") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}

gaetzFL1pr=data.frame()
state="FL"
district=1

for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://gaetz.house.gov/media/TESTpress-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 


paste("https://gaetz.house.gov/", ., sep="")



date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
gaetzFL1pr=rbind(gaetzFL1pr, data.frame(state, district, name, date, prpage))
}
View(gaetzFL1pr)

write.csv(gaetzFL1pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/gaetzFL1pr.csv")





get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".post-body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}

dunnFL2pr=data.frame()
state="FL"
district=2
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://dunn.house.gov/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".ContentGrid") %>% html_text()

links=page %>% html_nodes(".ContentGrid") %>% html_attr("href") %>% 
paste("https://dunn.house.gov/", ., sep="")



date=page %>%html_nodes(".recordListDate") %>% html_text()

prpage=sapply(links, FUN=get_main)

dunnFL2pr=rbind(dunnFL2pr, data.frame(state, district, name, date,prpage))
}
View(dunnFL2pr)

write.csv(dunnFL2pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/dunnFL2pr.csv")





get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}

cammackFL3pr=data.frame()
state="FL"
district=3

for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://cammack.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://cammack.house.gov/", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
cammackFL3pr=rbind(cammackFL3pr, data.frame(state, district, name, date,prpage))
}
View(cammackFL3pr)

write.csv(cammackFL3pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/cammackFL3pr.csv")




get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-type-text-with-summary .even") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}


rutherfordFL4pr=data.frame()
state="FL"
district=4

for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://rutherford.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://rutherford.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
rutherfordFL4pr=rbind(rutherfordFL4pr, data.frame(state, district, name, date,prpage))
}
View(rutherfordFL4pr)

write.csv(rutherfordFL4pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/rutherfordFL4pr.csv")




get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#press") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}

lawsonFL5pr=data.frame()
state="FL"
district=5
for(page_result in seq(from = 1 , to = 15, by = 1))
{
link=paste0("https://lawson.house.gov/media/press-releases?PageNum_rs=", page_result)
page=read_html(link)
name=page %>% html_nodes(".title a") %>% html_text()
links=page %>% html_nodes(".title a") %>% html_attr("href") %>% 
paste("https://lawson.house.gov", ., sep="")
date=page %>%html_nodes(".black") %>% html_text()
prpage=sapply(links, FUN=get_main)
lawsonFL5pr=rbind(lawsonFL5pr, data.frame(state, district, name, date,prpage))
}
View(lawsonFL5pr)

write.csv(lawsonFL5pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/lawsonFL5pr.csv")




get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}

waltzFL6pr=data.frame()
state="FL"
district=6
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://waltz.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://waltz.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
waltzFL6pr=rbind(waltzFL6pr, data.frame(state, district, name, date,prpage))
}
View(waltzFL6pr)

write.csv(waltzFL6pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/waltzFL6pr.csv")




get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-type-text-with-summary .even") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}

sotoFL9pr=data.frame()
state="FL"
district=9
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://soto.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://soto.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
sotoFL9pr=rbind(sotoFL9pr, data.frame(state, district, name, date, prpage))
}
View(sotoFL9pr)

write.csv(sotoFL9pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/sotoFL9pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#block-system-main") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}

demingsFL10pr=data.frame()
state="FL"
district=10
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://demings.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://demings.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
demingsFL10pr=rbind(demingsFL10pr, data.frame(state, district, name, date, prpage))
}
View(demingsFL10pr)

write.csv(demingsFL10pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/demingsFL10pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".content") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}

websterFL11pr=data.frame()
state="FL"
district=11
for(page_result in seq(from = 1 , to = 15, by = 1))
{
link=paste0("https://webster.house.gov/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".ContentGrid") %>% html_text()
links=page %>% html_nodes(".ContentGrid") %>% html_attr("href") %>% 
paste("https://webster.house.gov", ., sep="")
date=page %>%html_nodes(".recordListDate") %>% html_text()
prpage=sapply(links, FUN=get_main)
websterFL11pr=rbind(websterFL11pr, data.frame(state, district, name, date, prpage))
}
View(websterFL11pr)

write.csv(websterFL11pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/websterFL11pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#block-system-main") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}

bilirakisFL12pr=data.frame()
state="FL"
district=12
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://bilirakis.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://bilirakis.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
bilirakisFL12pr=rbind(bilirakisFL12pr, data.frame(state, district, name, date, prpage))
}
View(bilirakisFL12pr)

write.csv(bilirakisFL12pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/bilirakisFL12pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}

cristFL13pr=data.frame()
state="FL"
district=13
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://crist.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://crist.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
cristFL13pr=rbind(cristFL13pr, data.frame(state, district, name, date, prpage))
}
View(cristFL13pr)

write.csv(cristFL13pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/cristFL13pr.csv")




get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}

castorFL14pr=data.frame()
state="FL"
district=14
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://crist.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://crist.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
castorFL14pr=rbind(castorFL14pr, data.frame(state, district, name, date,prpage))
}
View(castorFL14pr)

write.csv(castorFL14pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/castorFL14pr.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}

franklinFL15pr=data.frame()
state="FL"
district=15
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://franklin.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://franklin.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
franklinFL15pr=rbind(franklinFL15pr, data.frame(state, district, name, date,prpage))
}
View(franklinFL15pr)

write.csv(franklinFL15pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/franklinFL15pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-type-text-with-summary .even") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}

buchananFL16pr=data.frame()
state="FL"
district=16
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://buchanan.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://buchanan.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
buchananFL16pr=rbind(buchananFL16pr, data.frame(state, district, name, date,prpage))
}
View(buchananFL16pr)

write.csv(buchananFL16pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/buchananFL16pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-label-hidden .even") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}

steubeFL17pr=data.frame()
state="FL"
district=17
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://steube.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://steube.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
steubeFL17pr=rbind(steubeFL17pr, data.frame(state, district, name, date,prpage))
}
View(steubeFL17pr)

write.csv(steubeFL17pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/steubeFL17pr.csv")



get_main=function(links){
press_page=read_html(links)
press_info=press_page %>% html_nodes(".content") %>% html_text() %>%str_trim
return(press_info)}


state="FL"
district="18"

mastpr=data.frame()

for(page_result in seq (from= 1, to=15, by=1))
{
link=paste0("https://mast.house.gov/press-releases?page=", page_result)
page=read_html(link)



name=page%>%html_nodes(".ContentGrid") %>% html_text()
links=page%>%html_nodes(".ContentGrid") %>% html_attr("href") %>% paste("https://mast.house.gov", ., sep="")
date=page%>%html_nodes(".recordListDate") %>% html_text()
prpage=sapply(links, FUN=get_main)
mastpr=rbind(mastpr, data.frame(state, district, name, date, prpage))
print(paste("Page:", page_result))
}
write.csv(mastpr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/mastprFL18.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}

donaldsFL19pr=data.frame()
state="FL"
district=19
for(page_result in seq(from = 1 , to = 15, by = 1))
{
link=paste0("https://donalds.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://donalds.house.gov", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
donaldsFL19pr=rbind(donaldsFL19pr, data.frame(state, district, name, date,prpage))
}
View(donaldsFL19pr)

write.csv(donaldsFL19pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/donaldsFL19pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-label-hidden .even") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}

diazbalartFL25pr=data.frame()
state="FL"
district=25
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://mariodiazbalart.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://mariodiazbalart.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
diazbalartFL25pr=rbind(diazbalartFL25pr, data.frame(state, district, name, date,prpage))
}
View(diazbalartFL25pr)

write.csv(diazbalartFL25pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/diazbalartFL25pr.csv")







get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}

salazarFL27pr=data.frame()
state="FL"
district=27
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://salazar.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://salazar.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
salazarFL27pr=rbind(salazarFL27pr, data.frame(state, district, name, date,prpage))
}
View(salazarFL27pr)

write.csv(salazarFL27pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/salazarFL27pr.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}

kellyIL2pr=data.frame()
state="IL"
district=2
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://robinkelly.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://robinkelly.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
kellyIL2pr =rbind(kellyIL2pr, data.frame(state, district, name, date,prpage))
}
View(kellyIL2pr)
write.csv(kellyIL2pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/kellyIL2pr.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}

chuygarciaIL4pr=data.frame()
state="IL"
district=4
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://chuygarcia.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://chuygarcia.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
chuygarciaIL4pr=rbind(chuygarciaIL4pr, data.frame(state, district, name, date,prpage))
}
View(chuygarciaIL4pr)


write.csv(chuygarciaIL4pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/chuygarciaIL4pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)
}

get_maindate=function(links) {
press_page2=read_html(links)
press_infodate=press_page2%>% html_nodes(".middleheadline+ .topnewsbar b") %>% html_text() %>% 
paste(collapse=",")
return(press_infodate)
}


kinzingerIL16pr=data.frame()
state="IL"
district=16
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://kinzinger.house.gov/news/documentquery.aspx?DocumentTypeID=2665&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".middleheadline") %>% html_text()
links=page %>% html_nodes(".middleheadline") %>% html_attr("href") %>% 
paste("https://kinzinger.house.gov/news/",., sep="")
prpage=sapply(links, FUN=get_main)
prpagedate=sapply(links, FUN=get_maindate)
kinzingerIL16pr =rbind(kinzingerIL16pr, data.frame(state, district, name, prpagedate, prpage))
}
View(kinzingerIL16pr)

write.csv(kinzingerIL16pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/kinzingerIL16pr.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)
}

get_maindate=function(links) {
press_page2=read_html(links)
press_infodate=press_page2%>% html_nodes(".topnewstext b") %>% html_text() %>% 
paste(collapse=",")
return(press_infodate)
}


murphyfl7pr=data.frame()
state="FL"
district=7
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://murphy.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".middleheadline") %>% html_text()
links=page %>% html_nodes(".middleheadline") %>% html_attr("href") %>% 
paste("https://murphy.house.gov/news/",., sep="")
prpage=sapply(links, FUN=get_main)
prpagedate=sapply(links, FUN=get_maindate)
murphyfl7pr =rbind(murphyfl7pr, data.frame(state, district, name, prpagedate, prpage))
}
View(murphyfl7pr)
write.csv(murphyfl7pr, “C:/Users/bestf/OneDrive/Desktop/Press Releases/murphyfl7pr.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".middlecopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}

poseyfl8pr=data.frame()
state="FL"
district=8
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://posey.house.gov/news/documentquery.aspx?DocumentTypeID=1487&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".middleheadline b") %>% html_text()
links=page %>% html_nodes(".middlelinks") %>% html_attr("href") %>% 
paste("https://posey.house.gov/news/", ., sep="")
date=page %>%html_nodes("br+ b") %>% html_text()
prpage=sapply(links, FUN=get_main)
poseyfl8pr =rbind(poseyfl8pr, data.frame(state, district, name, date,prpage))
}
View(poseyfl8pr)


write.csv(poseyfl8pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/poseyfl8pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-content") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}

cherfilusmccormickfl20pr=data.frame()
state="FL"
district=20
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://cherfilus-mccormick.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://cherfilus-mccormick.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
cherfilusmccormickfl20pr =rbind(cherfilusmccormickfl20pr, data.frame(state, district, name, date,prpage))
}
View(cherfilusmccormickfl20pr)


write.csv(cherfilusmccormickfl20pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/ cherfilusmccormickfl20pr.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)
}

get_maindate=function(links) {
press_page2=read_html(links)
press_infodate=press_page2%>% html_nodes(".topnewstext b") %>% html_text() %>% 
paste(collapse=",")
return(press_infodate)
}


frankelfl21pr=data.frame()
state="FL"
district=21
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://frankel.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".middleheadline") %>% html_text()
links=page %>% html_nodes(".middleheadline") %>% html_attr("href") %>% 
paste("https://frankel.house.gov/news/",., sep="")
prpage=sapply(links, FUN=get_main)
prpagedate=sapply(links, FUN=get_maindate)
frankelfl21pr =rbind(frankelfl21pr, data.frame(state, district, name, prpagedate, prpage))
}
View(frankelfl21pr)
write.csv(frankelfl21pr, C:/Users/bestf/OneDrive/Desktop/Press Releases/frankelfl21pr.csv")





get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)
}

get_maindate=function(links) {
press_page2=read_html(links)
press_infodate=press_page2%>% html_nodes(".topnewstext b") %>% html_text() %>% 
paste(collapse=",")
return(press_infodate)
}


wassermanschultzfl23pr=data.frame()
state="FL"
district=23
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://wassermanschultz.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".middleheadline") %>% html_text()
links=page %>% html_nodes(".middleheadline") %>% html_attr("href") %>% 
paste("https://wassermanschultz.house.gov/news/",., sep="")
prpage=sapply(links, FUN=get_main)
prpagedate=sapply(links, FUN=get_maindate)
wassermanschultzfl23 =rbind(wassermanschultzfl23, data.frame(state, district, name, prpagedate, prpage))
}
View(wassermanschultzfl23)
write.csv(wassermanschultzfl23,  C:/Users/bestf/OneDrive/Desktop/Press Releases/ wassermanschultzfl23.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}

wilsonfl24pr=data.frame()
state="FL"
district=24
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://wilson.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".evo-read-more .btn-primary") %>% html_attr("href") %>% 
paste("https://wilson.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
wilsonfl24pr=rbind(wilsonfl24pr, data.frame(state, district, name, date,prpage))
}
View(wilsonfl24pr)


write.csv(wilsonfl24pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/wilsonfl24pr.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".content") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}

giminezfl26pr=data.frame()
state="FL"
district=26
for(page_result in seq(from = 1 , to = 15, by = 1))
{
link=paste0("https://gimenez.house.gov/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".ContentGrid") %>% html_text()
links=page %>% html_nodes(".ContentGrid ") %>% html_attr("href") %>% 
paste("https://gimenez.house.gov", ., sep="")
date=page %>%html_nodes(".recordListDate") %>% html_text()
prpage=sapply(links, FUN=get_main)
giminezfl26pr=rbind(giminezfl26pr, data.frame(state, district, name, date,prpage))
}
View(giminezfl26pr)


write.csv(giminezfl26pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/ giminezfl26pr.csv")








get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}

carterGA1pr=data.frame()
state="GA"
district=1
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://buddycarter.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://buddycarter.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
carterGA1pr=rbind(carterGA1pr, data.frame(state, district, name, date,prpage))
}
View(carterGA1pr)

write.csv(carterGA1pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/carterGA1pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".region-content-inner") %>% html_text() %>%str_trim
return(press_info)}

bishopGA2pr=data.frame()
state="GA"
district=2
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://bishop.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://bishop.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
bishopGA2pr=rbind(bishopGA2pr, data.frame(state, district, name, date,prpage))
}
View(bishopGA2pr)

write.csv(bishopGA2pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/bishopGA2pr.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}

fergusonGA3pr=data.frame()
state="GA"
district=3
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://ferguson.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://ferguson.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
fergusonGA3pr=rbind(fergusonGA3pr, data.frame(state, district, name, date,prpage))
}
View(fergusonGA3pr)

write.csv(fergusonGA3pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/fergusonGA3pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-label-hidden .even") %>% html_text() %>%str_trim
return(press_info)}

johnsonGA4pr=data.frame()
state="GA"
district=4
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://hankjohnson.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://hankjohnson.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
johnsonGA4pr=rbind(johnsonGA4pr, data.frame(state, district, name, date,prpage))
}
View(johnsonGA4pr)

write.csv(johnsonGA4pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/johnsonGA4pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
return(press_info)}

williamsGA5pr=data.frame()
state="GA"
district=5
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://nikemawilliams.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://nikemawilliams.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
williamsGA5pr=rbind(williamsGA5pr, data.frame(state, district, name, date,prpage))
}
View(williamsGA5pr)

write.csv(williamsGA5pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/williamsGA5pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".content") %>% html_text() %>%str_trim
return(press_info)}

mcbathGA6pr=data.frame()
state="GA"
district=6
for(page_result in seq(from = 1, to = 15, by = 1))
{
link=paste0("https://mcbath.house.gov/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".ContentGrid") %>% html_text()
links=page %>% html_nodes(".ContentGrid") %>% html_attr("href") %>% 
paste("https://mcbath.house.gov", ., sep="")
date=page %>%html_nodes(".recordListDate") %>% html_text()
prpage=sapply(links, FUN=get_main)
mcbathGA6pr=rbind(mcbathGA6pr, data.frame(state, district, name, date,prpage))
}
View(mcbathGA6pr)

write.csv(mcbathGA6pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/mcbathGA6pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".content") %>% html_text() %>%str_trim
return(press_info)}

bourdeauxGA7pr=data.frame()
state="GA"
district=7
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://bourdeaux.house.gov/category/press_release/page/", page_result)
page=read_html(link)
name=page %>% html_nodes(".title span , strong") %>% html_text()
links=page %>% html_nodes(".title span , strong") %>% html_attr("href") %>% 
paste("https://bourdeaux.house.gov", ., sep="")
date=page %>%html_nodes(".date") %>% html_text()
prpage=sapply(links, FUN=get_main)
bourdeauxGA7pr=rbind(bourdeauxGA7pr, data.frame(state, district, name, date,prpage))
}
View(bourdeauxGA7pr)

write.csv(bourdeauxGA7pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/bourdeauxGA7pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}

clydeGA9pr=data.frame()
state="GA"
district=9
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://clyde.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://clyde.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
clydeGA9pr=rbind(clydeGA9pr, data.frame(state, district, name, date,prpage))
}
View(clydeGA9pr)

write.csv(clydeGA9pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/clydeGA9pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)
}

get_maindate=function(links) {
press_page2=read_html(links)
press_infodate=press_page2%>% html_nodes(".middleheadline+ .topnewsbar b") %>% html_text() %>% 
paste(collapse=",")
return(press_infodate)
}


hicega10pr=data.frame()

state="GA"
district=10
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://hice.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".middleheadline") %>% html_text()
links=page %>% html_nodes(".middleheadline") %>% html_attr("href") %>% 
paste("https://hice.house.gov/news/",., sep="")
prpage=sapply(links, FUN=get_main)
prpagedate=sapply(links, FUN=get_maindate)
hicega10pr =rbind(hicega10pr, data.frame(state, district, name, prpagedate, prpage))
}
View(hicega10pr)
write.csv(hicega10pr,  "C:/Users/bestf/OneDrive/Desktop/Press Releases/hicega10pr.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}

loudermilkGA11pr=data.frame()
state="GA"
district=11
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://loudermilk.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".middleheadline b") %>% html_text()
links=page %>% html_nodes(".middlelinks") %>% html_attr("href") %>% 
paste("https://loudermilk.house.gov/news/", ., sep="")
date=page %>%html_nodes("br+ b") %>% html_text()
prpage=sapply(links, FUN=get_main)
loudermilkGA11pr=rbind(loudermilkGA11pr, data.frame(state, district, name, date,prpage))
}
View(loudermilkGA11pr)

write.csv(loudermilkGA11pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/loudermilkGA11pr.csv")




get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}

allenGA12pr=data.frame()
state="GA"
district=12
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://allen.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://allen.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
allenGA12pr=rbind(allenGA12pr, data.frame(state, district, name, date,prpage))
}
View(allenGA12pr)

write.csv(allenGA12pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/allenGA12pr.csv")




get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}

scottGA13pr=data.frame()
state="GA"
district=13
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://davidscott.house.gov/news/documentquery.aspx?DocumentTypeID=377&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://davidscott.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
scottGA13pr=rbind(scottGA13pr, data.frame(state, district, name, date,prpage))
}
View(scottGA13pr)

write.csv(scottGA13pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/scottGA13pr.csv")




get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body ") %>% html_text() %>%str_trim
return(press_info)}

greeneGA14pr=data.frame()
state="GA"
district=14
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://greene.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://greene.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
greeneGA14pr=rbind(greeneGA14pr, data.frame(state, district, name, date,prpage))
}
View(greeneGA14pr)

write.csv(greeneGA14pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/greeneGA14pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}

caseHI1pr=data.frame()
state="HI"
district=1
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://case.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://case.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
caseHI1pr=rbind(caseHI1pr, data.frame(state, district, name, date,prpage))
}
View(caseHI1pr)

write.csv(caseHI1pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/caseHI1pr.csv")




get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
return(press_info)}

kaheleHI2pr=data.frame()
state="HI"
district=2
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://kahele.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://kahele.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
kaheleHI2pr=rbind(kaheleHI2pr, data.frame(state, district, name, date,prpage))
}
View(kaheleHI2pr)

write.csv(kaheleHI2pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/kaheleHI2pr.csv")




get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".content") %>% html_text() %>%str_trim
return(press_info)}

fulcherID1pr=data.frame()
state="ID"
district=1
for(page_result in seq(from = 1 , to = 15, by = 1))
{
link=paste0("https://fulcher.house.gov/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".ContentGrid") %>% html_text()
links=page %>% html_nodes(".ContentGrid") %>% html_attr("href") %>% 
paste("https://fulcher.house.gov", ., sep="")
date=page %>%html_nodes(".recordListDate") %>% html_text()
prpage=sapply(links, FUN=get_main)
fulcherID1pr=rbind(fulcherID1pr, data.frame(state, district, name, date,prpage))
}
View(fulcherID1pr)

write.csv(fulcherID1pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/fulcherID1pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}

simpsonID2=data.frame()
state="ID"
district=2
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://simpson.house.gov/news/documentquery.aspx?DocumentTypeID=1515&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://simpson.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
simpsonID2=rbind(simpsonID2, data.frame(state, district, name, date,prpage))
}
View(simpsonID2)

write.csv(simpsonID2, "C:/Users/bestf/OneDrive/Desktop/Press Releases/simpsonID2.csv")




get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
return(press_info)}

rushIL1pr=data.frame()
state="IL"
district=1
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://rush.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://rush.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
rushIL1pr=rbind(rushIL1pr, data.frame(state, district, name, date,prpage))
}
View(rushIL1pr)

write.csv(rushIL1pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/rushIL1pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("td") %>% html_text() %>%str_trim
return(press_info)}

kellyIL2pr=data.frame()
state="IL"
district=2
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://robinkelly.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://robinkelly.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
kellyIL2pr=rbind(kellyIL2pr, data.frame(state, district, name, date,prpage))
}
View(kellyIL2pr)

write.csv(kellyIL2pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/kellyIL2pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
return(press_info)}

newmanIL3pr=data.frame()
state="IL"
district=3
for(page_result in seq(from = 1 , to = 15, by = 1))
{
link=paste0("https://newman.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://newman.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
newmanIL3pr=rbind(newmanIL3pr, data.frame(state, district, name, date,prpage))
}
View(newmanIL3pr)

write.csv(newmanIL3pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/newmanIL3pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-label-hidden .even") %>% html_text() %>%str_trim
return(press_info)}

quigleyIL5pr=data.frame()
state="IL"
district=5
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://quigley.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://quigley.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
quigleyIL5pr=rbind(quigleyIL5pr, data.frame(state, district, name, date,prpage))
}
View(quigleyIL5pr)

write.csv(quigleyIL5pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/quigleyIL5pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#block-system-main .even") %>% html_text() %>%str_trim
return(press_info)}

castenIL6pr=data.frame()
state="IL"
district=6
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://casten.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://casten.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
castenIL6pr=rbind(castenIL6pr, data.frame(state, district, name, date,prpage))
}
View(castenIL6pr)

write.csv(castenIL6pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/castenIL6pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
return(press_info)}

davisIL7pr=data.frame()
state="IL"
district=7
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://davis.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://davis.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
davisIL7pr=rbind(davisIL7pr, data.frame(state, district, name, date,prpage))
}
View(davisIL7pr)

write.csv(davisIL7pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/davisIL7pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".even") %>% html_text() %>%str_trim
return(press_info)}

kishnamoorthiIL8pr=data.frame()
state="IL"
district=8
for(page_result in seq(from = 1 , to = 15, by = 1))
{
link=paste0("https://krishnamoorthi.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://krishnamoorthi.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
kishnamoorthiIL8pr=rbind(kishnamoorthiIL8pr, data.frame(state, district, name, date,prpage))
}
View(kishnamoorthiIL8pr)

write.csv(kishnamoorthiIL8pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/kishnamoorthiIL8pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-label-hidden .even") %>% html_text() %>%str_trim
return(press_info)}

schakowskyIL9pr=data.frame()
state="IL"
district=9
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://schakowsky.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://schakowsky.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
schakowskyIL9pr=rbind(schakowskyIL9pr, data.frame(state, district, name, date,prpage))
}
View(schakowskyIL9pr)

write.csv(schakowskyIL9pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/schakowskyIL9pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#block-system-main .even") %>% html_text() %>%str_trim
return(press_info)}

schneiderIL10pr=data.frame()
state="IL"
district=10
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://schneider.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://schneider.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
schneiderIL10pr=rbind(schneiderIL10pr, data.frame(state, district, name, date,prpage))
}
View(schneiderIL10pr)

write.csv(schneiderIL10pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/schneiderIL10pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-label-hidden .even") %>% html_text() %>%str_trim
return(press_info)}

fosterIL11pr=data.frame()
state="IL"
district=11
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://foster.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://foster.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
fosterIL11pr=rbind(fosterIL11pr, data.frame(state, district, name, date,prpage))
}
View(fosterIL11pr)

write.csv(fosterIL11pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/fosterIL11pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".content p:nth-child(1)") %>% html_text() %>%str_trim
return(press_info)}

bostIL12pr=data.frame()
state="IL"
district=12
for(page_result in seq(from = 1 , to = 15, by = 1))
{
link=paste0("https://bost.house.gov/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".ContentGrid") %>% html_text()
links=page %>% html_nodes(".ContentGrid") %>% html_attr("href") %>% 
paste("https://bost.house.gov", ., sep="")
date=page %>%html_nodes(".recordListDate") %>% html_text()
prpage=sapply(links, FUN=get_main)
bostIL12pr=rbind(bostIL12pr, data.frame(state, district, name, date,prpage))
}
View(bostIL12pr)

write.csv(bostIL12pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/bostIL12pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-label-hidden .even") %>% html_text() %>%str_trim
return(press_info)}

underwoodIL14pr=data.frame()
state="IL"
district=14
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://underwood.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://underwood.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
underwoodIL14pr=rbind(underwoodIL14pr, data.frame(state, district, name, date,prpage))
}
View(underwoodIL14pr)

write.csv(underwoodIL14pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/underwoodIL14pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
return(press_info)}

millerIL15pr=data.frame()
state="IL"
district=15
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://marymiller.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://marymiller.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
millerIL15pr=rbind(millerIL15pr, data.frame(state, district, name, date,prpage))
}
View(millerIL15pr)

write.csv(millerIL15pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/millerIL15pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}

kinzingerIL16pr=data.frame()
state="IL"
district=16
for(page_result in seq(from = 1 , to = 15, by = 1))
{
link=paste0("https://kinzinger.house.gov/news/documentquery.aspx?DocumentTypeID=2665&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".middleheadline") %>% html_text()
links=page %>% html_nodes(".middleheadline") %>% html_attr("href") %>% 
paste("https://kinzinger.house.gov/news/", ., sep="")
date=page %>%html_nodes(".middleheadline+ .topnewsbar b") %>% html_text()
prpage=sapply(links, FUN=get_main)
kinzingerIL16pr=rbind(kinzingerIL16pr, data.frame(state, district, name, date,prpage))
}
View(kinzingerIL16pr)

write.csv(kinzingerIL16pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/kinzingerIL16pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".page-content") %>% html_text() %>%str_trim
return(press_info)}

bustosIL17pr=data.frame()
state="IL"
district=17
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://bustos.house.gov/category/press-release/page/", page_result)
page=read_html(link)
name=page %>% html_nodes(".col-sm-8 a") %>% html_text()
links=page %>% html_nodes(".col-sm-8 a") %>% html_attr("href") %>% 

paste("", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
bustosIL17pr=rbind(bustosIL17pr, data.frame(state, district, name, date,prpage))
}
View(bustosIL17pr)

write.csv(bustosIL17pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/bustosIL17pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".content") %>% html_text() %>%str_trim
return(press_info)}

lahoodIL18pr=data.frame()
state="IL"
district=18
for(page_result in seq(from = 1 , to = 15, by = 1))
{
link=paste0("https://lahood.house.gov/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".ContentGrid") %>% html_text()
links=page %>% html_nodes(".ContentGrid") %>% html_attr("href") %>% 
paste("https://lahood.house.gov", ., sep="")
date=page %>%html_nodes(".recordListDate") %>% html_text()
prpage=sapply(links, FUN=get_main)
lahoodIL18pr=rbind(lahoodIL18pr, data.frame(state, district, name, date,prpage))
}
View(lahoodIL18pr)

write.csv(lahoodIL18pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/lahoodIL18pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
return(press_info)}

mrvanIN1pr=data.frame()
state="IN"
district=1
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://mrvan.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://mrvan.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
mrvanIN1pr=rbind(mrvanIN1pr, data.frame(state, district, name, date,prpage))
}
View(mrvanIN1pr)

write.csv(mrvanIN1pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/mrvanIN1pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".article-primary") %>% html_text() %>%str_trim
return(press_info)}

walorskiIN2pr=data.frame()
state="IN"
district=2
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://walorski.house.gov/news/press-releases/page/", page_result)
page=read_html(link)
name=page %>% html_nodes(".sub-heading a") %>% html_text()
links=page %>% html_nodes(".sub-heading a") %>% html_attr("href") %>% 
paste("", ., sep="")
date=page %>%html_nodes(".meta strong") %>% html_text()
prpage=sapply(links, FUN=get_main)
walorskiIN2pr=rbind(walorskiIN2pr, data.frame(state, district, name, date,prpage))
}
View(walorskiIN2pr)

write.csv(walorskiIN2pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/walorskiIN2pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}

banksIN3pr=data.frame()
state="IN"
district=3
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://banks.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://banks.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
banksIN3pr=rbind(banksIN3pr, data.frame(state, district, name, date,prpage))
}
View(banksIN3pr)

write.csv(banksIN3pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/banksIN3pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}

bairdIN4pr=data.frame()
state="IN"
district=4
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://baird.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://baird.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
bairdIN4pr=rbind(bairdIN4pr, data.frame(state, district, name, date,prpage))
}
View(bairdIN4pr)

write.csv(bairdIN4pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/bairdIN4pr.csv")




get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
return(press_info)}

spartzIN5pr=data.frame()
state="IN"
district=5
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://spartz.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://spartz.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
spartzIN5pr=rbind(spartzIN5pr, data.frame(state, district, name, date,prpage))
}
View(spartzIN5pr)

write.csv(spartzIN5pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/spartzIN5pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-type-text-with-summary .even") %>% html_text() %>%str_trim
return(press_info)}

penceIN6pr=data.frame()
state="IN"
district=6
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://pence.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://pence.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
penceIN6pr=rbind(penceIN6pr, data.frame(state, district, name, date,prpage))
}
View(penceIN6pr)

write.csv(penceIN6pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/penceIN6pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".even") %>% html_text() %>%str_trim
return(press_info)}

carsonIN7pr=data.frame()
state="IN"
district=7
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://carson.house.gov/newsroom/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://carson.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
carsonIN7pr=rbind(carsonIN7pr, data.frame(state, district, name, date,prpage))
}
View(carsonIN7pr)

write.csv(carsonIN7pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/carsonIN7pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}

bucshonIN8pr=data.frame()
state="IN"
district=8
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://bucshon.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://bucshon.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
bucshonIN8pr=rbind(bucshonIN8pr, data.frame(state, district, name, date,prpage))
}
View(bucshonIN8pr)

write.csv (bucshonIN8pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/bucshonIN8pr.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
hollingsworthin9pr=data.frame()
state="IN"
district=9
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://hollingsworth.house.gov/news/documentquery.aspx?DocumentTypeID=1950%3a27%3a1951%3a30%3a1952&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes("h2 a") %>% html_text()
links=page %>% html_nodes("h2 a") %>% html_attr("href") %>% 
paste("https://hollingsworth.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
hollingsworthin9pr=rbind(hollingsworthin9pr, data.frame(state, district, name, date, prpage))
}
View(hollingsworthin9pr)

write.csv(hollingsworthin9pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/hollingsworthin9pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
hinsonia1pr=data.frame()
state="IA"
district=1
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://hinson.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://hinson.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
hinsonia1pr=rbind(hinsonia1pr, data.frame(state, district, name, date, prpage))
}
View(hinsonia1pr)

write.csv(hinsonia1pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/hinsonia1pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
millermeeksia2pr=data.frame()
state="IA"
district=2
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://millermeeks.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://millermeeks.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
millermeeksia2pr=rbind(millermeeksia2pr, data.frame(state, district, name, date, prpage))
}
View(millermeeksia2pr)

write.csv(millermeeksia2pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/millermeeksia2pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".pane-node-body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
axneia3pr=data.frame()
state="IA"
district=3
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://axne.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://axne.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
axneia3pr=rbind(axneia3pr, data.frame(state, district, name, date, prpage))
}
View(axneia3pr)

write.csv(axneia3pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/axneia3pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
feenstraia4pr=data.frame()
state="IA"
district=4
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://feenstra.house.gov/media/press-releases?page=1", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://feenstra.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
feenstraia4pr=rbind(feenstraia4pr, data.frame(state, district, name, date, prpage))
}
View(feenstraia4pr)

write.csv(feenstraia4pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/feenstraia4pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
mannks1pr=data.frame()
state="KS"
district=1
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://mann.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://mann.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
mannks1pr=rbind(mannks1pr, data.frame(state, district, name, date, prpage))
}
View(mannks1pr)

write.csv(mannks1pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/mannks1pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
laturnerks2pr=data.frame()
state="KS"
district=2
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://laturner.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://laturner.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
laturnerks2pr=rbind(laturnerks2pr, data.frame(state, district, name, date, prpage))
}
View(laturnerks2pr)

write.csv(laturnerks2pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/laturnerks2pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-label-hidden .even") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
davidsks3pr=data.frame()
state="KS"
district=3
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://davids.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://davids.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
davidsks3pr=rbind(davidsks3pr, data.frame(state, district, name, date, prpage))
}
View(davidsks3pr)

write.csv(davidsks3pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/davidsks3pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
estesks4pr=data.frame()
state="KS"
district=4
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://estes.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://estes.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
estesks4pr=rbind(estesks4pr, data.frame(state, district, name, date, prpage))
}
View(estesks4pr)

write.csv(estesks4pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/estesks4pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".content") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
comerky1pr=data.frame()
state="KY"
district=1
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://comer.house.gov/press-release?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".ContentGrid") %>% html_text()
links=page %>% html_nodes(".ContentGrid") %>% html_attr("href") %>% 
paste("https://comer.house.gov", ., sep="")
date=page %>%html_nodes(".recordListDate") %>% html_text()
prpage=sapply(links, FUN=get_main)
comerky1pr=rbind(comerky1pr, data.frame(state, district, name, date, prpage))
}
View(comerky1pr)

write.csv(comerky1pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/comerky1pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
guthrieky2pr=data.frame()
state="KY"
district=2
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://guthrie.house.gov/news/documentquery.aspx?DocumentTypeID=2381&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://guthrie.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
guthrieky2pr=rbind(guthrieky2pr, data.frame(state, district, name, date, prpage))
}
View(guthrieky2pr)

write.csv(guthrieky2pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/guthrieky2pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
yarmuthky3pr=data.frame()
state="KY"
district=3
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://yarmuth.house.gov/press?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://yarmuth.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
yarmuthky3pr=rbind(yarmuthky3pr, data.frame(state, district, name, date, prpage))
}
View(yarmuthky3pr)

write.csv(yarmuthky3pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/yarmuthky3pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
massieky4pr=data.frame()
state="KY"
district=4
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://massie.house.gov/news/documentquery.aspx?DocumentTypeID=2362&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://massie.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
massieky4pr=rbind(massieky4pr, data.frame(state, district, name, date, prpage))
}
View(massieky4pr)

write.csv(massieky4pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/massieky4pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".content") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
rogersky5pr=data.frame()
state="KY"
district=5
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://halrogers.house.gov/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".ContentGrid") %>% html_text()
links=page %>% html_nodes(".ContentGrid") %>% html_attr("href") %>% 
paste("https://halrogers.house.gov", ., sep="")
date=page %>%html_nodes(".recordListDate") %>% html_text()
prpage=sapply(links, FUN=get_main)
rogersky5pr=rbind(rogersky5pr, data.frame(state, district, name, date, prpage))
}
View(rogersky5pr)

write.csv(rogersky5pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/rogersky5pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".content") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
barrky6pr=data.frame()
state="KY"
district=6
for(page_result in seq(from = 1, to = 15, by = 1))
{
link= 
paste0("https://barr.house.gov/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".ContentGrid") %>% html_text()
links=page %>% html_nodes(".ContentGrid") %>% html_attr("href") %>% 
paste("https://barr.house.gov", ., sep="")
date=page %>%html_nodes(".recordListDate") %>% html_text()
prpage=sapply(links, FUN=get_main)
barrky6pr=rbind(barrky6pr, data.frame(state, district, name, date, prpage))
}
View(barrky6pr)

write.csv(barrky6pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/barrky6pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#block-system-main") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
scalisela1pr=data.frame()
state="LA"
district=1
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://scalise.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://scalise.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
scalisela1pr=rbind(scalisela1pr, data.frame(state, district, name, date, prpage))
}
View(scalisela1pr)

write.csv(scalisela1pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/scalisela1pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
carterla2pr=data.frame()
state="LA"
district=2
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://troycarter.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://troycarter.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
carterla2pr=rbind(carterla2pr, data.frame(state, district, name, date, prpage))
}
View(carterla2pr)

write.csv(carterla2pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/carterla2pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#block-system-main") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
higginsla3pr=data.frame()
state="LA"
district=3
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://clayhiggins.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://clayhiggins.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
higginsla3pr=rbind(higginsla3pr, data.frame(state, district, name, date, prpage))
}
View(higginsla3pr)

write.csv(higginsla3pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/higginsla3pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
johnsonla4pr=data.frame()
state="LA"
district=4
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://mikejohnson.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://mikejohnson.house.gov/news/", ., sep="")
date=page %>%html_nodes("#newsdoclist time") %>% html_text()
prpage=sapply(links, FUN=get_main)
johnsonla4pr=rbind(johnsonla4pr, data.frame(state, district, name, date, prpage))
}
View(johnsonla4pr)

write.csv(johnsonla4pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/johnsonla4pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
letlowla5pr=data.frame()
state="LA"
district=5
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://letlow.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://letlow.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
letlowla5pr=rbind(letlowla5pr, data.frame(state, district, name, date, prpage))
}
View(letlowla5pr)

write.csv(letlowla5pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/letlowla5pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-label-hidden .even") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
gravesla6pr=data.frame()
state="LA"
district=6
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://garretgraves.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://garretgraves.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
gravesla6pr=rbind(gravesla6pr, data.frame(state, district, name, date, prpage))
}
View(gravesla6pr)

write.csv(gravesla6pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/gravesla6pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
pingreeme1pr=data.frame()
state="ME"
district=1
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://pingree.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://pingree.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
pingreeme1pr=rbind(pingreeme1pr, data.frame(state, district, name, date, prpage))
}
View(pingreeme1pr)

write.csv(pingreeme1pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/pingreeme1pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
goldenme2pr=data.frame()
state="ME"
district=2
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://golden.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://golden.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
goldenme2pr=rbind(goldenme2pr, data.frame(state, district, name, date, prpage))
}
View(goldenme2pr)

write.csv(goldenme2pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/goldenme2pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
harrismd1pr=data.frame()
state="MD"
district=1
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://harris.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://harris.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
harrismd1pr=rbind(harrismd1pr, data.frame(state, district, name, date, prpage))
}
View(harrismd1pr)

write.csv(harrismd1pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/harrismd1pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#block-system-main") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
ruppersbergermd2pr=data.frame()
state="MD"
district=3
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://ruppersberger.house.gov/news-room/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://ruppersberger.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
ruppersbergermd2pr=rbind(ruppersbergermd2pr, data.frame(state, district, name, date, prpage))
}
View(ruppersbergermd2pr)

write.csv(ruppersbergermd2pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/ruppersbergermd2pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#block-system-main") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
sarbanesmd3pr=data.frame()
state="MD"
district=3
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://sarbanes.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".field-content a") %>% html_text()
links=page %>% html_nodes(".field-content a") %>% html_attr("href") %>% 
paste("https://sarbanes.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
sarbanesmd3pr=rbind(sarbanesmd3pr, data.frame(state, district, name, date, prpage))
}
View(sarbanesmd3pr)

write.csv(sarbanesmd3pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/sarbanesmd3pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
brownmd4pr=data.frame()
state="MD"
district=4
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://anthonybrown.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://anthonybrown.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
brownmd4pr=rbind(brownmd4pr, data.frame(state, district, name, date, prpage))
}
View(brownmd4pr)

write.csv(brownmd4pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/brownmd4pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".even") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
hoyermd5pr=data.frame()
state="MD"
district=5
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://hoyer.house.gov/newsroom", page_result)
page=read_html(link)
name=page %>% html_nodes("#block-system-main a") %>% html_text()
links=page %>% html_nodes("#block-system-main a") %>% html_attr("href") %>% 
paste("https://hoyer.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
hoyermd5pr=rbind(hoyermd5pr, data.frame(state, district, name, date, prpage))
}
View(hoyermd5pr)

write.csv(hoyermd5pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/hoyermd5pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".content") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
tronemd6pr=data.frame()
state="MD"
district=6
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://trone.house.gov/category/congress_press_release/page/", page_result)
page=read_html(link)
name=page %>% html_nodes("h2") %>% html_text()
links=page %>% html_nodes(".btn") %>% html_attr("href") %>% 
paste("https://trone.house.gov/", ., sep="")
date=page %>%html_nodes(".date") %>% html_text()
prpage=sapply(links, FUN=get_main)
tronemd6pr=rbind(tronemd6pr, data.frame(state, district, name, date, prpage))
}
View(tronemd6pr)

write.csv(tronemd6pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/tronemd6pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".pane-node-body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
mfumemd7pr=data.frame()
state="MD"
district=7
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://mfume.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://mfume.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
mfumemd7pr=rbind(mfumemd7pr, data.frame(state, district, name, date, prpage))
}
View(mfumemd7pr)

write.csv(mfumemd7pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/mfumemd7pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".content") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
raskinmd8pr=data.frame()
state="MD"
district=8
for(page_result in seq(from = 1, to = 15, by = 1))
{
link= 
paste0("https://raskin.house.gov/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".ContentGrid") %>% html_text()
links=page %>% html_nodes(".ContentGrid") %>% html_attr("href") %>% 
paste("https://raskin.house.gov", ., sep="")
date=page %>%html_nodes(".recordListDate") %>% html_text()
prpage=sapply(links, FUN=get_main)
raskinmd8pr=rbind(raskinmd8pr, data.frame(state, district, name, date, prpage))
}
View(raskinmd8pr)

write.csv(raskinmd8pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/raskinmd8pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
nealma1pr=data.frame()
state="MA"
district=1
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://neal.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://neal.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
nealma1pr=rbind(nealma1pr, data.frame(state, district, name, date, prpage))
}
View(nealma1pr)

write.csv(nealma1pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/nealma1pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
mcgovernma2pr=data.frame()
state="MA"
district=2
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://mcgovern.house.gov/news/documentquery.aspx?DocumentTypeID=2472&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".middleheadline") %>% html_text()
links=page %>% html_nodes(".middleheadline") %>% html_attr("href") %>% 
paste("https://mcgovern.house.gov", ., sep="")
date=page %>%html_nodes(" ") %>% html_text()
prpage=sapply(links, FUN=get_main)
mcgovernma2pr=rbind(mcgovernma2pr, data.frame(state, district, name, date, prpage))
}
View(mcgovernma2pr)


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)
}

get_maindate=function(links) {
press_page2=read_html(links)
press_infodate=press_page2%>% html_nodes(".topnewstext b") %>% html_text() %>% 
paste(collapse=",")
return(press_infodate)
}


mcgovernma2pr=data.frame()
state="MA"
district=2
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://mcgovern.house.gov/news/documentquery.aspx?DocumentTypeID=2472&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".middleheadline") %>% html_text()
links=page %>% html_nodes(".middleheadline") %>% html_attr("href") %>% 
paste("https://mcgovern.house.gov/news/",., sep="")
prpage=sapply(links, FUN=get_main)
prpagedate=sapply(links, FUN=get_maindate)
mcgovernma2pr =rbind(mcgovernma2pr, data.frame(state, district, name, prpagedate, prpage))
}
View(mcgovernma2pr)


write.csv(mcgovernma2pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/mcgovernma2pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
trahanma3pr=data.frame()
state="MA"
district=3
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://trahan.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://trahan.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
trahanma3pr=rbind(trahanma3pr, data.frame(state, district, name, date, prpage))
}
View(trahanma3pr)

write.csv(trahanma3pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/trahanma3pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
auchinclossma4pr=data.frame()
state="MA"
district=4
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://auchincloss.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://auchincloss.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
auchinclossma4pr=rbind(auchinclossma4pr, data.frame(state, district, name, date, prpage))
}
View(auchinclossma4pr)

write.csv(auchinclossma4pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/auchinclossma4pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".post-content") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
clarkma5pr=data.frame()
state="MA"
district=5
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://katherineclark.house.gov/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".ContentGrid") %>% html_text()
links=page %>% html_nodes(".ContentGrid") %>% html_attr("href") %>% 
paste("https://katherineclark.house.gov", ., sep="")
date=page %>%html_nodes(".recordListDate") %>% html_text()
prpage=sapply(links, FUN=get_main)
clarkma5pr=rbind(clarkma5pr, data.frame(state, district, name, date, prpage))
}
View(clarkma5pr)

write.csv(clarkma5pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/clarkma5pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#press") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
moultonma6pr=data.frame()
state="MA"
district=6
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://moulton.house.gov/media/press-releases?PageNum_rs=", page_result)
page=read_html(link)
name=page %>% html_nodes(".title a") %>% html_text()
links=page %>% html_nodes(".title a") %>% html_attr("href") %>% 
paste("https://moulton.house.gov", ., sep="")
date=page %>%html_nodes(".black") %>% html_text()
prpage=sapply(links, FUN=get_main)
moultonma6pr=rbind(moultonma6pr, data.frame(state, district, name, date, prpage))
}
View(moultonma6pr)

write.csv(moultonma6pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/moultonma6pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-type-text-with-summary .even") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
pressleyma7pr=data.frame()
state="MA"
district=7
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://pressley.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://pressley.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
pressleyma7pr=rbind(pressleyma7pr, data.frame(state, district, name, date, prpage))
}
View(pressleyma7pr)

write.csv(pressleyma7pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/pressleyma7pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".content") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
lynchma8pr=data.frame()
state="MA"
district=8
for(page_result in seq(from = 1, to = 15, by = 1))
{
link= 
paste0("https://lynch.house.gov/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".ContentGrid") %>% html_text()
links=page %>% html_nodes(".ContentGrid") %>% html_attr("href") %>% 
paste("https://lynch.house.gov", ., sep="")
date=page %>%html_nodes(".recordListDate") %>% html_text()
prpage=sapply(links, FUN=get_main)
lynchma8pr=rbind(lynchma8pr, data.frame(state, district, name, date, prpage))
}
View(lynchma8pr)

write.csv(lynchma8pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/lynchma8pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-label-hidden .even") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
keatingma9pr=data.frame()
state="MA"
district=9
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://keating.house.gov/media-center/press-releases", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://keating.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
keatingma9pr=rbind(keatingma9pr, data.frame(state, district, name, date, prpage))
}
View(keatingma9pr)

write.csv(keatingma9pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/keatingma9pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
bergmanmi1pr=data.frame()
state="MI"
district=1
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://bergman.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://bergman.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
bergmanmi1pr=rbind(bergmanmi1pr, data.frame(state, district, name, date, prpage))
}
View(bergmanmi1pr)

write.csv(bergmanmi1pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/bergmanmi1pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
huizengami2pr=data.frame()
state="MI"
district=2
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://huizenga.house.gov/news/documentquery.aspx?DocumentTypeID=2041&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://huizenga.house.gov/news/", ., sep="")
date=page %>%html_nodes("#newsdoclist time") %>% html_text()
prpage=sapply(links, FUN=get_main)
huizengami2pr=rbind(huizengami2pr, data.frame(state, district, name, date, prpage))
}
View(huizengami2pr)

write.csv(huizengami2pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/huizengami2pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
meijerrmi3pr=data.frame()
state="MI"
district=3
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://meijer.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://meijer.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
meijerrmi3pr=rbind(meijerrmi3pr, data.frame(state, district, name, date, prpage))
}
View(meijerrmi3pr)

write.csv(meijerrmi3pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/meijerrmi3pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#block-system-main") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
moolenaarmi4pr=data.frame()
state="MI"
district=4
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://moolenaar.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://moolenaar.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
moolenaarmi4pr=rbind(moolenaarmi4pr, data.frame(state, district, name, date, prpage))
}
View(moolenaarmi4pr)

write.csv(moolenaarmi4pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/moolenaarmi4pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-type-text-with-summary .even") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
kildeemi5pr=data.frame()
state="MI"
district=5
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://dankildee.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://dankildee.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
kildeemi5pr=rbind(kildeemi5pr, data.frame(state, district, name, date, prpage))
}
View(kildeemi5pr)

write.csv(kildeemi5pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/kildeemi5pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
uptonmi6pr=data.frame()
state="MI"
district=6
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://upton.house.gov/news/documentquery.aspx?DocumentTypeID=1828&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://upton.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
uptonmi6pr=rbind(uptonmi6pr, data.frame(state, district, name, date, prpage))
}
View(uptonmi6pr)

write.csv(uptonmi6pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/uptonmi6pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
walbergmi7pr=data.frame()
state="MI"
district=7
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://walberg.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://walberg.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
walbergmi7pr=rbind(walbergmi7pr, data.frame(state, district, name, date, prpage))
}
View(walbergmi7pr)

write.csv(walbergmi7pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/walbergmi7pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
slotkinmi8pr=data.frame()
state="MI"
district=8
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://slotkin.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://slotkin.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
slotkinmi8pr=rbind(slotkinmi8pr, data.frame(state, district, name, date, prpage))
}
View(slotkinmi8pr)

write.csv(slotkinmi8pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/slotkinmi8pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
levinmi9pr=data.frame()
state="MI"
district=9
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://andylevin.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://andylevin.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
levinmi9pr=rbind(levinmi9pr, data.frame(state, district, name, date, prpage))
}
View(levinmi9pr)

write.csv(levinmi9pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/levinmi9pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
mcclainmi10pr=data.frame()
state="MI"
district=10
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://mcclain.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://mcclain.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
mcclainmi10pr=rbind(mcclainmi10pr, data.frame(state, district, name, date, prpage))
}
View(mcclainmi10pr)

write.csv(mcclainmi10pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/mcclainmi10pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
stevensmi11pr=data.frame()
state="MI"
district=11
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://stevens.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://stevens.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
stevensmi11pr=rbind(stevensmi11pr, data.frame(state, district, name, date, prpage))
}
View(stevensmi11pr)

write.csv(stevensmi11pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/stevensmi11pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
dingellmi12pr=data.frame()
state="MI"
district=12
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://debbiedingell.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://debbiedingell.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
dingellmi12pr=rbind(dingellmi12pr, data.frame(state, district, name, date, prpage))
}
View(dingellmi12pr)

write.csv(dingellmi12pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/dingellmi12pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-label-hidden .even") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
tlaibmi13pr=data.frame()
state="MI"
district=13
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://tlaib.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://tlaib.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
tlaibmi13pr=rbind(tlaibmi13pr, data.frame(state, district, name, date, prpage))
}
View(tlaibmi13pr)

write.csv(tlaibmi13pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/tlaibmi13pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-label-hidden .even") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
lawrencemi14pr=data.frame()
state="MI"
district=14
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://lawrence.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://lawrence.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
lawrencemi14pr=rbind(lawrencemi14pr, data.frame(state, district, name, date, prpage))
}
View(lawrencemi14pr)

write.csv(lawrencemi14pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/lawrencemi14pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("p") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
hagedornmn1pr=data.frame()
state="MN"
district=1
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://hagedorn.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://hagedorn.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
hagedornmn1pr=rbind(hagedornmn1pr, data.frame(state, district, name, date, prpage))
}
View(hagedornmn1pr)

write.csv(hagedornmn1pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/hagedornmn1pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-type-text-with-summary .even") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
craigmn2pr=data.frame()
state="MN"
district=2
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://craig.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://craig.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
craigmn2pr=rbind(craigmn2pr, data.frame(state, district, name, date, prpage))
}
View(craigmn2pr)

write.csv(craigmn2pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/craigmn2pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
phillipsmn3pr=data.frame()
state="MN"
district=3
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://phillips.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://phillips.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
phillipsmn3pr=rbind(phillipsmn3pr, data.frame(state, district, name, date, prpage))
}
View(phillipsmn3pr)

write.csv(phillipsmn3pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/phillipsmn3pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#block-system-main") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
mccollummn4pr=data.frame()
state="MN"
district=4
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://mccollum.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://mccollum.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
mccollummn4pr=rbind(mccollummn4pr, data.frame(state, district, name, date, prpage))
}
View(mccollummn4pr)

write.csv(mccollummn4pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/mccollummn4pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#block-system-main") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
omarmn5pr=data.frame()
state="MN"
district=5
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://omar.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://omar.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
omarmn5pr=rbind(omarmn5pr, data.frame(state, district, name, date, prpage))
}
View(omarmn5pr)

write.csv(omarmn5pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/omarmn5pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".content") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
emmermn6pr=data.frame()
state="MN"
district=6
for(page_result in seq(from = 1, to = 15, by = 1))
{
link= 
paste0("https://emmer.house.gov/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".ContentGrid") %>% html_text()
links=page %>% html_nodes(".ContentGrid") %>% html_attr("href") %>% 
paste("https://emmer.house.gov", ., sep="")
date=page %>%html_nodes(".recordListDate") %>% html_text()
prpage=sapply(links, FUN=get_main)
emmermn6pr=rbind(emmermn6pr, data.frame(state, district, name, date, prpage))
}
View(emmermn6pr)

write.csv(emmermn6pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/emmermn6pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".content") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
fischbachmn7pr=data.frame()
state="MN"
district=7
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://fischbach.house.gov/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".ContentGrid") %>% html_text()
links=page %>% html_nodes(".ContentGrid") %>% html_attr("href") %>% 
paste("https://fischbach.house.gov", ., sep="")
date=page %>%html_nodes(".recordListDate") %>% html_text()
prpage=sapply(links, FUN=get_main)
fischbachmn7pr=rbind(fischbachmn7pr, data.frame(state, district, name, date, prpage))
}
View(fischbachmn7pr)

write.csv(fischbachmn7pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/fischbachmn7pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".pane-node-body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
staubermn8pr=data.frame()
state="MN"
district=8
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://stauber.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% 
paste("https://stauber.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
staubermn8pr=rbind(staubermn8pr, data.frame(state, district, name, date, prpage))
}
View(staubermn8pr)

write.csv(staubermn8pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/staubermn8pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
kellyms1pr=data.frame()
state="MS"
district=1
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://trentkelly.house.gov/newsroom/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".middleheadline a") %>% html_text()
links=page %>% html_nodes(".middleheadline a") %>% html_attr("href") %>% 
paste("https://trentkelly.house.gov/newsroom/", ., sep="")
date=page %>%html_nodes("#newsdoclist time") %>% html_text()
prpage=sapply(links, FUN=get_main)
kellyms1pr=rbind(kellyms1pr, data.frame(state, district, name, date, prpage))
}
View(kellyms1pr)

write.csv(kellyms1pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/kellyms1pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-content") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
thompsonms2pr=data.frame()
state="MS"
district=2
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://benniethompson.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://benniethompson.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
thompsonms2pr=rbind(thompsonms2pr, data.frame(state, district, name, date, prpage))
}
View(thompsonms2pr)

write.csv(thompsonms2pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/thompsonms2pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
guestms3pr=data.frame()
state="MS"
district=3
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://guest.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% 
paste("https://guest.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
guestms3pr=rbind(guestms3pr, data.frame(state, district, name, date, prpage))
}
View(guestms3pr)

write.csv(guestms3pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/guestms3pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
palazzoms4pr=data.frame()
state="MS"
district=4
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://palazzo.house.gov/news/documentquery.aspx?DocumentTypeID=2519&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% 
paste("https://palazzo.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
palazzoms4pr=rbind(palazzoms4pr, data.frame(state, district, name, date, prpage))
}
View(palazzoms4pr)

write.csv(palazzoms4pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/palazzoms4pr.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#press") %>% html_text() %>% 
paste(collapse=",")
return(press_info)}
bushmo1pr=data.frame()
state="MO"
district=1
for(page_result in seq(from = 0, to = 15, by = 1))
{
link= 
paste0("https://bush.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".title a") %>% html_text()
links=page %>% html_nodes(".summary a") %>% html_attr("href") %>% 
paste("https://bush.house.gov", ., sep="")
date=page %>%html_nodes(".black") %>% html_text()
prpage=sapply(links, FUN=get_main)
bushmo1pr=rbind(bushmo1pr, data.frame(state, district, name, date, prpage))
}
View(bushmo1pr)

write.csv(bushmo1pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/bushmo1pr.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
luetkmeyermo3=data.frame()
state="MO"
district=3
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://luetkemeyer.house.gov/news/documentquery.aspx?DocumentTypeID=2270&Page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".newsie-titler a")%>%html_text()
links=page%>%html_nodes(".newsie-titler a")%>%html_attr("href")%>%
paste("https://luetkemeyer.house.gov/news/", .,sep="")
date=page%>%html_nodes("time")%>%html_text()
prpage=sapply(links, FUN=get_main)
luetkmeyermo3=rbind(luetkmeyermo3,data.frame(state,district,name,date, prpage))
}
View(luetkmeyermo3)
write.csv(luetkmeyermo3,"[Path]luetkmeyermo3.csv"



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#block-system-main") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
hartzlermo4=data.frame()
state="MO"
district=4
for(page_result in seq(from=0 ,to=15,by=1))
{
link=paste0("https://hartzler.house.gov/media-center/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".bold a")%>%html_text()
links=page%>%html_nodes(".bold a")%>%html_attr("href")%>%
paste("https://hartzler.house.gov/", .,sep="")
date=page%>%html_nodes(".views-field-created .field-content")%>%html_text()
prpage=sapply(links, FUN=get_main)
hartzlermo4=rbind(hartzlermo4,data.frame(state,district,name,date, prpage))
}
View(hartzlermo4)
write.csv(hartzlermo4,"C:/Users/bestf/OneDrive/Desktop/Press Releases/hartzlermo4.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-type-text-with-summary .even") %>%
html_text() %>%str_trim
return(press_info)}
cleavermo5=data.frame()
state="MO"
district=5
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://cleaver.house.gov/media-center/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".views-field-title a")%>%html_text()
links=page%>%html_nodes(".views-field-title a")%>%html_attr("href")%>%
paste("https://cleaver.house.gov/", .,sep="")
date=page%>%html_nodes(".views-field-created .field-content")%>%html_text()
prpage=sapply(links, FUN=get_main)
cleavermo5=rbind(cleavermo5,data.frame(state,district,name,date, prpage))
}
View(cleavermo5)
write.csv(cleavermo5,"C:/Users/bestf/OneDrive/Desktop/Press Releases/cleavermo5.csv


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
gravesmo6=data.frame()
state="MO"
district=6
for(page_result in seq(from=0,to=15,by=1))
{
link=paste0("https://graves.house.gov/media/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".font-weight-bold a")%>%html_text()
links=page%>%html_nodes(".font-weight-bold a")%>%html_attr("href")%>%
paste("https://graves.house.gov/", .,sep="")
date=page%>%html_nodes(".col-auto:nth-child(1)")%>%html_text()
prpage=sapply(links, FUN=get_main)
gravesmo6=rbind(gravesmo6,data.frame(state,district,name,date, prpage))
}
View(gravesmo6)
write.csv(gravesmo6,"C:/Users/bestf/OneDrive/Desktop/Press Releases/gravesmo6.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%
paste(collapse=",")
return(press_info)}

longmo7=data.frame()
state="MO"
district=7
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://long.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".newsie-titler a")%>%html_text()
links=page%>%html_nodes(".newsie-titler a")%>%html_attr("href")%>%
paste("https://long.house.gov/news/", .,sep="")
date=page%>%html_nodes("time")%>%html_text()
prpage=sapply(links, FUN=get_main)
longmo7=rbind(longmo7,data.frame(state,district,name,date, prpage))
}
View(longmo7)
write.csv(longmo7,"C:/Users/bestf/OneDrive/Desktop/Press Releases/longmo7.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
smithmo8=data.frame()
state="MO"
district=8
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://jasonsmith.house.gov/newsroom/documentquery.aspx?DocumentTypeID=1951%3a27&Page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".h3 a")%>%html_text()
links=page%>%html_nodes(".h3 a")%>%html_attr("href")%>%
paste("https://jasonsmith.house.gov", .,sep="")
date=page%>%html_nodes("time")%>%html_text()
prpage=sapply(links, FUN=get_main)
smithmo8=rbind(smithmo8,data.frame(state,district,name,date, prpage))
}
View(smithmo8)
write.csv(smithmo8,"C:/Users/bestf/OneDrive/Desktop/Press Releases/smithmo8.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
rosendalemt1=data.frame()
state="MT"
district=1
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://rosendale.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".newsie-titler a")%>%html_text()
links=page%>%html_nodes(".newsie-titler a")%>%html_attr("href")%>%
paste("https://rosendale.house.gov/news/", .,sep="")
date=page%>%html_nodes("time")%>%html_text()
prpage=sapply(links, FUN=get_main)
rosendalemt1=rbind(rosendalemt1,data.frame(state,district,name,date, prpage))
}

View(rosendalemt1)
write.csv(rosendalemt1,"C:/Users/bestf/OneDrive/Desktop/Press Releases/rosendalemt1.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#region-content span") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
fortenberryne1=data.frame()
state="NE"
district=1
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://fortenberry.house.gov/news/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".views-field-title a")%>%html_text()
links=page%>%html_nodes(".views-field-title a")%>%html_attr("href")%>%
paste("https://fortenberry.house.gov/", .,sep="")
date=page%>%html_nodes(".views-field-created .field-content")%>%html_text()
prpage=sapply(links, FUN=get_main)
fortenberryne1=rbind(fortenberryne1,data.frame(state,district,name,date, prpage))
}


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
baconne2=data.frame()
state="NE"
district=2
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://bacon.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page="
,page_result)
page=read_html(link)
name=page%>%html_nodes (".newsie-titler a")%>%html_text()
links=page%>%html_nodes(".newsie-titler a")%>%html_attr("href")%>%
paste("https://bacon.house.gov/news/", .,sep="")
date=page%>%html_nodes("time")%>%html_text()
prpage=sapply(links, FUN=get_main)
baconne2=rbind(baconne2,data.frame(state,district,name,date, prpage))
}
View(baconne2)
write.csv(baconne2,"C:/Users/bestf/OneDrive/Desktop/Press Releases/baconne2.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-label-hidden") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
smithne3=data.frame()
state="NE"
district=3
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://adriansmith.house.gov/newsroom/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".views-field-title a")%>%html_text()
links=page%>%html_nodes(".views-field-title a")%>%html_attr("href")%>%
paste("https://adriansmith.house.gov", .,sep="")
date=page%>%html_nodes(".views-field-created .field-content")%>%html_text()
prpage=sapply(links, FUN=get_main)
smithne3=rbind(smithne3,data.frame(state,district,name,date, prpage))
}
View(smithne3)
write.csv(smithne3,"C:/Users/bestf/OneDrive/Desktop/Press Releases/smithne3.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-content") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
amodeinv2=data.frame()
state="NV"
district=2
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://amodei.house.gov/news-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".font-weight-bold a")%>%html_text()
links=page%>%html_nodes(".font-weight-bold a")%>%html_attr("href")%>%
paste("https://amodei.house.gov/", .,sep="")
date=page%>%html_nodes(".col-auto:nth-child(1)")%>%html_text()
prpage=sapply(links, FUN=get_main)
amodeinv2=rbind(amodeinv2,data.frame(state,district,name,date, prpage))
}
View(amodeinv2)
write.csv(amodeinv2,"C:/Users/bestf/OneDrive/Desktop/Press Releases/amodeinv2.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".pane-node-body") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
leenv3=data.frame()
state="NV"
district=3
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://susielee.house.gov/media/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".views-field-title a")%>%html_text()
links=page%>%html_nodes(".views-field-title a")%>%html_attr("href")%>%
paste("https://susielee.house.gov/", .,sep="")
date=page%>%html_nodes(".views-field-created .field-content")%>%html_text()
prpage=sapply(links, FUN=get_main)
leenv3=rbind(leenv3,data.frame(state,district,name,date, prpage))
}
View(leenv3)
write.csv(leenv3,"C:/Users/bestf/OneDrive/Desktop/Press Releases/leenv3.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#block-system-main p") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
horsfordnv4=data.frame()
state="NV"
district=4
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://horsford.house.gov/media/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".views-field-title a")%>%html_text()
links=page%>%html_nodes(".views-field-title a")%>%html_attr("href")%>%
paste("https://horsford.house.gov/", .,sep="")
date=page%>%html_nodes(".views-field-created .field-content")%>%html_text()
prpage=sapply(links, FUN=get_main)
horsfordnv4=rbind(horsfordnv4,data.frame(state,district,name,date, prpage))
}
View(horsfordnv4)
write.csv(horsfordnv4,"C:/Users/bestf/OneDrive/Desktop/Press Releases/horsfordnv4.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-type-text-with-summary .even") %>%
html_text() %>%str_trim
return(press_info)}
pappasnh1=data.frame()
state="NH"
district=1
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://pappas.house.gov/media/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".views-field-title a")%>%html_text()
links=page%>%html_nodes(".views-field-title a")%>%html_attr("href")%>%
paste("https://pappas.house.gov/", .,sep="")
date=page%>%html_nodes(".views-field-created .field-content")%>%html_text()
prpage=sapply(links, FUN=get_main)
pappasnh1=rbind(pappasnh1,data.frame(state,district,name,date, prpage))
}
View(pappasnh1)
write.csv(pappasnh1,"C:/Users/bestf/OneDrive/Desktop/Press Releases/pappasnh1.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
kusternh2=data.frame()
state="NH"
district=2
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://kuster.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".newsie-titler a")%>%html_text()
links=page%>%html_nodes(".newsie-titler a")%>%html_attr("href")%>%
paste("https://kuster.house.gov/news/", .,sep="")
date=page%>%html_nodes("time")%>%html_text()
prpage=sapply(links, FUN=get_main)
kusternh2=rbind(kusternh2,data.frame(state,district,name,date, prpage))
}
View(kusternh2)
write.csv(kusternh2,"C:/Users/bestf/OneDrive/Desktop/Press Releases/kusternh2.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-label-hidden .even") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
norcrossnj1=data.frame()
state="NJ"
district=1
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://norcross.house.gov/media-center/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".views-field-title a")%>%html_text()
links=page%>%html_nodes(".views-field-title a")%>%html_attr("href")%>%
paste("https://norcross.house.gov/", .,sep="")
date=page%>%html_nodes(".date-box")%>%html_text()
prpage=sapply(links, FUN=get_main)
norcrossnj1=rbind(norcrossnj1,data.frame(state,district,name,date, prpage))
}
View(norcrossnj1)
write.csv(norcrossnj1,"C:/Users/bestf/OneDrive/Desktop/Press Releases/norcrossnj1.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-type-text-with-summary .even") %>%
html_text() %>%str_trim
return(press_info)}
vandrewnj2=data.frame()
state="NJ"
district=2
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://vandrew.house.gov/media/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".views-field-title a")%>%html_text()
links=page%>%html_nodes(".views-field-title a")%>%html_attr("href")%>%
paste("https://vandrew.house.gov/", .,sep="")
date=page%>%html_nodes(".views-field-created .field-content")%>%html_text()
prpage=sapply(links, FUN=get_main)
vandrewnj2=rbind(vandrewnj2,data.frame(state,district,name,date, prpage))
}
View(vandrewnj2)
write.csv(vandrewnj2,"C:/Users/bestf/OneDrive/Desktop/Press Releases/vandrewnj2.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
return(press_info)}
kimnj3=data.frame()
state="NJ"
district=3
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://kim.house.gov/media/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".font-weight-bold a")%>%html_text()
links=page%>%html_nodes(".font-weight-bold a")%>%html_attr("href")%>%
paste("https://kim.house.gov/", .,sep="")
date=page%>%html_nodes(".col-auto:nth-child(1)")%>%html_text()
prpage=sapply(links, FUN=get_main)
kimnj3=rbind(kimnj3,data.frame(state,district,name,date, prpage))
}
View(kimnj3)
write.csv(kimnj3,"C:/Users/bestf/OneDrive/Desktop/Press Releases/kimnj3.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
gottheimernj5=data.frame()
state="NJ"
district=5
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://gottheimer.house.gov//news/documentquery.aspx?DocumentTypeID=27&Page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".newsie-titler a")%>%html_text()
links=page%>%html_nodes(".newsie-titler a")%>%html_attr("href")%>%
paste("https://gottheimer.house.gov/news/", .,sep="")
date=page%>%html_nodes("time")%>%html_text()
prpage=sapply(links, FUN=get_main)
gottheimernj5=rbind(gottheimernj5,data.frame(state,district,name,date, prpage))
}
View(gottheimernj5)
write.csv(gottheimernj5,"C:/Users/bestf/OneDrive/Desktop/Press Releases/gottheimernj5.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#block-system-main") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
pallonenj6=data.frame()
state="NJ"
district=6
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://pallone.house.gov/media/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".views-field-title a")%>%html_text()
links=page%>%html_nodes(".views-field-title a")%>%html_attr("href")%>%
paste("https://pallone.house.gov/", .,sep="")
date=page%>%html_nodes(".views-field-created .field-content")%>%html_text()
prpage=sapply(links, FUN=get_main)
pallonenj6=rbind(pallonenj6,data.frame(state,district,name,date, prpage))
}
View(pallonenj6)
write.csv(pallonenj6,"C:/Users/bestf/OneDrive/Desktop/Press Releases/pallonenj6.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#block-system-main") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
malinowskinj7=data.frame()
state="NJ"
district=7
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://malinowski.house.gov/media/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".font-weight-bold a")%>%html_text()
links=page%>%html_nodes(".font-weight-bold a")%>%html_attr("href")%>%
paste("https://malinowski.house.gov/", .,sep="")
date=page%>%html_nodes(".col-auto:nth-child(1)")%>%html_text()
prpage=sapply(links, FUN=get_main)
malinowskinj7=rbind(malinowskinj7,data.frame(state,district,name,date, prpage))
}
View(malinowskinj7)
write.csv(malinowskinj7,"C:/Users/bestf/OneDrive/Desktop/Press Releases/malinowskinj7.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-label-hidden .even") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
siresnj8=data.frame()
state="NJ"
district=8
for(page_result in seq(from=0,to=15,by=1))
{
link=paste0("https://sires.house.gov/media-center/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".views-field-title a")%>%html_text()
links=page%>%html_nodes(".views-field-title a")%>%html_attr("href")%>%
paste("https://sires.house.gov/", .,sep="")
date=page%>%html_nodes(".views-field-created .field-content")%>%html_text()
prpage=sapply(links, FUN=get_main)
siresnj8=rbind(siresnj8,data.frame(state,district,name,date, prpage))
}
View(siresnj8)
write.csv(siresnj8,"C:/Users/bestf/OneDrive/Desktop/Press Releases/siresnj8.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
pascrellnj9=data.frame()
state="NJ"
district=9
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://pascrell.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".newsie-titler a")%>%html_text()
links=page%>%html_nodes(".newsie-titler a")%>%html_attr("href")%>%
paste("https://pascrell.house.gov/news/", .,sep="")
date=page%>%html_nodes("time")%>%html_text()
prpage=sapply(links, FUN=get_main)
pascrellnj9=rbind(pascrellnj9,data.frame(state,district,name,date, prpage))
}
View(pascrellnj9)
write.csv(pascrellnj9,"C:/Users/bestf/OneDrive/Desktop/Press Releases/pascrellnj9.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
pascrellnj9=data.frame()
state="NJ"
district=9
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://pascrell.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".newsie-titler a")%>%html_text()
links=page%>%html_nodes(".newsie-titler a")%>%html_attr("href")%>%
paste("https://pascrell.house.gov/news/", .,sep="")
date=page%>%html_nodes("time")%>%html_text()
prpage=sapply(links, FUN=get_main)
pascrellnj9=rbind(pascrellnj9,data.frame(state,district,name,date, prpage))
}
View(pascrellnj9)
write.csv(pascrellnj9,"C:/Users/bestf/OneDrive/Desktop/Press Releases/pascrellnj9.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-label-hidden .even") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
paynenj10=data.frame()
state="NJ"
district=10
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://payne.house.gov/media/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".views-field-title a")%>%html_text()
links=page%>%html_nodes(".views-field-title a")%>%html_attr("href")%>%
paste("https://payne.house.gov/", .,sep="")
date=page%>%html_nodes(".views-field-created .field-content")%>%html_text()
prpage=sapply(links, FUN=get_main)
paynenj10=rbind(paynenj10,data.frame(state,district,name,date, prpage))
}
View(paynenj10)
write.csv(paynenj10,"C:/Users/bestf/OneDrive/Desktop/Press Releases/paynenj10.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".pane-node-body") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
sherrillnj11=data.frame()
state="NJ"
district=11
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://sherrill.house.gov/media/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".views-field-title a")%>%html_text()
links=page%>%html_nodes(".views-field-title a")%>%html_attr("href")%>%
paste("https://sherrill.house.gov/", .,sep="")
date=page%>%html_nodes(".views-field-created .field-content")%>%html_text()
prpage=sapply(links, FUN=get_main)
sherrillnj11=rbind(sherrillnj11,data.frame(state,district,name,date, prpage))
}
View(sherrillnj11)
write.csv(sherrillnj11,"C:/Users/bestf/OneDrive/Desktop/Press Releases/sherrillnj11.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
colemannj12=data.frame()
state="NJ"
district=12
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://watsoncoleman.house.gov/newsroom/documentquery.aspx?DocumentTypeID=27&Page=",page_result)
page=read_html(link)
name=page%>%html_nodes ("#ctl00_ContentCell h2")%>%html_text()
links=page%>%html_nodes(".UnorderedNewsList a")%>%html_attr("href")%>%
paste("https://watsoncoleman.house.gov/newsroom/", .,sep="")
date=page%>%html_nodes(".date")%>%html_text()
prpage=sapply(links, FUN=get_main)
colemannj12=rbind(colemannj12,data.frame(state,district,name,date, prpage))
}
View(colemannj12)
write.csv(colemannj12,"C:/Users/bestf/OneDrive/Desktop/Press Releases/colemannj12.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
stansburynm1=data.frame()
state="NM"
district=1
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://stansbury.house.gov/media/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".font-weight-bold a")%>%html_text()
links=page%>%html_nodes(".font-weight-bold a")%>%html_attr("href")%>%
paste("https://stansbury.house.gov/", .,sep="")
date=page%>%html_nodes(".col-auto:nth-child(1)")%>%html_text()
prpage=sapply(links, FUN=get_main)
stansburynm1=rbind(stansburynm1,data.frame(state,district,name,date, prpage))
}
View(stansburynm1)
write.csv(stansburynm1,"C:/Users/bestf/OneDrive/Desktop/Press Releases/stansburynm1.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("td") %>% html_text() %>%str_trim
return(press_info)}
herrellnm2=data.frame()
state="NM"
district=2
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://herrell.house.gov/media/press-releases-c?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".font-weight-bold a")%>%html_text()
links=page%>%html_nodes(".font-weight-bold a")%>%html_attr("href")%>%
paste("https://herrell.house.gov/", .,sep="")
date=page%>%html_nodes(".col-auto:nth-child(1)")%>%html_text()
prpage=sapply(links, FUN=get_main)
herrellnm2=rbind(herrellnm2,data.frame(state,district,name,date, prpage))
}
View(herrellnm2)
write.csv(herrellnm2,"C:/Users/bestf/OneDrive/Desktop/Press Releases/herrellnm2.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
legerfernandeznm3=data.frame()
state="NM"
district=3
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://fernandez.house.gov/media?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".font-weight-bold a")%>%html_text()
links=page%>%html_nodes(".font-weight-bold a")%>%html_attr("href")%>%
paste("https://fernandez.house.gov/", .,sep="")
date=page%>%html_nodes(".col-auto:nth-child(1)")%>%html_text()
prpage=sapply(links, FUN=get_main)
legerfernandeznm3=rbind(legerfernandeznm3,data.frame(state,district,name,date, prpage))
}
View(legerfernandeznm3)
write.csv(legerfernandeznm3,"C:/Users/bestf/OneDrive/Desktop/Press Releases/legerfernandeznm3.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-type-text-with-summary .even") %>%
html_text() %>%str_trim
return(press_info)}
zeldinny1=data.frame()
state="NY"
district=1
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://zeldin.house.gov/media-center/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".views-field-title a")%>%html_text()
links=page%>%html_nodes(".views-field-title a")%>%html_attr("href")%>%
paste("https://zeldin.house.gov/", .,sep="")
date=page%>%html_nodes(".views-field-created .field-content")%>%html_text()
prpage=sapply(links, FUN=get_main)
zeldinny1=rbind(zeldinny1,data.frame(state,district,name,date, prpage))
}
View(zeldinny1)
write.csv(zeldinny1,"C:/Users/bestf/OneDrive/Desktop/Press Releases/zeldinny1.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("td") %>% html_text() %>%str_trim
return(press_info)}
garbarinony2=data.frame()
state="NY"
district=2
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://garbarino.house.gov/media/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".font-weight-bold a")%>%html_text()
links=page%>%html_nodes(".font-weight-bold a")%>%html_attr("href")%>%
paste("https://garbarino.house.gov/", .,sep="")
date=page%>%html_nodes(".col-auto:nth-child(1)")%>%html_text()
prpage=sapply(links, FUN=get_main)
garbarinony2=rbind(garbarinony2,data.frame(state,district,name,date, prpage))
}
View(garbarinony2)
write.csv(garbarinony2,"C:/Users/bestf/OneDrive/Desktop/Press Releases/garbarinony2.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#region-content .even") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
suozziny3=data.frame()
state="NY"
district=3
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://suozzi.house.gov/media/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".views-field-title a")%>%html_text()
links=page%>%html_nodes(".views-field-title a")%>%html_attr("href")%>%
paste("https://suozzi.house.gov/", .,sep="")
date=page%>%html_nodes(".views-field-created .field-content")%>%html_text()
prpage=sapply(links, FUN=get_main)
suozziny3=rbind(suozziny3,data.frame(state,district,name,date, prpage))
}
View(suozziny3)
write.csv(suozziny3,"C:/Users/bestf/OneDrive/Desktop/Press Releases/suozziny3.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
meeksny5=data.frame()
state="NY"
district=5
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://meeks.house.gov/media/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".font-weight-bold a")%>%html_text()
links=page%>%html_nodes(".font-weight-bold a")%>%html_attr("href")%>%
paste("https://meeks.house.gov/", .,sep="")
date=page%>%html_nodes(".col-auto:nth-child(1)")%>%html_text()
prpage=sapply(links, FUN=get_main)
meeksny5=rbind(meeksny5,data.frame(state,district,name,date, prpage))
}
View(meeksny5)
write.csv(meeksny5,"C:/Users/bestf/OneDrive/Desktop/Press Releases/meeksny5.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-type-text-with-summary .even") %>%
html_text() %>%str_trim
return(press_info)}
mengny6=data.frame()
state="NY"
district=6
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://meng.house.gov/media-center/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".views-field-title a")%>%html_text()
links=page%>%html_nodes(".views-field-title a")%>%html_attr("href")%>%
paste("https://meng.house.gov/", .,sep="")
date=page%>%html_nodes(".views-field-created .field-content")%>%html_text()
prpage=sapply(links, FUN=get_main)
mengny6=rbind(mengny6,data.frame(state,district,name,date, prpage))
}
View(mengny6)
write.csv(mengny6,"C:/Users/bestf/OneDrive/Desktop/Press Releases/mengny6.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#region-content p") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
velazquezny7=data.frame()
state="NY"
district=7
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://velazquez.house.gov/media-center/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".views-field-title a")%>%html_text()
links=page%>%html_nodes(".views-field-title a")%>%html_attr("href")%>%
paste("https://velazquez.house.gov/", .,sep="")
date=page%>%html_nodes(".views-field-created .field-content")%>%html_text()
prpage=sapply(links, FUN=get_main)
velazquezny7=rbind(velazquezny7,data.frame(state,district,name,date, prpage))
}
View(velazquezny7)
write.csv(velazquezny7,"C:/Users/bestf/OneDrive/Desktop/Press Releases/velazquezny7.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("p+ p") %>% html_text() %>%str_trim
return(press_info)}
jeffriesny8=data.frame()
state="NY"
district=8
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://jeffries.house.gov/category/press-release/page/",page_result)
page=read_html(link)
name=page%>%html_nodes (".border-wrapper a")%>%html_text()
links=page%>%html_nodes(".border-wrapper a")%>%html_attr("href")%>%
paste("https://jeffries.house.gov/", .,sep="")
date=page%>%html_nodes("time")%>%html_text()
prpage=sapply(links, FUN=get_main)
jeffriesny8=rbind(jeffriesny8,data.frame(state,district,name,date, prpage))
}
View(jeffriesny8)
write.csv(jeffriesny8,"C:/Users/bestf/OneDrive/Desktop/Press Releases/jeffriesny8.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".content") %>% html_text() %>%str_trim
return(press_info)}
clarkeny9=data.frame()
state="NY"
district=9
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://clarke.house.gov/category/press-releases/page/",page_result)
page=read_html(link)
name=page%>%html_nodes ("h2")%>%html_text()
links=page%>%html_nodes(".btn")%>%html_attr("href")%>%
paste("", .,sep="")
date=page%>%html_nodes(".date")%>%html_text()
prpage=sapply(links, FUN=get_main)
clarkeny9=rbind(clarkeny9,data.frame(state,district,name,date, prpage))
}
View(clarkeny9)
write.csv(clarkeny9,"C:/Users/bestf/OneDrive/Desktop/Press Releases/clarkeny9.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
nadlerny10=data.frame()
state="NY"
district=10
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://nadler.house.gov/news/documentquery.aspx?DocumentTypeID=1753&Page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".newsie-titler a")%>%html_text()
links=page%>%html_nodes(".newsie-titler a")%>%html_attr("href")%>%
paste("https://nadler.house.gov/news/", .,sep="")
date=page%>%html_nodes("#newsdoclist time")%>%html_text()
prpage=sapply(links, FUN=get_main)
nadlerny10=rbind(nadlerny10,data.frame(state,district,name,date, prpage))
}
View(nadlerny10)
write.csv(nadlerny10,"C:/Users/bestf/OneDrive/Desktop/Press Releases/nadlerny10.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
malliotakisny11=data.frame()
state="NY"
district=11
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://malliotakis.house.gov/media/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".font-weight-bold a")%>%html_text()
links=page%>%html_nodes(".font-weight-bold a")%>%html_attr("href")%>%
paste("https://malliotakis.house.gov/", .,sep="")
date=page%>%html_nodes(".col-auto:nth-child(1)")%>%html_text()
prpage=sapply(links, FUN=get_main)
malliotakisny11=rbind(malliotakisny11,data.frame(state,district,name,date, prpage))
}
View(malliotakisny11)
write.csv(malliotakisny11,"C:/Users/bestf/OneDrive/Desktop/Press Releases/malliotakisny11.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#region-content .even") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
maloneyny12=data.frame()
state="NY"
district=12
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://maloney.house.gov/news/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".views-field-title a")%>%html_text()
links=page%>%html_nodes(".views-field-title a")%>%html_attr("href")%>%
paste("https://maloney.house.gov/", .,sep="")
date=page%>%html_nodes(".views-field-created .field-content")%>%html_text()
prpage=sapply(links, FUN=get_main)
maloneyny12=rbind(maloneyny12,data.frame(state,district,name,date, prpage))
}
View(maloneyny12)
write.csv(maloneyny12,"C:/Users/bestf/OneDrive/Desktop/Press Releases/maloneyny12.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("p") %>% html_text() %>%str_trim
return(press_info)}
espaillatny13=data.frame()
state="NY"
district=13
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://espaillat.house.gov/media/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".font-weight-bold a")%>%html_text()
links=page%>%html_nodes(".font-weight-bold a")%>%html_attr("href")%>%
paste("https://espaillat.house.gov/", .,sep="")
date=page%>%html_nodes(".col-auto:nth-child(1)")%>%html_text()
prpage=sapply(links, FUN=get_main)
espaillatny13=rbind(espaillatny13,data.frame(state,district,name,date, prpage))
}
View(espaillatny13)
write.csv(espaillatny13,"C:/Users/bestf/OneDrive/Desktop/Press Releases/espaillatny13.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
ocasiocortezny14=data.frame()
state="NY"
district=14
for(page_result in seq(from=0,to=15,by=1))
{
link=paste0("https://ocasio-cortez.house.gov/media/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".font-weight-bold a")%>%html_text()
links=page%>%html_nodes(".font-weight-bold a")%>%html_attr("href")%>%
paste("https://ocasio-cortez.house.gov/", .,sep="")
date=page%>%html_nodes(".col-auto")%>%html_text()
prpage=sapply(links, FUN=get_main)
ocasiocortezny14=rbind(ocasiocortezny14,data.frame(state,district,name,date, prpage))
}
View(ocasiocortezny14)
write.csv(ocasiocortezny14,"C:/Users/bestf/OneDrive/Desktop/Press Releases/ocasiocortezny14.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".content") %>% html_text() %>%str_trim
return(press_info)}
bowmanny16=data.frame()
state="NY"
district=16
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://bowman.house.gov/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".ContentGrid")%>%html_text()
links=page%>%html_nodes(".ContentGrid")%>%html_attr("href")%>%
paste("https://bowman.house.gov/", .,sep="")
date=page%>%html_nodes(".recordListDate")%>%html_text()
prpage=sapply(links, FUN=get_main)
bowmanny16=rbind(bowmanny16,data.frame(state,district,name,date, prpage))
}
View(bowmanny16)
write.csv(bowmanny16,"C:/Users/bestf/OneDrive/Desktop/Press Releases/bowmanny16.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
jonesny17=data.frame()
state="NY"
district=17
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://jones.house.gov/media/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".font-weight-bold a")%>%html_text()
links=page%>%html_nodes(".font-weight-bold a")%>%html_attr("href")%>%
paste("https://jones.house.gov/", .,sep="")
date=page%>%html_nodes(".col-auto:nth-child(1)")%>%html_text()
prpage=sapply(links, FUN=get_main)
jonesny17=rbind(jonesny17,data.frame(state,district,name,date, prpage))
}
View(jonesny17)
write.csv(jonesny17,"C:/Users/bestf/OneDrive/Desktop/Press Releases/jonesny17.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#block-system-main .even") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
maloneyny18=data.frame()
state="NY"
district=18
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://seanmaloney.house.gov/media-center/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".views-field-title a")%>%html_text()
links=page%>%html_nodes(".views-field-title a")%>%html_attr("href")%>%
paste("https://seanmaloney.house.gov/", .,sep="")
date=page%>%html_nodes(".views-field-created .field-content")%>%html_text()
prpage=sapply(links, FUN=get_main)
maloneyny18=rbind(maloneyny18,data.frame(state,district,name,date, prpage))
}
View(maloneyny18)
write.csv(maloneyny18,"C:/Users/bestf/OneDrive/Desktop/Press Releases/maloneyny18.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
delgadony19=data.frame()
state="NY"
district=19
for(page_result in seq(from=1,to=15,by=1))
{
link=paste0("https://delgado.house.gov/media/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".font-weight-bold a")%>%html_text()
links=page%>%html_nodes(".font-weight-bold a")%>%html_attr("href")%>%
paste("https://delgado.house.gov/", .,sep="")
date=page%>%html_nodes(".col-auto:nth-child(1)")%>%html_text()
prpage=sapply(links, FUN=get_main)
delgadony19=rbind(delgadony19,data.frame(state,district,name,date, prpage))
}
View(delgadony19)
write.csv(delgadony19,"C:/Users/bestf/OneDrive/Desktop/Press Releases/delgadony19.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
tonkony20=data.frame()
state="NY"
district=20
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://tonko.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page%>%html_nodes (".newsie-titler a")%>%html_text()
links=page%>%html_nodes(".newsie-titler a")%>%html_attr("href")%>%
paste("https://tonko.house.gov/news/", .,sep="")
date=page%>%html_nodes("time")%>%html_text()
prpage=sapply(links, FUN=get_main)
tonkony20=rbind(tonkony20,data.frame(state,district,name,date, prpage))
}
View(tonkony20)
write.csv(tonkony20,"C:/Users/bestf/OneDrive/Desktop/Press Releases/tonkony20.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#content") %>% html_text() %>%str_trim
return(press_info)}
stefanikny21=data.frame()
state="NY"
district=21
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://stefanik.house.gov/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".ContentGrid")%>%html_text()
links=page%>%html_nodes(".ContentGrid")%>%html_attr("href")%>%
paste("https://stefanik.house.gov/", .,sep="")
date=page%>%html_nodes(".recordListDate")%>%html_text()
prpage=sapply(links, FUN=get_main)
stefanikny21=rbind(stefanikny21,data.frame(state,district,name,date, prpage))
}
View(stefanikny21)
write.csv(stefanikny21,"C:/Users/bestf/OneDrive/Desktop/Press Releases/stefanikny21.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("p:nth-child(1))") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
tenneyny22=data.frame()
state="NY"
district=22
for(page_result in seq(from=0,to=15,by=1))
{
link=paste0("https://tenney.house.gov/media/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".font-weight-bold a")%>%html_text()
links=page%>%html_nodes(".font-weight-bold a")%>%html_attr("href")%>%
paste("https://tenney.house.gov/", .,sep="")
date=page%>%html_nodes(".col-auto:nth-child(1)")%>%html_text()
prpage=sapply(links, FUN=get_main)
tenneyny22=rbind(tenneyny22,data.frame(state,district,name,date, prpage))
}
View(tenneyny22)
write.csv(tenneyny22,"C:/Users/bestf/OneDrive/Desktop/Press Releases/tenneyny22.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".indent-1") %>% html_text() %>%str_trim
return(press_info)}
katkony24=data.frame()
state="NY"
district=24
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://katko.house.gov/media-center/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".views-field-title a")%>%html_text()
links=page%>%html_nodes(".views-field-title a")%>%html_attr("href")%>%
paste("https://katko.house.gov/", .,sep="")
date=page%>%html_nodes(".views-field-created .field-content")%>%html_text()
prpage=sapply(links, FUN=get_main)
katkony24=rbind(katkony24,data.frame(state,district,name,date, prpage))
}
View(katkony24)
write.csv(katkony24,"C:/Users/bestf/OneDrive/Desktop/Press Releases/katkony24.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
morelleny25=data.frame()
state="NY"
district=25
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://morelle.house.gov/media/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".font-weight-bold a")%>%html_text()
links=page%>%html_nodes(".font-weight-bold a")%>%html_attr("href")%>%
paste("https://morelle.house.gov/", .,sep="")
date=page%>%html_nodes(".col-auto:nth-child(1)")%>%html_text()
prpage=sapply(links, FUN=get_main)
morelleny25=rbind(morelleny25,data.frame(state,district,name,date, prpage))
}
View(morelleny25)
write.csv(morelleny25,"C:/Users/bestf/OneDrive/Desktop/Press Releases/morelleny25.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-type-text-with-summary .even) %>% html_text()
%>%str_trim
return(press_info)}

state="NY"
district=26

higginsny26=data.frame()


for(page_result in seq(from=0,to=15,by=1))
{
link=paste0("https://higgins.house.gov/media-center/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".views-field-title a")%>%html_text()
links=page%>%html_nodes(".views-field-title a")%>%html_attr("href")%>%
paste("https://higgins.house.gov/", .,sep="")
date=page%>%html_nodes(".views-field-created .field-content")%>%html_text()
prpage=sapply(links, FUN=get_main)
higginsny26=rbind(higginsny26, data.frame(state,district,name,date, prpage))
}
View(higginsny26)
write.csv(higginsny26,"C:/Users/bestf/OneDrive/Desktop/Press Releases/higginsny26.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-type-text-with-summary .even") %>%
html_text() %>%str_trim
return(press_info)}
jacobsny27=data.frame()
state="NY"
district=27
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://jacobs.house.gov/media/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".views-field-title a")%>%html_text()
links=page%>%html_nodes(".views-field-title a")%>%html_attr("href")%>%
paste("https://jacobs.house.gov/", .,sep="")
date=page%>%html_nodes(".views-field-created .field-content")%>%html_text()
prpage=sapply(links, FUN=get_main)
jacobsny27=rbind(jacobsny27,data.frame(state,district,name,date, prpage))
}
View(jacobsny27)
write.csv(jacobsny27,"C:/Users/bestf/OneDrive/Desktop/Press Releases/jacobsny27.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".even") %>% html_text() %>%str_trim
return(press_info)}
butterfieldnc1=data.frame()
state="NC"
district=1
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://butterfield.house.gov/media-center/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".views-field-title a")%>%html_text()
links=page%>%html_nodes(".views-field-title a")%>%html_attr("href")%>%
paste("https://butterfield.house.gov/", .,sep="")
date=page%>%html_nodes(".views-field-created .field-content")%>%html_text()
prpage=sapply(links, FUN=get_main)
butterfieldnc1=rbind(butterfieldnc1,data.frame(state,district,name,date, prpage))
}

View(butterfieldnc1)
write.csv(butterfieldnc1,"C:/Users/bestf/OneDrive/Desktop/Press Releases/butterfieldnc1.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
rossnc2=data.frame()
state="NC"
district=2
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://ross.house.gov/media/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".font-weight-bold a")%>%html_text()
links=page%>%html_nodes(".font-weight-bold a")%>%html_attr("href")%>%
paste("https://ross.house.gov/", .,sep="")
date=page%>%html_nodes(".col-auto:nth-child(1)")%>%html_text()
prpage=sapply(links, FUN=get_main)
rossnc2=rbind(rossnc2,data.frame(state,district,name,date, prpage))
}
View(rossnc2)
write.csv(rossnc2,"C:/Users/bestf/OneDrive/Desktop/Press Releases/rossnc2.csv") 

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".even") %>% html_text() %>%str_trim
return(press_info)}
murphync3=data.frame()
state="NC"
district=3
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://gregmurphy.house.gov/media/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".views-field-title a")%>%html_text()
links=page%>%html_nodes(".views-field-title a")%>%html_attr("href")%>%
paste("https://gregmurphy.house.gov/", .,sep="")
date=page%>%html_nodes(".views-field-created .field-content")%>%html_text()
prpage=sapply(links, FUN=get_main)
murphync3=rbind(murphync3,data.frame(state,district,name,date, prpage))
}
View(murphync3)
write.csv(murphync3,"C:/Users/bestf/OneDrive/Desktop/Press Releases/murphync3.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-label-hidden .even") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
pricenc4=data.frame()
state="NC"
district=4
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://price.house.gov/newsroom/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".views-field-title a")%>%html_text()
links=page%>%html_nodes(".views-field-title a")%>%html_attr("href")%>%
paste("https://price.house.gov/", .,sep="")
date=page%>%html_nodes(".views-field-created .field-content")%>%html_text()
prpage=sapply(links, FUN=get_main)
pricenc4=rbind(pricenc4,data.frame(state,district,name,date, prpage))
}
View(pricenc4)
write.csv(pricenc4,"C:/Users/bestf/OneDrive/Desktop/Press Releases/pricenc4.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
foxxnc5=data.frame()
state="NC"
district=5
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://foxx.house.gov/news/documentquery.aspx?DocumentTypeID=2367&Page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".newsie-titler a")%>%html_text()
links=page%>%html_nodes(".newsie-titler a")%>%html_attr("href")%>%
paste("https://foxx.house.gov/news/", .,sep="")
date=page%>%html_nodes("time")%>%html_text()
prpage=sapply(links, FUN=get_main)
foxxnc5=rbind(foxxnc5,data.frame(state,district,name,date, prpage))
}
View(foxxnc5)
write.csv(foxxnc5,"C:/Users/bestf/OneDrive/Desktop/Press Releases/foxxnc5.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
manningnc6=data.frame()
state="NC"
district=6
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://manning.house.gov/media/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".font-weight-bold a")%>%html_text()
links=page%>%html_nodes(".font-weight-bold a")%>%html_attr("href")%>%
paste("https://manning.house.gov/", .,sep="")
date=page%>%html_nodes(".col-auto:nth-child(1)")%>%html_text()
prpage=sapply(links, FUN=get_main)
manningnc6=rbind(manningnc6,data.frame(state,district,name,date, prpage))
}
View(manningnc6)
write.csv(manningnc6,"C:/Users/bestf/OneDrive/Desktop/Press Releases/manningnc6.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".content") %>% html_text() %>%str_trim
return(press_info)}
rouzernc7=data.frame()
state="NC"
district=7
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://rouzer.house.gov/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".ContentGrid")%>%html_text()
links=page%>%html_nodes(".ContentGrid")%>%html_attr("href")%>%
paste("https://rouzer.house.gov/", .,sep="")
date=page%>%html_nodes(".recordListDate")%>%html_text()
prpage=sapply(links, FUN=get_main)
rouzernc7=rbind(rouzernc7,data.frame(state,district,name,date, prpage))
}
View(rouzernc7)
write.csv(rouzernc7,"C:/Users/bestf/OneDrive/Desktop/Press Releases/rouzernc7.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
hudsonnc8=data.frame()
state="NC"
district=8
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://hudson.house.gov/media/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".font-weight-bold a")%>%html_text()
links=page%>%html_nodes(".font-weight-bold a")%>%html_attr("href")%>%
paste("https://hudson.house.gov/", .,sep="")
date=page%>%html_nodes(".col-auto:nth-child(1)")%>%html_text()
prpage=sapply(links, FUN=get_main)
hudsonnc8=rbind(hudsonnc8,data.frame(state,district,name,date, prpage))
}
View(hudsonnc8)
write.csv(hudsonnc8,"C:/Users/bestf/OneDrive/Desktop/Press Releases/hudsonnc8.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".pane-node-body") %>% html_text() %>%
paste(collapse=",")
return(press_info)}
bishopnc9=data.frame()
state="NC"
district=9
for(page_result in seq(from= 0,to=15,by=1))
{
link=paste0("https://danbishop.house.gov/media/press-releases?page=",page_result)
page=read_html(link)
name=page%>%html_nodes (".views-field-title a")%>%html_text()
links=page%>%html_nodes(".views-field-title a")%>%html_attr("href")%>%
paste("https://danbishop.house.gov/", .,sep="")
date=page%>%html_nodes(".views-field-created .field-content")%>%html_text()
prpage=sapply(links, FUN=get_main)
bishopnc9=rbind(bishopnc9,data.frame(state,district,name,date, prpage))
}
View(bishopnc9)
write.csv(bishopnc9,"C:/Users/bestf/OneDrive/Desktop/Press Releases/bishopnc9.csv")


get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes("p") %>% html_text() %>%str_trim
  return(press_info)}

mchenrync10=data.frame()
state="NC"
district=10

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://mchenry.house.gov/news/documentquery.aspx?DocumentTypeID=418&Page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".newsie-titler a") %>% html_text() 
  links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://mchenry.house.gov/news/", ., sep="")
  date=page %>% html_nodes("time") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  mchenrync10=rbind(mchenrync10, data.frame(state, district, name, date, prpage))
}
View(mchenrync10)
write.csv(mchenrync10, "C:/Users/bestf/OneDrive/Desktop/Press Releases/mchenrync10.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
  return(press_info)}

cawthornnc11=data.frame()
state="NC"
district=11

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://cawthorn.house.gov/media/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".font-weight-bold a") %>% html_text() 
  links=page %>% html_nodes("font-weight-bold a") %>% html_attr("href") %>% paste("https://cawthorn.house.gov/media/", ., sep="")
  date=page %>% html_nodes(".col-auto:nth-child(1)") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  cawthornnc11=rbind(cawthornnc11, data.frame(state, district, name, date, prpage))
}
View(cawthornnc11)
write.csv(cawthornnc11, "C:/Users/bestf/OneDrive/Desktop/Press Releases/cawthornnc11.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes("block-system-main p") %>% html_text() %>%str_trim
  return(press_info)}

adamsnc12=data.frame()
state="NC"
district=12

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://adams.house.gov/media-center/press-releases?page=", page_result) 
  page=read_html(link)
  name=page %>% html_nodes(".views-field-title a") %>% html_text() 
  links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://adams.house.gov/media-center/press-releases/", ., sep="")
  date=page %>% html_nodes(".views-field-created .field-content") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  adamsnc12=rbind(adamsnc12, data.frame(state, district, name, date, prpage))
}

View(adamsnc12)
write.csv(adamsnc12, "C:/Users/bestf/OneDrive/Desktop/Press Releases/adamsnc12.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
  return(press_info)}

buddnc13=data.frame()
state="NC"
district=13

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://budd.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".newsie-titler a") %>% html_text() 
  links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://budd.house.gov/news/", ., sep="")
  date=page %>% html_nodes("time") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  buddnc13=rbind(buddnc13, data.frame(state, district, name, date, prpage))
}
View(buddnc13)
write.csv(buddnc13, "C:/Users/bestf/OneDrive/Desktop/Press Releases/buddnc13.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
  return(press_info)}

armstrong1nd=data.frame()
state="ND"
district=1

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://armstrong.house.gov/media/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".font-weight-bold a") %>% html_text() 
  links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://armstrong.house.gov/", ., sep="")
  date=page %>% html_nodes(".col-auto:nth-child(1)") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  armstrong1nd=rbind(armstrong1nd, data.frame(state, district, name, date, prpage))
}
View(armstrong1nd)
write.csv(armstrong1nd, "C:/Users/bestf/OneDrive/Desktop/Press Releases/armstrong1nd.csv")


get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
  return(press_info)}

beatty3oh=data.frame()
state="OH"
district=3

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://beatty.house.gov/media-center/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".font-weight-bold a") %>% html_text() 
  links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://beatty.house.gov/", ., sep="")
  date=page %>% html_nodes(".col-auto:nth-child(1)") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  beatty3oh=rbind(beatty3oh, data.frame(state, district, name, date, prpage))
}
View(beatty3oh)
write.csv(beatty3oh, "C:/Users/bestf/OneDrive/Desktop/Press Releases/beatty3oh.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
  return(press_info)}

jordan4oh=data.frame()
state="OH"
district=4

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://jordan.house.gov/media/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".font-weight-bold a") %>% html_text() 
  links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://jordan.house.gov/", ., sep="")
  date=page %>% html_nodes(".col-auto:nth-child(1)") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  jordan4oh=rbind(jordan4oh, data.frame(state, district, name, date, prpage))
}
View(jordan4oh)
write.csv(jordan4oh, "C:/Users/bestf/OneDrive/Desktop/Press Releases/jordan4oh.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
  return(press_info)}

latta5oh=data.frame()
state="OH"
district=5

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://latta.house.gov/news/documentquery.aspx?DocumentTypeID=1456&Page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".newsie-titler a") %>% html_text() 
  links=page %>% html_nodes(".newsbtn") %>% html_attr("href") %>% paste("https://latta.house.gov/", ., sep="")
  date=page %>% html_nodes("time") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  latta5oh=rbind(latta5oh, data.frame(state, district, name, date, prpage))
}
View(latta5oh)
write.csv(latta5oh, "C:/Users/bestf/OneDrive/Desktop/Press Releases/latta5oh.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".clearfix") %>% html_text() %>%str_trim
  return(press_info)}

johnson6oh=data.frame()
state="OH"
district=6

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://billjohnson.house.gov/news/documentquery.aspx?DocumentTypeID=2085&Page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".newsie-titler a") %>% html_text() 
  links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://billjohnson.house.gov/news/", ., sep="")
  date=page %>% html_nodes("time") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  johnson6oh=rbind(johnson6oh, data.frame(state, district, name, date, prpage))
}
View(johnson6oh)
write.csv(johnson6oh, "C:/Users/bestf/OneDrive/Desktop/Press Releases/johnson6oh.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".clearfix") %>% html_text() %>%str_trim
  return(press_info)}

gibbs7oh=data.frame()
state="OH"
district=7

for(page_result in seq(from = 1 , to = 15, by = 1))
{
  link= paste0("https://gibbs.house.gov/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".post-media-digest-title") %>% html_text() 
  links=page %>% html_nodes(".media-digest-body-link") %>% html_attr("href") %>% paste("https://gibbs.house.gov", ., sep="")
  date=page %>% html_nodes(".post-media-digest-date") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  gibbs7oh=rbind(gibbs7oh, data.frame(state, district, name, date, prpage))
}
View(gibbs7oh)
write.csv(gibbs7oh, "C:/Users/bestf/OneDrive/Desktop/Press Releases/gibbs7oh.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".content") %>% html_text() %>%str_trim
  return(press_info)}

davidson8oh=data.frame()
state="OH"
district=8

for(page_result in seq(from = 0 , to = 15, by = 1))
{
 link= paste0("https://davidson.house.gov/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".ContentGrid") %>% html_text() 
links=page %>% html_nodes(".ContentGrid") %>% html_attr("href") %>% paste("https://davidson.house.gov", ., sep="")
date=page %>% html_nodes(".recordListDate") %>% html_text()
prpage=sapply(links, FUN=get_main)
davidson8oh=rbind(davidson8oh, data.frame(state, district, name, date, prpage))
}
View(davidson8oh)
write.csv(davidson8oh, "C:/Users/bestf/OneDrive/Desktop/Press Releases/davidson8oh.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
  return(press_info)}

kaptur9oh=data.frame()
state="OH"
district=9

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://kaptur.house.gov/media-center/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".font-weight-bold a") %>% html_text() 
  links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://kaptur.house.gov/", ., sep="")
  date=page %>% html_nodes(".col-auto:nth-child(1)") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  kaptur9oh=rbind(kaptur9oh, data.frame(state, district, name, date, prpage))
}
View(kaptur9oh)
write.csv(kaptur9oh, "C:/Users/bestf/OneDrive/Desktop/Press Releases/kaptur9oh.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".content") %>% html_text() %>%str_trim
  return(press_info)}

turner10oh=data.frame()
state="OH"
district=10

for(page_result in seq(from = 1 , to = 15, by = 1))
{
  link= paste0("https://turner.house.gov/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".ContentGrid") %>% html_text() 
  links=page %>% html_nodes(".ContentGrid") %>% html_attr("href") %>% paste("https://turner.house.gov/", ., sep="")
  date=page %>% html_nodes(".recordListDate") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  turner10oh=rbind(turner10oh, data.frame(state, district, name, date, prpage))
}
View(turner10oh)
write.csv(turner10oh, "C:/Users/bestf/OneDrive/Desktop/Press Releases/turner10oh.csv")


get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
  return(press_info)}

brown11oh=data.frame()
state="OH"
district=11

for(page_result in seq(from = 0 , to = 15, by = 1))
{
 link= paste0("https://shontelbrown.house.gov/media/press-releases?page=", page_result)
  page=read_html(link)
 name=page %>% html_nodes(".font-weight-bold a") %>% html_text() 
links=page %>% html_nodes(".evo-read-more .btn-primary") %>% html_attr("href") %>% paste("https://shontelbrown.house.gov", ., sep="")
  date=page %>% html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
 brown11oh=rbind(brown11oh, data.frame(state, district, name, date, prpage))
}
View(brown11oh)
write.csv(brown11oh, "C:/Users/bestf/OneDrive/Desktop/Press Releases/brown11oh.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
  return(press_info)}

balderson12oh=data.frame()
state="OH"
district=12

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://balderson.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".newsie-titler a") %>% html_text()
  links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://balderson.house.gov/news/", ., sep="")
  date=page %>% html_nodes("time") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  balderson12oh=rbind(balderson12oh, data.frame(state, district, name, date, prpage))
}
View(balderson12oh)
write.csv(balderson12oh, "C:/Users/bestf/OneDrive/Desktop/Press Releases/balderson12oh.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
  return(press_info)}

ryan13oh=data.frame()
state="OH"
district=13

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://timryan.house.gov/media/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".font-weight-bold a") %>% html_text() 
  links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://timryan.house.gov/", ., sep="")
  date=page %>% html_nodes(".col-auto:nth-child(1)") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  ryan13oh=rbind(ryan13oh, data.frame(state, district, name, date, prpage))
}
View(ryan13oh)
write.csv(ryan13oh, "C:/Users/bestf/OneDrive/Desktop/Press Releases/ryan13oh.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
  return(press_info)}


carey15oh=data.frame()
state="OH"
district=15
for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://carey.house.gov/media/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".mt-0") %>% html_text() 
links=page %>% html_nodes(".evo-read-more .btn-primary") %>% html_attr("href") %>% paste("https://carey.house.gov", ., sep="")
  date=page %>% html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
  carey15oh=rbind(carey15oh, data.frame(state, district, name, date, prpage))
}
View(carey15oh)
write.csv(carey15oh, "C:/Users/bestf/OneDrive/Desktop/Press Releases/carey15oh.csv")



get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
  return(press_info)}


get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
  return(press_info)}
gonzalez16oh=data.frame()
state="OH"
district=16

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://anthonygonzalez.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".newsie-titler a") %>% html_text() 
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://anthonygonzalez.house.gov/news/", ., sep="")
  date=page %>% html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
  gonzalez16oh=rbind(gonzalez16oh, data.frame(state, district, name, date, prpage))
}
View(gonzalez16oh)
write.csv(gonzalez16oh, "C:/Users/bestf/OneDrive/Desktop/Press Releases/gonzalez16oh.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
  return(press_info)}

hern1ok=data.frame()
state="OK"
district=1

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://hern.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".newsie-titler a") %>% html_text()
  links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://hern.house.gov/news/", ., sep="")
  date=page %>% html_nodes("time") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  hern1ok=rbind(hern1ok, data.frame(state, district, name, date, prpage))
}
View(hern1ok)
write.csv(hern1ok, "C:/Users/bestf/OneDrive/Desktop/Press Releases/hern1ok.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
  return(press_info)}

mullin2ok=data.frame()
state="OK"
district=2

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://mullin.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".newsie-titler") %>% html_text()
  links=page %>% html_nodes(".newsbtn") %>% html_attr("href") %>% paste("https://mullin.house.gov", ., sep="")
  date=page %>% html_nodes("time") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  mullin2ok=rbind(mullin2ok, data.frame(state, district, name, date, prpage))
}
View(mullin2ok)
write.csv(mullin2ok, "C:/Users/bestf/OneDrive/Desktop/Press Releases/mullin2ok.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes("wysiwyg-content utility-font") %>% html_text() %>%str_trim
  return(press_info)}

lucas3ok=data.frame()
state="OK"
district=3

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://lucas.house.gov/press", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".brand-font") %>% html_text() 
links=page %>% html_nodes(".brand-font") %>% html_attr("href") %>% paste("https://lucas.house.gov/press/", ., sep="")
prpage=sapply(links, FUN=get_main)
  lucas3ok=rbind(lucas3ok, data.frame(state, district, name, prpage))
}
View(lucas3ok)
write.csv(lucas3ok, "C:/Users/bestf/OneDrive/Desktop/Press Releases/lucas3ok.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".even ") %>% html_text() %>%str_trim
  return(press_info)}

cole4ok=data.frame()
state="OK"
district=4

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://cole.house.gov/media-center/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".views-field-title a") %>% html_text() 
  links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://cole.house.gov/", ., sep="")
  date=page %>% html_nodes(".views-field-created .field-content") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  cole4ok=rbind(cole4ok, data.frame(state, district, name, date, prpage))
}
View(cole4ok)
write.csv(cole4ok, "C:/Users/bestf/OneDrive/Desktop/Press Releases/cole4ok.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
  return(press_info)}

bice5ok=data.frame()
state="OK"
district=5

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://bice.house.gov/media/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".font-weight-bold a") %>% html_text() 
  links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://bice.house.gov/", ., sep="")
  date=page %>% html_nodes(".col-auto:nth-child(1)") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  bice5ok=rbind(bice5ok, data.frame(state, district, name, date, prpage))
}
View(bice5ok)
write.csv(bice5ok, "C:/Users/bestf/OneDrive/Desktop/Press Releases/bice5ok.csv")



get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".even") %>% html_text() %>%str_trim
  return(press_info)}

bonamici1or=data.frame()
state="OR"
district=1

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://bonamici.house.gov/media/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".views-field-title a") %>% html_text() 
  links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://bonamici.house.gov", ., sep="")
  date=page %>% html_nodes(".views-field-created .field-content") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  bonamici1or=rbind(bonamici1or, data.frame(state, district, name, date, prpage))
}
View(bonamici1or)
write.csv(bonamici1or, "C:/Users/bestf/OneDrive/Desktop/Press Releases/bonamici1or.csv")
get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
  return(press_info)}

bentz2or=data.frame()
state="OR"
district=2

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://bentz.house.gov/media/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".font-weight-bold a") %>% html_text() 
  links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://bentz.house.gov/", ., sep="")
  date=page %>% html_nodes(".col-auto:nth-child(1)") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  bentz2or=rbind(bentz2or, data.frame(state, district, name, date, prpage))
}
View(bentz2or)
write.csv(bentz2or, "C:/Users/bestf/OneDrive/Desktop/Press Releases/bentz2or.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
  return(press_info)}

blumenauer3or=data.frame()
state="OR"
district=3

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://blumenauer.house.gov/media-center/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".font-weight-bold a") %>% html_text() 
  links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://blumenauer.house.gov", ., sep="")
  date=page %>% html_nodes(".col-auto:nth-child(1)") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  blumenauer3or=rbind(blumenauer3or, data.frame(state, district, name, date, prpage))
}
View(blumenauer3or)
write.csv(blumenauer3or, "C:/Users/bestf/OneDrive/Desktop/Press Releases/blumenauer3or.csv")


get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".pane-node-body") %>% html_text() %>%str_trim
  return(press_info)}

defazio4or=data.frame()
state="OR"
district=4

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://defazio.house.gov/media-center/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".views-field-title a") %>% html_text() 
  links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://defazio.house.gov", ., sep="")
  date=page %>% html_nodes(".views-field-created .field-content") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  defazio4or=rbind(defazio4or, data.frame(state, district, name, date, prpage))
}
View(defazio4or)
write.csv(defazio4or, "C:/Users/bestf/OneDrive/Desktop/Press Releases/defazio4or.csv")
get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
  return(press_info)}

schrader5or=data.frame()
state="OR"
district=5

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://schrader.house.gov/newsroom/documentquery.aspx?DocumentTypeID=2382&Page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes("h5") %>% html_text() 
  links=page %>% html_nodes(".more") %>% html_attr("href") %>% paste("https://schrader.house.gov", ., sep="")
  date=page %>% html_nodes("time") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  schrader5or=rbind(schrader5or, data.frame(state, district, name, date, prpage))
}
View(schrader5or)
write.csv(schrader5or, "C:/Users/bestf/OneDrive/Desktop/Press Releases/schrader5or.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".content") %>% html_text() %>%str_trim
  return(press_info)}

fitzpatrick1pa=data.frame()
state="PA"
district=1

for(page_result in seq(from = 1 , to = 15, by = 1))
{
  link= paste0("https://fitzpatrick.house.gov/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".ContentGrid") %>% html_text() 
  links=page %>% html_nodes(".ContentGrid") %>% html_attr("href") %>% paste("https://fitzpatrick.house.gov/", ., sep="")
  date=page %>% html_nodes(".recordListDate") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  fitzpatrick1pa=rbind(fitzpatrick1pa, data.frame(state, district, name, date, prpage))
}
View(fitzpatrick1pa)
write.csv(fitzpatrick1pa, "C:/Users/bestf/OneDrive/Desktop/Press Releases/fitzpatrick1pa.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".field-type-text-with-summary .even ") %>% html_text() %>%str_trim
  return(press_info)}

boyle2pa=data.frame()
state="PA"
district=2

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://boyle.house.gov/media-center/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".views-field-title a") %>% html_text() 
  links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://boyle.house.gov", ., sep="")
  date=page %>% html_nodes(".views-field-created .field-content") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  boyle2pa=rbind(boyle2pa, data.frame(state, district, name, date, prpage))
}
View(boyle2pa)
write.csv(boyle2pa, "C:/Users/bestf/OneDrive/Desktop/Press Releases/boyle2pa.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".pane-node-body") %>% html_text() %>%str_trim
  return(press_info)}

evans3pa=data.frame()
state="PA"
district=3

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://evans.house.gov/media-center/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".views-field-title a") %>% html_text() 
  links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://evans.house.gov", ., sep="")
  date=page %>% html_nodes(".views-field-created .field-content") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  evans3pa=rbind(evans3pa, data.frame(state, district, name, date, prpage))
}
View(evans3pa)
write.csv(evans3pa, "C:/Users/bestf/OneDrive/Desktop/Press Releases/evans3pa.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".content") %>% html_text() %>%str_trim
  return(press_info)}

dean4pa=data.frame()
state="PA"
district=4

for(page_result in seq(from = 1 , to = 15, by = 1))
{
  link= paste0("https://dean.house.gov/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".ContentGrid") %>% html_text() 
  links=page %>% html_nodes(".ContentGrid") %>% html_attr("href") %>% paste("https://dean.house.gov/", ., sep="")
  date=page %>% html_nodes(".recordListDate") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  dean4pa=rbind(dean4pa, data.frame(state, district, name, date, prpage))
}
View(dean4pa)
write.csv(dean4pa, "C:/Users/bestf/OneDrive/Desktop/Press Releases/dean4pa.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
  return(press_info)}

scanlon5pa=data.frame()
state="PA"
district=5

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://scanlon.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".newsie-titler a") %>% html_text() 
  links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://scanlon.house.gov/news/", ., sep="")
  date=page %>% html_nodes("time") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  scanlon5pa=rbind(scanlon5pa, data.frame(state, district, name, date, prpage))
}
View(scanlon5pa)
write.csv(scanlon5pa, "C:/Users/bestf/OneDrive/Desktop/Press Releases/scanlon5pa.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
  return(press_info)}

houlahan6pa=data.frame()
state="PA"
district=6

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://houlahan.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".title a") %>% html_text() 
  links=page %>% html_nodes(".read-more") %>% html_attr("href") %>% paste("https://houlahan.house.gov",., sep="")
  date=page %>% html_nodes(".date") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  houlahan6pa=rbind(houlahan6pa, data.frame(state, district, name, date, prpage))
}
View(houlahan6pa)
write.csv(houlahan6pa, "C:/Users/bestf/OneDrive/Desktop/Press Releases/houlahan6pa.csv")



get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".pane-node-body") %>% html_text() %>%str_trim
  return(press_info)}

wild7pa=data.frame()
state="PA"
district=7

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://wild.house.gov/media/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".views-field-title a") %>% html_text()
  links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://wild.house.gov", ., sep="")
  date=page %>% html_nodes(".views-field-created .field-content") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  wild7pa=rbind(wild7pa, data.frame(state, district, name, date, prpage))
}
View(wild7pa)
write.csv(wild7pa, "C:/Users/bestf/OneDrive/Desktop/Press Releases/wild7pa.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
  return(press_info)}

cartwright8pa=data.frame()
state="PA"
district=8

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://cartwright.house.gov/news/documentquery.aspx?DocumentTypeID=2442&Page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".newsie-titler a") %>% html_text() 
  links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://cartwright.house.gov/news/", ., sep="")
  date=page %>% html_nodes("time") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  cartwright8pa=rbind(cartwright8pa, data.frame(state, district, name, date, prpage))
}
View(cartwright8pa)
write.csv(cartwright8pa, "C:/Users/bestf/OneDrive/Desktop/Press Releases/cartwright8pa.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
  return(press_info)}

meuser9pa=data.frame()
state="PA"
district=9

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://meuser.house.gov/media/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".font-weight-bold a") %>% html_text() 
  links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://meuser.house.gov/", ., sep="")
  date=page %>% html_nodes(".col-auto:nth-child(1)") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  meuser9pa=rbind(meuser9pa, data.frame(state, district, name, date, prpage))
}
View(meuser9pa)
write.csv(meuser9pa, "C:/Users/bestf/OneDrive/Desktop/Press Releases/meuser9pa.csv")
get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
  return(press_info)}

perry10pa=data.frame()
state="PA"
district=10

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://perry.house.gov/news/documentquery.aspx?DocumentTypeID=2608&Page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".newsie-titler a") %>% html_text() 
  links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://perry.house.gov/news/", ., sep="")
  date=page %>% html_nodes("#newsdoclist time") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  perry10pa=rbind(perry10pa, data.frame(state, district, name, date, prpage))
}
View(perry10pa)
write.csv(perry10pa, "C:/Users/bestf/OneDrive/Desktop/Press Releases/perry10pa.csv")


get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes("p:nth-child(1)") %>% html_text() %>%str_trim
  return(press_info)}

smucker11pa=data.frame()
state="PA"
district=11

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://smucker.house.gov/media/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".views-field-title a") %>% html_text()
  links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://smucker.house.gov/media/", ., sep="")
  date=page %>% html_nodes(".views-field-created .field-content") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  smucker11pa=rbind(smucker11pa, data.frame(state, district, name, date, prpage))
}
View(smucker11pa)
write.csv(smucker11pa, "C:/Users/bestf/OneDrive/Desktop/Press Releases/smucker11pa.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".even") %>% html_text() %>%str_trim
  return(press_info)}

keller12pa=data.frame()
state="PA"
district=12

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://keller.house.gov/media/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".views-field-title a") %>% html_text() 
  links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://keller.house.gov", ., sep="")
  date=page %>% html_nodes(".views-field-created .field-content") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  keller12pa=rbind(keller12pa, data.frame(state, district, name, date, prpage))
}
View(keller12pa)
write.csv(keller12pa, "C:/Users/bestf/OneDrive/Desktop/Press Releases/keller12pa.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
  return(press_info)}

joyce13pa=data.frame()
state="PA"
district=13

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://johnjoyce.house.gov/media/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".font-weight-bold a") %>% html_text() 
  links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://johnjoyce.house.gov/", ., sep="")
  date=page %>% html_nodes(".col-auto:nth-child(1)") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  joyce13pa=rbind(joyce13pa, data.frame(state, district, name, date, prpage))
}
View(joyce13pa)
write.csv(joyce13pa, "C:/Users/bestf/OneDrive/Desktop/Press Releases/joyce13pa.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
  return(press_info)}

reschenthaler14pa=data.frame()
state="PA"
district=14

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://reschenthaler.house.gov/media/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".font-weight-bold a") %>% html_text() 
  links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://reschenthaler.house.gov/", ., sep="")
  date=page %>% html_nodes(".col-auto:nth-child(1)") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  reschenthaler14pa=rbind(reschenthaler14pa, data.frame(state, district, name, date, prpage))
}
View(reschenthaler14pa)
write.csv(reschenthaler14pa, "C:/Users/bestf/OneDrive/Desktop/Press Releases/reschenthaler14pa.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes("p:nth-child(1)") %>% html_text() %>%str_trim
  return(press_info)}

thompson15pa=data.frame()
state="PA"
district=15

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://thompson.house.gov/media-center/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".views-field-title a") %>% html_text()
  links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://thompson.house.gov/media-center/", ., sep="")
  date=page %>% html_nodes(".views-field-created .field-content") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  thompson15pa=rbind(thompson15pa, data.frame(state, district, name, date, prpage))
}
View(thompson15pa)
write.csv(thompson15pa, "C:/Users/bestf/OneDrive/Desktop/Press Releases/thompson15pa.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
  return(press_info)}

kelly16pa=data.frame()
state="PA"
district=16

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://kelly.house.gov/media/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".font-weight-bold a") %>% html_text() 
  links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://kelly.house.gov/", ., sep="")
  date=page %>% html_nodes(".col-auto:nth-child(1)") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  kelly16pa=rbind(kelly16pa, data.frame(state, district, name, date, prpage))
}
View(kelly16pa)
write.csv(kelly16pa, "C:/Users/bestf/OneDrive/Desktop/Press Releases/kelly16pa.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
  return(press_info)}

lamb17pa=data.frame()
state="PA"
district=17

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://lamb.house.gov/media/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".font-weight-bold a") %>% html_text() 
  links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://lamb.house.gov/", ., sep="")
  date=page %>% html_nodes(".col-auto:nth-child(1)") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  lamb17pa=rbind(lamb17pa, data.frame(state, district, name, date, prpage))
}
View(lamb17pa)
write.csv(lamb17pa, "C:/Users/bestf/OneDrive/Desktop/Press Releases/lamb17pa.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".even") %>% html_text() %>%str_trim
  return(press_info)}

doyle18pa=data.frame()
state="PA"
district=18

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://doyle.house.gov/media/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".views-field-title a") %>% html_text() 
  links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://doyle.house.gov/media/", ., sep="")
  date=page %>% html_nodes(".views-field-created .field-content") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  doyle18pa=rbind(doyle18pa, data.frame(state, district, name, date, prpage))
}
View(doyle18pa)
write.csv(doyle18pa, "C:/Users/bestf/OneDrive/Desktop/Press Releases/doyle18pa.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".even") %>% html_text() %>%str_trim
  return(press_info)}

cicilline1ri=data.frame()
state="RI"
district=1

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://cicilline.house.gov/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".list-item a") %>% html_text()
  links=page %>% html_nodes(".list-item a") %>% html_attr("href") %>% paste("https://cicilline.house.gov/", ., sep="")
  date=page %>% html_nodes(".date") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  cicilline1ri=rbind(cicilline1ri, data.frame(state, district, name, date, prpage))
}
View(cicilline1ri)
write.csv(cicilline1ri, "C:/Users/bestf/OneDrive/Desktop/Press Releases/cicilline1ri.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
  return(press_info)}

langevin2ri=data.frame()
state="RI"
district=2

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://langevin.house.gov/media/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".font-weight-bold a") %>% html_text() 
  links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://langevin.house.gov", ., sep="")
  date=page %>% html_nodes(".col-auto:nth-child(1)") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  langevin2ri=rbind(langevin2ri, data.frame(state, district, name, date, prpage))
}
View(langevin2ri)
write.csv(langevin2ri, "C:/Users/bestf/OneDrive/Desktop/Press Releases/langevin2ri.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
  return(press_info)}

mace1sc=data.frame()
state="SC"
district=1

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://mace.house.gov/media/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".font-weight-bold a") %>% html_text() 
  links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://mace.house.gov/", ., sep="")
  date=page %>% html_nodes(".col-auto:nth-child(1)") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  mace1sc=rbind(mace1sc, data.frame(state, district, name, date, prpage))
}
View(mace1sc)
write.csv(mace1sc, "C:/Users/bestf/OneDrive/Desktop/Press Releases/mace1sc.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".pane-node-body") %>% html_text() %>%str_trim
  return(press_info)}

wilson2sc=data.frame()
state="SC"
district=2

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://joewilson.house.gov/media-center/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".views-field-title a") %>% html_text() 
  links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://joewilson.house.gov", ., sep="")
  date=page %>% html_nodes(".views-field-created .field-content") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  wilson2sc=rbind(wilson2sc, data.frame(state, district, name, date, prpage))
}
View(wilson2sc)
write.csv(wilson2sc, "C:/Users/bestf/OneDrive/Desktop/Press Releases/wilson2sc.csv")
get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".field-label-hidden .even") %>% html_text() %>%str_trim
  return(press_info)}

duncan3sc=data.frame()
state="SC"
district=3

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://jeffduncan.house.gov/media/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".views-field-title a") %>% html_text() 
  links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://jeffduncan.house.gov/", ., sep="")
  date=page %>% html_nodes(".views-field-created .field-content") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  duncan3sc=rbind(duncan3sc, data.frame(state, district, name, date, prpage))
}
View(duncan3sc)
write.csv(duncan3sc, "C:/Users/bestf/OneDrive/Desktop/Press Releases/duncan3sc.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
  return(press_info)}

timmons4sc=data.frame()
state="SC"
district=4

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://timmons.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".newsie-titler a") %>% html_text() 
  links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://timmons.house.gov/news/", ., sep="")
  date=page %>% html_nodes("time") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  timmons4sc=rbind(timmons4sc, data.frame(state, district, name, date, prpage))
}
View(timmons4sc)
write.csv(timmons4sc, "C:/Users/bestf/OneDrive/Desktop/Press Releases/timmons4sc")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
  return(press_info)}

norman5sc=data.frame()
state="SC"
district=5

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://norman.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".newsie-titler a") %>% html_text() 
  links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://norman.house.gov/news/", ., sep="")
  date=page %>% html_nodes("time") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  norman5sc=rbind(norman5sc, data.frame(state, district, name, date, prpage))
}
View(norman5sc)
write.csv(norman5sc, "C:/Users/bestf/OneDrive/Desktop/Press Releases/norman5sc.csv")


get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".region-content-inner") %>% html_text() %>%str_trim
  return(press_info)}

clyburn6sc=data.frame()
state="SC"
district=6

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://clyburn.house.gov/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".field-content a") %>% html_text() 
  links=page %>% html_nodes(".field-content a") %>% html_attr("href") %>% paste("https://clyburn.house.gov", ., sep="")
  date=page %>% html_nodes(".views-field-created .field-content") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  clyburn6sc=rbind(clyburn6sc, data.frame(state, district, name, date, prpage))
}
View(clyburn6sc)
write.csv(clyburn6sc, "C:/Users/bestf/OneDrive/Desktop/Press Releases/clyburn6sc.csv")
get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".content") %>% html_text() %>%str_trim
  return(press_info)}

rice7sc=data.frame()
state="SC"
district=6

for(page_result in seq(from = 1, to = 15, by = 1))
{
  link= paste0("https://rice.house.gov/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".ContentGrid") %>% html_text() 
  links=page %>% html_nodes(".ContentGrid") %>% html_attr("href") %>% paste("https://rice.house.gov/", ., sep="")
  date=page %>% html_nodes(".recordListDate") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  rice7sc=rbind(rice7sc, data.frame(state, district, name, date, prpage))
}
View(rice7sc)
write.csv(rice7sc, "C:/Users/bestf/OneDrive/Desktop/Press Releases/rice7sc.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".evo-content") %>% html_text() %>%str_trim
  return(press_info)}

johnson1sd=data.frame()
state="SD"
district=1

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://dustyjohnson.house.gov/media/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".font-weight-bold a") %>% html_text() 
  links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://dustyjohnson.house.gov/", ., sep="")
  date=page %>% html_nodes(".col-auto:nth-child(1)") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  johnson1sd=rbind(johnson1sd, data.frame(state, district, name, date, prpage))
}
View(johnson1sd)
write.csv(johnson1sd, "C:/Users/bestf/OneDrive/Desktop/Press Releases/johnson1sd.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".evo-press-release__body span") %>% html_text() %>%str_trim
  return(press_info)}

harshbarger1tn=data.frame()
state="TN"
district=1

for(page_result in seq(from = 0 , to = 15, by = 1))
{
 link= paste0("https://harshbarger.house.gov/media/press-releases?page=", page_result)
  page=read_html(link)
 name=page %>% html_nodes(".font-weight-bold a") %>% html_text() 
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://harshbarger.house.gov/", ., sep="")
 date=page %>% html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
 harshbarger1tn=rbind(harshbarger1tn, data.frame(state, district, name, date, prpage))
}
View(harshbarger1tn)
write.csv(harshbarger1tn, "C:/Users/bestf/OneDrive/Desktop/Press Releases/harshbarger1tn.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes("p") %>% html_text() %>%str_trim
  return(press_info)}

burchett2sd=data.frame()
state="TN"
district=2

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://burchett.house.gov/media/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".font-weight-bold a") %>% html_text() 
  links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://burchett.house.gov/", ., sep="")
  date=page %>% html_nodes(".col-auto:nth-child(1)") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  burchett2sd=rbind(burchett2sd, data.frame(state, district, name, date, prpage))
}
View(burchett2sd)
write.csv(burchett2sd, "C:/Users/bestf/OneDrive/Desktop/Press Releases/burchett2sd.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
  return(press_info)}

fleishmann3tn=data.frame()
state="TN"
district=3

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://fleischmann.house.gov/media/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".font-weight-bold a") %>% html_text() 
  links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://fleischmann.house.gov", ., sep="")
  date=page %>% html_nodes(".col-auto:nth-child(1)") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  fleishmann3tn=rbind(fleishmann3tn, data.frame(state, district, name, date, prpage))
}
View(fleishmann3tn)
write.csv(fleishmann3tn, "C:/Users/bestf/OneDrive/Desktop/Press Releases/fleishmann3tn.csv")


get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".post-content") %>% html_text() %>%str_trim
  return(press_info)}

desjarlais4tn=data.frame()
state="TN"
district=4

for(page_result in seq(from = 1 , to = 15, by = 1))
{
  link= paste0("https://desjarlais.house.gov/media-center?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".post-media-digest-title") %>% html_text() 
  links=page %>% html_nodes(".media-digest-body-link") %>% html_attr("href") %>% paste("https://desjarlais.house.gov", ., sep="")
  date=page %>% html_nodes(".post-media-digest-date") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  desjarlais4tn=rbind(desjarlais4tn, data.frame(state, district, name, date, prpage))
}
View(desjarlais4tn)
write.csv(desjarlais4tn, "C:/Users/bestf/OneDrive/Desktop/Press Releases/desjarlais4tn.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes("block-system-main span") %>% html_text() %>%str_trim
  return(press_info)}

cooper5tn=data.frame()
state="TN"
district=5

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://cooper.house.gov/media-center/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".views-field-title a") %>% html_text() 
  links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://cooper.house.gov/media-center/press-releases/", ., sep="")
  date=page %>% html_nodes(".views-field-created .field-content") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  cooper5tn=rbind(cooper5tn, data.frame(state, district, name, date, prpage))
}
View(cooper5tn)
write.csv(cooper5tn, "C:/Users/bestf/OneDrive/Desktop/Press Releases/cooper5tn.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
  return(press_info)}

rose6tn=data.frame()
state="TN"
district=6

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://johnrose.house.gov/media/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".font-weight-bold a") %>% html_text() 
  links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://johnrose.house.gov/", ., sep="")
  date=page %>% html_nodes(".col-auto:nth-child(1)") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  rose6tn=rbind(rose6tn, data.frame(state, district, name, date, prpage))
}
View(rose6tn)
write.csv(rose6tn, "C:/Users/bestf/OneDrive/Desktop/Press Releases/rose6tn.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".content") %>% html_text() %>%str_trim
  return(press_info)}

green7tn=data.frame()
state="TN"
district=7

for(page_result in seq(from = 1, to = 15, by = 1))
{
  link= paste0("https://markgreen.house.gov/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".ContentGrid") %>% html_text() 
  links=page %>% html_nodes(".ContentGrid") %>% html_attr("href") %>% paste("https://markgreen.house.gov/", ., sep="")
  date=page %>% html_nodes(".recordListDate") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  green7tn=rbind(green7tn, data.frame(state, district, name, date, prpage))
}
View(green7tn)
write.csv(green7tn, "C:/Users/bestf/OneDrive/Desktop/Press Releases/green7tn.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".even") %>% html_text() %>%str_trim
  return(press_info)}

kustoff8tn=data.frame()
state="TN"
district=8

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://kustoff.house.gov/media/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".views-field-title a") %>% html_text()
  links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://kustoff.house.gov/media/", ., sep="")
  date=page %>% html_nodes(".views-field-created .field-content") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  kustoff8tn=rbind(kustoff8tn, data.frame(state, district, name, date, prpage))
}
View(kustoff8tn)
write.csv(kustoff8tn, "C:/Users/bestf/OneDrive/Desktop/Press Releases/kustoff8tn.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".pane-node-body") %>% html_text() %>%str_trim
  return(press_info)}

cohen9tn=data.frame()
state="TN"
district=9

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://cohen.house.gov/media-center/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".views-field-title a") %>% html_text()
  links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://cohen.house.gov", ., sep="")
  date=page %>% html_nodes(".views-field-created .field-content") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  cohen9tn=rbind(cohen9tn, data.frame(state, district, name, date, prpage))
}
View(cohen9tn)
write.csv(cohen9tn, "C:/Users/bestf/OneDrive/Desktop/Press Releases/cohen9tn.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
  return(press_info)}

chabotoh1pr=data.frame()
state="OH"
district=1

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://chabot.house.gov/news/documentquery.aspx?DocumentTypeID=2508&Page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".newsie-titler a") %>% html_text()
  links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://chabot.house.gov/news/", ., sep="")
  date=page %>% html_nodes("time") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  chabotoh1pr=rbind(chabotoh1pr, data.frame(state, district, name, date, prpage))
}
View(chabotoh1pr)
write.csv(chabotoh1pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/chabotoh1pr.csv")

get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
  return(press_info)}

wenstrupOH2pr=data.frame()
state="OH"
district=2

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://wenstrup.house.gov/updates/documentquery.aspx?DocumentTypeID=2491&Page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes("h2 a") %>% html_text()
  links=page %>% html_nodes(".btn-link") %>% html_attr("href") %>% paste("https://wenstrup.house.gov", ., sep="")
  date=page %>% html_nodes("time") %>% html_text()
  prpage=sapply(links, FUN=get_main)
  wenstrupOH2pr=rbind(wenstrupOH2pr, data.frame(state, district, name, date, prpage))
}
View(wenstrupOH2pr)
write.csv(wenstrupOH2pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/wenstrupOH2pr.csv")


get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
  return(press_info)}

lattaOH5pr=data.frame()
state="OH"
district=2

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://latta.house.gov/news/documentquery.aspx?DocumentTypeID=1456&Page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".newsie-titler a") %>% html_text()
  links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://latta.house.gov/news/", ., sep="")
  date=page %>% html_nodes("time") %>% html_text()
  prpage=sapply(links, FUN=get_main)
 lattaOH5pr=rbind(lattaOH5pr, data.frame(state, district, name, date, prpage))
}
View(lattaOH5pr)
write.csv(lattaOH5pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/lattaOH5pr.csv")


get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".content") %>% html_text() %>%str_trim
  return(press_info)}

turnerOH10pr=data.frame()
state="OH"
district=10

for(page_result in seq(from = 0 , to = 15, by = 1))
{
  link= paste0("https://turner.house.gov/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".ContentGrid") %>% html_text()
  links=page %>% html_nodes(".ContentGrid") %>% html_attr("href") %>% paste("https://turner.house.gov/", ., sep="")
  date=page %>% html_nodes(".recordListDate") %>% html_text()
  prpage=sapply(links, FUN=get_main)
 turnerOH10pr=rbind(turnerOH10pr, data.frame(state, district, name, date, prpage))
}
View(turnerOH10pr)
write.csv(turnerOH10pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/turnerOH10pr.csv")


https://davidson.house.gov/press-releases?page=


get_main=function(links) {
  press_page=read_html(links)
  press_info=press_page%>% html_nodes(".content") %>% html_text() %>%str_trim
  return(press_info)}

davidsonOH8pr=data.frame()
state="OH"
district=8

for(page_result in seq(from = 1 , to = 15, by = 1))
{
  link= paste0("https://davidson.house.gov/press-releases?page=", page_result)
  page=read_html(link)
  name=page %>% html_nodes(".ContentGrid") %>% html_text()
  links=page %>% html_nodes(".ContentGrid") %>% html_attr("href") %>% paste("https://davidson.house.gov", ., sep="")
  date=page %>% html_nodes(".recordListDate") %>% html_text()
  prpage=sapply(links, FUN=get_main)
 davidsonOH8pr=rbind(davidsonOH8pr, data.frame(state, district, name, date, prpage))
}
View(davidsonOH8pr)
write.csv(davidsonOH8pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/davidsonOH8pr.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}
gohmerttx1=data.frame()
state="TX"
district=1
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://gohmert.house.gov/news/documentquery.aspx?DocumentTypeID=1954&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://gohmert.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
gohmerttx1=rbind(gohmerttx1, data.frame(state, district, name, date, prpage))
}
View(gohmerttx1)
write.csv(gohmerttx1, "C:/Users/bestf/OneDrive/Desktop/Press Releases/gohmerttx1.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".content p:nth-child(1) ") %>% html_text() %>%str_trim
return(press_info)}
crenshawtx2=data.frame()
state="TX"
district=2
for(page_result in seq(from = 1 , to = 15, by = 1))
{
link= 
paste0("https://crenshaw.house.gov/press-releases?page=", 
page_result)
page=read_html(link)
name=page %>% html_nodes(".ContentGrid") %>% html_text()
links=page %>% html_nodes(".ContentGrid") %>% html_attr("href") %>% paste("https://crenshaw.house.gov", ., sep="")
date=page %>%html_nodes(".recordListDate") %>% html_text()
prpage=sapply(links, FUN=get_main)
crenshawtx2=rbind(crenshawtx2, data.frame(state, district, name, date, prpage))
}
View(crenshawtx2)
write.csv(crenshawtx2, "C:/Users/bestf/OneDrive/Desktop/Press Releases/crenshawtx2.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}
vantaylortx3=data.frame()
state="TX"
district=3
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://vantaylor.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", 
page_result)
page=read_html(link)
name=page %>% html_nodes(".news-title a") %>% html_text()
links=page %>% html_nodes(".news-title a") %>% html_attr("href") %>% paste("https://vantaylor.house.gov", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
vantaylortx3=rbind(vantaylortx3, data.frame(state, district, name, date, prpage))
}
View(vantaylortx3)
write.csv(vantaylortx3, "C:/Users/bestf/OneDrive/Desktop/Press Releases/vantaylortx3.csv")




get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
return(press_info)}
fallontx4=data.frame()
state="TX"
district=4
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://fallon.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://fallon.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
fallontx4=rbind(fallontx4, data.frame(state, district, name, date, prpage))
}
View(fallontx4)
write.csv(fallontx4, "C:/Users/bestf/OneDrive/Desktop/Press Releases/fallontx4.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".content") %>% html_text() %>%str_trim
return(press_info)}
goodentx5=data.frame()
state="TX"
district=5
for(page_result in seq(from = 1 , to = 15, by = 1))
{
link= 
paste0("https://gooden.house.gov/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".post-media-digest-title") %>% html_text()
links=page %>% html_nodes(".media-digest-body-link") %>% html_attr("href")%>% paste("https://gooden.house.gov", ., sep="")
date=page %>%html_nodes(".post-media-digest-date") %>% html_text()
prpage=sapply(links, FUN=get_main)
goodentx5=rbind(goodentx5, data.frame(state, district, name, date, prpage))
}
View(goodentx5)
write.csv(goodentx5, "C:/Users/bestf/OneDrive/Desktop/Press Releases/goodentx5.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
return(press_info)}
ellzeytx6=data.frame()
state="TX"
district=6
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://ellzey.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://ellzey.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
ellzeytx6=rbind(ellzeytx6, data.frame(state, district, name, date, prpage))
}
View(ellzeytx6)
write.csv(ellzeytx6, "C:/Users/bestf/OneDrive/Desktop/Press Releases/ellzeytx6.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}
fletchertx7=data.frame()
state="TX"
district=7
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://fletcher.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsbtn") %>% html_attr("href") %>% paste("https://fletcher.house.gov", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
fletchertx7=rbind(fletchertx7, data.frame(state, district, name, date, prpage))
}
View(fletchertx7)
write.csv(fletchertx7, "C:/Users/bestf/OneDrive/Desktop/Press Releases/fletchertx7.csv")







get_main=function(links) { 
press_page=read_html(links) 
press_info=press_page%>% html_nodes(".bodycopy ") %>% html_text() %>%  
paste(collapse=",") 
return(press_info) 
} 

get_maindate=function(links) { 
press_page2=read_html(links) 
press_infodate=press_page2%>% html_nodes("b") %>% html_text() %>%  
paste(collapse=",") 
return(press_infodate) 
} 
bradytx8pr=data.frame() 
state="TX" 
district=8 
for(page_result in seq(from = 0, to = 15, by = 1)) 
{ 
link=  
paste0("https://kevinbrady.house.gov/news/documentquery.aspx?DocumentTypeID=2657&Page=", page_result) 
page=read_html(link) 
name=page %>% html_nodes(".middleheadline") %>% html_text() 
links=page %>% html_nodes(".middleheadline") %>% html_attr("href") %>%  
paste("https://kevinbrady.house.gov/news/",., sep="") 
prpage=sapply(links, FUN=get_main) 
prpagedate=sapply(links, FUN=get_maindate) 
bradytx8pr =rbind(bradytx8pr, data.frame(state, district, name, prpagedate, prpage)) 
} 
View(bradytx8pr) 
write.csv(bradytx8pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/bradytx8pr.csv")







get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
return(press_info)}
greentx9=data.frame()
state="TX"
district=9
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://algreen.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://algreen.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
greentx9=rbind(greentx9, data.frame(state, district, name, date, prpage))
}
View(greentx9)
write.csv(greentx9, "C:/Users/bestf/OneDrive/Desktop/Press Releases/greentx9.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-label-hidden .even") %>% html_text() %>%str_trim
return(press_info)}
mccaultx10=data.frame()
state="TX"
district=10
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://mccaul.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://mccaul.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
mccaultx10=rbind(mccaultx10, data.frame(state, district, name, date, prpage))
}
View(mccaultx10)
write.csv(mccaultx10, "C:/Users/bestf/OneDrive/Desktop/Press Releases/mccaultx10.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
return(press_info)}
pflugertx11=data.frame()
state="TX"
district=11
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link=paste0("https://pfluger.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://pfluger.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
pflugertx11=rbind(pflugertx11, data.frame(state, district, name, date, prpage))
}
View(pflugertx11)
write.csv(pflugertx11, "C:/Users/bestf/OneDrive/Desktop/Press Releases/pflugertx11.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".content") %>% html_text() %>%str_trim
return(press_info)}
grangertx12=data.frame()
state="TX"
district=12
for(page_result in seq(from = 1 , to = 15, by = 1))
{
link= 
paste0("https://kaygranger.house.gov/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".ContentGrid") %>% html_text()
links=page %>% html_nodes(".ContentGrid") %>% html_attr("href")%>% paste("https://kaygranger.house.gov", ., sep="")
date=page %>%html_nodes(".recordListDate") %>% html_text()
prpage=sapply(links, FUN=get_main)
grangertx12=rbind(grangertx12, data.frame(state, district, name, date, prpage))
}
View(grangertx12)
write.csv(grangertx12, "C:/Users/bestf/OneDrive/Desktop/Press Releases/grangertx12.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}
Jacksontx13=data.frame()
state="TX"
district=13
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://jackson.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://jackson.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
Jacksontx13=rbind(Jacksontx13, data.frame(state, district, name, date, prpage))
}
View(Jacksontx13)
write.csv(Jacksontx13, "C:/Users/bestf/OneDrive/Desktop/Press Releases/Jacksontx13.csv")
  

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}
Webertx14=data.frame()
state="TX"
district=14
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://weber.house.gov/news/documentquery.aspx?DocumentTypeID=27&page=", 
page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://weber.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
Webertx14=rbind(Webertx14, data.frame(state, district, name, date, prpage))
}
View(Webertx14)
write.csv(Webertx14, "C:/Users/bestf/OneDrive/Desktop/Press Releases/Webertx14.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".even") %>% html_text() %>%str_trim
return(press_info)}
gonzáleztx15=data.frame()
state="TX"
district=15
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://gonzalez.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://gonzalez.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
gonzáleztx15=rbind(gonzáleztx15, data.frame(state, district, name, date, prpage))
}
View(gonzáleztx15)

write.csv(gonzáleztx15, "C:/Users/bestf/OneDrive/Desktop/Press Releases/gonzáleztx15.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}
escobartx16=data.frame()
state="TX"
district=16
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://escobar.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://escobar.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
escobartx16=rbind(escobartx16, data.frame(state, district, name, date, prpage))
}
View(escobartx16)
write.csv(escobartx16, "C:/Users/bestf/OneDrive/Desktop/Press Releases/escobartx16.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
return(press_info)}
sessionsx17=data.frame()
state="TX"
district=17
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://sessions.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://sessions.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
sessionsx17=rbind(sessionsx17, data.frame(state, district, name, date, prpage))
}
View(sessionsx17)
write.csv(sessionsx17, "C:/Users/bestf/OneDrive/Desktop/Press Releases/sessionsx17.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}
jacksonleetx18=data.frame()
state="TX"
district=18
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://jacksonlee.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://jacksonlee.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
jacksonleetx18=rbind(jacksonleetx18, data.frame(state, district, name, date, prpage))
}
View(jacksonleetx18)
write.csv(jacksonleetx18, "C:/Users/bestf/OneDrive/Desktop/Press Releases/jacksonleetx18.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}
arringtontx19=data.frame()
state="TX"
district=19
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://arrington.house.gov/news/documentquery.aspx?DocumentTypeID=27&page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://arrington.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
arringtontx19=rbind(arringtontx19, data.frame(state, district, name, date, prpage))
}
View(arringtontx19)
write.csv(arringtontx19, "C:/Users/bestf/OneDrive/Desktop/Press Releases/arringtontx19.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
return(press_info)}
roytx21=data.frame()
state="TX"
district=21
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://roy.house.gov/media/press-releases?page=",page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://roy.house.gov/", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
roytx21=rbind(roytx21, data.frame(state, district, name, date, prpage))
}
View(roytx21)
write.csv(roytx21, "C:/Users/bestf/OneDrive/Desktop/Press Releases/roytx21.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#press") %>% html_text() %>%str_trim
return(press_info)}
castrotx20=data.frame()
state="TX"
district=20
for(page_result in seq(from = 1 , to = 15, by = 1))
{
link= 
paste0("https://castro.house.gov/media-center/press-releases?PageNum_rs=",page_result)
page=read_html(link)
name=page %>% html_nodes(".title a") %>% html_text()
links=page %>% html_nodes(".title a") %>% html_attr("href") %>% paste("https://castro.house.gov", ., sep="")
date=page %>%html_nodes(".black") %>% html_text()
prpage=sapply(links, FUN=get_main)
castrotx20=rbind(castrotx20, data.frame(state, district, name, date, prpage))
}
View(castrotx20)
write.csv(castrotx20, "C:/Users/bestf/OneDrive/Desktop/Press Releases/castrotx20.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#press") %>% html_text() %>%str_trim
return(press_info)}
castrotx20=data.frame()
state="TX"
district=20
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://castro.house.gov/media-center/press-releases?PageNum_rs=",page_result)
page=read_html(link)
name=page %>% html_nodes(".title a") %>% html_text()
links=page %>% html_nodes(".title a") %>% html_attr("href") %>% paste("https://castro.house.gov", ., sep="")
date=page %>%html_nodes(".black") %>% html_text()
prpage=sapply(links, FUN=get_main)
castrotx20=rbind(castrotx20, data.frame(state, district, name, date, prpage))
}
View(castrotx20)
write.csv(castrotx20, "C:/Users/bestf/OneDrive/Desktop/Press Releases/castrotx20.csv")




get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
return(press_info)}
gonzaleztx23=data.frame()
state="TX"
district=23
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://gonzales.house.gov/media/press-releases?page=",page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://gonzales.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
gonzaleztx23=rbind(gonzaleztx23, data.frame(state, district, name, date, prpage))
}
View(gonzaleztx23)
write.csv(gonzaleztx23, "C:/Users/bestf/OneDrive/Desktop/Press Releases/gonzaleztx23.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
return(press_info)}
vanduynetx24=data.frame()
state="TX"
district=24
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://vanduyne.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://vanduyne.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
vanduynetx24=rbind(vanduynetx24, data.frame(state, district, name, date, prpage))
}
View(vanduynetx24)
write.csv(vanduynetx24, "C:/Users/bestf/OneDrive/Desktop/Press Releases/vanduynetx24.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}
williamstx25=data.frame()
state="TX"
district=25
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://williams.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://williams.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
williamstx25=rbind(williamstx25, data.frame(state, district, name, date, prpage))
}
View(williamstx25)
write.csv(williamstx25, "C:/Users/bestf/OneDrive/Desktop/Press Releases/williamstx25.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}
burgesstx26=data.frame()
state="TX"
district=26
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://burgess.house.gov/news/documentquery.aspx?DocumentTypeID=75&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://burgess.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
burgesstx26=rbind(burgesstx26, data.frame(state, district, name, date, prpage))
}
View(burgesstx26)
write.csv(burgesstx26, "C:/Users/bestf/OneDrive/Desktop/Press Releases/burgesstx26.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}
cloudtx27=data.frame()
state="TX"
district=27
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://cloud.house.gov/news/documentquery.aspx?DocumentTypeID=27&page=", 
page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://cloud.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
cloudtx27=rbind(cloudtx27, data.frame(state, district, name, date, prpage))
}
View(cloudtx27)
write.csv(cloudtx27, "C:/Users/bestf/OneDrive/Desktop/Press Releases/cloudtx27.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}
cuellartx28=data.frame()
state="TX"
district=28
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://cuellar.house.gov/news/documentquery.aspx?DocumentTypeID=1232&page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler") %>% html_text()
links=page %>% html_nodes(".newsbtn") %>% html_attr("href") %>% paste("https://cuellar.house.gov", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
cuellartx28=rbind(cuellartx28, data.frame(state, district, name, date, prpage))
}
View(cuellartx28)
write.csv(cuellartx28, "C:/Users/bestf/OneDrive/Desktop/Press Releases/cuellartx28.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}
garciatx29=data.frame()
state="TX"
district=29
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://sylviagarcia.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://sylviagarcia.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
garciatx29=rbind(garciatx29, data.frame(state, district, name, date, prpage))
}
View(garciatx29)
write.csv(garciatx29, "C:/Users/bestf/OneDrive/Desktop/Press Releases/garciatx29.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}
johnsontx30=data.frame()
state="TX"
district=30
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://ebjohnson.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://ebjohnson.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
johnsontx30=rbind(johnsontx30, data.frame(state, district, name, date, prpage))
}
View(johnsontx30)
write.csv(johnsontx30, "C:/Users/bestf/OneDrive/Desktop/Press Releases/johnsontx30.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}
carterx31=data.frame()
state="TX"
district=31
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://carter.house.gov/news/documentquery.aspx?DocumentTypeID=27&page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://carter.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
carterx31=rbind(carterx31, data.frame(state, district, name, date, prpage))
}
View(carterx31)
write.csv(carterx31, "C:/Users/bestf/OneDrive/Desktop/Press Releases/carterx31.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
return(press_info)}
allredtx32=data.frame()
state="TX"
district=32
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://allred.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://allred.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
allredtx32=rbind(allredtx32, data.frame(state, district, name, date, prpage))
}
View(allredtx32)
write.csv(allredtx32, "C:/Users/bestf/OneDrive/Desktop/Press Releases/allredtx32.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}
veaseytx33=data.frame()
state="TX"
district=33
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://veasey.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://veasey.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
veaseytx33=rbind(veaseytx33, data.frame(state, district, name, date, prpage))
}
View(veaseytx33)
write.csv(veaseytx33, "C:/Users/bestf/OneDrive/Desktop/Press Releases/veaseytx33.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
return(press_info)}
doggetttx35=data.frame()
state="TX"
district=35
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://doggett.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://doggett.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
doggetttx35=rbind(doggetttx35, data.frame(state, district, name, date, prpage))
}
View(doggetttx35)
write.csv(doggetttx35, "C:/Users/bestf/OneDrive/Desktop/Press Releases/doggetttx35.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}
babintx36=data.frame()
state="TX"
district=36
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://babin.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://babin.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
babintx36=rbind(babintx36, data.frame(state, district, name, date, prpage))
}
View(babintx36)
write.csv(babintx36, "C:/Users/bestf/OneDrive/Desktop/Press Releases/babintx36.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
return(press_info)}
Mooreut1=data.frame()
state="UT"
district=1
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://blakemoore.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://blakemoore.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
Mooreut1=rbind(Mooreut1, data.frame(state, district, name, date, prpage))
}
View(Mooreut1)
write.csv(Mooreut1, "C:/Users/bestf/OneDrive/Desktop/Press Releases/Mooreut1.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}
stewartut2=data.frame()
state="UT"
district=2
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://stewart.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://stewart.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
stewartut2=rbind(stewartut2, data.frame(state, district, name, date, prpage))
}
View(stewartut2)
write.csv(stewartut2, "C:/Users/bestf/OneDrive/Desktop/Press Releases/stewartut2.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".container") %>% html_text() %>%str_trim
return(press_info)}
curtisut3=data.frame()
state="UT"
district=3
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://curtis.house.gov/category/press-releases/page/", page_result)
page=read_html(link)
name=page %>% html_nodes(".post-preview-title") %>% html_text()
links=page %>% html_nodes(".post-preview-title") %>% html_attr("href") %>% paste("", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
curtisut3=rbind(curtisut3, data.frame(state, district, name, date, prpage))
}
View(curtisut3)
write.csv(curtisut3, "C:/Users/bestf/OneDrive/Desktop/Press Releases/curtisut3.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}
Welchvt1=data.frame()
state="VT"
district=1
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://welch.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://welch.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
Welchvt1=rbind(Welchvt1, data.frame(state, district, name, date, prpage))
}
View(Welchvt1)
write.csv(Welchvt1, "C:/Users/bestf/OneDrive/Desktop/Press Releases/Welchvt1.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}
wittmanva1=data.frame()
state="VA"
district=1
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://wittman.house.gov/news/documentquery.aspx?DocumentTypeID=2670&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://wittman.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
wittmanva1=rbind(wittmanva1, data.frame(state, district, name, date, prpage))
}
View(wittmanva1)
write.csv(wittmanva1, "C:/Users/bestf/OneDrive/Desktop/Press Releases/wittmanva1.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
return(press_info)}
luriava2=data.frame()
state="VA"
district=2
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://luria.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://luria.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
luriava2=rbind(luriava2, data.frame(state, district, name, date, prpage))
}
View(luriava2)
write.csv(luriava2, "C:/Users/bestf/OneDrive/Desktop/Press Releases/luriava2.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}
scottva3=data.frame()
state="VA"
district=3
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://bobbyscott.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://bobbyscott.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
scottva3=rbind(scottva3, data.frame(state, district, name, date, prpage))
}
View(scottva3)
write.csv(scottva3, "C:/Users/bestf/OneDrive/Desktop/Press Releases/scottva3.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}
mceachinva4=data.frame()
state="VA"
district=4
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://mceachin.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://mceachin.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
mceachinva4=rbind(mceachinva4, data.frame(state, district, name, date, prpage))
}
View(mceachinva4)
write.csv(mceachinva4, "C:/Users/bestf/OneDrive/Desktop/Press Releases/mceachinva4.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
return(press_info)}
goodva5=data.frame()
state="VA"
district=5
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://good.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://good.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-nothing .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
goodva5=rbind(goodva5, data.frame(state, district, name, date, prpage))
}
View(goodva5)
write.csv(goodva5, "C:/Users/bestf/OneDrive/Desktop/Press Releases/goodva5.csv")





get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
return(press_info)}
clineva6=data.frame()
state="VA"
district=6
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://cline.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://cline.house.gov/", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
clineva6=rbind(clineva6, data.frame(state, district, name, date, prpage))
}
View(clineva6)
write.csv(clineva6, "C:/Users/bestf/OneDrive/Desktop/Press Releases/clineva6.csv")




get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}
beyerva8=data.frame()
state="VA"
district=8
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://beyer.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://beyer.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
beyerva8=rbind(beyerva8, data.frame(state, district, name, date, prpage))
}
View(beyerva8)
write.csv(beyerva8, "C:/Users/bestf/OneDrive/Desktop/Press Releases/beyerva8.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}
griffithva9=data.frame()
state="VA"
district=9
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://morgangriffith.house.gov/news/documentquery.aspx?DocumentTypeID=2235&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://morgangriffith.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
griffithva9=rbind(griffithva9, data.frame(state, district, name, date, prpage))
}
View(griffithva9)
write.csv(griffithva9, "C:/Users/bestf/OneDrive/Desktop/Press Releases/griffithva9.csv")





get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}
wextonva10=data.frame()
state="VA"
district=10
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://wexton.house.gov/news/documentquery.aspx?DocumentTypeID=27&page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://wexton.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
wextonva10=rbind(wextonva10, data.frame(state, district, name, date, prpage))
}
View(wextonva10)
write.csv(wextonva10, "C:/Users/bestf/OneDrive/Desktop/Press Releases/wextonva10.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}
connollyva11=data.frame()
state="VA"
district=11
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://connolly.house.gov/news/documentquery.aspx?DocumentTypeID=1952&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://connolly.house.gov/news/", ., sep="")
date=page %>%html_nodes("#newsdoclist time") %>% html_text()
prpage=sapply(links, FUN=get_main)
connollyva11=rbind(connollyva11, data.frame(state, district, name, date, prpage))
}
View(connollyva11)
write.csv(connollyva11, "C:/Users/bestf/OneDrive/Desktop/Press Releases/connollyva11.csv")

get_main=function(links) { 
press_page=read_html(links) 
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%  
paste(collapse=",") 
return(press_info) 
} 

get_maindate=function(links) { 
press_page2=read_html(links) 
press_infodate=press_page2%>% html_nodes(".topnewstext b") %>% html_text() %>%  
paste(collapse=",") 
return(press_infodate) 
} 
delbenewa1pr=data.frame() 
state="WA" 
district=1 
for(page_result in seq(from = 0, to = 15, by = 1)) 
{ 
link=  
paste0("https://delbene.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result) 
page=read_html(link) 
name=page %>% html_nodes(".middleheadline") %>% html_text() 
links=page %>% html_nodes(".middleheadline") %>% html_attr("href") %>%  
paste("https://delbene.house.gov/news/",., sep="") 
prpage=sapply(links, FUN=get_main) 
prpagedate=sapply(links, FUN=get_maindate) 
delbenewa1pr=rbind(delbenewa1pr, data.frame(state, district, name, prpagedate, prpage)) 
} 
View(delbenewa1pr) 
write.csv(delbenewa1pr, "C:/Users/bestf/OneDrive/Desktop/Press Releases/delbenewa1pr.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}
larsenwa2=data.frame()
state="WA"
district=2
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://larsen.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://larsen.house.gov/news/", ., sep="")
date=page %>%html_nodes("#newsdoclist time") %>% html_text()
prpage=sapply(links, FUN=get_main)
larsenwa2=rbind(larsenwa2, data.frame(state, district, name, date, prpage))
}
View(larsenwa2)
write.csv(larsenwa2, "C:/Users/bestf/OneDrive/Desktop/Press Releases/larsenwa2.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}
beutlerwa3=data.frame()
state="WA"
district=3
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://jhb.house.gov/news/documentquery.aspx?DocumentTypeID=2113&page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://jhb.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
beutlerwa3=rbind(beutlerwa3, data.frame(state, district, name, date, prpage))
}
View(beutlerwa3)
write.csv(beutlerwa3, "C:/Users/bestf/OneDrive/Desktop/Press Releases/beutlerwa3.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
return(press_info)}
newhousewa4=data.frame()
state="WA"
district=4
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://newhouse.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://newhouse.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
newhousewa4=rbind(newhousewa4, data.frame(state, district, name, date, prpage))
}
View(newhousewa4)
write.csv(newhousewa4, "C:/Users/bestf/OneDrive/Desktop/Press Releases/newhousewa4.csv")





get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#press") %>% html_text() %>%str_trim
return(press_info)}
kilmerwa6=data.frame()
state="WA"
district=6
for(page_result in seq(from = 1 , to = 15, by = 1))
{
link= 
paste0("https://kilmer.house.gov/news/press-releases?PageNum_rs=", page_result)
page=read_html(link)
name=page %>% html_nodes(".title a") %>% html_text()
links=page %>% html_nodes(".title a") %>% html_attr("href") %>% paste("https://kilmer.house.gov/", ., sep="")
date=page %>%html_nodes(".black") %>% html_text()
prpage=sapply(links, FUN=get_main)
kilmerwa6=rbind(kilmerwa6, data.frame(state, district, name, date, prpage))
}
View(kilmerwa6)
write.csv(kilmerwa6, "C:/Users/bestf/OneDrive/Desktop/Press Releases/kilmerwa6.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".clearfix") %>% html_text() %>%str_trim
return(press_info)}
jayapalwa7=data.frame()
state="WA"
district=7
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://jayapal.house.gov/category/news/page/", page_result)
page=read_html(link)
name=page %>% html_nodes("h2 a") %>% html_text()
links=page %>% html_nodes("h2 a") %>% html_attr("href") %>% paste("https://jayapal.house.gov/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
jayapalwa7=rbind(jayapalwa7, data.frame(state, district, name, date, prpage))
}
View(jayapalwa7)
write.csv(jayapalwa7, "C:/Users/bestf/OneDrive/Desktop/Press Releases/jayapalwa7.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
return(press_info)}
schrierwa8=data.frame()
state="WA"
district=8
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://schrier.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://schrier.house.gov/", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
schrierwa8=rbind(schrierwa8, data.frame(state, district, name, date, prpage))
}
View(schrierwa8)
write.csv(schrierwa8, "C:/Users/bestf/OneDrive/Desktop/Press Releases/schrierwa8.csv")





get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".post-content") %>% html_text() %>%str_trim
return(press_info)}
smithwa9=data.frame()
state="WA"
district=9
for(page_result in seq(from = 1 , to = 15, by = 1))
{
link= 
paste0("https://adamsmith.house.gov/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".ContentGrid") %>% html_text()
links=page %>% html_nodes(".ContentGrid") %>% html_attr("href") %>% paste("https://adamsmith.house.gov", ., sep="")
date=page %>%html_nodes(".recordListDate") %>% html_text()
prpage=sapply(links, FUN=get_main)
smithwa9=rbind(smithwa9, data.frame(state, district, name, date, prpage))
}
View(smithwa9)
write.csv(smithwa9, "C:/Users/bestf/OneDrive/Desktop/Press Releases/smithwa9.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
return(press_info)}
stricklandwa10=data.frame()
state="WA"
district=10
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://strickland.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://strickland.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
stricklandwa10=rbind(stricklandwa10, data.frame(state, district, name, date, prpage))
}
View(stricklandwa10)
write.csv(stricklandwa10, "C:/Users/bestf/OneDrive/Desktop/Press Releases/stricklandwa10.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}
mckinleywv1=data.frame()
state="WV"
district=1
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://mckinley.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://mckinley.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
mckinleywv1=rbind(mckinleywv1, data.frame(state, district, name, date, prpage))
}
View(mckinleywv1)
write.csv(mckinleywv1, "C:/Users/bestf/OneDrive/Desktop/Press Releases/mckinleywv1.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".article .container") %>% html_text() %>%str_trim
return(press_info)}

get_maindate=function(links) { 
press_page2=read_html(links) 
press_infodate=press_page2%>% html_nodes(".article__meta span") %>% html_text() %>%  
paste(collapse=",") 
return(press_infodate) 
} 

mooneywv2=data.frame()
state="WV"
district=2
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://mooney.house.gov/category/press-releases/page/", page_result)
page=read_html(link)
name=page %>% html_nodes(".articles__itemTitle") %>% html_text()
links=page %>% html_nodes(".articles__itemLink") %>% html_attr("href") %>% paste("https://mooney.house.gov/", ., sep="")
prpagedate=sapply(links, FUN=get_maindate) 
prpage=sapply(links, FUN=get_main)
mooneywv2=rbind(mooneywv2, data.frame(state, district, name, prpagedate, prpage))
}
View(mooneywv2)
write.csv(mooneywv2, "C:/Users/bestf/OneDrive/Desktop/Press Releases/mooneywv2.csv")





get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
return(press_info)}
millerwv3=data.frame()
state="WV"
district=3
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://miller.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://miller.house.gov//", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
millerwv3=rbind(millerwv3, data.frame(state, district, name, date, prpage))
}
View(millerwv3)
write.csv(millerwv3, "C:/Users/bestf/OneDrive/Desktop/Press Releases/millerwv3.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-content") %>% html_text() %>%str_trim
return(press_info)}
steilwi1=data.frame()
state="WI"
district=1
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://steil.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://steil.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
steilwi1=rbind(steilwi1, data.frame(state, district, name, date, prpage))
}
View(steilwi1)
write.csv(steilwi1, "C:/Users/bestf/OneDrive/Desktop/Press Releases/steilwi1.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes("#block-system-main") %>% html_text() %>%str_trim
return(press_info)}
pocanwi2=data.frame()
state="WI"
district=2
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://pocan.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://pocan.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
pocanwi2=rbind(pocanwi2, data.frame(state, district, name, date, prpage))
}
View(pocanwi2)
write.csv(pocanwi2, "C:/Users/bestf/OneDrive/Desktop/Press Releases/pocanwi2.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".field-label-hidden") %>% html_text() %>%str_trim
return(press_info)}
kindwi3=data.frame()
state="WI"
district=3
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://kind.house.gov/media-center/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://kind.house.gov/", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
kindwi3=rbind(kindwi3, data.frame(state, district, name, date, prpage))
}
View(kindwi3)
write.csv(kindwi3, "C:/Users/bestf/OneDrive/Desktop/Press Releases/kindwi3.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}
moorewi4=data.frame()
state="WI"
district=4
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://gwenmoore.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://gwenmoore.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
moorewi4=rbind(moorewi4, data.frame(state, district, name, date, prpage))
}
View(moorewi4)
write.csv(moorewi4, "C:/Users/bestf/OneDrive/Desktop/Press Releases/moorewi4.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-press-release__body") %>% html_text() %>%str_trim
return(press_info)}
fitzgeraldwi5=data.frame()
state="WI"
district=5
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://fitzgerald.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://fitzgerald.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
fitzgeraldwi5=rbind(fitzgeraldwi5, data.frame(state, district, name, date, prpage))
}
View(fitzgeraldwi5)
write.csv(fitzgeraldwi5, "C:/Users/bestf/OneDrive/Desktop/Press Releases/fitzgeraldwi5.csv")



get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".bodycopy") %>% html_text() %>%str_trim
return(press_info)}
grothmanwi6=data.frame()
state="WI"
district=6
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://grothman.house.gov/news/documentquery.aspx?DocumentTypeID=27&Page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".newsie-titler a") %>% html_text()
links=page %>% html_nodes(".newsie-titler a") %>% html_attr("href") %>% paste("https://grothman.house.gov/news/", ., sep="")
date=page %>%html_nodes("time") %>% html_text()
prpage=sapply(links, FUN=get_main)
grothmanwi6=rbind(grothmanwi6, data.frame(state, district, name, date, prpage))
}
View(grothmanwi6)
write.csv(grothmanwi6, "C:/Users/bestf/OneDrive/Desktop/Press Releases/grothmanwi6.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".evo-content") %>% html_text() %>%str_trim
return(press_info)}
tiffanywi7=data.frame()
state="WI"
district=7
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://tiffany.house.gov/media/press-releases?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".font-weight-bold a") %>% html_text()
links=page %>% html_nodes(".font-weight-bold a") %>% html_attr("href") %>% paste("https://tiffany.house.gov", ., sep="")
date=page %>%html_nodes(".col-auto:nth-child(1)") %>% html_text()
prpage=sapply(links, FUN=get_main)
tiffanywi7=rbind(tiffanywi7, data.frame(state, district, name, date, prpage))
}
View(tiffanywi7)
write.csv(tiffanywi7, "C:/Users/bestf/OneDrive/Desktop/Press Releases/tiffanywi7.csv")


get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".even") %>% html_text() %>%str_trim
return(press_info)}
gallagherwi8=data.frame()
state="WI"
district=8
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://gallagher.house.gov/media?page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".views-field-title a") %>% html_text()
links=page %>% html_nodes(".views-field-title a") %>% html_attr("href") %>% paste("https://gallagher.house.gov", ., sep="")
date=page %>%html_nodes(".views-field-created .field-content") %>% html_text()
prpage=sapply(links, FUN=get_main)
gallagherwi8=rbind(gallagherwi8, data.frame(state, district, name, date, prpage))
}
View(gallagherwi8)
write.csv(gallagherwi8, "C:/Users/bestf/OneDrive/Desktop/Press Releases/gallagherwi8.csv")

get_main=function(links) {
press_page=read_html(links)
press_info=press_page%>% html_nodes(".post-content") %>% html_text() %>%str_trim
return(press_info)}
cheneywy1=data.frame()
state="WY"
district=1
for(page_result in seq(from = 0 , to = 15, by = 1))
{
link= 
paste0("https://cheney.house.gov/category/press_release/?filter_page=", page_result)
page=read_html(link)
name=page %>% html_nodes(".h4") %>% html_text()
links=page %>% html_nodes(".h4") %>% html_attr("href") %>% paste("https://cheney.house.gov/", ., sep="")
date=page %>%html_nodes(".news-top") %>% html_text()
prpage=sapply(links, FUN=get_main)
cheneywy1=rbind(cheneywy1, data.frame(state, district, name, date, prpage))
}
View(cheneywy1)
write.csv(cheneywy1, "C:/Users/bestf/OneDrive/Desktop/Press Releases/cheneywy1.csv")













