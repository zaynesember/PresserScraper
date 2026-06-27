# Option 3 — member-matched cross-modal control (breadth: members in >=2 media).
# Purpose: are findings 3-4 (D>R sentence-length gap; PR>newsletters>tweets>FB
# ordering) a MEMBER-COMPOSITION artifact (each medium = different accounts)?
# Build a member(bioguide) x medium panel of mean words/sentence over 2019-2023,
# then (1) within-member medium effects, (2) partisan gap on a shared roster,
# (3) individual-style stability across media.
suppressMessages({ library(DBI); library(duckdb); library(data.table); library(ggplot2)
  library(quanteda); library(quanteda.textstats); library(jsonlite); library(stringi); library(patchwork) })
set.seed(1)
OUT <- "/Users/zaynesember/GitRepos/pressR/blog/analysis"
FIG <- "/Users/zaynesember/GitRepos/pressR/blog/figures"
DB  <- path.expand("~/Library/Application Support/org.R-project.R/R/pressR_nlp/press.duckdb")
WIN <- 2019:2023
norm  <- function(x) stri_trans_general(stri_trans_tolower(stri_trim_both(x)), "Latin-ASCII")
clean <- function(t){ t<-ifelse(is.na(t),"",t); t<-stri_replace_all_regex(t,"https?://\\S+|www\\.\\S+"," ")
  t<-stri_replace_all_regex(t,"[@#]\\w+"," "); t<-stri_replace_all_fixed(t,"&amp;","and")
  stri_trim_both(stri_replace_all_regex(t,"\\s+"," ")) }
wps_of <- function(txt) textstat_readability(corpus(txt), measure="meanSentenceLength")$meanSentenceLength
SUF <- c("jr","sr","ii","iii","iv","v")

## ---- crosswalk + name matcher --------------------------------------------
xw <- fread(file.path(OUT,"member_crosswalk.csv"))
xw[, `:=`(last=norm(last), first=norm(first), fi=substr(norm(first),1,1), state=toupper(state))]
handles <- fread(file.path(OUT,"member_handles.csv"))
bmap <- setNames(handles$bioguide, handles$handle)        # handle -> bioguide (named vector)
# uniqueness-aware candidate maps
uniq <- function(by) { d <- xw[, .N, by=by][N==1][, N:=NULL]; merge(d, xw[,.(bioguide, last, first, fi, state)], by=by) }
m_lfs <- xw[!duplicated(paste(last,first,state)), .(bioguide,last,first,state)]   # exact (assume ~unique)
m_lf  <- uniq(c("last","first")); m_ls <- uniq(c("last","state")); m_lfis <- uniq(c("last","fi","state"))
resolve <- function(last, first, state=NA_character_) {
  q <- data.table(idx=seq_along(last), last=norm(last), first=norm(first), fi=substr(norm(first),1,1),
                  state=toupper(ifelse(is.na(state),"",state)), bio=NA_character_)
  hit <- function(q, m, by) { u <- q[is.na(bio)]; if(!nrow(u)) return(q)
    j <- merge(u[,!"bio"], m, by=by, all.x=TRUE); q[match(j$idx, q$idx), bio := j$bioguide]; q }
  q <- hit(q, m_lfs[,.(last,first,state,bioguide)], c("last","first","state"))
  q <- hit(q, m_lf[,.(last,first,bioguide)],        c("last","first"))
  q <- hit(q, m_lfis[,.(last,fi,state,bioguide)],   c("last","fi","state"))
  q <- hit(q, m_ls[,.(last,state,bioguide)],        c("last","state"))
  q$bio }
parse_last_first <- function(name) {        # "First [Middle] Last [Suffix]"
  toks <- strsplit(norm(name), "\\s+");
  list(first=vapply(toks, function(t) t[1], ""),
       last =vapply(toks, function(t){ t<-t[!t %in% SUF]; t[length(t)] }, ""))
}

## ---- TWEET handle -> bioguide (direct handle, then name fallback) ---------
ct <- fromJSON("/Users/zaynesember/GitRepos/pressR/blog/analysis/congresstweets_handle_party_crosswalk.json",
               simplifyDataFrame=FALSE)
ctmem <- rbindlist(lapply(ct, function(e){ if (is.null(e$type)||e$type!="member") return(NULL)
  rbindlist(lapply(e$accounts, function(a) list(handle=tolower(a$screen_name), name=e$name))) }))
pf <- parse_last_first(ctmem$name)
ctmem[, bio := bmap[handle]]                                    # direct handle match
miss <- is.na(ctmem$bio)
ctmem[miss, bio := resolve(pf$last[miss], pf$first[miss])]      # name fallback
sn2bio <- ctmem[!is.na(bio) & !duplicated(handle)]; sb <- setNames(sn2bio$bio, sn2bio$handle)
cat(sprintf("tweet handles resolved: %d / %d (%.0f%%)\n", sum(!is.na(ctmem$bio)), nrow(ctmem),
            100*mean(!is.na(ctmem$bio))))

