# Option 2 — Facebook video/views analysis (integrated story).
# Tests the open speculation from findings 5-6: is FB's doc-length collapse a
# FORMAT SHIFT to video + short captions, not members shortening sentences?
# And: do video posts pay off in views/reach? Does brevity buy views?
#
# Data: blog/data/CrowdTangle/facebook_posts_w_metadata.rds (1.29M posts, 2014-24).
# Member key = icpsr (self-contained; no crosswalk needed for within-member).
# NOTE: figures -> blog/figures (a REAL path; not the old ephemeral SCRATCH).
suppressMessages({ library(data.table); library(ggplot2); library(quanteda)
  library(quanteda.textstats); library(stringi); library(patchwork) })
set.seed(1)
FIG <- "/Users/zaynesember/GitRepos/pressR/blog/figures"
clean <- function(t){ t <- ifelse(is.na(t), "", t)
  t <- stri_replace_all_regex(t, "https?://\\S+|www\\.\\S+", " ")
  stri_trim_both(stri_replace_all_regex(t, "\\s+", " ")) }
nwords <- function(t) stri_count_regex(clean(t), "\\S+")

fb <- as.data.table(readRDS("/Users/zaynesember/GitRepos/pressR/blog/data/CrowdTangle/facebook_posts_w_metadata.rds"))
fb[, yr := suppressWarnings(as.integer(year))]
fb <- fb[yr %in% 2014:2024]
fb[, tlow := tolower(Type)]
fb[, grp := fcase(
  tlow %in% c("native video","video","vine","live video","live video complete","live video scheduled"), "Video",
  tlow == "youtube", "YouTube",
  tlow == "photo",  "Photo",
  tlow == "link",   "Link",
  tlow == "status", "Status",
  default = "Other")]
fb[, is_native_video := tlow %in% c("native video","video","vine","live video","live video complete","live video scheduled")]
fb[, cap_words := nwords(Message)]          # caption length (URLs stripped); 0 if no caption
fb[, tviews := suppressWarnings(as.numeric(Total.Views))]
fb[, folw := suppressWarnings(as.numeric(Followers.at.Posting))]
react <- c("Likes","Comments","Shares","Love","Wow","Haha","Sad","Angry","Care")
fb[, inter := rowSums(sapply(react, function(c) suppressWarnings(as.numeric(get(c)))), na.rm=TRUE)]

cat("=== rows by year x group (post-type mix) ===\n")
print(dcast(fb[, .N, by=.(yr, grp)], yr ~ grp, value.var="N", fill=0))

## ----------------------------------------------------------------------------
## 1. Video share over time
## ----------------------------------------------------------------------------
share <- fb[, .N, by=.(yr, grp)][, share := N/sum(N), by=yr]
share[, grp := factor(grp, levels=c("Status","Link","YouTube","Photo","Video","Other"))]
cat("\n=== video share of posts by year ===\n")
print(fb[, .(video_share=round(mean(grp=="Video"),3), n=.N), by=yr][order(yr)])

## ----------------------------------------------------------------------------
## 2. Caption-length decline: format-shift (between) vs within-type shortening
## ----------------------------------------------------------------------------
capyr <- fb[, .(cap=mean(cap_words), n=.N), by=yr][order(yr)]
cat("\n=== mean caption words/post by year (overall) ===\n"); print(capyr)
cat("corr(caption words, year):", round(cor(capyr$yr, capyr$cap), 3), "\n")

# type means and shares by year, plus a fixed-mix counterfactual (shares frozen
# at 2015-2017) to isolate within-type change from the composition shift.
EARLY <- 2015:2017; LATE <- 2021:2023
base_share <- fb[yr %in% EARLY, .N, by=grp][, s := N/sum(N)][, .(grp, s)]
tm <- fb[, .(m=mean(cap_words), n=.N), by=.(yr, grp)]
tm <- merge(tm, fb[, .(stot=.N), by=yr], by="yr")[, syr := n/stot]
# actual mean = sum_g syr*m ; fixed-mix = sum_g base_share*m
cf <- merge(tm, base_share, by="grp", all.x=TRUE)[is.na(s), s := 0]
cfyr <- cf[, .(actual=sum(syr*m), fixed_mix=sum(s*m)/sum(s)), by=yr][order(yr)]
cat("\n=== actual vs fixed-mix (2015-17 composition) caption words by year ===\n"); print(cfyr)

