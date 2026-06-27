suppressMessages(devtools::load_all("/Users/zaynesember/GitRepos/pressR"))
source("/Users/zaynesember/GitRepos/pressR/nlp/R/00_foundation.R")
suppressMessages({ library(DBI); library(duckdb); library(data.table); library(ggplot2) })
SCRATCH <- "/private/tmp/claude-501/-Users-zaynesember-GitRepos-pressR/4f90cad5-86dd-450b-a0ac-0a8f83f6520d/scratchpad"

con <- dbConnect(duckdb::duckdb(), nlp_duckdb_path(), read_only = TRUE)
d <- as.data.table(dbGetQuery(con, "
  SELECT party, year, AVG(fk_grade) fk, AVG(sent_len) sent, AVG(syll) syll, COUNT(*) n
  FROM readability WHERE source='scraped' AND party IN ('D','R') AND year BETWEEN 2010 AND 2026
  GROUP BY 1,2 ORDER BY 2,1"))
dbDisconnect(con, shutdown = TRUE)

w <- dcast(d, year ~ party, value.var = c("fk","sent","syll","n"))
# FK = 0.39*words_per_sentence + 11.8*syllables_per_word - 15.59  -> gap decomposes additively
w[, c_sent := 0.39 * (sent_D - sent_R)]     # contribution of the sentence-length gap (grade levels)
w[, c_syll := 11.8 * (syll_D - syll_R)]      # contribution of the word-length gap (grade levels)
w[, gap_recon := c_sent + c_syll]
w[, gap_meas  := fk_D - fk_R]
cat("=== D-R Flesch-Kincaid gap decomposition (scraped, grade-level units) ===\n")
print(w[, .(year, gap_meas=round(gap_meas,2), from_sentence_len=round(c_sent,2),
            from_word_syllables=round(c_syll,2), nD=n_D, nR=n_R)])
cat(sprintf("\nMean gap 2010-2017: %.2f  |  2018-2025: %.2f\n",
            w[year<=2017, mean(gap_meas)], w[year>=2018 & year<=2025, mean(gap_meas)]))
cat(sprintf("Share of gap from sentence length (overall): %.0f%%  | from word syllables: %.0f%%\n",
            100*w[,sum(c_sent)]/w[,sum(gap_recon)], 100*w[,sum(c_syll)]/w[,sum(gap_recon)]))

m <- melt(w[, .(year, `Longer sentences`=c_sent, `Longer / harder words`=c_syll)],
          id.vars="year", variable.name="component", value.name="grades")
p <- ggplot(m, aes(year, grades, fill=component)) +
  geom_col(width=0.8) +
  geom_point(data=w, aes(year, gap_meas), inherit.aes=FALSE, size=1.6, color="grey15") +
  geom_line(data=w, aes(year, gap_meas), inherit.aes=FALSE, color="grey15", linewidth=0.5) +
  geom_hline(yintercept=0, color="grey60", linewidth=0.3) +
  scale_fill_manual(values=c("Longer sentences"="#7fb3d5","Longer / harder words"="#16a085")) +
  scale_x_continuous(breaks=seq(2010,2026,2)) +
  labs(title="What drives the Democrat-Republican readability gap?",
       subtitle="Flesch-Kincaid grade-level gap (D minus R) split into its two formula components.\nBars = each component's contribution; black line/points = total measured gap. Scraped corpus, 2010-2026.",
       x=NULL, y="D - R gap (Flesch-Kincaid grade levels)", fill="Gap comes from") +
  theme_minimal(base_size=12) +
  theme(plot.title=element_text(face="bold"), legend.position="top",
        panel.grid.minor=element_blank())
ggsave(file.path(SCRATCH,"decomp.png"), p, width=9, height=5.2, dpi=140)
cat("\nsaved decomp.png\n")