## ---- PRESS RELEASES: per-member wps from DuckDB (sent_len precomputed) ----
con <- dbConnect(duckdb::duckdb(), DB, read_only=TRUE)
pr <- as.data.table(dbGetQuery(con, sprintf(
  "SELECT r.name, r.state, AVG(rd.sent_len) wps, COUNT(*) n FROM readability rd JOIN releases r ON rd.url=r.url
   WHERE rd.source='scraped' AND rd.year BETWEEN %d AND %d AND rd.sent_len IS NOT NULL AND r.name IS NOT NULL
   GROUP BY r.name, r.state", min(WIN), max(WIN))))
dbDisconnect(con, shutdown=TRUE)
ab <- setNames(state.abb, toupper(state.name)); ab["DISTRICT OF COLUMBIA"]<-"DC"
pr[, st2 := ifelse(nchar(state)==2, toupper(state), ab[toupper(state)])]
pr[, last  := norm(sub(",.*$","",name))]                                # "Last, First" -> full last before comma
pr[, first := norm(sub("^[^,]*,\\s*","",name))]; pr[, first := vapply(strsplit(first,"\\s+"), `[`, "", 1)]
pr[, bio := resolve(last, first, st2)]
cat(sprintf("PR members resolved: %d / %d (%.0f%%)\n", uniqueN(pr[!is.na(bio)]$bio), nrow(pr), 100*mean(!is.na(pr$bio))))
pr_m <- pr[!is.na(bio), .(wps=weighted.mean(wps,n), n=sum(n)), by=bio][, medium:="Press releases"]

## ---- NEWSLETTERS: bioguide direct ----------------------------------------
nl <- fread("/Users/zaynesember/GitRepos/pressR/blog/data/Newsletters_111th_to_118th_Nov2024.csv",
            select=c("Body","BioGuide ID","Unix Timestamp"))
setnames(nl, c("BioGuide ID","Unix Timestamp"), c("bio","ts"))
nl[, yr := as.integer(format(as.POSIXct(ts/1000, origin="1970-01-01"),"%Y"))]
nl <- nl[!is.na(bio) & bio!="" & nchar(Body)>300 & yr %in% WIN]
if (nrow(nl) > 70000) nl <- nl[sample(.N, 70000)]
nl[, wps := wps_of(Body)]
nl_m <- nl[is.finite(wps)&wps>1&wps<80, .(wps=mean(wps), n=.N), by=bio][, medium:="Newsletters"]
cat(sprintf("newsletters: %d docs -> %d members\n", nrow(nl), nrow(nl_m)))

## ---- FACEBOOK: icpsr -> bioguide -----------------------------------------
fb <- as.data.table(readRDS("/Users/zaynesember/GitRepos/pressR/blog/data/CrowdTangle/facebook_posts_w_metadata.rds"))
fb[, yr := suppressWarnings(as.integer(year))]
fb <- fb[yr %in% WIN & !is.na(Message) & nchar(Message)>40 & !is.na(icpsr)]
if (nrow(fb) > 130000) fb <- fb[sample(.N, 130000)]
fb[, ctext := clean(Message)]; fb <- fb[nchar(ctext)>15]
fb[, wps := wps_of(ctext)]
i2b <- xw[!is.na(icpsr) & !duplicated(icpsr)]; ib <- setNames(i2b$bioguide, as.character(as.integer(i2b$icpsr)))
fb[, bio := ib[as.character(as.integer(icpsr))]]
fb_m <- fb[is.finite(wps)&wps>1&wps<80 & !is.na(bio), .(wps=mean(wps), n=.N), by=bio][, medium:="Facebook"]
cat(sprintf("FB: %d docs -> %d members (icpsr match %.0f%%)\n", nrow(fb), nrow(fb_m), 100*mean(!is.na(fb$bio))))

## ---- TWEETS: handle -> bioguide ------------------------------------------
allf <- list.files("/Users/zaynesember/GitRepos/pressR/blog/data/congresstweets_115_118_tweets/JSONs", full.names=TRUE)
fyr <- as.integer(substr(basename(allf),1,4)); allf <- allf[fyr %in% WIN]
sel <- unlist(lapply(split(allf, fyr[fyr %in% WIN]), function(fs) sample(fs, min(length(fs),70))))
tw <- rbindlist(lapply(sel, function(f){ d<-tryCatch(as.data.table(fromJSON(f)),error=function(e) NULL)
  if (is.null(d)||!"text"%in%names(d)) return(NULL); d[, .(handle=tolower(screen_name), text)] }), fill=TRUE)
tw <- tw[!grepl("^RT @", text) & nchar(text)>15]
tw[, bio := sb[handle]]; tw <- tw[!is.na(bio)]
tw[, ctext := clean(text)]; tw <- tw[nchar(ctext)>15]
tw[, wps := wps_of(ctext)]
tw_m <- tw[is.finite(wps)&wps>1&wps<80, .(wps=mean(wps), n=.N), by=bio][, medium:="Tweets"]
cat(sprintf("tweets: %d docs -> %d members\n", nrow(tw), nrow(tw_m)))

## ---- PANEL: bioguide x medium --------------------------------------------
MIN <- c(`Press releases`=10, Newsletters=5, Facebook=10, Tweets=30)
panel <- rbindlist(list(pr_m, nl_m, fb_m, tw_m))
panel <- panel[n >= MIN[medium]]
panel <- merge(panel, xw[, .(bio=bioguide, party, chamber)], by="bio")
panel <- panel[party %in% c("D","R")]
panel[, nmed := uniqueN(medium), by=bio]
saveRDS(panel, file.path(FIG,"xmodal_panel.rds"))
cat("\n=== members per medium (panel, n>=min) ===\n"); print(panel[, .(members=uniqueN(bio)), by=medium])
cat("\n=== members by # media present ===\n"); print(unique(panel[, .(bio, nmed)])[, .(members=.N), by=nmed][order(nmed)])
cat("\nPanel saved -> xmodal_panel.rds. Run blog/analysis/xmodal_figs.R for analyses + figures.\n")
