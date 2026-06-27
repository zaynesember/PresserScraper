# Option 3, figures + analyses. Reads the cached member x medium panel
# (xmodal_panel.rds, built by xmodal_member.R) so plotting iterates cheaply.
suppressMessages({ library(data.table); library(ggplot2); library(patchwork) })
FIG <- "/Users/zaynesember/GitRepos/pressR/blog/figures"
panel <- as.data.table(readRDS(file.path(FIG,"xmodal_panel.rds")))
ML <- c("Press releases","Newsletters","Tweets","Facebook")
panel[, medium := factor(medium, levels=ML)]

## (1) within-member medium effects (members in >=2 media)
sh <- panel[nmed >= 2]
sh[, wc := wps - mean(wps), by=bio]
fe      <- sh[, .(within=mean(wc), n=.N), by=medium]
raw_all <- panel[, .(raw_all=mean(wps)), by=medium]
raw_sh  <- sh[, .(raw_shared=mean(wps)), by=medium]
me <- Reduce(function(a,b) merge(a,b,by="medium"), list(raw_all, raw_sh, fe))[order(medium)]
cat("=== medium means: naive vs shared-roster vs within-member offset ===\n"); print(me)

## (2) partisan gap, composition control
gap <- function(D) dcast(D[, .(wps=mean(wps)), by=.(medium,party)], medium~party, value.var="wps")[, .(medium, gap=D-R)]
gg <- rbind(gap(panel)[, set:="All members"], gap(sh)[, set:="In >=2 media"])
gg[, medium := factor(medium, levels=ML)]
cat("\n=== D-R words/sentence gap: all vs shared roster ===\n"); print(dcast(gg, medium~set, value.var="gap"))

## (3) individual style stability
wide <- dcast(panel, bio+party ~ medium, value.var="wps")
prs <- list(c("Press releases","Newsletters"), c("Press releases","Facebook"),
            c("Press releases","Tweets"), c("Newsletters","Facebook"))
corr <- rbindlist(lapply(prs, function(p){ d<-wide[!is.na(get(p[1])) & !is.na(get(p[2]))]
  list(pair=paste(p[1],"vs",p[2]), r=cor(d[[p[1]]], d[[p[2]]]), n=nrow(d)) }))
cat("\n=== member-level wps correlation across media ===\n"); print(corr)

## ---- FIG 1: medium effect, two panels (levels + within-member offset) -----
pcol <- c("Press releases"="#2c3e50","Newsletters"="#e67e22","Tweets"="#16a085","Facebook"="#8e44ad")
pA <- ggplot(me, aes(medium, raw_all, fill=medium)) + geom_col(width=0.65, show.legend=FALSE) +
  scale_fill_manual(values=pcol) +
  labs(title="Levels: words per sentence by medium (all members)",
       x=NULL, y="words / sentence") +
  theme_minimal(base_size=13) + theme(plot.title=element_text(face="bold"), panel.grid.minor=element_blank())
pB <- ggplot(me, aes(medium, within, fill=within>0)) + geom_col(width=0.65, show.legend=FALSE) +
  geom_hline(yintercept=0, color="grey40") +
  scale_fill_manual(values=c(`TRUE`="#2c3e50",`FALSE`="#c0392b")) +
  labs(title="Within member: offset from each member's OWN cross-media average (>=2 media)",
       subtitle="The same member writes ~7 more words/sentence in press releases than in tweets\n-> a real medium effect, not member composition.",
       x=NULL, y="offset (words / sentence)") +
  theme_minimal(base_size=13) + theme(plot.title=element_text(face="bold"), panel.grid.minor=element_blank())
ggsave(file.path(FIG,"xmodal_medium_fe.png"), pA/pB + plot_layout(heights=c(1,1.15)),
       width=10, height=8.5, dpi=150)

## ---- FIG 2: partisan gap, composition control ----------------------------
p2 <- ggplot(gg, aes(medium, gap, fill=set)) + geom_col(position="dodge", width=0.7) +
  geom_hline(yintercept=0, color="grey50") +
  scale_fill_manual(values=c("All members"="#bdc3c7","In >=2 media"="#2c3e50")) +
  labs(title="The partisan sentence-length gap survives a shared-member roster",
       subtitle="D minus R words/sentence by medium, 2019-2023. Restricting to members present in >=2 media (dark)\nbarely moves the gap -> it isn't a composition artifact of different accounts in each medium.",
       x=NULL, y="D - R words per sentence", fill=NULL) +
  theme_minimal(base_size=13) + theme(plot.title=element_text(face="bold"), legend.position="top",
    panel.grid.minor=element_blank())
ggsave(file.path(FIG,"xmodal_gap_control.png"), p2, width=10, height=6, dpi=150)

## ---- FIG 3: individual style stability ------------------------------------
sc <- wide[!is.na(`Press releases`) & !is.na(Facebook)]
rPF <- cor(sc$`Press releases`, sc$Facebook)
p3 <- ggplot(sc, aes(`Press releases`, Facebook, color=party)) +
  geom_point(alpha=0.6, size=1.8) + geom_smooth(method="lm", se=FALSE, color="grey20", linewidth=0.6) +
  scale_color_manual(values=c(D="#2c5fa8",R="#c0392b")) +
  labs(title=sprintf("Sentence length is partly an individual style (r=%.2f, n=%d)", rPF, nrow(sc)),
       subtitle="Each point = a member's mean words/sentence in press releases vs on Facebook (2019-2023).",
       x="words/sentence in press releases", y="words/sentence on Facebook", color="Party") +
  theme_minimal(base_size=13) + theme(plot.title=element_text(face="bold"), panel.grid.minor=element_blank())
ggsave(file.path(FIG,"xmodal_style_corr.png"), p3, width=9, height=6.5, dpi=150)

saveRDS(list(medium_effects=me, gap=gg, corr=corr,
  members=panel[, .(members=uniqueN(bio)), by=medium]), file.path(FIG,"xmodal_data.rds"))
cat("\nsaved: xmodal_medium_fe.png, xmodal_gap_control.png, xmodal_style_corr.png, xmodal_data.rds\n")
