#!/bin/bash
# run_overnight.sh -- unattended closing sequence for the institutional
# collection. Waits for every running job to drain, then:
#
#   1. --audit-pagers over ALL hosts (the earlier audit skipped the busy five)
#   2. re-collects whatever the audit flags (minus feeds already verified as
#      genuinely small -- the audit heuristic cannot tell "capped at one page"
#      from "fits on one page", so re-verified feeds are whitelisted)
#   3. backfills bodies on any feed under 70% coverage with >=10 rows
#   4. final --sweep
#   5. 09_assemble.R -> institutional_releases.rds
#   6. writes a consolidated report to ~/institutional_logs/overnight_report.txt
#      and touches ~/institutional_logs/overnight.done
#
# DELIBERATELY NOT HERE: the fold-in (nlp/run_foldin.sh). It rebuilds DuckDB and
# every layer over hours and the standing instruction is to launch it only on an
# explicit go-ahead with final counts in hand.
#
# Run detached:  nohup bash institutional/run_overnight.sh > ~/institutional_logs/overnight.log 2>&1 &

set -uo pipefail
REPO="/Users/zaynesember/GitRepos/pressR"
RDIR="$REPO/institutional/R"
LOGDIR="$HOME/institutional_logs"
REPORT="$LOGDIR/overnight_report.txt"
mkdir -p "$LOGDIR"
rm -f "$LOGDIR/overnight.done"

log() { echo "[$(date '+%F %T')] $*"; }

busy() {
  pgrep -f "exec/R.*(07_collect_feeds|14_recollect_feed|13_backfill_bodies)" >/dev/null 2>&1 \
    || pgrep -f "audit-pagers" >/dev/null 2>&1
}

log "waiting for running jobs to drain..."
while busy; do sleep 120; done
log "all jobs drained"

# ---- 1. full pager audit ----------------------------------------------------
log "running full --audit-pagers"
caffeinate -is Rscript "$RDIR/12_diagnose_thin_feeds.R" --audit-pagers \
  > "$LOGDIR/audit_final.log" 2>&1
log "audit done: $(grep -oE '^[0-9]+ feed\(s\) need re-collection' "$LOGDIR/audit_final.log" | tail -1)"

# ---- 2. re-collect what it flags ---------------------------------------------
# Whitelist: flagged before and re-verified as genuinely small (same counts on a
# re-walk with the fixed pager), so flagging them again is a known false alarm.
WHITELIST="rules.senate.gov#r#majority-news budget.senate.gov#r#press"
cmdline=$(grep '14_recollect_feed.R' "$LOGDIR/audit_final.log" | tail -1 || true)
targets=()
if [ -n "$cmdline" ]; then
  while IFS= read -r id; do
    skip=0
    for w in $WHITELIST; do [ "$id" = "$w" ] && skip=1; done
    [ "$skip" = "1" ] && { log "  whitelisted (re-verified small): $id"; continue; }
    targets+=("$id")
  done < <(grep -oE '"[^"]+"' <<<"$cmdline" | tr -d '"')
fi
if [ "${#targets[@]}" -gt 0 ]; then
  log "re-collecting ${#targets[@]} flagged feed(s): ${targets[*]}"
  caffeinate -is Rscript "$RDIR/14_recollect_feed.R" "${targets[@]}" \
    > "$LOGDIR/recollect_overnight.log" 2>&1
  log "re-collection done"
else
  log "nothing to re-collect"
fi

# ---- 3. backfill low-coverage feeds ------------------------------------------
log "computing body-backfill targets (<70% coverage, >=10 rows)"
Rscript - > "$LOGDIR/backfill_targets.txt" 2>/dev/null <<'RS'
RAW <- "/Users/zaynesember/GitRepos/pressR/institutional/data/raw"
for (f in list.files(RAW, pattern = "^feed_.*[.]rds$")) {
  x <- tryCatch(readRDS(file.path(RAW, f)), error = function(e) NULL)
  if (!is.data.frame(x) || nrow(x) < 10) next
  b <- if ("body" %in% names(x)) x$body else rep(NA_character_, nrow(x))
  ok <- sum(!is.na(b) & nchar(b) > 200)
  if (ok / nrow(x) < 0.70) cat(f, "\n", sep = "")
}
RS
if [ -s "$LOGDIR/backfill_targets.txt" ]; then
  bf=()
  while IFS= read -r f; do [ -n "$f" ] && bf+=("$f"); done < "$LOGDIR/backfill_targets.txt"
  log "backfilling ${#bf[@]} file(s): ${bf[*]}"
  caffeinate -is Rscript "$RDIR/13_backfill_bodies.R" "${bf[@]}" \
    > "$LOGDIR/backfill_overnight.log" 2>&1
  log "backfill done"
else
  log "no low-coverage feeds to backfill"
fi

# ---- 4. final sweep -----------------------------------------------------------
log "running final --sweep"
Rscript "$RDIR/12_diagnose_thin_feeds.R" --sweep > "$LOGDIR/sweep_final.log" 2>&1

# ---- 5. assemble ---------------------------------------------------------------
log "running 09_assemble.R"
Rscript "$RDIR/09_assemble.R" > "$LOGDIR/assemble_final.log" 2>&1

# ---- 6. report -----------------------------------------------------------------
{
  echo "==================================================================="
  echo " OVERNIGHT CLOSING SEQUENCE -- finished $(date '+%F %T')"
  echo " Fold-in NOT launched (awaits explicit go-ahead)."
  echo "==================================================================="
  echo
  echo "---- audit (full, all hosts) ----"
  tail -6 "$LOGDIR/audit_final.log"
  echo
  if [ -f "$LOGDIR/recollect_overnight.log" ]; then
    echo "---- overnight re-collections ----"
    grep -E '^===== |^  -> |REGRESSION|previous output' "$LOGDIR/recollect_overnight.log"
    echo
  fi
  if [ -f "$LOGDIR/backfill_overnight.log" ]; then
    echo "---- overnight backfills ----"
    grep -E '^== .*(missing a body|done: filled)|ABORTING|skipped as duplicates' "$LOGDIR/backfill_overnight.log"
    echo
  fi
  echo "---- final sweep ----"
  cat "$LOGDIR/sweep_final.log"
  echo
  echo "---- assembly ----"
  grep -vE "Waiting|■" "$LOGDIR/assemble_final.log"
} > "$REPORT"

touch "$LOGDIR/overnight.done"
log "report written to $REPORT"