# Oaxaca-style decomposition of the EARLY->LATE change in mean caption words.
ox <- merge(
  fb[yr %in% EARLY, .(sE=.N), by=grp][, sE := sE/sum(sE)],
  fb[yr %in% LATE,  .(sL=.N), by=grp][, sL := sL/sum(sL)], by="grp", all=TRUE)
ox <- merge(ox, fb[yr %in% EARLY, .(mE=mean(cap_words)), by=grp], by="grp", all.x=TRUE)
ox <- merge(ox, fb[yr %in% LATE,  .(mL=mean(cap_words)), by=grp], by="grp", all.x=TRUE)
ox[is.na(ox)] <- 0
between <- sum((ox$sL-ox$sE)*ox$mE)          # composition shift (more video)
within  <- sum(ox$sE*(ox$mL-ox$mE))          # within-type shortening
inter   <- sum((ox$sL-ox$sE)*(ox$mL-ox$mE))  # interaction
total   <- sum(ox$sL*ox$mL) - sum(ox$sE*ox$mE)
cat(sprintf("\n=== caption-words change %d-%d -> %d-%d ===\n", min(EARLY),max(EARLY),min(LATE),max(LATE)))
cat(sprintf("total Delta = %.2f words | between(composition)= %.2f (%.0f%%) | within= %.2f (%.0f%%) | interaction= %.2f\n",
    total, between, 100*between/total, within, 100*within/total, inter))
print(ox[order(-sL)])

## ----------------------------------------------------------------------------
## 3. Views as reach/payoff (native FB video only -> Total.Views meaningful)
## ----------------------------------------------------------------------------
vid <- fb[is_native_video==TRUE & is.finite(tviews) & tviews>0]
cat("\n=== native-video posts with views:", nrow(vid), "===\n")
viewyr <- vid[, .(med_views=median(tviews), n=.N), by=yr][order(yr)]
cat("\n=== median Total.Views by year (native video) ===\n"); print(viewyr)
# engagement-per-1k-followers trajectory for context (reach decline check)
engyr <- fb[is.finite(inter)&is.finite(folw)&folw>500, .(eng=median(1000*inter/folw), n=.N), by=yr][order(yr)]
cat("\n=== median interactions/1k followers by year (all posts) ===\n"); print(engyr)

# Brevity -> views: among native video with a real caption, slope of log views
# on words/sentence (pooled vs within-member icpsr), mirroring finding 6.
vw <- vid[cap_words>=4 & !is.na(icpsr)]
vw <- vw[sample(.N, min(.N, 120000))]
vw[, wps := textstat_readability(corpus(clean(Message)), measure="meanSentenceLength")$meanSentenceLength]
vw <- vw[is.finite(wps) & wps>1 & wps<60]
vw[, lv := log1p(tviews)]
pooled <- coef(lm(lv ~ wps, vw))[2]
vw[, `:=`(lvc=lv-mean(lv), wc=wps-mean(wps)), by=icpsr]
within_s <- coef(lm(lvc ~ wc, vw))[2]
cat(sprintf("\n=== brevity -> views (native video, n=%d) ===\nlog(1+views) on words/sentence: pooled=%.4f | within-member=%.4f (neg => shorter caption -> more views)\n",
    nrow(vw), pooled, within_s))
vw[, wbin := cut(wps, breaks=c(0,8,12,16,20,24,28,34,60))]
vbin <- vw[, .(med_views=median(tviews), n=.N), by=wbin][order(wbin)]
cat("\nmedian views by words/sentence bin:\n"); print(vbin)

## ----------------------------------------------------------------------------
## Figures
## ----------------------------------------------------------------------------
cols_grp <- c(Video="#8e44ad", Photo="#27ae60", Link="#2980b9", Status="#7f8c8d",
              YouTube="#c0392b", Other="#bdc3c7")
