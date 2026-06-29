suppressMessages(devtools::load_all("/Users/zaynesember/GitRepos/pressR"))
source("/Users/zaynesember/GitRepos/pressR/nlp/R/00_foundation.R")
suppressMessages({ library(DBI); library(duckdb); library(data.table); library(ggplot2)
  library(quanteda); library(quanteda.textstats) })
FIG <- "/Users/zaynesember/GitRepos/pressR/blog/figures"

# balanced sample: up to 500 scraped usable releases per party-year (2010-2025)
con <- dbConnect(duckdb::duckdb(), nlp_duckdb_path(), read_only = TRUE)
samp <- as.data.table(dbGetQuery(con, "
  SELECT url, party, year, body FROM (
    SELECT url, party, year, body,
           row_number() OVER (PARTITION BY party, year ORDER BY hash(url)) rn  -- deterministic sample
    FROM releases
    WHERE source='scraped' AND usable AND body IS NOT NULL AND length(body) > 200
      AND party IN ('D','R') AND year BETWEEN 2010 AND 2025
  ) WHERE rn <= 500"))
dbDisconnect(con, shutdown = TRUE)
cat("sampled", nrow(samp), "releases\n")

co <- corpus(samp$body, docvars = data.frame(party = samp$party, year = samp$year))
rd <- textstat_readability(co, measure = c("Flesch.Kincaid", "Dale.Chall"))
tk <- tokens(co, remove_punct = TRUE, remove_numbers = TRUE, remove_symbols = TRUE)
ld <- textstat_lexdiv(tk, measure = "MATTR")
D  <- cbind(as.data.table(docvars(co)),
            fk = rd$Flesch.Kincaid, dale = rd$Dale.Chall, mtld = ld$MATTR)
agg <- D[, .(`Flesch-Kincaid grade\n(readability)` = mean(fk, na.rm=TRUE),
             `Dale-Chall\n(vocabulary difficulty)` = mean(dale, na.rm=TRUE),
             `MATTR\n(lexical diversity)` = mean(mtld, na.rm=TRUE), n = .N),
           by = .(party, year)][n >= 80]

# print the D-R gaps
g <- dcast(melt(agg, id.vars=c("party","year","n"), variable.name="measure"),
           year + measure ~ party, value.var="value")
g[, gap := round(D - R, 2)]
cat("\n=== D-R gap by measure (selected years) ===\n")
print(dcast(g, year ~ measure, value.var="gap")[year %in% c(2012,2016,2019,2022,2025)])

long <- melt(agg, id.vars=c("party","year","n"), variable.name="measure", value.name="score")
long[, measure := factor(measure, levels=c("Flesch-Kincaid grade\n(readability)",
                                           "Dale-Chall\n(vocabulary difficulty)",
                                           "MATTR\n(lexical diversity)"))]
p <- ggplot(long, aes(year, score, color=party)) +
  geom_line(linewidth=0.9) + geom_point(size=1.3) +
  facet_wrap(~measure, scales="free_y") +
  scale_color_manual(values=c(D="#2c5fa8", R="#c0392b")) +
  scale_x_continuous(breaks=seq(2010,2024,4)) +
  labs(title="Readability vs. sophistication: the D-R gap is in sentence length, not vocabulary",
       subtitle="Balanced sample (<=500 scraped releases per party-year). FK separates D and R; the two vocabulary\nmeasures (word difficulty, lexical diversity) show little to no partisan gap.",
       x=NULL, y="mean score", color="Party") +
  theme_minimal(base_size=12) +
  theme(plot.title=element_text(face="bold"), legend.position="top",
        panel.grid.minor=element_blank(), strip.text=element_text(face="bold", size=9))
ggsave(file.path(FIG,"soph.png"), p, width=11, height=4.8, dpi=140)
cat("\nsaved soph.png\n")
