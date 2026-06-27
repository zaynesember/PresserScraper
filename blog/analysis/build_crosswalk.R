# Option 3, step A — build a universal member crosswalk from unitedstates/
# congress-legislators. Self-contained: fetches + caches the source files, then
# writes, in blog/analysis/:
#   member_crosswalk.csv  bioguide, icpsr, last, first, state, party, chamber
#   member_handles.csv    bioguide, handle   (one row per twitter handle, lc)
# These resolve all four media to a single bioguide key:
#   newsletters = BioGuide direct | FB = icpsr | tweets = handle | PR = name+state
suppressMessages({ library(data.table); library(jsonlite); library(stringi) })
OUT   <- "/Users/zaynesember/GitRepos/pressR/blog/analysis"
CACHE <- "/Users/zaynesember/GitRepos/pressR/blog/data/congress-legislators"  # gitignored cache
dir.create(CACHE, showWarnings=FALSE, recursive=TRUE)
BASE  <- "https://unitedstates.github.io/congress-legislators/"
files <- c(cur="legislators-current.csv", his="legislators-historical.csv", soc="legislators-social-media.json")
for (f in files) { dst <- file.path(CACHE, f)
  if (!file.exists(dst)) { message("downloading ", f); download.file(paste0(BASE, f), dst, quiet=TRUE) } }

keep <- c("last_name","first_name","type","state","party","twitter","twitter_id","bioguide_id","icpsr_id")
leg <- rbind(fread(file.path(CACHE, files["cur"]), select=keep),
             fread(file.path(CACHE, files["his"]), select=keep))
leg <- leg[bioguide_id != ""][!duplicated(bioguide_id)]      # one identity row per member

norm <- function(x) stri_trans_general(stri_trans_tolower(stri_trim_both(x)), "Latin-ASCII")
xw <- leg[, .(
  bioguide = bioguide_id,
  icpsr    = suppressWarnings(as.integer(icpsr_id)),
  last     = norm(last_name),
  first    = norm(first_name),
  state,
  party    = fcase(party=="Democrat","D", party=="Republican","R", default="O"),
  chamber  = fcase(type=="sen","Senate", type=="rep","House", default=type))]
fwrite(xw, file.path(OUT,"member_crosswalk.csv"))

# handle map: union of social.json + the CSV twitter columns
soc <- fromJSON(file.path(CACHE, files["soc"]))
handles <- rbind(data.table(bioguide=soc$id$bioguide, handle=soc$social$twitter),
                 leg[twitter!="", .(bioguide=bioguide_id, handle=twitter)])
handles <- handles[!is.na(handle) & handle!=""]
handles[, handle := stri_trans_tolower(stri_replace_all_regex(handle,"^@",""))]
handles <- unique(handles)
fwrite(handles, file.path(OUT,"member_handles.csv"))

cat("members:", nrow(xw), "| with icpsr:", sum(!is.na(xw$icpsr)),
    "| D/R:", sum(xw$party %in% c("D","R")), "\n")
cat("handles:", nrow(handles), "| distinct members with a handle:", uniqueN(handles$bioguide), "\n")
cat("chambers:\n"); print(table(xw$chamber))
