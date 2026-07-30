# 02_feed_configs.R -- NARA feed configs, tier A (the institutional holes).
# Sourced by 03_walk.R / 04_extract.R / 05_stage.R; not run directly.
#
# Schema per feed (one row = one unit x one congress snapshot):
#   feed_id     c{congress}#{host}#{party-lowercase} -- names the walk output
#   congress    which harvest to walk
#   listing     ORIGINAL listing URL (never a replay URL)
#   item_re     matched against STRIPPED original URLs
#   engine      walk | cfm_monthyear (query pagination vs Month/Year sweep)
#   years       cfm_monthyear only: years to enumerate
#   party_feed  R / D / NP / MAJ / ALL -- same vocab as institutional configs
#               (NP joint-bipartisan, ALL unbranded-combined; both -> party NA;
#                MAJ resolved by chamber_majority at release date in 05)
#   name/unit/type/chamber  staging metadata, matching the live institutional
#               conventions EXACTLY so NARA rows land beside live rows
#
# Tier-A rationale (evidence in SCOPING-nara-crawler.md + live-corpus checks):
#   aging       live corpus has 1-3 rows/yr for 2007-2011 and nothing before;
#               the 112th snapshot's CFM archive covers everything to 2012.
#               109th sweep = insurance against pre-2012 pruning.
#   jec         live D(minority) feed starts 2026 (R side goes to 2003); the
#               archived MAIN site is the chair/D side in the 113th. Party
#               stays ALL -> NA (the archived feed is not cleanly branded).
#   drugcaucus  live corpus holds SIX rows (2022-24). Drupal /content/ slugs,
#               ?page=N pagination, confirmed in the 115th snapshot.
#   energycommerce  majority site is a Next.js SPA the live collector cannot
#               walk (58 posts total, 49 unreachable). The 118th snapshot is a
#               PROBE: if it predates the SPA it opens the whole majority
#               archive; if it is the SPA, expect a thin walk and move on.

nara_feed_configs <- function() {
  L <- list(
    list(feed_id = "c112#aging.senate.gov#all", congress = 112L,
         host = "aging.senate.gov",
         unit = "Special Committee on Aging",
         name = "Senate Committee on Special Committee on Aging",
         type = "committee", chamber = "senate", party_feed = "ALL",
         listing = "http://aging.senate.gov/public/index.cfm?FuseAction=PressReleases.Home",
         item_re = "FuseAction=PressReleases[.]Detail",
         engine = "cfm_monthyear", years = 1997:2012, page_limit = 200L),
    list(feed_id = "c109#aging.senate.gov#all", congress = 109L,
         host = "aging.senate.gov",
         unit = "Special Committee on Aging",
         name = "Senate Committee on Special Committee on Aging",
         type = "committee", chamber = "senate", party_feed = "ALL",
         listing = "http://aging.senate.gov/public/index.cfm?FuseAction=PressReleases.Home",
         item_re = "FuseAction=PressReleases[.]Detail",
         engine = "cfm_monthyear", years = 1997:2006, page_limit = 200L),

    list(feed_id = "c113#jec.senate.gov#all", congress = 113L,
         host = "www.jec.senate.gov",
         unit = "Joint Economic Committee",
         name = "Joint Committee on Joint Economic Committee",
         type = "committee", chamber = "joint", party_feed = "ALL",
         listing = "http://www.jec.senate.gov/public/index.cfm?p=PressReleases",
         item_re = "ContentRecord_id=[0-9a-fA-F][0-9a-fA-F-]{30,}",
         engine = "walk", years = NULL, page_limit = 200L),

    list(feed_id = "c117#drugcaucus.senate.gov#np", congress = 117L,
         host = "www.drugcaucus.senate.gov",
         unit = "Caucus on International Narcotics Control",
         name = "Caucus on International Narcotics Control",
         type = "caucus", chamber = "senate", party_feed = "NP",
         listing = "https://www.drugcaucus.senate.gov/press-releases",
         item_re = "drugcaucus[.]senate[.]gov/content/[a-z0-9][a-z0-9%_-]{15,}",
         engine = "walk", years = NULL, page_limit = 60L),
    list(feed_id = "c115#drugcaucus.senate.gov#np", congress = 115L,
         host = "www.drugcaucus.senate.gov",
         unit = "Caucus on International Narcotics Control",
         name = "Caucus on International Narcotics Control",
         type = "caucus", chamber = "senate", party_feed = "NP",
         listing = "https://www.drugcaucus.senate.gov/press-releases",
         item_re = "drugcaucus[.]senate[.]gov/content/[a-z0-9][a-z0-9%_-]{15,}",
         engine = "walk", years = NULL, page_limit = 60L),
    list(feed_id = "c113#drugcaucus.senate.gov#np", congress = 113L,
         host = "www.drugcaucus.senate.gov",
         unit = "Caucus on International Narcotics Control",
         name = "Caucus on International Narcotics Control",
         type = "caucus", chamber = "senate", party_feed = "NP",
         listing = "http://www.drugcaucus.senate.gov/press-releases",
         item_re = "drugcaucus[.]senate[.]gov/content/[a-z0-9][a-z0-9%_-]{15,}",
         engine = "walk", years = NULL, page_limit = 60L),

    list(feed_id = "c118#energycommerce.house.gov#maj", congress = 118L,
         host = "energycommerce.house.gov",
         unit = "Energy and Commerce",
         name = "House Committee on Energy and Commerce",
         type = "committee", chamber = "house", party_feed = "MAJ",
         listing = "https://energycommerce.house.gov/news",
         item_re = "energycommerce[.]house[.]gov/news/[a-z0-9][a-z0-9-]{15,}",
         engine = "walk", years = NULL, page_limit = 200L)
  )
  do.call(rbind, lapply(L, function(x) {
    x$years <- if (is.null(x$years)) NA_character_ else paste(range(x$years), collapse = ":")
    as.data.frame(x, stringsAsFactors = FALSE)
  }))
}

nara_config_years <- function(cfg_row) {
  if (is.na(cfg_row$years)) return(integer(0))
  r <- as.integer(strsplit(cfg_row$years, ":", fixed = TRUE)[[1]])
  seq(r[1], r[2])
}
