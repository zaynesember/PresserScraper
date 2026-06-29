suppressMessages(devtools::load_all("/Users/zaynesember/GitRepos/pressR"))
source("/Users/zaynesember/GitRepos/pressR/nlp/R/00_foundation.R")
suppressMessages({ library(DBI); library(duckdb); library(data.table); library(ggplot2)
  library(quanteda); library(quanteda.textstats) })
FIG <- "/Users/zaynesember/GitRepos/pressR/blog/figures"

con <- dbConnect(duckdb::duckdb(), nlp_duckdb_path(), read_only = TRUE)
# full-corpus FK components by year (scraped)
full <- as.data.table(dbGetQuery(con, "
  SELECT year, AVG(fk_grade) fk_grade, AVG(sent_len) words_per_sentence, AVG(syll) syllables_per_word, COUNT(*) n
  FROM readability WHERE source='scraped' AND year BETWEEN 2010 AND 2025 GROUP BY 1 ORDER BY 1"))
# pooled sample for vocab + driver features
samp <- as.data.table(dbGetQuery(con, "
  SELECT url, year, body FROM (
    SELECT url, year, body, row_number() OVER (PARTITION BY year ORDER BY hash(url)) rn
    FROM releases WHERE source='scraped' AND usable AND body IS NOT NULL AND length(body)>200
      AND year BETWEEN 2010 AND 2025) WHERE rn <= 800"))
dbDisconnect(con, shutdown = TRUE)
cat("sampled", nrow(samp), "releases\n")

co <- corpus(samp$body)
dale <- textstat_readability(co, measure = "Dale.Chall")$Dale.Chall
mattr <- textstat_lexdiv(tokens(co, remove_punct=TRUE, remove_numbers=TRUE), measure="MATTR")$MATTR
tk_raw <- tokens(co, remove_punct=TRUE, remove_symbols=TRUE)               # keep case + numbers
ntok <- ntoken(tk_raw)
chars <- as.list(tk_raw)
caps_pct  <- vapply(chars, function(w){ a <- grepl("^[A-Za-z]", w); if(!any(a)) return(NA_real_); 100*mean(grepl("^[A-Z][a-z]+$", w[a])) }, numeric(1))
allcaps_pct <- vapply(chars, function(w){ a <- grepl("[A-Za-z]", w); if(!any(a)) return(NA_real_); 100*mean(grepl("^[A-Z]{2,}$", w[a])) }, numeric(1))
digit_pct <- vapply(chars, function(w) 100*mean(grepl("[0-9]", w)), numeric(1))
S <- data.table(year=samp$year, dale, mattr, ntok, caps_pct, allcaps_pct, digit_pct)
sagg <- S[, .(`Dale-Chall (difficulty)`=mean(dale,na.rm=T), `MATTR (diversity)`=mean(mattr,na.rm=T),
              `doc length (tokens)`=mean(ntok,na.rm=T), `% Capitalized (proper-noun proxy)`=mean(caps_pct,na.rm=T),
              `% ALLCAPS (acronyms)`=mean(allcaps_pct,na.rm=T), `% with digit (numbers)`=mean(digit_pct,na.rm=T)), by=year][order(year)]

M <- merge(full[, .(year, `Flesch-Kincaid grade`=fk_grade, `words / sentence`=words_per_sentence,
                    `syllables / word`=syllables_per_word)], sagg, by="year")
cat("\n=== pooled yearly trends (scraped) ===\n"); print(M)
cat("\n=== correlation of each series with year (trend direction/strength) ===\n")
trendcor <- sapply(names(M)[-1], function(c) round(cor(M$year, M[[c]], use="complete.obs"),2))
print(trendcor)

long <- melt(M, id.vars="year", variable.name="metric")
long[, metric := factor(metric, levels=names(M)[-1])]
saveRDS(M, file.path(FIG,"trends_data.rds"))
p <- ggplot(long, aes(year, value)) +
  geom_line(linewidth=1.1, color="#2c3e50") + geom_point(size=2, color="#2c3e50") +
  geom_smooth(method="lm", se=FALSE, linewidth=0.7, color="#c0392b", linetype="dashed") +
  facet_wrap(~metric, scales="free_y", ncol=3) +
  scale_x_continuous(breaks=seq(2010,2024,4)) +
  labs(title="Press-release language trends over time (both parties pooled, scraped corpus)",
       subtitle="Each panel = corpus-wide yearly mean. Red dashed = linear trend.\nThe puzzle: longer multi-syllable words (syllables/word up) and more variety (MATTR up) in longer documents,\nwhile Dale-Chall difficulty falls -- i.e. entity/jargon densification, not rising 'sophistication'.",
       x=NULL, y=NULL) +
  theme_minimal(base_size=16) +
  theme(plot.title=element_text(face="bold", size=19),
        plot.subtitle=element_text(size=13, color="grey30"),
        strip.text=element_text(face="bold", size=14),
        axis.text=element_text(size=12),
        panel.grid.minor=element_blank(), panel.spacing=unit(1, "lines"))
ggsave(file.path(FIG,"trends_hires.png"), p, width=18, height=11, dpi=170)
cat("\nsaved trends_hires.png\n")
