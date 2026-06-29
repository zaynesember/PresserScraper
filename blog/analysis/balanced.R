suppressMessages(devtools::load_all("/Users/zaynesember/GitRepos/pressR"))
source("/Users/zaynesember/GitRepos/pressR/nlp/R/00_foundation.R")
suppressMessages({ library(DBI); library(duckdb); library(data.table); library(ggplot2)
  library(quanteda); library(quanteda.textstats) })
FIG <- "/Users/zaynesember/GitRepos/pressR/blog/figures"

con <- dbConnect(duckdb::duckdb(), nlp_duckdb_path(), read_only = TRUE)
yrs <- as.data.table(dbGetQuery(con, "SELECT rel.name AS name, COUNT(DISTINCT r.year) ny, COUNT(*) n
  FROM readability r JOIN releases rel ON r.url = rel.url
  WHERE r.source='scraped' AND rel.name IS NOT NULL AND r.year BETWEEN 2010 AND 2025 GROUP BY 1"))
cat("members by # years present (of 16):\n"); print(table(yrs$ny))
K <- 11L
cohort <- yrs[ny >= K, name]
cat(sprintf("\nCOHORT = members publishing in >=%d of 16 years: %d members, %s releases\n\n",
            K, length(cohort), format(yrs[ny >= K, sum(n)], big.mark=",")))

# --- FK components: full release-level data (all scraped) -> pooled & within-member slopes ---
fk_all <- as.data.table(dbGetQuery(con, "SELECT rel.name AS name, r.year AS year,
    r.fk_grade AS fk_grade, r.sent_len AS sent_len, r.syll AS syll
  FROM readability r JOIN releases rel ON r.url = rel.url
  WHERE r.source='scraped' AND rel.name IS NOT NULL AND r.year BETWEEN 2010 AND 2025"))
fk <- fk_all[name %in% cohort]

# --- vocab/driver measures: sample among COHORT members (so members repeat across years -> FE identified) ---
inlist <- paste0("'", gsub("'", "''", cohort), "'", collapse = ",")
samp <- as.data.table(dbGetQuery(con, sprintf("
  SELECT name, year, body FROM (
    SELECT name, year, body, row_number() OVER (PARTITION BY year ORDER BY hash(url)) rn
    FROM releases WHERE source='scraped' AND usable AND body IS NOT NULL AND length(body)>200
      AND year BETWEEN 2010 AND 2025 AND name IN (%s)) WHERE rn <= 900", inlist)))
dbDisconnect(con, shutdown = TRUE)
cat("cohort vocab sample:", nrow(samp), "releases\n")
co <- corpus(samp$body)
samp[, dale := textstat_readability(co, measure="Dale.Chall")$Dale.Chall]
samp[, mattr := textstat_lexdiv(tokens(co, remove_punct=TRUE, remove_numbers=TRUE), measure="MATTR")$MATTR]
samp[, ntok := ntoken(tokens(co, remove_punct=TRUE, remove_symbols=TRUE))]

# pooled vs within-member (member-FE) yearly slope
fe <- function(dt, col) {
  d <- dt[is.finite(get(col)), .(name, year, v = as.numeric(get(col)))]
  pooled <- coef(lm(v ~ year, data = d))[2]
  d[, `:=`(vc = v - mean(v), yc = year - mean(year)), by = name]
  within <- coef(lm(vc ~ yc, data = d))[2]
  data.table(metric = col, pooled_per_yr = round(pooled, 4), within_member_per_yr = round(within, 4),
             retained_pct = round(100 * within / pooled))
}
res <- rbindlist(list(
  fe(fk, "fk_grade"), fe(fk, "sent_len"), fe(fk, "syll"),
  fe(samp, "dale"), fe(samp, "mattr"), fe(samp, "ntok")))
cat("\n=== POOLED vs WITHIN-MEMBER yearly slope (does the trend survive fixing the roster?) ===\n")
print(res)

# --- plot: full corpus vs cohort yearly means, headline metrics ---
fkfull <- melt(fk_all[, .(`Flesch-Kincaid grade`=mean(fk_grade), `syllables / word`=mean(syll)), by=year],
               id.vars="year")[, set:="full corpus"]
fkcoh  <- melt(fk[, .(`Flesch-Kincaid grade`=mean(fk_grade), `syllables / word`=mean(syll)), by=year],
               id.vars="year")[, set:="cohort (continuous)"]
fd <- readRDS(file.path(FIG,"trends_data.rds"))            # full-corpus vocab means (from trends step)
vfull <- melt(fd[, .(year, `Dale-Chall (difficulty)`=`Dale-Chall (difficulty)`, `doc length (tokens)`=`doc length (tokens)`)],
              id.vars="year")[, set:="full corpus"]
vcoh  <- melt(samp[, .(`Dale-Chall (difficulty)`=mean(dale), `doc length (tokens)`=mean(ntok)), by=year],
              id.vars="year")[, set:="cohort (continuous)"]
pl <- rbindlist(list(fkfull, fkcoh, vfull, vcoh))
pl[, variable := factor(variable, levels=c("Flesch-Kincaid grade","syllables / word","Dale-Chall (difficulty)","doc length (tokens)"))]
p <- ggplot(pl, aes(year, value, color=set)) +
  geom_line(linewidth=1.1) + geom_point(size=1.8) +
  facet_wrap(~variable, scales="free_y") +
  scale_color_manual(values=c("full corpus"="#95a5a6","cohort (continuous)"="#8e44ad")) +
  scale_x_continuous(breaks=seq(2010,2024,4)) +
  labs(title="Balanced-panel control: do the trends survive a fixed roster of continuously-publishing members?",
       subtitle=sprintf("Grey = full corpus; purple = the %d members publishing in >=%d of 16 years. If purple tracks grey, the trend is real (within-member), not compositional.", length(cohort), K),
       x=NULL, y=NULL, color=NULL) +
  theme_minimal(base_size=15) +
  theme(plot.title=element_text(face="bold", size=17), legend.position="top",
        strip.text=element_text(face="bold", size=13), panel.grid.minor=element_blank())
ggsave(file.path(FIG,"balanced.png"), p, width=15, height=9.5, dpi=160)
cat("\nsaved balanced.png\n")
