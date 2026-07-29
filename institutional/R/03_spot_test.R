# 03_spot_test.R -- feasibility spot-test: try the existing extractors against
# every resolving institutional host, listings only (fetch_bodies = FALSE),
# over the last 90 days.
#
# On-domain (*.house.gov / *.senate.gov) hosts go through scrape_member(),
# which brings the JS-render and generic fallbacks. Off-domain leadership hosts
# (speaker.gov etc.) fail its is_member_url() guard, so they go through the
# internal scrape_member_core() directly; we replicate the generic fallback.
#
# Writes institutional/data/spot_results.csv + spot_samples.rds.
#
# Run:  Rscript institutional/R/03_spot_test.R

ROOT <- "/Users/zaynesember/GitRepos/pressR"   # consolidated onto the `corpus` branch (was the pressR-sources worktree)
suppressMessages(devtools::load_all(ROOT, quiet = TRUE))

OUT <- file.path(ROOT, "institutional", "data")
hosts <- read.csv(file.path(OUT, "hosts_clean.csv"), stringsAsFactors = FALSE)
hosts <- hosts[hosts$resolves, ]

FROM <- Sys.Date() - 90
TO   <- Sys.Date()

on_domain <- grepl("\\.(house|senate)\\.gov$", hosts$host)

spot_one <- function(host, on_dom) {
  url <- paste0("https://", host)
  t0 <- Sys.time()
  res <- NULL; err <- NA_character_
  if (on_dom) {
    res <- tryCatch(
      scrape_member(url, from = FROM, to = TO, page_limit = 10,
                    fetch_bodies = FALSE, quiet = TRUE),
      error = function(e) { err <<- conditionMessage(e); NULL }
    )
  } else {
    # Off-domain: core pass, then a generic-extractor retry like scrape_member's.
    res <- tryCatch({
      r <- scrape_member_core(url, FROM, TO, cms = NULL, page_limit = 10,
                              fetch_bodies = FALSE, quiet = TRUE)
      if (nrow(r) == 0 && !identical(attr(r, "cms_detected"), "generic")) {
        r2 <- scrape_member_core(url, FROM, TO, "generic", 10, FALSE, TRUE)
        if (nrow(r2) > 0) r <- r2
      }
      if (!isTRUE(attr(r, "found_home"))) err <<- "could not fetch homepage"
      else if (!isTRUE(attr(r, "found_listing"))) err <<- paste0("no listing (cms: ", attr(r, "cms_detected"), ")")
      else if (!isTRUE(attr(r, "saw_items")) && nrow(r) == 0) err <<- "listing yielded no parseable items"
      strip_status(r)
    }, error = function(e) { err <<- conditionMessage(e); NULL })
  }
  secs <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
  n <- if (is.null(res)) 0L else nrow(res)
  list(
    summary = data.frame(
      host = host, n_90d = n,
      date_min = if (n > 0) as.character(min(res$date, na.rm = TRUE)) else NA_character_,
      date_max = if (n > 0) as.character(max(res$date, na.rm = TRUE)) else NA_character_,
      cms_used = if (n > 0) res$cms[1] else NA_character_,
      error = err, secs = round(secs, 1),
      stringsAsFactors = FALSE
    ),
    sample = res
  )
}

results <- vector("list", nrow(hosts))
samples <- list()
for (i in seq_len(nrow(hosts))) {
  h <- hosts$host[i]
  message(sprintf("[%3d/%3d] %s ...", i, nrow(hosts), h))
  out <- spot_one(h, on_domain[i])
  results[[i]] <- out$summary
  samples[[h]] <- out$sample
  message(sprintf("          -> %d releases  %s", out$summary$n_90d,
                  ifelse(is.na(out$summary$error), "", paste0("(", out$summary$error, ")"))))
}

summary_df <- do.call(rbind, results)
summary_df <- merge(hosts[, c("host", "unit", "type", "chamber", "party_site", "cms")],
                    summary_df, by = "host", sort = FALSE)
write.csv(summary_df, file.path(OUT, "spot_results.csv"), row.names = FALSE)
saveRDS(samples, file.path(OUT, "spot_samples.rds"))

ok <- summary_df$n_90d > 0
message("\nHosts yielding releases in the last 90 days: ", sum(ok), " / ", nrow(summary_df))
message("Total releases seen (90d): ", sum(summary_df$n_90d))
message("\nBy CMS:")
print(tapply(summary_df$n_90d, summary_df$cms, sum))
message("\nFailures:")
print(summary_df[!ok, c("host", "cms", "error")], row.names = FALSE)
