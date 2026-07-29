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
  for f in backfill_hsgac backfill_commerce; do
    local log="$LOGDIR/$f.log"
    [ -f "$log" ] || continue
    local st prog file
    if pgrep -f "exec/R.*13_backfill_bodies" >/dev/null 2>&1; then st="run "; else st="done"; fi
    prog=$(grep -oE '[0-9]+/[0-9]+  filled [0-9]+' "$log" | tail -1)
    file=$(grep -oE '^== [^:]+' "$log" | tail -1 | sed 's/^== //')
    printf "  %-18s %s %-34s %s\n" "$f" "$st" "${file:0:34}" "${prog:-starting}"
  done

  # ---- targeted re-collects ---------------------------------------------
  if ls "$LOGDIR"/recollect*.log >/dev/null 2>&1; then
    echo
    echo "RE-COLLECTS (most recent result per log)"
    for log in "$LOGDIR"/recollect*.log; do
      printf "  %-22s %s\n" "$(basename "$log" .log)" \
        "$(grep -E '^  ->' "$log" | tail -1 | sed 's/^  -> //')"
    done
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
