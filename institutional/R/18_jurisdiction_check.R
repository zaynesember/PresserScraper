# 18_jurisdiction_check.R -- validate predicted issue labels on committee text
# against committee jurisdiction.
#
# Committee releases carry no office tags, so the tag model's held-out F1 says
# nothing about them. But jurisdiction is ground truth we get for free: House
# Agriculture's releases should overwhelmingly draw the Agriculture label. Per
# committee we hand-author the expected subset of the 31 canonical labels and
# measure the share of releases whose PREDICTED labels intersect it, against the
# base rate of the same expected set among member releases -- lift well above 1
# means the model transfers to institutional text; a committee near base rate is
# one whose predictions should not be trusted.
#
# The crosswalk is judgment, deliberately narrow: it names a committee's core
# jurisdiction, not everything it could plausibly touch, so agreement here is a
# conservative floor. Process committees (Oversight, Ethics, Rules, Admin) get
# Government Reform & Oversight, but their releases legitimately roam -- read
# their rows accordingly.
#
# Read-only. Prints the table; saves institutional/data/jurisdiction_check.rds.
#
# Run:  Rscript institutional/R/18_jurisdiction_check.R

suppressMessages({library(DBI); library(duckdb)})
ROOT <- "/Users/zaynesember/GitRepos/pressR"
RU <- file.path(path.expand("~"), "Library/Application Support/org.R-project.R/R/pressR_nlp")

# Ordered first-match patterns over the canonical committee name. Order matters:
# "Financial Services" must match before bare "Finance", "Energy and Natural
# Resources" before "Natural Resources", HSGAC before bare "Homeland Security".
XWALK <- list(
  list("Financial Services",                        c("Financial Services & Consumer Protection","Housing","Economy & Jobs")),
  list("on Finance",                                c("Taxes & Budget","Health Care","Trade","Seniors & Retirement")),
  list("Homeland Security and Governmental Affairs",c("Immigration & Border","Government Reform & Oversight","Defense & National Security","Disaster & Emergency")),
  list("Homeland Security",                         c("Immigration & Border","Defense & National Security","Disaster & Emergency")),
  list("Energy and Natural Resources",              c("Energy","Environment & Climate")),
  list("Energy and Commerce",                       c("Energy","Health Care","Technology & Broadband","Environment & Climate","Public Health")),
  list("Natural Resources",                         c("Environment & Climate","Energy","Oceans & Fisheries")),
  list("Ways and Means",                            c("Taxes & Budget","Trade","Health Care","Seniors & Retirement","Economy & Jobs")),
  list("Foreign Relations",                         c("Foreign Affairs","Defense & National Security")),
  list("Foreign Affairs",                           c("Foreign Affairs","Defense & National Security")),
  list("Education and Workforce",                   c("Education","Labor & Workers","Children & Families")),
  list("Health, Education, Labor",                  c("Health Care","Education","Labor & Workers","Public Health","Seniors & Retirement")),
  list("Environment and Public Works",              c("Environment & Climate","Transportation & Infrastructure","Energy")),
  list("Judiciary",                                 c("Crime & Justice","Immigration & Border","Civil Rights & Equality","Guns")),
  list("Science, Space, and Technology",            c("Science & Innovation","Technology & Broadband")),
  list("Oversight",                                 c("Government Reform & Oversight")),
  list("Commerce, Science, and Transportation",     c("Transportation & Infrastructure","Technology & Broadband","Science & Innovation","Oceans & Fisheries")),
  list("Appropriations",                            c("Taxes & Budget")),
  list("Armed Services",                            c("Defense & National Security","Veterans")),
  list("Transportation and Infrastructure",         c("Transportation & Infrastructure","Disaster & Emergency")),
  list("Agriculture",                               c("Agriculture","Children & Families")),
  list("Budget",                                    c("Taxes & Budget")),
  list("Small Business",                            c("Small Business")),
  list("Veterans",                                  c("Veterans")),
  list("Intelligence",                              c("Defense & National Security")),
  list("Banking",                                   c("Financial Services & Consumer Protection","Housing","Economy & Jobs")),
  list("Aging",                                     c("Seniors & Retirement","Health Care")),
  list("Indian Affairs",                            c("Civil Rights & Equality","Health Care","Education")),
  list("Ethics",                                    c("Government Reform & Oversight")),
  list("Rules and Administration",                  c("Government Reform & Oversight")),
  list("House Administration",                      c("Government Reform & Oversight")),
  list("Economic",                                  c("Economy & Jobs","Taxes & Budget"))
)
expected_for <- function(nm) {
  for (e in XWALK) if (grepl(e[[1]], nm, fixed = TRUE)) return(e[[2]])
  NULL
}

con <- dbConnect(duckdb::duckdb(), dbdir = file.path(RU, "press.duckdb"), read_only = TRUE)
d <- dbGetQuery(con, "
  SELECT r.name, r.source, il.predicted_issues, il.top_issue
  FROM releases r JOIN issue_labels il ON r.url = il.url
  WHERE r.usable AND il.predicted_issues IS NOT NULL")
dbDisconnect(con, shutdown = TRUE)

is_mem <- d$source %in% c("scraped", "stout", "wangtucker", "wayback")
mem_pred <- d$predicted_issues[is_mem]
mem_top  <- d$top_issue[is_mem]

hit_any <- function(pred, E) {
  h <- rep(FALSE, length(pred))
  for (lab in E) h <- h | grepl(lab, pred, fixed = TRUE)
  h
}

com <- d[d$source == "committee", ]
rows <- list()
for (nm in unique(com$name)) {
  E <- expected_for(nm)
  s <- com[com$name == nm, ]
  if (is.null(E)) { message("no crosswalk entry: ", nm, " (", nrow(s), " rows) -- skipped"); next }
  agree_any <- mean(hit_any(s$predicted_issues, E))
  agree_top <- mean(s$top_issue %in% E)
  base_any  <- mean(hit_any(mem_pred, E))
  rows[[nm]] <- data.frame(
    committee = sub("^(House|Senate|Joint) Committee on ", "", nm),
    n = nrow(s), expected = length(E),
    agree_any = round(100 * agree_any, 1),
    base_any  = round(100 * base_any, 1),
    lift      = round(agree_any / max(base_any, 1e-9), 1),
    agree_top = round(100 * agree_top, 1),
    stringsAsFactors = FALSE)
}
res <- do.call(rbind, rows)
res <- res[order(-res$n), ]
rownames(res) <- NULL

cat("=========== JURISDICTION vs PREDICTED ISSUES (committee releases) ===========\n")
cat("agree_any: % of releases with >=1 predicted label in the committee's expected set\n")
cat("base_any : same measure over MEMBER releases (chance level for that set)\n\n")
print(res, row.names = FALSE)

w <- sum(res$n * res$agree_any) / sum(res$n)
b <- sum(res$n * res$base_any) / sum(res$n)
cat(sprintf("\nweighted overall: agree %.1f%% vs base %.1f%% (lift %.1f)\n", w, b, w / b))
cat(sprintf("committees with lift < 1.5 (predictions suspect there): %s\n",
    paste(res$committee[res$lift < 1.5], collapse = ", ")))

saveRDS(res, file.path(ROOT, "institutional", "data", "jurisdiction_check.rds"))
