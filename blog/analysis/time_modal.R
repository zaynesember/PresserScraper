suppressMessages(devtools::load_all("/Users/zaynesember/GitRepos/pressR"))
source("/Users/zaynesember/GitRepos/pressR/nlp/R/00_foundation.R")
suppressMessages({ library(DBI); library(duckdb); library(data.table); library(ggplot2)
  library(quanteda); library(quanteda.textstats); library(jsonlite) })
SCRATCH <- "/private/tmp/claude-501/-Users-zaynesember-GitRepos-pressR/4f90cad5-86dd-450b-a0ac-0a8f83f6520d/scratchpad"
set.seed(1)
wps_of <- function(txt) textstat_readability(corpus(txt), measure="meanSentenceLength")$meanSentenceLength
clean <- function(t){ t<-gsub("https?://\\S+"," ",t); t<-gsub("@\\w+"," ",t); t<-gsub("#\\w+"," ",t)
  t<-gsub("&amp;","and",t); trimws(gsub("\\s+"," ",t)) }

## crosswalk
ct <- fromJSON("/tmp/ct_historical-users-filtered.json", simplifyDataFrame=FALSE)
xw <- unique(rbindlist(lapply(ct, function(e){ if (is.null(e$type)||e$type!="member"||is.null(e$party)||!(e$party %in% c("D","R"))) return(NULL)
  rbindlist(lapply(e$accounts, function(a) list(sn=tolower(a$screen_name), party=e$party))) })))

## TWEETS: ~40 days per year (stratified), cleaned, wps by party-year
allf <- list.files("blog/data/congresstweets_115_118_tweets/JSONs", full.names=TRUE)
fyr  <- as.integer(substr(basename(allf),1,4))
sel  <- unlist(lapply(split(allf, fyr), function(fs) sample(fs, min(length(fs),40))))
tw <- rbindlist(lapply(sel, function(f){ d <- tryCatch(as.data.table(fromJSON(f)),error=function(e) NULL)
  if (is.null(d)||!"text"%in%names(d)) return(NULL); d[, .(sn=tolower(screen_name), text, yr=as.integer(substr(time,1,4)))] }), fill=TRUE)
tw <- tw[!grepl("^RT @",text) & nchar(text)>15]; tw <- merge(tw, xw, by="sn")
tw[, ctext := clean(text)]; tw <- tw[nchar(ctext)>15 & yr %in% 2017:2023]
tw <- tw[, .SD[sample(.N, min(.N,2500))], by=.(party,yr)]
tw[, wps := wps_of(ctext)]
twy <- tw[is.finite(wps)&wps<80, .(wps=mean(wps), n=.N), by=.(party, year=yr)][, modality:="Tweets"]

## NEWSLETTERS: up to 1200 per party-year, wps
nl <- fread("blog/data/Newsletters_111th_to_118th_Nov2024.csv", select=c("Body","Party","Unix Timestamp"))
nl[, party := fifelse(Party=="Democrat","D",fifelse(Party=="Republican","R",NA_character_))]
nl[, year := as.integer(format(as.POSIXct(`Unix Timestamp`/1000, origin="1970-01-01"),"%Y"))]
nl <- nl[!is.na(party) & nchar(Body)>300 & year %in% 2010:2024]
nl <- nl[, .SD[sample(.N, min(.N,1200))], by=.(party,year)]
nl[, wps := wps_of(Body)]
nly <- nl[is.finite(wps)&wps<80, .(wps=mean(wps), n=.N), by=.(party, year)][, modality:="Newsletters"]

## PRESS RELEASES: sent_len by party-year (readability table, full)
con <- dbConnect(duckdb::duckdb(), nlp_duckdb_path(), read_only=TRUE)
rely <- as.data.table(dbGetQuery(con, "SELECT 'Press releases' modality, party, year, AVG(sent_len) wps, COUNT(*) n
  FROM readability WHERE source='scraped' AND party IN ('D','R') AND sent_len IS NOT NULL
    AND year BETWEEN 2010 AND 2025 GROUP BY 1,2,3"))
dbDisconnect(con, shutdown=TRUE)

Y <- rbindlist(list(rely, nly, twy), use.names=TRUE, fill=TRUE)[n >= 120]
g <- dcast(Y, modality+year ~ party, value.var="wps")[!is.na(D)&!is.na(R)]
g[, gap := D - R]
g[, modality := factor(modality, levels=c("Press releases","Newsletters","Tweets"))]
cat("=== D-R words/sentence gap by modality x year ===\n")
print(dcast(g, year ~ modality, value.var="gap")[order(year)])

cols <- c("Press releases"="#2c3e50","Newsletters"="#e67e22","Tweets"="#16a085")
pA <- ggplot(g, aes(year, gap, color=modality)) +
  geom_hline(yintercept=0, color="grey60") +
  geom_line(linewidth=1.1) + geom_point(size=2.2) +
  geom_smooth(method="lm", se=FALSE, linewidth=0.5, linetype="dashed") +
  scale_color_manual(values=cols) + scale_x_continuous(breaks=seq(2010,2024,2)) +
  labs(title="The partisan sentence-length gap over time, by medium",
       subtitle="D minus R words/sentence (cleaned tweets). The press-release gap widens post-2018;\ndoes the same trajectory appear in newsletters and tweets over their available spans?",
       x=NULL, y="D - R words per sentence", color=NULL) +
  theme_minimal(base_size=14) + theme(plot.title=element_text(face="bold"), legend.position="top",
    panel.grid.minor=element_blank())
ggsave(file.path(SCRATCH,"time_gap.png"), pA, width=11, height=6, dpi=160)

pB <- ggplot(Y[n>=120], aes(year, wps, color=party)) +
  geom_line(linewidth=1) + geom_point(size=1.8) +
  facet_wrap(~modality, scales="free_y") +
  scale_color_manual(values=c(D="#2c5fa8",R="#c0392b")) + scale_x_continuous(breaks=seq(2010,2024,4)) +
  labs(title="Words per sentence over time, by medium and party",
       subtitle="Levels differ by medium (tweets shortest); D sits above R within each medium across most years.",
       x=NULL, y="words per sentence", color="Party") +
  theme_minimal(base_size=14) + theme(plot.title=element_text(face="bold"), legend.position="top",
    strip.text=element_text(face="bold"), panel.grid.minor=element_blank())
ggsave(file.path(SCRATCH,"time_levels.png"), pB, width=13, height=5, dpi=160)
cat("\nsaved time_gap.png, time_levels.png\n")
