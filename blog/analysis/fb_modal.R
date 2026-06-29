suppressMessages(devtools::load_all("/Users/zaynesember/GitRepos/pressR"))
source("/Users/zaynesember/GitRepos/pressR/nlp/R/00_foundation.R")
suppressMessages({ library(DBI); library(duckdb); library(data.table); library(ggplot2)
  library(quanteda); library(quanteda.textstats); library(jsonlite) })
FIG <- "/Users/zaynesember/GitRepos/pressR/blog/figures"
set.seed(1)
wps_of <- function(txt) textstat_readability(corpus(txt), measure="meanSentenceLength")$meanSentenceLength
clean <- function(t){ t<-gsub("https?://\\S+"," ",t); t<-gsub("@\\w+"," ",t); t<-gsub("#\\w+"," ",t)
  t<-gsub("&amp;","and",t); trimws(gsub("\\s+"," ",t)) }

## ---- FACEBOOK (CrowdTangle) ----
fb <- readRDS("blog/data/CrowdTangle/facebook_posts_w_metadata.rds"); setDT(fb)
pv <- trimws(as.character(fb$party))                 # CEL 'dem' dummy: 1=Democrat, 0=Republican
fb[, pty := fcase(pv %in% c("1","D","Democrat"), "D",
                  pv %in% c("0","R","Republican"), "R", default=NA_character_)]
d1 <- grep("dwnom.*dim1|nominate.*1|dim1", names(fb), value=TRUE)[1]   # verify: D should be <0
if (!is.na(d1)) { cat("VERIFY party mapping vs", d1, "(Democrats should be negative):\n")
  chk <- fb[!is.na(pty) & is.finite(get(d1)), .(mean_dwnom1=round(mean(get(d1)),3), n=.N), by=pty]
  print(chk)
  mD <- chk[pty=="D", mean_dwnom1]; mR <- chk[pty=="R", mean_dwnom1]
  if (length(mD) && length(mR) && !(mD < mR))
    stop("FB party 0/1 dummy looks INVERTED: D mean DW-NOMINATE dim1 (", mD,
         ") should be < R (", mR, "). Check the CEL 'dem' coding before trusting partisan FB results.") }
fb <- fb[pty %in% c("D","R") & !is.na(Message) & nchar(Message)>120 & year %in% 2015:2024,
         .(party=pty, year, txt=Message)]
fb <- fb[, .SD[sample(.N, min(.N,1500))], by=.(party,year)]
fb[, wps := wps_of(clean(txt))]
fby <- fb[is.finite(wps)&wps<80, .(wps=mean(wps), n=.N), by=.(party,year)][, modality:="Facebook"]
rm(fb); invisible(gc()); cat("Facebook done:", sum(fby$n), "posts\n")

## ---- crosswalk + TWEETS ----
ct <- fromJSON("/Users/zaynesember/GitRepos/pressR/blog/analysis/congresstweets_handle_party_crosswalk.json", simplifyDataFrame=FALSE)
xw <- unique(rbindlist(lapply(ct, function(e){ if (is.null(e$type)||e$type!="member"||is.null(e$party)||!(e$party %in% c("D","R"))) return(NULL)
  rbindlist(lapply(e$accounts, function(a) list(sn=tolower(a$screen_name), party=e$party))) })))
allf <- list.files("blog/data/congresstweets_115_118_tweets/JSONs", full.names=TRUE)
sel  <- unlist(lapply(split(allf, as.integer(substr(basename(allf),1,4))), function(fs) sample(fs, min(length(fs),40))))
tw <- rbindlist(lapply(sel, function(f){ d <- tryCatch(as.data.table(fromJSON(f)),error=function(e) NULL)
  if (is.null(d)||!"text"%in%names(d)) return(NULL); d[, .(sn=tolower(screen_name), text, yr=as.integer(substr(time,1,4)))] }), fill=TRUE)
tw <- tw[!grepl("^RT @",text)&nchar(text)>15]; tw <- merge(tw,xw,by="sn"); tw[, ctext:=clean(text)]
tw <- tw[nchar(ctext)>15 & yr %in% 2017:2023][, .SD[sample(.N,min(.N,2500))], by=.(party,yr)]
tw[, wps := wps_of(ctext)]
twy <- tw[is.finite(wps)&wps<80, .(wps=mean(wps), n=.N), by=.(party, year=yr)][, modality:="Tweets"]

## ---- NEWSLETTERS ----
nl <- fread("blog/data/Newsletters_111th_to_118th_Nov2024.csv", select=c("Body","Party","Unix Timestamp"))
nl[, party := fifelse(Party=="Democrat","D",fifelse(Party=="Republican","R",NA_character_))]
nl[, year := as.integer(format(as.POSIXct(`Unix Timestamp`/1000, origin="1970-01-01"),"%Y"))]
nl <- nl[!is.na(party)&nchar(Body)>300&year %in% 2010:2024][, .SD[sample(.N,min(.N,1200))], by=.(party,year)]
nl[, wps := wps_of(Body)]
nly <- nl[is.finite(wps)&wps<80, .(wps=mean(wps), n=.N), by=.(party,year)][, modality:="Newsletters"]

## ---- PRESS RELEASES ----
con <- dbConnect(duckdb::duckdb(), nlp_duckdb_path(), read_only=TRUE)
rely <- as.data.table(dbGetQuery(con, "SELECT 'Press releases' modality, party, year, AVG(sent_len) wps, COUNT(*) n
  FROM readability WHERE source='scraped' AND party IN ('D','R') AND sent_len IS NOT NULL AND year BETWEEN 2010 AND 2025 GROUP BY 1,2,3"))
dbDisconnect(con, shutdown=TRUE)

Y <- rbindlist(list(rely, nly, fby, twy), use.names=TRUE, fill=TRUE)[n>=120]
g <- dcast(Y, modality+year ~ party, value.var="wps")[!is.na(D)&!is.na(R)]; g[, gap := D-R]
g[, modality := factor(modality, levels=c("Press releases","Newsletters","Facebook","Tweets"))]
cat("\n=== D-R words/sentence gap by modality x year (with Facebook) ===\n")
print(dcast(g, year ~ modality, value.var="gap")[order(year)])
cat("\n=== 2019-2023 mean gap by modality ===\n")
print(g[year %in% 2019:2023, .(mean_gap=round(mean(gap),2)), by=modality])

cols <- c("Press releases"="#2c3e50","Newsletters"="#e67e22","Facebook"="#8e44ad","Tweets"="#16a085")
p <- ggplot(g, aes(year, gap, color=modality)) +
  geom_hline(yintercept=0, color="grey60") +
  geom_line(linewidth=1.1) + geom_point(size=2.2) +
  geom_smooth(method="lm", se=FALSE, linewidth=0.5, linetype="dashed") +
  scale_color_manual(values=cols) + scale_x_continuous(breaks=seq(2010,2024,2)) +
  labs(title="The partisan sentence-length gap over time, across FOUR media",
       subtitle="D minus R words/sentence. The gap is positive (Democrats longer) in all four media and broadly rises toward ~2021.\nMagnitude tracks long-form-ness: largest in press releases & newsletters, modest in short-form social (tweets, Facebook).",
       x=NULL, y="D - R words per sentence", color=NULL) +
  theme_minimal(base_size=14) + theme(plot.title=element_text(face="bold"), legend.position="top",
    panel.grid.minor=element_blank())
ggsave(file.path(FIG,"time_gap_4modal.png"), p, width=11.5, height=6, dpi=160)
saveRDS(g, file.path(FIG,"time_gap_4modal_data.rds"))
cat("\nsaved time_gap_4modal.png + data\n")
