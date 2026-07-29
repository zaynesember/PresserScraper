#!/usr/bin/env Rscript
# Phase A of the Wayback roster expansion: for each former-House candidate
# (nlp/crosswalks/wayback_expansion_candidates.csv — final term ended 2007-2016,
# zero corpus coverage, built from congress-legislators + a corpus anti-join),
# infer the member's house.gov hostname, verify it has Wayback captures, and
# bucket capture volume for batch ranking. Writes/appends
# nlp/crosswalks/wayback_expansion_probe.csv; resumable (skips probed members).
# CDX-only and gentle: ~6s pacing, long backoff (IA throttles CDX bursts hard).
# Run with the Bash sandbox disabled (network).
suppressMessages(devtools::load_all("/Users/zaynesember/GitRepos/pressR"))
source("/Users/zaynesember/GitRepos/pressR/nlp/R/00_foundation.R")
suppressMessages({ library(httr2); library(data.table) })
t0 <- Sys.time()
XW  <- "/Users/zaynesember/GitRepos/pressR/nlp/crosswalks"
OUT <- file.path(XW, "wayback_expansion_probe.csv")
PACE <- as.numeric(Sys.getenv("WAYBACK_PROBE_PACE", "6"))
UA <- "pressR-research (congressional press-release archive)"
GET <- function(url, to = 60) request(url) |> req_timeout(to) |> req_user_agent(UA) |>
  req_retry(max_tries = 5, backoff = ~ min(60, 5 * 2^.x)) |> req_perform()

# a CDX text response is data iff it starts with a 14-digit timestamp
cdx_lines <- function(u) {
  txt <- tryCatch(resp_body_string(GET(u)), error = function(e) "")
  Sys.sleep(PACE)
  if (!nzchar(txt) || grepl("^\\s*<", txt)) return(character(0))   # html error page
  ln <- strsplit(txt, "\n", fixed = TRUE)[[1]]
  ln[grepl("^[0-9]{14}", ln)]
}
exists_host <- function(host) length(cdx_lines(sprintf(
  "http://web.archive.org/cdx/search/cdx?url=%s/*&from=2005&to=2016&limit=1&fl=timestamp", host))) > 0
volume_host <- function(host) length(cdx_lines(sprintf(
  "http://web.archive.org/cdx/search/cdx?url=%s/*&from=2005&to=2016&limit=2000&fl=timestamp&collapse=urlkey&filter=statuscode:200&filter=mimetype:text/html",
  host)))

strip  <- function(x) gsub("[^a-z]", "", tolower(x))
striph <- function(x) gsub("[^a-z-]", "", tolower(x))          # keep hyphens (ros-lehtinen)
host_candidates <- function(last, first) unique(c(
  paste0(strip(last),  ".house.gov"),
  paste0(striph(last), ".house.gov"),
  paste0(strip(first), strip(last), ".house.gov")))

cand <- fread(file.path(XW, "wayback_expansion_candidates.csv"))
done <- if (file.exists(OUT)) fread(OUT)$bioguide else character(0)
todo <- cand[!bioguide %in% done]
message(sprintf("== probing %d of %d candidates (resumable; pace %.0fs) ==", nrow(todo), nrow(cand), PACE))

for (i in seq_len(nrow(todo))) {
  M <- todo[i]
  found <- NA_character_; vol <- 0L
  for (h in host_candidates(M$last, M$first)) {
    if (exists_host(h)) { found <- h; vol <- volume_host(h); break }
  }
  row <- data.table(bioguide = M$bioguide, name = M$name, state = M$state, party = M$party,
                    house_end = M$house_end, n_house_terms = M$n_house_terms,
                    host = found, n_captures = vol, probed = format(Sys.time(), "%Y-%m-%d %H:%M"))
  fwrite(row, OUT, append = file.exists(OUT))
  cat(sprintf("  [%3d/%3d] %-28s -> %s (%s)\n", i, nrow(todo), M$name,
              ifelse(is.na(found), "NOT FOUND", found), vol))
}
res <- fread(OUT)
# NB fread reads an unfound host back as "" (not NA), so test both.
cat(sprintf("\n== probe complete: %d/%d hosts found | volume buckets: 2000+:%d 500-1999:%d 100-499:%d <100:%d ==\n",
    sum(!is.na(res$host) & nzchar(res$host)), nrow(res),
    sum(res$n_captures >= 2000), sum(res$n_captures %between% c(500, 1999)),
    sum(res$n_captures %between% c(100, 499)), sum(res$n_captures > 0 & res$n_captures < 100)))
cat(sprintf("done in %.1f min\n", as.numeric(difftime(Sys.time(), t0, units = "mins"))))
