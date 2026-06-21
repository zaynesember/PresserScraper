#!/usr/bin/env Rscript
# Parse the two external datasets, map them to the archive schema (+ source), and
# write them as year-partitioned RDS under pressR_nlp/external/. These are then
# folded into the DuckDB store + NLP layers by the (source-aware) builders.
#   Rscript nlp/run_external.R sample   # dry-run: parse a slice, print, DON'T write
#   Rscript nlp/run_external.R          # full parse + write
suppressMessages(devtools::load_all("/Users/zaynesember/GitRepos/pressR"))
H <- "/Users/zaynesember/GitRepos/pressR/nlp/R"
source(file.path(H, "00_foundation.R"))
source(file.path(H, "03_external.R"))
suppressMessages({ library(data.table) })
t0 <- Sys.time()
mode <- (commandArgs(trailingOnly = TRUE)[1] %||% "full")
SAMPLE <- identical(mode, "sample")

COMMS <- "/Users/zaynesember/Dropbox (Personal)/UCSD/Dissertation/Communications Data"
STOUT_CSV <- file.path(COMMS, "114th-117th Master Press Release.csv")
WT_DIR    <- file.path(COMMS, "WangTucker109_115_press/109_to_115")

# voteview roster: cache a copy in pressR_nlp/ (download if absent)
vv <- file.path(nlp_out_dir(), "voteview_members.csv")
if (!file.exists(vv)) {
  scratch <- "/tmp/fold/voteview_members.csv"
  if (file.exists(scratch)) file.copy(scratch, vv) else
    download.file("https://voteview.com/static/data/out/members/HSall_members.csv",
                  vv, quiet = TRUE)
}
namemap <- nlp_voteview_namemap(vv)
message(sprintf("voteview namemap: %d House member-terms", length(namemap)))

## ---- parse ----------------------------------------------------------------
message("== Parsing Stout 114-117 ==")
stout <- nlp_parse_stout(STOUT_CSV, namemap, nrows = if (SAMPLE) 8000L else Inf)
message(sprintf("  stout: %s releases", format(nrow(stout), big.mark = ",")))
message("== Parsing Wang & Tucker 109-115 ==")
wt <- nlp_parse_wt(WT_DIR, max_dirs = if (SAMPLE) 8L else Inf)
message(sprintf("  wangtucker: %s releases", format(nrow(wt), big.mark = ",")))

ext <- rbindlist(list(stout, wt), use.names = TRUE)

## ---- validate -------------------------------------------------------------
cat("\n================ EXTERNAL PARSE ================\n")
cat(sprintf("total external releases: %s (stout %s + wt %s)\n",
  format(nrow(ext), big.mark = ","), format(nrow(stout), big.mark = ","),
  format(nrow(wt), big.mark = ",")))
cat(sprintf("date range: %s .. %s\n", min(ext$date), max(ext$date)))
cat("by source x chamber:\n"); print(table(ext$source, ext$chamber, useNA = "ifany"))
cat("by source x party:\n");   print(table(ext$source, ext$party, useNA = "ifany"))
cat("releases per year:\n");   print(table(format(ext$date, "%Y")))
cat(sprintf("NA name: %d | NA party: %d | NA state: %d | NA date: %d\n",
  sum(is.na(ext$name)), sum(is.na(ext$party)), sum(is.na(ext$state)), sum(is.na(ext$date))))
cat(sprintf("dup urls: %d | empty body: %d\n",
  sum(duplicated(ext$url)), sum(!nzchar(ext$body))))
cat(sprintf("body nchar q(.05,.5,.95): %s\n",
  paste(round(quantile(nchar(ext$body), c(.05,.5,.95))), collapse = " / ")))
cat("\nstout name samples:\n"); print(head(unique(stout$name), 6))
cat("wt name + chamber + party + state samples:\n")
print(unique(wt[, .(name, chamber, party, state)])[1:min(8, .N)])
cat("\nsample stout title|body:\n")
cat("  T:", substr(stout$title[1], 1, 80), "\n  B:", substr(stout$body[1], 1, 120), "\n")
cat("sample wt title|body:\n")
cat("  T:", substr(wt$title[1], 1, 80), "\n  B:", substr(wt$body[1], 1, 120), "\n")

## ---- write ----------------------------------------------------------------
if (!SAMPLE) {
  extdir <- nlp_external_dir(create = TRUE)
  # clear any prior external files so a re-run is clean
  old <- list.files(extdir, pattern = "releases-[0-9]{4}[.]rds$", full.names = TRUE)
  if (length(old)) file.remove(old)
  yr_tab <- nlp_write_external_years(ext, extdir)
  cat(sprintf("\nwrote %d year files to %s\n", length(yr_tab), extdir))
} else {
  cat("\n[sample mode] nothing written\n")
}
cat(sprintf("done in %.1f min\n", as.numeric(difftime(Sys.time(), t0, units = "mins"))))
