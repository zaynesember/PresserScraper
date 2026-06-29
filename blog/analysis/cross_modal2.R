suppressMessages(devtools::load_all("/Users/zaynesember/GitRepos/pressR"))
source("/Users/zaynesember/GitRepos/pressR/nlp/R/00_foundation.R")
suppressMessages({ library(DBI); library(duckdb); library(data.table); library(ggplot2)
  library(quanteda); library(quanteda.textstats); library(jsonlite) })
FIG <- "/Users/zaynesember/GitRepos/pressR/blog/figures"
set.seed(1)
RD <- function(txt) { co <- corpus(txt); r <- textstat_readability(co,
    measure=c("meanSentenceLength","meanWordSyllables","Flesch.Kincaid"))
  data.table(wps=r$meanSentenceLength, syll=r$meanWordSyllables, fk=r$Flesch.Kincaid) }

## crosswalk
ct <- fromJSON("/Users/zaynesember/GitRepos/pressR/blog/analysis/congresstweets_handle_party_crosswalk.json", simplifyDataFrame=FALSE)
xw <- unique(rbindlist(lapply(ct, function(e){ if (is.null(e$type)||e$type!="member"||is.null(e$party)||!(e$party %in% c("D","R"))) return(NULL)
  rbindlist(lapply(e$accounts, function(a) list(sn=tolower(a$screen_name), party=e$party))) })))

## TWEETS: parse, features from RAW text, then clean for prose readability
files <- sample(list.files("blog/data/congresstweets_115_118_tweets/JSONs", full.names=TRUE), 180)
tw <- rbindlist(lapply(files, function(f){ d <- tryCatch(as.data.table(fromJSON(f)), error=function(e) NULL)
  if (is.null(d)||!"text" %in% names(d)) return(NULL); d[, .(sn=tolower(screen_name), text, time)] }), fill=TRUE)
tw <- tw[!grepl("^RT @", text) & nchar(text) > 15]
tw <- merge(tw, xw, by="sn"); tw[, yr := as.integer(substr(time,1,4))]; tw <- tw[yr %in% 2019:2023]
tw <- tw[sample(.N, min(.N, 45000))]
tw[, `:=`(has_url = grepl("https?://", text),
          n_ment  = lengths(regmatches(text, gregexpr("@\\w+", text))),
          n_hash  = lengths(regmatches(text, gregexpr("#\\w+", text))))]
clean <- function(t){ t<-gsub("https?://\\S+"," ",t); t<-gsub("@\\w+"," ",t); t<-gsub("#\\w+"," ",t)
  t<-gsub("&amp;","and",t); trimws(gsub("\\s+"," ",t)) }
tw[, ctext := clean(text)]
twc <- tw[nchar(ctext) > 15]
cat("tweets:", nrow(tw), "| with prose after cleaning:", nrow(twc), "\n")

