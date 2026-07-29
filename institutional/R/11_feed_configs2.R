# 11_feed_configs2.R -- second-round feed configs, curated from the
# 10_qa_thin_hosts.R probe digest: hosts whose Tier-1 haul was a single
# listing page (pagination undiscoverable by the stock extractors).
#
# party codes: R / D / NP (joint-bipartisan) / MAJ (majority-at-date, resolve
# at fold-in) / ALL (unbranded combined feed; leave party NA at fold-in).

feed_configs <- function() {
  rows <- list(
    # ---- House committees --------------------------------------------------
    list("appropriations.house.gov", "Appropriations", "committee", "house", "MAJ", "insti",
         "https://appropriations.house.gov/news/press-releases",
         "appropriations\\.house\\.gov/news/press-releases/[a-z0-9]"),
    list("transportation.house.gov", "Transportation and Infrastructure", "committee", "house", "MAJ", "insti",
         "https://transportation.house.gov/news/documentquery.aspx?DocumentTypeID=2545",
         "transportation\\.house\\.gov/news/documentsingle\\.aspx\\?"),
    list("oversight.house.gov", "Oversight and Government Reform", "committee", "house", "MAJ", "insti",
         "https://oversight.house.gov/release",
         "oversight\\.house\\.gov/release/[a-z0-9]"),
    list("ethics.house.gov", "Ethics", "committee", "house", "NP", "insti",
         "https://ethics.house.gov/press-releases/",
         "ethics\\.house\\.gov/press-releases/[a-z0-9]"),
    list("intelligence.house.gov", "Permanent Select Committee on Intelligence", "committee", "house", "MAJ", "insti",
         "https://intelligence.house.gov/category/press-releases/",
         "intelligence\\.house\\.gov/20[0-9]{2}/[0-9]"),

    # ---- House minority sites ----------------------------------------------
    list("democrats-foreignaffairs.house.gov", "Foreign Affairs", "committee", "house", "D", "insti",
         "https://democrats-foreignaffairs.house.gov/news-dems",
         "democrats-foreignaffairs\\.house\\.gov/press-releases\\?"),
    list("democrats-armedservices.house.gov", "Armed Services", "committee", "house", "D", "insti",
         "https://democrats-armedservices.house.gov/press-releases",
         "democrats-armedservices\\.house\\.gov/press-releases\\?"),
    list("democrats-homeland.house.gov", "Homeland Security", "committee", "house", "D", "insti",
         "https://democrats-homeland.house.gov/news/press-releases",
         "democrats-homeland\\.house\\.gov/news/press-releases/[a-z0-9]"),
    list("democrats-edworkforce.house.gov", "Education and Workforce", "committee", "house", "D", "insti",
         "https://democrats-edworkforce.house.gov/media/press-releases/",
         "democrats-edworkforce\\.house\\.gov/media/press-releases/[a-z0-9]"),
    list("democrats-cha.house.gov", "House Administration", "committee", "house", "D", "insti",
         "https://democrats-cha.house.gov/media/press-releases",
         "democrats-cha\\.house\\.gov/media/press-releases/[a-z0-9]"),

    # ---- Senate committees: chair/ranking feed pairs -----------------------
    list("www.finance.senate.gov", "Finance", "committee", "senate", "R", "insti",
         "https://www.finance.senate.gov/chairmans-news",
         "finance\\.senate\\.gov/chairmans-news/[a-z0-9]"),
    list("www.finance.senate.gov", "Finance", "committee", "senate", "D", "insti",
         "https://www.finance.senate.gov/ranking-members-news",
         "finance\\.senate\\.gov/ranking-members-news/[a-z0-9]"),
    list("www.indian.senate.gov", "Indian Affairs", "committee", "senate", "R", "insti",
         "https://www.indian.senate.gov/newsroom/republican-news/",
         "indian\\.senate\\.gov/newsroom/press-release/republican/"),
    list("www.indian.senate.gov", "Indian Affairs", "committee", "senate", "D", "insti",
         "https://www.indian.senate.gov/newsroom/democratic-news/",
         "indian\\.senate\\.gov/newsroom/press-release/democratic/"),
    list("www.appropriations.senate.gov", "Appropriations", "committee", "senate", "R", "insti",
         "https://www.appropriations.senate.gov/news/majority",
         "appropriations\\.senate\\.gov/news/majority/[a-z0-9]"),
    list("www.appropriations.senate.gov", "Appropriations", "committee", "senate", "D", "insti",
         "https://www.appropriations.senate.gov/news/minority",
         "appropriations\\.senate\\.gov/news/minority/[a-z0-9]"),
    list("www.foreign.senate.gov", "Foreign Relations", "committee", "senate", "R", "insti",
         "https://www.foreign.senate.gov/press/chair",
         "foreign\\.senate\\.gov/press/rep/release/"),
    list("www.foreign.senate.gov", "Foreign Relations", "committee", "senate", "D", "insti",
         "https://www.foreign.senate.gov/press/ranking",
         "foreign\\.senate\\.gov/press/dem/release/"),
    list("www.agriculture.senate.gov", "Agriculture, Nutrition, and Forestry", "committee", "senate", "R", "insti",
         "https://www.agriculture.senate.gov/newsroom/majority-news",
         "agriculture\\.senate\\.gov/newsroom/rep/press/release/"),
    list("www.agriculture.senate.gov", "Agriculture, Nutrition, and Forestry", "committee", "senate", "D", "insti",
         "https://www.agriculture.senate.gov/newsroom/minority-news",
         "agriculture\\.senate\\.gov/newsroom/dem/press/release/"),
    list("www.epw.senate.gov", "Environment and Public Works", "committee", "senate", "R", "insti",
         "https://www.epw.senate.gov/public/index.cfm/press-releases-republican",
         "index\\.cfm/press-releases-republican\\?id="),
    list("www.epw.senate.gov", "Environment and Public Works", "committee", "senate", "D", "insti",
         "https://www.epw.senate.gov/public/index.cfm/press-releases-democratic",
         "index\\.cfm/press-releases-democratic\\?id="),
    list("www.veterans.senate.gov", "Veterans' Affairs", "committee", "senate", "R", "insti",
         "https://www.veterans.senate.gov/majority-news",
         "veterans\\.senate\\.gov/20[0-9]{2}/[0-9]"),
    list("www.veterans.senate.gov", "Veterans' Affairs", "committee", "senate", "D", "insti",
         "https://www.veterans.senate.gov/minority-news",
         "veterans\\.senate\\.gov/20[0-9]{2}/[0-9]"),
    # /<role>/newsroom is a hub that teases 5 recent items and does not
    # paginate; the archive behind its "All Press" link does (PageNum_rs). The
    # hub URL collected 5 items per feed in 0.1 min and looked like a finished
    # feed. Use the archive path, without the ?type= filter -- it returns the
    # same set as ?type=press_release and does not depend on the query param.
    list("www.budget.senate.gov", "Budget", "committee", "senate", "R", "insti",
         "https://www.budget.senate.gov/chairman/newsroom/press/",
         "budget\\.senate\\.gov/chairman/newsroom/press/[a-z0-9]"),
    list("www.budget.senate.gov", "Budget", "committee", "senate", "D", "insti",
         "https://www.budget.senate.gov/ranking-member/newsroom/press/",
         "budget\\.senate\\.gov/ranking-member/newsroom/press/[a-z0-9]"),
    list("www.energy.senate.gov", "Energy and Natural Resources", "committee", "senate", "R", "insti",
         "https://www.energy.senate.gov/republican-news",
         "energy\\.senate\\.gov/20[0-9]{2}/[0-9]"),
    list("www.energy.senate.gov", "Energy and Natural Resources", "committee", "senate", "D", "insti",
         "https://www.energy.senate.gov/democratic-news",
         "energy\\.senate\\.gov/20[0-9]{2}/[0-9]"),
    list("www.armed-services.senate.gov", "Armed Services", "committee", "senate", "ALL", "insti",
         "https://www.armed-services.senate.gov/press-releases",
         "armed-services\\.senate\\.gov/press-releases/[a-z0-9]"),
    list("www.jec.senate.gov", "Joint Economic Committee", "committee", "joint", "R", "insti",
         "https://www.jec.senate.gov/public/index.cfm/republicans/newsroom",
         "index\\.cfm/republicans/newsroom\\?id="),
    list("www.jec.senate.gov", "Joint Economic Committee", "committee", "joint", "D", "insti",
         "https://www.jec.senate.gov/public/index.cfm/democrats/press-releases",
         "index\\.cfm/democrats/press-releases\\?id="),

    # ---- Senate Democratic caucus (democraticleader/dpcc redirect here) ----
    list("www.democrats.senate.gov", "Senate Democratic Caucus", "caucus", "senate", "D", "insti",
         "https://www.democrats.senate.gov/newsroom/press-releases",
         "democrats\\.senate\\.gov/newsroom/press-releases/[a-z0-9]")
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
