suppressMessages(devtools::load_all("/Users/zaynesember/GitRepos/pressR"))
source("/Users/zaynesember/GitRepos/pressR/nlp/R/00_foundation.R")
suppressMessages({ library(data.table); library(ggplot2); library(quanteda); library(quanteda.textstats) })
FIG <- "/Users/zaynesember/GitRepos/pressR/blog/figures"
set.seed(1)
clean <- function(t){ trimws(gsub("\\s+"," ", gsub("https?://\\S+"," ", t))) }

fb <- as.data.table(readRDS("blog/data/CrowdTangle/facebook_posts_w_metadata.rds"))
cat("=== candidate engagement / reach columns ===\n")
print(grep("interact|like|comment|share|love|wow|haha|sad|angry|care|follow|view|reaction|overperf",
           names(fb), ignore.case=TRUE, value=TRUE))

## pick interactions + followers adaptively
nm <- names(fb)
inter_col <- grep("^total[._ ]?interact", nm, ignore.case=TRUE, value=TRUE)[1]
folw_col  <- grep("follow", nm, ignore.case=TRUE, value=TRUE)[1]
react <- grep("^(likes|comments|shares|love|wow|haha|sad|angry|care)$", nm, ignore.case=TRUE, value=TRUE)
cat("\nusing interactions:", inter_col, "| followers:", folw_col, "| fallback reacts:", paste(react, collapse=","), "\n")
fb[, inter := if (!is.na(inter_col)) as.numeric(get(inter_col)) else rowSums(sapply(react, function(c) as.numeric(get(c))), na.rm=TRUE)]
fb[, folw  := as.numeric(get(folw_col))]

d <- fb[!is.na(Message) & nchar(Message)>120 & is.finite(inter) & is.finite(folw) & folw > 500 &
        year %in% 2015:2024, .(icpsr, year, Message, inter, folw)]
d <- d[sample(.N, min(.N, 120000))]
d[, eng := 1000 * inter / folw]                       # interactions per 1,000 followers
d[, wps := textstat_readability(corpus(clean(Message)), measure="meanSentenceLength")$meanSentenceLength]
d <- d[is.finite(wps) & wps>1 & wps<60 & is.finite(eng)]
cat("\nanalysis posts:", nrow(d), "| median eng/1k:", round(median(d$eng),1),
    "| median wps:", round(median(d$wps),1), "\n")

## ---- Q1: do fewer words/sentence get more engagement? ----
fe <- function(D) { D <- copy(D)[, `:=`(ly=log1p(eng))]
  pooled <- coef(lm(ly ~ wps, D))[2]
  D[, `:=`(lyc=ly-mean(ly), wc=wps-mean(wps)), by=icpsr]   # within-member
  within <- coef(lm(lyc ~ wc, D))[2]; c(pooled=unname(pooled), within=unname(within)) }
ov <- fe(d)
cat(sprintf("\n=== Q1: slope of log(1+eng) on words/sentence ===\npooled: %.4f  | within-member: %.4f  (negative => shorter sentences get more engagement)\n", ov[1], ov[2]))
d[, wbin := cut(wps, breaks=c(0,8,12,16,20,24,28,34,60))]
binned <- d[, .(med_eng=median(eng), n=.N), by=wbin][order(wbin)]
cat("\nmedian engagement/1k by words-per-sentence bin:\n"); print(binned)

## ---- Q2: time trend in the relationship + in engagement levels ----
slopes <- d[, { D<-copy(.SD)[, ly:=log1p(eng)][, `:=`(lyc=ly-mean(ly), wc=wps-mean(wps)), by=icpsr]
  .(within_slope=coef(lm(lyc~wc, D))[2], med_eng=median(eng), n=.N) }, by=year][order(year)]
cat("\n=== Q2: within-member wps->engagement slope & median engagement, by year ===\n"); print(slopes)

## plots
d[, era := ifelse(year<=2019, "2015-2019", "2020-2024")]
pe <- d[, .(med_eng=median(eng), n=.N), by=.(wbin, era)][n>=200]
p1 <- ggplot(pe, aes(wbin, med_eng, color=era, group=era)) + geom_line(linewidth=1) + geom_point(size=2) +
  scale_color_manual(values=c("2015-2019"="#95a5a6","2020-2024"="#8e44ad")) +
  labs(title="Facebook: do shorter-sentence posts get more engagement?",
       subtitle="Median interactions per 1,000 followers, by words/sentence bin. Split by era to show any time trend.",
       x="words per sentence (binned)", y="median interactions / 1k followers", color=NULL) +
  theme_minimal(base_size=14) + theme(plot.title=element_text(face="bold"), legend.position="top",
    axis.text.x=element_text(angle=35, hjust=1), panel.grid.minor=element_blank())
ggsave(file.path(FIG,"fb_engage_bins.png"), p1, width=10, height=6, dpi=150)
p2 <- ggplot(slopes, aes(year, within_slope)) + geom_hline(yintercept=0, color="grey60") +
  geom_line(linewidth=1, color="#2c3e50") + geom_point(size=2.4, color="#2c3e50") +
  scale_x_continuous(breaks=2015:2024) +
  labs(title="Does brevity pay off more over time? (Facebook, within-member)",
       subtitle="Within-member slope of log engagement on words/sentence, by year. Below 0 = shorter sentences -> more engagement.",
       x=NULL, y="within-member slope (log engagement per word/sentence)") +
  theme_minimal(base_size=14) + theme(plot.title=element_text(face="bold"), panel.grid.minor=element_blank())
ggsave(file.path(FIG,"fb_engage_slope.png"), p2, width=10, height=5.5, dpi=150)
saveRDS(list(binned=binned, slopes=slopes, overall=ov), file.path(FIG,"fb_engage_data.rds"))
cat("\nsaved fb_engage_bins.png, fb_engage_slope.png\n")
