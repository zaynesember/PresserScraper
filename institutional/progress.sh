#!/bin/bash
# progress.sh -- live dashboard for the detached institutional collection jobs.
#
# The collectors run via `nohup ... & disown`, so they survive the session but do
# not show up in any task list. This is how you watch them.
#
#   bash institutional/progress.sh          # refresh every 10s (Ctrl-C to quit)
#   bash institutional/progress.sh once     # one snapshot, then exit
#   INTERVAL=30 bash institutional/progress.sh
#
# Pure shell on purpose: no R startup, so it stays cheap enough to loop.

REPO="/Users/zaynesember/GitRepos/pressR"
LOGDIR="$HOME/institutional_logs"
RAW="$REPO/institutional/data/raw"
INTERVAL="${INTERVAL:-10}"
ONCE=""
[ "${1:-}" = "once" ] && ONCE=1

alive() { pgrep -f "$1" 2>/dev/null | head -1; }

snapshot() {
  echo "=============================================================="
  echo " institutional collection   $(date '+%F %H:%M:%S')"
  echo "=============================================================="

  # ---- lanes -------------------------------------------------------------
  local running=0 assigned=0 position=0
  echo "LANES"
  for K in 1 2 3 4 5 6 7 8; do
    local log="$LOGDIR/lane$K.log"
    [ -f "$log" ] || continue
    local st cur n m
    if pgrep -f "exec/R.*lane=$K/8" >/dev/null 2>&1; then st="run "; running=$((running+1));
    else st="done"; fi
    # last "[ n/ m] feed_id" line tells us where the lane is
    local line
    line=$(grep -oE '\[ *[0-9]+/ *[0-9]+\] [^ ]+' "$log" 2>/dev/null | tail -1)
    n=$(echo "$line" | sed -E 's/^\[ *([0-9]+).*/\1/')
    m=$(echo "$line" | sed -E 's/^\[ *[0-9]+\/ *([0-9]+)\].*/\1/')
    cur=$(echo "$line" | awk '{print $NF}')
    [ -n "$m" ] && assigned=$((assigned+m))
    [ -n "$n" ] && position=$((position+n))
    printf "  %d %s %-6s %-46s\n" "$K" "$st" "${n:-0}/${m:-0}" "${cur:0:46}"
  done
  echo "  -> $running lane(s) running; at feed $position of $assigned assigned"

  # ---- body backfills ----------------------------------------------------
  echo
  echo "BODY BACKFILLS"
  for log in "$LOGDIR"/backfill_*.log; do
    [ -f "$log" ] || continue
    local f st prog file
    f=$(basename "$log" .log)
    # done/run per log: a log whose last file-block printed "done:" is finished
    # even while other backfill processes are still alive.
    if grep -qE 'done: filled' "$log" && ! grep -qE '^== [^:]+: .*missing a body$' <(tail -5 "$log"); then
      st="done"
    elif pgrep -f "exec/R.*13_backfill_bodies" >/dev/null 2>&1; then st="run "; else st="done"; fi
    prog=$(grep -oE '([0-9]+/[0-9]+  filled [0-9]+|done: filled [0-9]+ of [0-9]+; coverage now [0-9.]+%)' "$log" | tail -1)
    file=$(grep -oE '^== [^:]+' "$log" | tail -1 | sed 's/^== //;s/^feed_//')
    printf "  %-18s %s %-30s %s\n" "${f#backfill_}" "$st" "${file:0:30}" "${prog:-starting}"
  done

  # ---- targeted re-collects ---------------------------------------------
  if ls "$LOGDIR"/recollect*.log >/dev/null 2>&1; then
    echo
    echo "RE-COLLECTS (last feed started; -> line = its result when done)"
    for log in "$LOGDIR"/recollect*.log; do
      local cur res
      cur=$(grep -oE '^===== [^ ]+' "$log" | tail -1 | sed 's/^===== //')
      res=$(grep -E '^  ->' "$log" | tail -1 | sed 's/^  -> //')
      printf "  %-20s %-42s %s\n" "$(basename "$log" .log | sed 's/^recollect_*//;s/^$/-/')" \
        "${cur:0:42}" "${res:0:60}"
    done
  fi

  # ---- pager audit ---------------------------------------------------------
  if [ -f "$LOGDIR/audit_pagers.log" ]; then
    echo
    if pgrep -f "audit-pagers" >/dev/null 2>&1; then
      echo "PAGER AUDIT: running ($(grep -c ' ok$\|CAPPED' "$LOGDIR/audit_pagers.log" 2>/dev/null) feeds probed)"
    else
      echo "PAGER AUDIT: done -- $(grep -oE '^[0-9]+ feed\(s\) need re-collection' "$LOGDIR/audit_pagers.log" | tail -1)"
    fi
  fi

  # ---- outputs -----------------------------------------------------------
  echo
  echo "OUTPUTS"
  printf "  feed files : %s   (all .rds: %s)\n" \
    "$(ls "$RAW"/feed_*.rds 2>/dev/null | wc -l | tr -d ' ')" \
    "$(ls "$RAW"/*.rds 2>/dev/null | wc -l | tr -d ' ')"
  printf "  data size  : %s\n" "$(du -sh "$REPO/institutional/data" 2>/dev/null | awk '{print $1}')"
  echo "  newest:"
  ls -t "$RAW"/*.rds 2>/dev/null | head -3 | while read -r p; do
    printf "    %s  %s\n" "$(date -r "$p" '+%H:%M')" "$(basename "$p")"
  done

  # ---- anything crashed? -------------------------------------------------
  local bad
  bad=$(grep -lE "Execution halted" "$LOGDIR"/*.log 2>/dev/null | xargs -n1 basename 2>/dev/null | tr '\n' ' ')
  echo
  if [ -n "$bad" ]; then echo "!! CRASHED LOGS: $bad"; else echo "no crashed logs"; fi
}

if [ -n "$ONCE" ]; then
  snapshot
else
  while true; do
    clear
    snapshot
    echo
    echo "(refreshing every ${INTERVAL}s -- Ctrl-C to quit)"
    sleep "$INTERVAL"
  done
fi