p1 <- ggplot(share, aes(yr, share, fill=grp)) + geom_area(alpha=0.92) +
  scale_fill_manual(values=cols_grp) + scale_x_continuous(breaks=2014:2024) +
  scale_y_continuous(labels=scales::percent) +
  labs(title="Facebook's format mix shifted - but video never took over",
       subtitle="Share of members' Facebook posts by type, 2014-2024.\nVideo rose only to ~14% as photos grew and links faded after 2020.",
       x=NULL, y="share of posts", fill=NULL) +
  theme_minimal(base_size=14) + theme(plot.title=element_text(face="bold"),
    legend.position="top", panel.grid.minor=element_blank())
ggsave(file.path(FIG,"fb_video_share.png"), p1, width=10, height=6, dpi=150)

cf_long <- melt(cfyr, id.vars="yr", variable.name="series", value.name="cap")
cf_long[, series := factor(series, c("actual","fixed_mix"),
        labels=c("Actual","If 2015-17 post mix had held"))]
pA <- ggplot(cf_long, aes(yr, cap, color=series, linetype=series)) +
  geom_line(linewidth=1.1) + geom_point(size=2) +
  scale_color_manual(values=c("Actual"="#8e44ad","If 2015-17 post mix had held"="#95a5a6")) +
  scale_linetype_manual(values=c("Actual"=1,"If 2015-17 post mix had held"=2)) +
  scale_x_continuous(breaks=seq(2014,2024,2)) +
  labs(title="Facebook captions shrank within each format - not by switching to video",
       subtitle="Mean caption words/post. Freezing the 2015-17 post mix (dashed)\nbarely moves the path -> composition isn't the cause.",
       x=NULL, y="caption words per post", color=NULL, linetype=NULL) +
  theme_minimal(base_size=13) + theme(plot.title=element_text(face="bold"),
    legend.position="top", panel.grid.minor=element_blank())
decdt <- data.table(component=factor(c("Format shift\n(to video)","Within-type\nshortening","Interaction"),
                      levels=c("Format shift\n(to video)","Within-type\nshortening","Interaction")),
                    grades=c(between, within, inter))
pB <- ggplot(decdt, aes(component, grades, fill=grades<0)) + geom_col(width=0.65) +
  geom_hline(yintercept=0, color="grey40") +
  scale_fill_manual(values=c("FALSE"="#bdc3c7","TRUE"="#8e44ad"), guide="none") +
  labs(title=sprintf("Decomposing the %.1f-word caption drop (2015-17 -> 2021-23)", total),
       x=NULL, y="contribution (words)") +
  theme_minimal(base_size=13) + theme(plot.title=element_text(face="bold"),
    panel.grid.minor=element_blank())
ggsave(file.path(FIG,"fb_caption_decomp.png"), pA/pB + plot_layout(heights=c(1.3,1)),
       width=10, height=9, dpi=150)

pV1 <- ggplot(viewyr, aes(yr, med_views)) + geom_line(linewidth=1, color="#8e44ad") +
  geom_point(size=2.2, color="#8e44ad") + scale_x_continuous(breaks=2014:2024) +
  labs(title="Video reach: median Facebook video views by year", x=NULL, y="median Total.Views") +
  theme_minimal(base_size=13) + theme(plot.title=element_text(face="bold"), panel.grid.minor=element_blank())
pV2 <- ggplot(vbin[n>=200], aes(wbin, med_views, group=1)) +
  geom_line(linewidth=1, color="#2c3e50") + geom_point(size=2.2, color="#2c3e50") +
  labs(title="Do shorter video captions get more views?",
       subtitle=sprintf("Median views by caption words/sentence. within-member slope=%.3f", within_s),
       x="caption words per sentence (binned)", y="median Total.Views") +
  theme_minimal(base_size=13) + theme(plot.title=element_text(face="bold"),
    axis.text.x=element_text(angle=35,hjust=1), panel.grid.minor=element_blank())
ggsave(file.path(FIG,"fb_views.png"), pV1/pV2, width=10, height=9, dpi=150)

saveRDS(list(share=share, capyr=capyr, cfyr=cfyr, oaxaca=ox,
  decomp=c(total=total, between=between, within=within, inter=inter),
  viewyr=viewyr, engyr=engyr, vbin=vbin, slopes=c(pooled=unname(pooled), within=unname(within_s))),
  file.path(FIG, "fb_views_data.rds"))
cat("\nsaved: fb_video_share.png, fb_caption_decomp.png, fb_views.png, fb_views_data.rds\n")
