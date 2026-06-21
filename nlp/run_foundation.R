#!/usr/bin/env Rscript
# Foundation + near-dup family layer, end to end.
#   Rscript nlp/run_foundation.R            # full (duckdb + exact + near-dup)
#   Rscript nlp/run_foundation.R exact      # skip near-dup (exact families only)
suppressMessages(devtools::load_all("/Users/zaynesember/GitRepos/pressR"))
here <- "/Users/zaynesember/GitRepos/pressR/nlp/R"
source(file.path(here, "00_foundation.R"))
source(file.path(here, "01_build_duckdb.R"))
source(file.path(here, "02_near_dup.R"))
suppressMessages({ library(DBI); library(duckdb); library(dplyr) })

mode <- (commandArgs(trailingOnly = TRUE)[1] %||% "full")
near <- !identical(mode, "exact")
t0 <- Sys.time()

## 1) DuckDB store -----------------------------------------------------------
message("== Building DuckDB store ==")
nlp_build_duckdb(overwrite = TRUE)

## 2) Identity stoplist (saved for downstream slices) -----------------------
con <- dbConnect(duckdb::duckdb(), dbdir = nlp_duckdb_path())
members <- dbGetQuery(con, "SELECT DISTINCT name FROM releases WHERE name IS NOT NULL")$name
stop_id <- nlp_identity_stoplist(members)
saveRDS(stop_id, file.path(nlp_out_dir(), "identity_stoplist.rds"))
message(sprintf("Identity stoplist: %d terms -> identity_stoplist.rds", length(stop_id)))

## 3) Near-dup families -----------------------------------------------------
message("== Building coordinated-messaging families ==")
fam <- nlp_build_families(near_dup = near, jaccard = 0.7)
saveRDS(fam$families,    file.path(nlp_out_dir(), "families.rds"))
saveRDS(fam$per_release, file.path(nlp_out_dir(), "release_family.rds"))

# Persist into DuckDB so the dashboard/downstream join cheaply.
dbWriteTable(con, "families", fam$families, overwrite = TRUE)
dbWriteTable(con, "release_family",
             fam$per_release %>% select(url, family_id, n_docs, is_reused,
                                        cross_member, cross_party, cross_chamber),
             overwrite = TRUE)

## 4) Validation + headline metrics -----------------------------------------
per <- fam$per_release; fams <- fam$families
n_usable <- nrow(per)
reused <- per$is_reused
# Validation: every exact-dup (same ut_id appearing >1) must share one family.
exact_ok <- per %>% group_by(ut_id) %>% summarise(nf = n_distinct(family_id)) %>%
  summarise(bad = sum(nf > 1)) %>% pull(bad)
# near-dup merges: families spanning >1 distinct unique-text
fam_uts <- per %>% group_by(family_id) %>% summarise(nut = n_distinct(ut_id))
near_merged <- sum(fam_uts$nut > 1)

cat(sprintf("\n================ FOUNDATION + FAMILIES ================\n"))
cat(sprintf("usable releases (deduped scope): %s\n", format(n_usable, big.mark=",")))
cat(sprintf("reused releases (family size>1): %s (%.1f%%)\n",
            format(sum(reused), big.mark=","), 100*mean(reused)))
cat(sprintf("distinct families: %s | reused families: %s\n",
            format(nrow(fams), big.mark=","), format(sum(fams$is_reused), big.mark=",")))
cat(sprintf("  cross-member families:  %s\n", format(sum(fams$cross_member), big.mark=",")))
cat(sprintf("  cross-party families:   %s\n", format(sum(fams$cross_party), big.mark=",")))
cat(sprintf("  cross-chamber families: %s\n", format(sum(fams$cross_chamber), big.mark=",")))
cat(sprintf("validation: exact-dup split across families = %d (must be 0)\n", exact_ok))
cat(sprintf("near-dup merged families (span >1 distinct text): %s\n",
            format(near_merged, big.mark=",")))

cat("\nTop 12 cross-member families (most members sharing one message):\n")
top <- fams %>% arrange(desc(n_members)) %>% head(12)
titles <- dbGetQuery(con, sprintf(
  "SELECT family_id, ANY_VALUE(title) title FROM release_family rf
   JOIN releases r USING(url) WHERE family_id IN (%s) GROUP BY family_id",
  paste(top$family_id, collapse=",")))
top <- left_join(top, titles, by = "family_id")
for (i in seq_len(nrow(top))) cat(sprintf("  %3d members, %2d docs %s/%s [%s]  \"%s\"\n",
  top$n_members[i], top$n_docs[i], top$parties[i],
  ifelse(top$cross_chamber[i],"2ch","1ch"),
  format(top$date_min[i]), substr(top$title[i] %||% "(no title)",1,70)))

dbDisconnect(con, shutdown = TRUE)
cat(sprintf("\nartifacts in %s\n", nlp_out_dir()))
cat(sprintf("done in %.1f min\n", as.numeric(difftime(Sys.time(), t0, units="mins"))))
