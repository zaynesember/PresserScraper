#!/usr/bin/env Rscript
# 05_stage.R -- stage extracted NARA releases for the NLP fold-in.
#
# Maps nara/data/extracted/*.rds onto the 13-column wayback schema and writes
# year partitions to external/nara/. Follows 17_stage_external.R exactly where
# it matters:
#   - the anti-join against the WHOLE corpus happens HERE, in the staged files,
#     because families/tag-complete stream year files directly and duplicate
#     urls crash rbind2 ("docnames must be unique") -- DuckDB-level dedup alone
#     is the wrong layer;
#   - rerunning OVERWRITES external/nara/ wholesale (projection, not
#     accumulation);
#   - rows without a parseable date were already dropped in 04.
#
# NARA-specific:
#   - source: institutional units keep their institutional source values
#     ("committee"/"caucus"/"leadership") so the one-predicate isolation keeps
#     working; future member-site rows will get source="nara" (scoping doc
#     section 6). Provenance for institutional rows lives in the sidecar
#     nara/data/nara_provenance.csv, not the schema.
#   - the anti-join key is scheme-insensitive (nara_url_key): the same page can
#     be captured http:// in one harvest and https:// in a later one.
#
# DO NOT run before reading 04's QA output. Ask before folding in.
#
# Run:  Rscript nara/R/05_stage.R

ROOT <- "/Users/zaynesember/GitRepos/pressR"
suppressMessages(devtools::load_all(ROOT, quiet = TRUE))
source(file.path(ROOT, "nara", "R", "lib_nara.R"))
source(file.path(ROOT, "institutional", "R", "lib_party.R"))
source(file.path(ROOT, "nlp", "R", "00_foundation.R"))

EXT_DIR <- file.path(NARA_OUT, "extracted")
OUT     <- file.path(nara_data_dir(), "external", "nara")

fs <- list.files(EXT_DIR, pattern = "[.]rds$", full.names = TRUE)
stopifnot(length(fs) > 0)
x <- do.call(rbind, lapply(fs, readRDS))
message("staging ", nrow(x), " extracted rows from ", length(fs), " feeds")

# Cross-feed / cross-congress dedup inside the NARA pool itself.
x <- x[order(-x$congress), ]
x <- x[!duplicated(nara_url_key(x$url)), , drop = FALSE]
message("after intra-pool dedup: ", nrow(x))

# Anti-join against everything already streamed by the layers: archive year
# files + every external subdir (wayback, institutional, any earlier nara).
message("collecting existing corpus url keys...")
existing <- new.env(parent = emptyenv())
ext_files <- list.files(file.path(nara_data_dir(), "external"),
                        pattern = "releases-[0-9]{4}[.]rds$",
                        recursive = TRUE, full.names = TRUE)
ext_files <- ext_files[!grepl("/external/nara/", ext_files)]   # we overwrite that
for (f in c(nlp_year_files(), ext_files)) {
  for (u in unique(readRDS(f)$url)) assign(nara_url_key(u), TRUE, envir = existing)
}
dup <- vapply(nara_url_key(x$url), function(k) isTRUE(existing[[k]]), logical(1),
              USE.NAMES = FALSE)
if (any(dup)) {
  message("  DROPPING ", sum(dup), " row(s) whose url already exists in the corpus:")
  for (u in utils::head(x$url[dup], 10)) message("    ", u)
  x <- x[!dup, , drop = FALSE]
}

# Party: same vocab as the institutional round. MAJ resolves by who held the
# chamber on the release date; NP/ALL stay NA by design.
party <- rep(NA_character_, nrow(x))
party[x$party_feed %in% c("R", "D")] <- x$party_feed[x$party_feed %in% c("R", "D")]
maj <- x$party_feed == "MAJ"
if (any(maj)) party[maj] <- chamber_majority(x$date[maj], x$chamber[maj])

out <- data.frame(
  date      = as.Date(x$date),
  title     = as.character(x$title),
  body      = as.character(x$body),
  tags      = NA_character_,
  url       = as.character(x$url),
  cms       = NA_character_,
  name      = as.character(x$name),
  state     = NA_character_,
  district  = NA_character_,
  party     = party,
  committee = ifelse(x$type == "committee", as.character(x$unit), NA_character_),
  chamber   = as.character(x$chamber),
  source    = as.character(x$type),
  stringsAsFactors = FALSE
)
stopifnot(all(out$source %in% c("committee", "leadership", "caucus", "nara")))

# Provenance sidecar: the schema carries no replay information by design.
prov <- data.frame(url = x$url, congress = x$congress, capture_ts = x$capture_ts,
                   feed_id = x$feed_id, url_replay = x$url_replay,
                   date_src = x$date_src, stringsAsFactors = FALSE)
write.csv(prov, file.path(NARA_OUT, "nara_provenance.csv"), row.names = FALSE)

if (dir.exists(OUT)) unlink(OUT, recursive = TRUE)
dir.create(OUT, recursive = TRUE, showWarnings = FALSE)
yrs <- format(out$date, "%Y")
for (y in sort(unique(yrs))) {
  d <- out[yrs == y, , drop = FALSE]
  saveRDS(d, file.path(OUT, paste0("releases-", y, ".rds")))
  message(sprintf("  releases-%s.rds  %6d rows", y, nrow(d)))
}

message("\nstaged ", nrow(out), " rows across ", length(unique(yrs)),
        " year files -> ", OUT)
message("by source: ", paste(names(table(out$source)), as.integer(table(out$source)),
                             sep = "=", collapse = "  "))
message("party: ", paste(names(table(out$party, useNA = "ifany")),
                         as.integer(table(out$party, useNA = "ifany")),
                         sep = "=", collapse = "  "))
message("date_src: ", paste(names(table(x$date_src)), as.integer(table(x$date_src)),
                            sep = "=", collapse = "  "))
message("\nfold-in is HOURS and rebuilds every layer -- batch with other pending ",
        "sources and ask before launching (bash nlp/run_foldin.sh).")
