#!/usr/bin/env Rscript
# Slice 5: member coordination network. Members are linked when they share a
# near-duplicate "message family" (joint statements, sign-on letters, reused
# talking points). v1 = SCRAPED source only (clean "Last, First" names, 2010-2026)
# to avoid cross-source name fragmentation; folding stout/wangtucker in via name
# canonicalization is a documented v2.
#   edge weight = sum over shared families of 1/(k-1)  (Newman co-membership
#   weighting, so a 30-member sign-on letter doesn't dominate); families with
#   >MAX_FAM members (mass sign-ons / procedural) are excluded from the dyadic
#   projection. Outputs: communities (Louvain), centrality, cross-party brokerage,
#   ideological homophily vs DW-NOMINATE, and a cross-party-coordination time series.
suppressMessages(devtools::load_all("/Users/zaynesember/GitRepos/pressR"))
source("/Users/zaynesember/GitRepos/pressR/nlp/R/00_foundation.R")
suppressMessages({ library(DBI); library(duckdb); library(data.table); library(igraph) })
t0 <- Sys.time(); OUT <- nlp_out_dir()
MAX_FAM <- 40L

# normalize a name to "surname, firstgiventoken" for fuzzy-ish joins
norm_name <- function(x) {
  x <- tolower(trimws(x))
  sur <- sub(",.*$", "", x)
  giv <- sub("^[^,]*,\\s*", "", x)
  giv1 <- sub("\\s.*$", "", giv)
  paste0(trimws(sur), ", ", trimws(giv1))
}

