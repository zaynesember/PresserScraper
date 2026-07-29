# 06_feed_configs.R -- hand-curated feed configs for the hosts the stock
# extractors can't walk (from the 04_diagnose_failures.R findings).
#
# One row per FEED (a host can carry several party-tagged feeds). Engines:
#   insti   : lib_institutional.R walker (explicit listing + item regex)
#   guid    : package guid extractor with an explicit listing URL
#   package : stock scrape flow, full history (for hosts whose feed the stock
#             extractor finds but whose recent window was empty)
#
# party = attribution of the FEED: "R", "D", "NP" (nonpartisan/joint), or
# "MAJ" (the chamber's majority party at release date -- resolved at fold-in).

feed_configs <- function() {
  rows <- list(
    # ---- House committee: Budget (Drupal-ish; items at /press-release/<slug>)
    list("budget.house.gov", "Budget", "committee", "house", "MAJ", "insti",
         "https://budget.house.gov/news/press-releases",
         "budget\\.house\\.gov/press-release/"),

    # ---- Senate: Aging (items at /press-releases/<slug>, off the listing path)
    list("www.aging.senate.gov", "Special Committee on Aging", "committee", "senate", "R", "insti",
         "https://www.aging.senate.gov/press-room/majority",
         "aging\\.senate\\.gov/press-releases/"),
    list("www.aging.senate.gov", "Special Committee on Aging", "committee", "senate", "D", "insti",
         "https://www.aging.senate.gov/press-room/minority",
         "aging\\.senate\\.gov/press-releases/"),
    list("www.aging.senate.gov", "Special Committee on Aging", "committee", "senate", "NP", "insti",
         "https://www.aging.senate.gov/press-room/joint",
         "aging\\.senate\\.gov/press-releases/"),

    # ---- Senate: Banking
    list("www.banking.senate.gov", "Banking, Housing, and Urban Affairs", "committee", "senate", "R", "insti",
         "https://www.banking.senate.gov/newsroom/majority-press-releases",
         "banking\\.senate\\.gov/newsroom/majority/"),
    list("www.banking.senate.gov", "Banking, Housing, and Urban Affairs", "committee", "senate", "D", "insti",
         "https://www.banking.senate.gov/newsroom/minority-press-releases",
         "banking\\.senate\\.gov/newsroom/minority/"),

    # ---- Senate: Commerce (WordPress front; items at /press/rep|dem/release/)
    list("www.commerce.senate.gov", "Commerce, Science, and Transportation", "committee", "senate", "R", "insti",
         "https://www.commerce.senate.gov/press/republican-news/",
         "commerce\\.senate\\.gov/press/rep/release/"),
    list("www.commerce.senate.gov", "Commerce, Science, and Transportation", "committee", "senate", "D", "insti",
         "https://www.commerce.senate.gov/press/democratic-news/",
         "commerce\\.senate\\.gov/press/dem/release/"),

    # ---- Senate: HSGAC (listings paginate client-side -> sitemap enumeration)
    list("www.hsgac.senate.gov", "Homeland Security and Governmental Affairs", "committee", "senate", "R", "sitemap",
         "https://www.hsgac.senate.gov/sitemap_index.xml",
         "hsgac\\.senate\\.gov/media/reps/"),
    list("www.hsgac.senate.gov", "Homeland Security and Governmental Affairs", "committee", "senate", "D", "sitemap",
         "https://www.hsgac.senate.gov/sitemap_index.xml",
         "hsgac\\.senate\\.gov/media/dems/"),

    # ---- Senate: HELP (chair vs ranking; JS load-more -> sitemap enumeration)
    list("www.help.senate.gov", "Health, Education, Labor, and Pensions", "committee", "senate", "R", "sitemap",
         "https://www.help.senate.gov/sitemap.xml",
         "help\\.senate\\.gov/rep/newsroom/press/"),
    list("www.help.senate.gov", "Health, Education, Labor, and Pensions", "committee", "senate", "D", "sitemap",
         "https://www.help.senate.gov/sitemap.xml",
         "help\\.senate\\.gov/dem/newsroom/press/"),

    # ---- Senate: Judiciary
    list("www.judiciary.senate.gov", "Judiciary", "committee", "senate", "R", "insti",
         "https://www.judiciary.senate.gov/press/majority",
         "judiciary\\.senate\\.gov/press/rep/releases/"),
    list("www.judiciary.senate.gov", "Judiciary", "committee", "senate", "D", "insti",
         "https://www.judiciary.senate.gov/press/minority",
         "judiciary\\.senate\\.gov/press/dem/releases/"),

    # ---- Senate: Rules (listing lacks dates)
    # The item path encodes the party that held the majority when the release
    # was published, NOT the listing it now appears under: the minority-news
    # listing is all Klobuchar-era releases whose permalinks still live under
    # /news/majority-news/. A minority-only regex therefore matched nothing and
    # the D feed collected 0 rows. Both feeds accept either path -- the two
    # listings serve disjoint item sets (verified), so party still comes from
    # the feed, which is what the schema wants.
    list("www.rules.senate.gov", "Rules and Administration", "committee", "senate", "R", "insti",
         "https://www.rules.senate.gov/news/majority-news",
         "rules\\.senate\\.gov/news/(majority|minority)-news/[a-z0-9]"),
    list("www.rules.senate.gov", "Rules and Administration", "committee", "senate", "D", "insti",
         "https://www.rules.senate.gov/news/minority-news",
         "rules\\.senate\\.gov/news/(majority|minority)-news/[a-z0-9]"),

    # ---- Senate: Small Business (CFM; relative pressreleases?ID=<GUID> items)
    list("www.sbc.senate.gov", "Small Business and Entrepreneurship", "committee", "senate", "R", "insti",
         "https://www.sbc.senate.gov/public/index.cfm/republicanpressreleases",
         "index\\.cfm/pressreleases\\?id="),
    list("www.sbc.senate.gov", "Small Business and Entrepreneurship", "committee", "senate", "D", "insti",
         "https://www.sbc.senate.gov/public/index.cfm/democraticpressreleases",
         "index\\.cfm/pressreleases\\?id="),

    # ---- Senate: Ethics (CFM; bipartisan, tiny volume)
    list("www.ethics.senate.gov", "Select Committee on Ethics", "committee", "senate", "NP", "insti",
         "https://www.ethics.senate.gov/public/index.cfm/pressreleases",
         "ethics\\.senate\\.gov/public/index\\.cfm/pressreleases\\?id="),

    # ---- Senate: drug caucus (WP; slug items under /media-center/press-releases)
    list("www.drugcaucus.senate.gov", "Caucus on International Narcotics Control", "caucus", "senate", "NP", "insti",
         "https://www.drugcaucus.senate.gov/media-center/press-releases/",
         "drugcaucus\\.senate\\.gov/(media-center/)?press-releases?/[a-z0-9]"),

    # ---- Senate party conferences: stock WP REST feed found but recent window
    # empty -- retry over full history through the package.
    list("www.republicans.senate.gov", "Senate Republican Conference", "caucus", "senate", "R", "package",
         "https://www.republicans.senate.gov", NA_character_),
    list("www.src.senate.gov", "Senate Republican Conference (src)", "caucus", "senate", "R", "package",
         "https://www.src.senate.gov", NA_character_)
  )
  df <- do.call(rbind, lapply(rows, function(r) {
    data.frame(host = r[[1]], unit = r[[2]], type = r[[3]], chamber = r[[4]],
               party = r[[5]], engine = r[[6]], listing = r[[7]], item_re = r[[8]],
               stringsAsFactors = FALSE)
  }))
  df$feed_id <- paste0(gsub("^www\\.", "", df$host), "#", tolower(df$party), "#",
                       vapply(strsplit(df$listing, "/"), function(p) p[length(p)], ""))
  df
}
