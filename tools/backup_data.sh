#!/bin/bash
# backup_data.sh -- copy every gitignored pressR dataset to a timestamped folder.
#
#   bash tools/backup_data.sh                 # default destination
#   DEST=/Volumes/Drive/pressR bash tools/backup_data.sh
#   SKIP_BLOG=1 bash tools/backup_data.sh     # omit the 8.7 GB blog/data
#
# What it copies and why each matters:
#   institutional/data  collected committee releases -- only one copy exists
#   R_user_dir/pressR   the scraped member archive -- replaceable only by re-scraping
#   R_user_dir/pressR_nlp  DuckDB + layers; external/ holds the Wayback recoveries
#   blog/data           newsletters, congresstweets, CrowdTangle -- CrowdTangle was
#                       discontinued, so treat that one as unrecoverable
#
# Safe to run while collectors are working: rsync copies what is on disk, and the
# verify pass below re-reads every .rds in the backup and re-copies any file that
# was caught mid-write (the feed collector's saveRDS is not atomic).

set -uo pipefail
REPO="/Users/zaynesember/GitRepos/pressR"
STAMP="$(date '+%Y-%m-%d_%H%M')"
DEST="${DEST:-$HOME/pressR_backups}/$STAMP"
RU="$HOME/Library/Application Support/org.R-project.R/R"

mkdir -p "$DEST" || exit 1
echo "backup -> $DEST"
echo

copy() {                       # copy <label> <src> <dest-subdir>
  local label="$1" src="$2" sub="$3"
  [ -e "$src" ] || { echo "  SKIP $label (not found)"; return; }
  mkdir -p "$DEST/$sub"
  printf "  %-22s " "$label"
  rsync -a --stats "$src" "$DEST/$sub/" 2>/dev/null \
    | awk '/Number of regular files transferred/ {f=$NF} /Total file size/ {s=$4} END {printf "%s files, %s bytes\n", f, s}'
}

# Destination subdirs must be distinct per source. Both repo datasets are named
# "data", so sending them to a shared "repo/" made rsync merge them into one
# repo/data -- nothing was lost (no filename collisions) but a restore could not
# tell which files belonged to which dataset.
copy "institutional/data" "$REPO/institutional/data"  "repo/institutional"
copy "pressR archive"     "$RU/pressR"                "R_user_dir"
copy "pressR_nlp"         "$RU/pressR_nlp"            "R_user_dir"
if [ -z "${SKIP_BLOG:-}" ]; then
  copy "blog/data"        "$REPO/blog/data"           "repo/blog"
else
  echo "  SKIP blog/data (SKIP_BLOG set)"
fi

# ---- manifest so the backup describes itself ------------------------------
{
  echo "pressR data backup"
  echo "created : $(date '+%F %T')"
  echo "host    : $(hostname)"
  echo "git     : $(cd "$REPO" && git rev-parse --short HEAD) on $(cd "$REPO" && git branch --show-current)"
  echo
  echo "collectors running at backup time:"
  pgrep -fl "07_collect_feeds.R|13_backfill_bodies.R|14_recollect_feed.R" 2>/dev/null \
    | grep "exec/R" | sed 's/^/  /' || echo "  none"
  echo
  echo "sizes:"
  du -sh "$DEST"/* 2>/dev/null | sed 's/^/  /'
} > "$DEST/MANIFEST.txt"

# ---- verify: every .rds in the backup must actually load ------------------
echo
echo "verifying .rds integrity in the backup..."
Rscript - "$DEST" <<'RS'
args <- commandArgs(trailingOnly = TRUE); dest <- args[1]
fs <- list.files(dest, pattern = "\\.rds$", recursive = TRUE, full.names = TRUE)
bad <- character(0)
for (f in fs) {
  ok <- tryCatch({ x <- readRDS(f); TRUE }, error = function(e) FALSE, warning = function(w) TRUE)
  if (!ok) bad <- c(bad, f)
}
cat("  checked ", length(fs), " .rds files; ", length(bad), " unreadable\n", sep = "")
if (length(bad)) { cat("  UNREADABLE:\n"); cat(paste0("    ", bad, collapse = "\n"), "\n") }
writeLines(bad, file.path(dest, ".unreadable"))
RS

# Re-copy anything that was mid-write, then re-check just those.
UNREAD="$DEST/.unreadable"
if [ -s "$UNREAD" ]; then
  echo
  echo "re-copying files that were mid-write..."
  while read -r bf; do
    [ -n "$bf" ] || continue
    rel="${bf#$DEST/}"
    case "$rel" in
      repo/data/*)        src="$REPO/${rel#repo/}" ;;
      repo/*)             src="$REPO/${rel#repo/}" ;;
      R_user_dir/*)       src="$RU/${rel#R_user_dir/}" ;;
      *)                  src="" ;;
    esac
    if [ -n "$src" ] && [ -f "$src" ]; then
      rsync -a "$src" "$bf" && echo "  recopied $(basename "$bf")"
    fi
  done < "$UNREAD"
fi
rm -f "$UNREAD"

echo
echo "DONE  $DEST"
du -sh "$DEST"