## ---- pull scraped family memberships + member attributes ------------------
con <- dbConnect(duckdb::duckdb(), nlp_duckdb_path(), read_only = TRUE)
mem <- as.data.table(dbGetQuery(con, "
  SELECT rf.family_id, r.name
  FROM release_family rf JOIN releases r USING(url)
  WHERE r.source = 'scraped' AND r.usable AND r.name IS NOT NULL AND rf.is_reused"))
matt <- as.data.table(dbGetQuery(con, "
  SELECT name, party, chamber, COUNT(*) n FROM releases
  WHERE source = 'scraped' AND name IS NOT NULL AND party IN ('D','R','I')
  GROUP BY 1,2,3"))
ts <- as.data.table(dbGetQuery(con, "
  SELECT CAST(EXTRACT(year FROM date_min) AS INT) yr,
    COUNT(*) FILTER (WHERE is_reused AND cross_member) n_coord,
    COUNT(*) FILTER (WHERE is_reused AND cross_member AND cross_party) n_xparty
  FROM families WHERE sources = 'scraped' AND date_min IS NOT NULL
  GROUP BY 1 HAVING CAST(EXTRACT(year FROM date_min) AS INT) BETWEEN 2010 AND 2026
  ORDER BY 1"))
dbDisconnect(con, shutdown = TRUE)
ts[, xparty_share := round(n_xparty / n_coord, 3)]

# member-level modal party / chamber
setorder(matt, name, -n)
mp <- matt[, .(party = party[1], chamber = chamber[1]), by = name]

## ---- project families -> weighted member edges ----------------------------
mem <- unique(mem[, .(family_id, name)])
fk  <- mem[, .(k = .N), by = family_id]
mem <- merge(mem, fk, by = "family_id")[k >= 2 & k <= MAX_FAM]
pr  <- merge(mem, mem[, .(family_id, name)], by = "family_id",
             allow.cartesian = TRUE, suffixes = c("", "2"))[name < name2]
pr[, w := 1 / (k - 1)]
edges <- pr[, .(weight = sum(w), n_families = .N), by = .(a = name, b = name2)]
message(sprintf("  %s members in %s families -> %s edges",
  format(uniqueN(mem$name), big.mark=","), format(uniqueN(mem$family_id), big.mark=","),
  format(nrow(edges), big.mark=",")))

## ---- igraph metrics + communities -----------------------------------------
g <- graph_from_data_frame(edges[, .(a, b, weight, n_families)], directed = FALSE)
E(g)$dist <- 1 / E(g)$weight                      # strong tie = short path
V(g)$party   <- mp$party[match(V(g)$name, mp$name)]
V(g)$chamber <- mp$chamber[match(V(g)$name, mp$name)]
comm <- cluster_louvain(g, weights = E(g)$weight)
V(g)$community   <- as.integer(membership(comm))
V(g)$strength    <- strength(g, weights = E(g)$weight)
V(g)$degree      <- degree(g)
V(g)$betweenness <- betweenness(g, weights = E(g)$dist, directed = FALSE)
V(g)$eigen       <- eigen_centrality(g, weights = E(g)$weight)$vector

# per-edge + per-member cross-party coordination
el <- as.data.table(igraph::as_data_frame(g, "edges"))
el[, pa := mp$party[match(from, mp$name)]]
el[, pb := mp$party[match(to,   mp$name)]]
el[, cross_party := pa != pb & pa %in% c("D","R") & pb %in% c("D","R")]
cp <- rbind(el[, .(name = from, w = weight, cp = cross_party)],
            el[, .(name = to,   w = weight, cp = cross_party)])
cpm <- cp[, .(cross_party_strength = sum(w * cp), tot = sum(w)), by = name]
cpm[, cross_party_share := round(cross_party_strength / tot, 3)]

## ---- attach DW-NOMINATE (latest term per member) --------------------------
vv <- fread(file.path(OUT, "voteview_members.csv"),
            select = c("congress","bioname","nominate_dim1"))
vv <- vv[!is.na(nominate_dim1)]
vv[, key := norm_name(bioname)]
setorder(vv, key, congress)
vnom <- vv[, .(nominate = nominate_dim1[.N]), by = key]     # latest congress

nodes <- data.table(
  name = V(g)$name, party = V(g)$party, chamber = V(g)$chamber,
  community = V(g)$community, degree = V(g)$degree,
  strength = round(V(g)$strength, 2), betweenness = round(V(g)$betweenness, 1),
  eigen = round(V(g)$eigen, 3))
nodes <- merge(nodes, cpm[, .(name, cross_party_strength = round(cross_party_strength, 2),
                              cross_party_share)], by = "name", all.x = TRUE)
nodes[, key := norm_name(name)]
nodes <- merge(nodes, vnom, by = "key", all.x = TRUE)[, key := NULL]

## ---- summary stats --------------------------------------------------------
nomv <- nodes$nominate[match(V(g)$name, nodes$name)]
assort_party <- assortativity_nominal(g, as.integer(factor(V(g)$party)), directed = FALSE)
# ideological homophily: assortativity() can't take NAs -> compute on the matched subgraph
matched <- which(!is.na(nomv))
assort_nom <- assortativity(igraph::induced_subgraph(g, matched), nomv[matched], directed = FALSE)
summ <- data.table(
  n_nodes = vcount(g), n_edges = ecount(g),
  n_communities = max(nodes$community),
  modularity = round(modularity(comm), 3),
  assort_party = round(assort_party, 3),       # +1 = party-homophilous, 0 = random
  assort_nominate = round(assort_nom, 3),
  pct_edges_crossparty = round(100 * mean(el$cross_party), 1),
  nominate_matched = sum(!is.na(nodes$nominate)))

## ---- persist (duckdb tables + rds) ----------------------------------------
edges_out <- el[, .(a = from, b = to, weight = round(weight, 3), n_families,
                    cross_party)]
con <- dbConnect(duckdb::duckdb(), nlp_duckdb_path())
dbWriteTable(con, "network_nodes", as.data.frame(nodes),     overwrite = TRUE)
dbWriteTable(con, "network_edges", as.data.frame(edges_out), overwrite = TRUE)
dbWriteTable(con, "network_ts",    as.data.frame(ts),        overwrite = TRUE)
dbWriteTable(con, "network_summary", as.data.frame(summ),    overwrite = TRUE)
dbDisconnect(con, shutdown = TRUE)
saveRDS(list(nodes = nodes, edges = edges_out, ts = ts, summary = summ),
        file.path(OUT, "network.rds"))

cat("\n================ COORDINATION NETWORK (scraped v1) ================\n")
print(summ)
cat("\nTop 15 cross-party brokers (most coordination weight reaching the other party):\n")
brk <- nodes[party %in% c("D","R")][order(-cross_party_strength)][1:15,
  .(name, party, chamber, community, betweenness, cross_party_strength, cross_party_share,
    nominate)]
print(brk)
cat("\nCommunity sizes (top 8) + party mix:\n")
cm <- nodes[, .(n = .N, D = sum(party=="D"), R = sum(party=="R"), I = sum(party=="I")),
            by = community][order(-n)][1:8]
print(cm)
cat(sprintf("\nartifacts: network.rds, duckdb network_nodes/edges/ts/summary\n"))
cat(sprintf("done in %.1f min\n", as.numeric(difftime(Sys.time(), t0, units = "mins"))))
