suppressMessages(devtools::load_all("/Users/zaynesember/GitRepos/pressR"))
source("/Users/zaynesember/GitRepos/pressR/nlp/R/00_foundation.R")
suppressMessages({ library(DBI); library(duckdb); library(data.table); library(ggplot2)
  library(quanteda); library(quanteda.textstats); library(jsonlite) })
FIG <- "/Users/zaynesember/GitRepos/pressR/blog/figures"
set.seed(1)
clean <- function(t){ t<-gsub("https?://\\S+"," ",t); t<-gsub("@\\w+"," ",t); t<-gsub("#\\w+"," ",t)
  t<-gsub("&amp;","and",t); trimws(gsub("\\s+"," ",t)) }
metrics_of <- function(txt) {
  co <- corpus(txt)
  rd <- textstat_readability(co, measure=c("Flesch.Kincaid","meanSentenceLength","meanWordSyllables","Dale.Chall"))
  tk <- tokens(co, remove_punct=TRUE, remove_numbers=TRUE); ntk <- ntoken(tk)
  mattr <- rep(NA_real_, length(txt)); ok <- ntk >= 12   # MATTR needs a window; skip very short docs
  if (any(ok)) mattr[ok] <- suppressWarnings(textstat_lexdiv(tk[ok], measure="MATTR")$MATTR)
  wl <- as.list(tokens(co, remove_punct=TRUE, remove_symbols=TRUE))
  caps <- vapply(wl, function(w){a<-grepl("^[A-Za-z]",w); if(!any(a)) NA_real_ else 100*mean(grepl("^[A-Z][a-z]+$", w[a]))}, numeric(1))
  allc <- vapply(wl, function(w){a<-grepl("[A-Za-z]",w); if(!any(a)) NA_real_ else 100*mean(grepl("^[A-Z]{2,}$", w[a]))}, numeric(1))
  dig  <- vapply(wl, function(w) 100*mean(grepl("[0-9]",w)), numeric(1))
  data.table(`Flesch-Kincaid grade`=rd$Flesch.Kincaid, `words / sentence`=rd$meanSentenceLength,
    `syllables / word`=rd$meanWordSyllables, `Dale-Chall (difficulty)`=rd$Dale.Chall,
    `MATTR (diversity)`=mattr, `doc length (tokens)`=ntoken(tokens(co, remove_punct=TRUE)),
    `% Capitalized`=caps, `% ALLCAPS`=allc, `% with digit`=dig)
}
agg <- function(dt) { mcols <- setdiff(names(dt), c("year"))
  dt[, lapply(.SD, function(v) mean(v, na.rm=TRUE)), by=year, .SDcols=mcols][, n:=dt[,.N,by=year]$N] }

## PRESS RELEASES
con <- dbConnect(duckdb::duckdb(), nlp_duckdb_path(), read_only=TRUE)
rb <- as.data.table(dbGetQuery(con, "SELECT year, body FROM (SELECT year, body,
  row_number() OVER (PARTITION BY year ORDER BY hash(url)) rn FROM releases
  WHERE source='scraped' AND usable AND body IS NOT NULL AND length(body)>200 AND year BETWEEN 2010 AND 2025) WHERE rn<=600"))
dbDisconnect(con, shutdown=TRUE)
rel <- agg(cbind(year=rb$year, metrics_of(rb$body)))[, modality:="Press releases"]; cat("releases done\n")

## NEWSLETTERS
nl <- fread("blog/data/Newsletters_111th_to_118th_Nov2024.csv", select=c("Body","Unix Timestamp"))
nl[, year := as.integer(format(as.POSIXct(`Unix Timestamp`/1000, origin="1970-01-01"),"%Y"))]
nl <- nl[nchar(Body)>300 & year %in% 2010:2024][, .SD[sample(.N,min(.N,600))], by=year]
news <- agg(cbind(year=nl$year, metrics_of(nl$Body)))[, modality:="Newsletters"]; cat("newsletters done\n")

## FACEBOOK (raw Message; pooled)
fb <- readRDS("blog/data/CrowdTangle/facebook_posts_w_metadata.rds"); setDT(fb)
fb <- fb[!is.na(Message) & nchar(Message)>120 & year %in% 2015:2024, .(year, txt=Message)][, .SD[sample(.N,min(.N,600))], by=year]
fbm <- agg(cbind(year=fb$year, metrics_of(fb$txt)))[, modality:="Facebook"]; rm(fb); invisible(gc()); cat("facebook done\n")

## TWEETS (cleaned prose; pooled)
allf <- list.files("blog/data/congresstweets_115_118_tweets/JSONs", full.names=TRUE)
sel  <- unlist(lapply(split(allf, as.integer(substr(basename(allf),1,4))), function(fs) sample(fs, min(length(fs),45))))
tw <- rbindlist(lapply(sel, function(f){ d<-tryCatch(as.data.table(fromJSON(f)),error=function(e) NULL)
  if (is.null(d)||!"text"%in%names(d)) return(NULL); d[!grepl("^RT @",text)&nchar(text)>15, .(yr=as.integer(substr(time,1,4)), ct=clean(text))] }), fill=TRUE)
tw <- tw[nchar(ct)>15 & yr %in% 2017:2023][, .SD[sample(.N,min(.N,1500))], by=yr]
twm <- agg(cbind(year=tw$yr, metrics_of(tw$ct)))[, modality:="Tweets"]; cat("tweets done\n")

## combine, standardize within mode x metric, plot
A <- rbindlist(list(rel, news, fbm, twm), use.names=TRUE, fill=TRUE)[n>=100]
mcols <- c("Flesch-Kincaid grade","words / sentence","syllables / word","Dale-Chall (difficulty)",
           "MATTR (diversity)","doc length (tokens)","% Capitalized","% ALLCAPS","% with digit")
L <- melt(A, id.vars=c("modality","year","n"), measure.vars=mcols, variable.name="metric")
L[, z := (value-mean(value, na.rm=TRUE))/sd(value, na.rm=TRUE), by=.(modality, metric)]
L[, metric := factor(metric, levels=mcols)]
cols <- c("Press releases"="#2c3e50","Newsletters"="#e67e22","Facebook"="#8e44ad","Tweets"="#16a085")
p <- ggplot(L, aes(year, z, color=modality)) +
  geom_hline(yintercept=0, color="grey85") +
  geom_line(linewidth=0.9) + geom_point(size=1.3) +
  facet_wrap(~metric, ncol=3, scales="free_y") +
  scale_color_manual(values=cols) + scale_x_continuous(breaks=seq(2010,2024,4)) +
  labs(title="Densification trends by communication mode (standardized within mode)",
       subtitle="Each line is one comms mode's yearly mean, z-scored within mode so trajectories are comparable despite very different levels.\nShared shape across modes = a general shift. Note doc length & syllables/word rise in most modes; numbers (% digit) fall.",
       x=NULL, y="standardized (SD from each mode's mean)", color=NULL) +
  theme_minimal(base_size=13) +
  theme(plot.title=element_text(face="bold", size=16), plot.subtitle=element_text(size=11, color="grey30"),
        legend.position="top", strip.text=element_text(face="bold", size=11), panel.grid.minor=element_blank())
ggsave(file.path(FIG,"trends_modal.png"), p, width=15, height=10, dpi=150)
saveRDS(A, file.path(FIG,"trends_modal_data.rds"))
cat("\n=== correlation of each metric with year, by mode (trend direction) ===\n")
print(dcast(L[, .(r=round(cor(year, value, use="complete.obs"),2)), by=.(metric, modality)],
            metric ~ modality, value.var="r"))
cat("\nsaved trends_modal.png\n")
