#!/usr/bin/env Rscript
# Phase B roster builder: merge the original 16 wayback targets with the probed
# expansion hosts (wayback_expansion_probe.csv), ranked by archived-capture
# volume. Writes:
#   nlp/crosswalks/wayback_targets_full.csv    16 originals + every found host
#   nlp/crosswalks/wayback_targets_batch1.csv  16 originals + top BATCH_N hosts
# A full (non-VALID) run_wayback.R run rewrites external/wayback/ from its
# roster's caches only, so EVERY batch roster must include the original 16
# (they resolve instantly from cache).
suppressMessages(library(data.table))
XW <- "/Users/zaynesember/GitRepos/pressR/nlp/crosswalks"
BATCH_N <- as.integer(Sys.getenv("WAYBACK_BATCH_N", "25"))

orig  <- fread(file.path(XW, "wayback_targets.csv"))
probe <- fread(file.path(XW, "wayback_expansion_probe.csv"))
stopifnot(nrow(probe) >= 300)   # don't build from a half-finished probe

found <- probe[!is.na(host) & host != ""]
# house_end drives run_wayback.R's service-window guard: hosts are inferred by
# SURNAME, so a seat inherited by a relative (Bilirakis, Payne) would otherwise
# attribute the successor's releases to the departed member.
exp <- found[order(-n_captures, -n_house_terms), .(
  name, host, party, state, district = NA_integer_, cms = "generic",
  n_press = n_captures, house_end = as.character(house_end))]
cat(sprintf("probe: %d members | hosts found: %d (%.0f%%) | not found: %d\n",
    nrow(probe), nrow(found), 100 * nrow(found) / nrow(probe), nrow(probe) - nrow(found)))
cat("volume tiers among found: ")
cat(sprintf("2000+: %d | 500-1999: %d | 100-499: %d | 1-99: %d | 0: %d\n",
    found[n_captures >= 2000, .N], found[n_captures %between% c(500, 1999), .N],
    found[n_captures %between% c(100, 499), .N], found[n_captures %between% c(1, 99), .N],
    found[n_captures == 0, .N]))

orig[, house_end := NA_character_]     # originals are hand-verified; no guard needed
full   <- rbind(orig, exp)
batch1 <- rbind(orig, head(exp, BATCH_N))
fwrite(full,   file.path(XW, "wayback_targets_full.csv"))
fwrite(batch1, file.path(XW, "wayback_targets_batch1.csv"))
cat(sprintf("\nwrote wayback_targets_full.csv (%d rows) + wayback_targets_batch1.csv (%d rows = 16 + %d)\n",
    nrow(full), nrow(batch1), min(BATCH_N, nrow(exp))))
cat("\nbatch 1 expansion members:\n")
print(head(exp, BATCH_N)[, .(name, host, party, state, n_press)])