## readability per modality (cleaned tweets are the main; raw tweets for the cleaning check)
rd_tc <- cbind(twc[, .(modality="Tweets (cleaned)", party)], RD(twc$ctext))
rd_tr <- cbind(tw[,  .(modality="Tweets (raw)",     party)], RD(tw$text))
nl <- fread("blog/data/Newsletters_111th_to_118th_Nov2024.csv", select=c("Body","Party","Unix Timestamp"))
nl[, party := fifelse(Party=="Democrat","D",fifelse(Party=="Republican","R",NA_character_))]
nl[, yr := as.integer(format(as.POSIXct(`Unix Timestamp`/1000, origin="1970-01-01"),"%Y"))]
nl <- nl[!is.na(party) & nchar(Body)>300 & yr %in% 2019:2023][, .SD[sample(.N,min(.N,7000))], by=party]
rd_nl <- cbind(nl[, .(modality="Newsletters", party)], RD(nl$Body))
con <- dbConnect(duckdb::duckdb(), nlp_duckdb_path(), read_only=TRUE)
rel <- as.data.table(dbGetQuery(con, "SELECT party, sent_len AS wps, syll, fk_grade AS fk FROM readability
  WHERE source='scraped' AND party IN ('D','R') AND sent_len IS NOT NULL AND year BETWEEN 2019 AND 2023 ORDER BY hash(url) LIMIT 14000"))
dbDisconnect(con, shutdown=TRUE); rel[, modality:="Press releases"]
ALL <- rbindlist(list(rel[,.(modality,party,wps,syll,fk)], rd_nl, rd_tr, rd_tc))[is.finite(wps)&is.finite(fk)&wps<80]

## ---- FK-gap DECOMPOSITION by modality:  FK = 0.39*wps + 11.8*syll - 15.59 ----
m <- ALL[, .(wps=mean(wps), syll=mean(syll), fk=mean(fk)), by=.(modality,party)]
w <- dcast(m, modality ~ party, value.var=c("wps","syll","fk"))
w[, `:=`(c_sentence=0.39*(wps_D-wps_R), c_word=11.8*(syll_D-syll_R), fk_gap=fk_D-fk_R)]
w[, modality := factor(modality, levels=c("Tweets (raw)","Tweets (cleaned)","Newsletters","Press releases"))]
cat("\n=== D-R FK gap decomposition by modality (grade levels) ===\n")
print(w[order(modality), .(modality, fk_gap=round(fk_gap,2), from_sentence_len=round(c_sentence,2),
                           from_word_syllables=round(c_word,2), wps_gap=round(wps_D-wps_R,2))])
dec <- melt(w[, .(modality, `Longer sentences`=c_sentence, `Harder / longer words`=c_word)],
            id.vars="modality", variable.name="component", value.name="grades")
p1 <- ggplot(dec, aes(modality, grades, fill=component)) +
  geom_col(width=0.7) + geom_hline(yintercept=0, color="grey50") +
  geom_point(data=w, aes(modality, fk_gap), inherit.aes=FALSE, size=2.6, color="grey15") +
  scale_fill_manual(values=c("Longer sentences"="#7fb3d5","Harder / longer words"="#16a085")) +
  labs(title="Why 'sophistication' flips by medium: the D-R Flesch-Kincaid gap, decomposed",
       subtitle="Black dot = total D-R FK gap. In long-form, longer sentences (blue) dominate -> D reads 'harder'.\nIn raw tweets, hashtag/URL tokens inflate R's word score (green) and flip it; cleaning the prose removes most of that.",
       x=NULL, y="D - R gap (Flesch-Kincaid grade levels)", fill="Gap comes from") +
  theme_minimal(base_size=14) + theme(plot.title=element_text(face="bold"), legend.position="top",
    panel.grid.minor=element_blank(), axis.text.x=element_text(face="bold"))
ggsave(file.path(FIG,"cm_decomp.png"), p1, width=11, height=6.5, dpi=160)

## ---- hashtags / links / mentions as partisan FEATURES ----
feat <- tw[, .(`% with a link`=100*mean(has_url), `mentions per tweet`=mean(n_ment),
               `hashtags per tweet`=mean(n_hash), `% with a hashtag`=100*mean(n_hash>0)), by=party]
cat("\n=== tweet meta-features by party ===\n"); print(feat)
fl <- melt(feat, id.vars="party", variable.name="feature")
p2 <- ggplot(fl, aes(party, value, fill=party)) + geom_col(width=0.65) +
  facet_wrap(~feature, scales="free_y", nrow=1) +
  scale_fill_manual(values=c(D="#2c5fa8",R="#c0392b"), guide="none") +
  labs(title="Hashtags, links, and mentions are partisan data in themselves (tweets, 2019-2023)",
       x=NULL, y=NULL) + theme_minimal(base_size=14) +
  theme(plot.title=element_text(face="bold"), strip.text=element_text(face="bold", size=11),
        panel.grid.minor=element_blank())
ggsave(file.path(FIG,"cm_features.png"), p2, width=12, height=4.6, dpi=160)

## most partisan hashtags
ht <- tw[, .(h=tolower(unlist(regmatches(text, gregexpr("#\\w+", text))))), by=party]
htc <- dcast(ht[, .N, by=.(party,h)], h ~ party, value.var="N", fill=0)
htc <- htc[(D+R) >= 40][, rshare := R/(D+R)]
top <- rbind(htc[order(-rshare)][1:12], htc[order(rshare)][1:12])
top[, skew := ifelse(rshare>=0.5,"R","D")]
top[, h := factor(h, levels=top[order(rshare), h])]
p3 <- ggplot(top, aes(rshare-0.5, h, fill=skew)) + geom_col() +
  geom_vline(xintercept=0, color="grey50") +
  scale_fill_manual(values=c(D="#2c5fa8",R="#c0392b"), guide="none") +
  scale_x_continuous(labels=function(x) paste0(round(100*(x+0.5)),"% R")) +
  labs(title="Most partisan hashtags (share of uses that are Republican; min 40 uses)",
       x="<- more Democratic        |        more Republican ->", y=NULL) +
  theme_minimal(base_size=13) + theme(plot.title=element_text(face="bold"), panel.grid.minor=element_blank())
ggsave(file.path(FIG,"cm_hashtags.png"), p3, width=11, height=7, dpi=150)
cat("\nsaved cm_decomp.png, cm_features.png, cm_hashtags.png\n")
