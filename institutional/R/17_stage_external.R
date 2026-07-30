# 17_stage_external.R -- stage the assembled institutional releases for the
# NLP fold-in.
#
# The DuckDB rebuild streams every external/<subdir>/releases-YYYY.rds
# recursively, each file carrying its own `source` (that is how the wayback
# rows enter). This script maps institutional_releases.rds onto exactly that
# schema and writes year partitions to external/institutional/.
#
# Mapping (per institutional/README.md):
#   name      canonical unit name, chamber-prefixed ("Senate Committee on ...");
#             built by 09_assemble.R, never a person
#   party     resolved party (MAJ resolved by chamber majority at release date;
#             NP/ALL/conflicting-branding -> NA)
#   committee the committee's own name for source="committee", NA otherwise
#   source    "committee" / "leadership" / "caucus" -- the one predicate that
#             lets member-level analyses exclude institutional rows
#   state, district  NA (institutions have neither)
#
# Rows without a parseable date are DROPPED (reported): the store types `date`
# as DATE and every layer partitions on year.
#
# Rerunning OVERWRITES external/institutional/ from the current staging RDS --
# it is a projection, not an accumulation.
#
# Run:  Rscript institutional/R/17_stage_external.R

ROOT <- "/Users/zaynesember/GitRepos/pressR"
suppressMessages(devtools::load_all(ROOT, quiet = TRUE))

IN  <- file.path(ROOT, "institutional", "data", "institutional_releases.rds")
OUT <- file.path(tools::R_user_dir("pressR_nlp", "data"), "external", "institutional")

x <- readRDS(IN)
message("staging ", nrow(x), " assembled institutional releases")

no_date <- is.na(x$date)
if (any(no_date)) {
  message("  DROPPING ", sum(no_date), " rows with no parseable date (",
          sprintf("%.2f%%", 100 * mean(no_date)), ")")
  x <- x[!no_date, , drop = FALSE]
}

# Drop rows whose URL already exists elsewhere in the corpus. This must happen
# HERE, in the staged files: families and tag-complete stream the year files
# directly (not DuckDB), quanteda uses url as the docname, and rbind2 refuses
# duplicate docnames -- two member releases on minority-committee hosts were
# swept by both the member scrape and this collection at identical URLs, and
# they aborted tag-complete. A DuckDB-level dedup alone does not reach the
# streamed path (that lesson cost one 52-minute families rerun). The member-
# attributed copy is the one kept, matching the store's first-inserted rule.
message("collecting existing corpus urls (archive + external/wayback)...")
H <- file.path(ROOT, "nlp", "R")
source(file.path(H, "00_foundation.R"))
existing <- new.env(parent = emptyenv())
arch <- c(nlp_year_files(),
          list.files(file.path(tools::R_user_dir("pressR_nlp", "data"), "external", "wayback"),
                     pattern = "releases-[0-9]{4}[.]rds$", full.names = TRUE))
for (f in arch) {
  for (u in unique(readRDS(f)$url)) assign(u, TRUE, envir = existing)
}
dup <- vapply(x$url, function(u) isTRUE(existing[[u]]), logical(1), USE.NAMES = FALSE)
if (any(dup)) {
  message("  DROPPING ", sum(dup), " row(s) whose url already exists in the corpus:")
  for (u in utils::head(x$url[dup], 10)) message("    ", u)
  x <- x[!dup, , drop = FALSE]
}

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
  party     = as.character(x$party),
  committee = ifelse(x$source == "committee", as.character(x$unit), NA_character_),
  chamber   = as.character(x$chamber),
  source    = as.character(x$source),
  stringsAsFactors = FALSE
)
stopifnot(all(out$source %in% c("committee", "leadership", "caucus")))

# Overwrite the projection wholesale so a stale partition can't linger.
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
