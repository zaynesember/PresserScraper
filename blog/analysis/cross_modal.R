suppressMessages(devtools::load_all("/Users/zaynesember/GitRepos/pressR"))
source("/Users/zaynesember/GitRepos/pressR/nlp/R/00_foundation.R")
suppressMessages({ library(DBI); library(duckdb); library(data.table); library(ggplot2)
  library(quanteda); library(quanteda.textstats); library(jsonlite) })
SCRATCH <- "/private/tmp/claude-501/-Users-zaynesember-GitRepos-pressR/4f90cad5-86dd-450b-a0ac-0a8f83f6520d/scratchpad"
set.seed(1)
WPS <- function(txt) {                          # words/sentence + FK per doc via quanteda
  co <- corpus(txt); r <- textstat_readability(co, measure=c("meanSentenceLength","Flesch.Kincaid"))
  list(wps=r$meanSentenceLength, fk=r$Flesch.Kincaid)
}

## ---- handle -> party crosswalk (members only) ----
ct <- fromJSON("/tmp/ct_historical-users-filtered.json", simplifyDataFrame=FALSE)
xw <- rbindlist(lapply(ct, function(e){
  if (is.null(e$type) || e$type!="member" || is.null(e$party) || !(e$party %in% c("D","R"))) return(NULL)
  rbindlist(lapply(e$accounts, function(a) list(sn=tolower(a$screen_name), party=e$party)))
}))
xw <- unique(xw); cat("crosswalk: ", nrow(xw), "member handles\n")

## ---- TWEETS: sample ~180 days, drop RTs, join party ----
files <- list.files("blog/data/congresstweets_115_118_tweets/JSONs", full.names=TRUE)
files <- sample(files, 180)
tw <- rbindlist(lapply(files, function(f){
  d <- tryCatch(as.data.table(fromJSON(f)), error=function(e) NULL)
  if (is.null(d) || !"text" %in% names(d)) return(NULL)
  d[, .(sn=tolower(screen_name), text, time)]
}), fill=TRUE)
tw <- tw[!grepl("^RT @", text) & nchar(text) > 15]
tw <- merge(tw, xw, by="sn")
tw[, yr := as.integer(substr(time, 1, 4))]
tw <- tw[yr %in% 2019:2023]
tw <- tw[sample(.N, min(.N, 45000))]
cat("tweets (own, party-matched):", nrow(tw), "\n")
tr <- WPS(tw$text); tweets <- data.table(modality="Tweets", party=tw$party, wps=tr$wps, fk=tr$fk)

## ---- NEWSLETTERS: balanced sample per party ----
nl <- fread("blog/data/Newsletters_111th_to_118th_Nov2024.csv",
            select=c("Body","Party","Unix Timestamp"))
nl[, party := fifelse(Party=="Democrat","D", fifelse(Party=="Republican","R", NA_character_))]
nl[, yr := as.integer(format(as.POSIXct(`Unix Timestamp`/1000, origin="1970-01-01"), "%Y"))]
nl <- nl[!is.na(party) & nchar(Body) > 300 & yr %in% 2019:2023]
nl <- nl[, .SD[sample(.N, min(.N, 7000))], by=party]      # ~7k per party
cat("newsletters sampled:", nrow(nl), "\n")
nr <- WPS(nl$Body); news <- data.table(modality="Newsletters", party=nl$party, wps=nr$wps, fk=nr$fk)

## ---- PRESS RELEASES: per-release sent_len + fk from readability table ----
con <- dbConnect(duckdb::duckdb(), nlp_duckdb_path(), read_only=TRUE)
rel <- as.data.table(dbGetQuery(con, "SELECT party, sent_len AS wps, fk_grade AS fk
  FROM readability WHERE source='scraped' AND party IN ('D','R') AND sent_len IS NOT NULL
    AND year BETWEEN 2019 AND 2023 USING SAMPLE 14000"))
dbDisconnect(con, shutdown=TRUE)
rel[, modality := "Press releases"]

D <- rbindlist(list(rel[, .(modality, party, wps, fk)], news, tweets))
D <- D[is.finite(wps) & is.finite(fk) & wps < 80]         # drop extreme parse failures
D[, modality := factor(modality, levels=c("Tweets","Newsletters","Press releases"))]

## ---- D-R gaps per modality ----
gap <- D[, .(words_per_sentence=mean(wps), fk_grade=mean(fk), n=.N), by=.(modality, party)]
g2 <- dcast(gap, modality ~ party, value.var=c("words_per_sentence","fk_grade","n"))
g2[, `:=`(wps_gap_DminusR = round(words_per_sentence_D - words_per_sentence_R, 2),
          fk_gap_DminusR  = round(fk_grade_D - fk_grade_R, 2))]
cat("\n=== sentence-length & FK gap (D - R) by modality ===\n")
print(g2[, .(modality, D_wps=round(words_per_sentence_D,1), R_wps=round(words_per_sentence_R,1),
             wps_gap_DminusR, fk_gap_DminusR, nD=n_D, nR=n_R)])

p <- ggplot(D, aes(party, wps, fill=party)) +
  geom_violin(scale="width", alpha=0.6, color=NA) +
  geom_boxplot(width=0.18, outlier.shape=NA, alpha=0.9) +
  facet_wrap(~modality, scales="free_y") +
  scale_fill_manual(values=c(D="#2c5fa8", R="#c0392b"), guide="none") +
  coord_cartesian(ylim=c(0, NA)) +
  labs(title="Cross-modality partisan sentence-length gap (time-matched, 2019-2023)",
       subtitle="Words per sentence, by party, same window across modalities. Where does the D>R gap that drives\nthe press-release readability story reappear -- and where does it vanish?",
       x=NULL, y="words per sentence") +
  theme_minimal(base_size=15) +
  theme(plot.title=element_text(face="bold", size=17), strip.text=element_text(face="bold", size=14),
        panel.grid.minor=element_blank())
ggsave(file.path(SCRATCH,"cross_modal.png"), p, width=14, height=6.5, dpi=160)
cat("\nsaved cross_modal.png\n")
