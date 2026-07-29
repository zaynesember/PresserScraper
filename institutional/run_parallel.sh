#!/bin/bash
# Collect the outstanding institutional feeds with N lanes in parallel.
#
#   bash institutional/run_parallel.sh            # 4 lanes, round-2 configs
#   LANES=6 bash institutional/run_parallel.sh    # more lanes
#   CONFIGS=06_feed_configs.R bash institutional/run_parallel.sh
#
# Lanes are partitioned BY HOST (see 07_collect_feeds.R --lane), so no two
# processes ever hit the same server at once; each process keeps the normal
# throttle, so per-host politeness is unchanged and only total throughput rises.
# Feeds already collected are skipped, so this is safe to re-run or interrupt --
# an interrupted feed simply gets redone (outputs are written per completed feed).
set -uo pipefail
REPO="/Users/zaynesember/GitRepos/pressR"
LANES="${LANES:-4}"
CONFIGS="${CONFIGS:-11_feed_configs2.R}"
LOGDIR="$HOME/institutional_logs"
cd "$REPO" || exit 1
mkdir -p "$LOGDIR"

# Refuse to start alongside another collector: two processes writing the same
# feed file would race, and the serial resume run may still be going.
if pgrep -f "07_collect_feeds.R" > /dev/null; then
  echo "ERROR: a collector is already running. Stop it first:"
  echo "         pkill -f 07_collect_feeds.R"
  pgrep -fl "07_collect_feeds.R" | sed 's/^/         /'
  exit 1
fi

echo "$(date '+%F %T')  starting $LANES lanes over $CONFIGS"
echo "logs: $LOGDIR/lane<K>.log"
before=$(ls institutional/data/raw/*.rds 2>/dev/null | wc -l | tr -d ' ')

pids=()
for K in $(seq 1 "$LANES"); do
  ( caffeinate -is Rscript institutional/R/07_collect_feeds.R \
      --configs="$CONFIGS" --lane="$K/$LANES" ) > "$LOGDIR/lane$K.log" 2>&1 &
  # $! not ${pids[-1]}: macOS ships bash 3.2, which has no negative array
  # subscripts, and `set -u` turns that into a fatal error mid-launch -- a
  # previous run died here having started only lane 1.
  lane_pid=$!
  pids+=("$lane_pid")
  echo "  lane $K/$LANES -> pid $lane_pid"
  sleep 2                       # stagger startup so load_all() doesn't thrash
done

echo "$(date '+%F %T')  waiting for $LANES lanes..."
fail=0
for p in "${pids[@]}"; do wait "$p" || fail=1; done

after=$(ls institutional/data/raw/*.rds 2>/dev/null | wc -l | tr -d ' ')
echo "$(date '+%F %T')  ALL LANES DONE (failures: $fail)"
echo "  feed files: $before -> $after"
echo "  per-lane tails:"
for K in $(seq 1 "$LANES"); do
  echo "  --- lane $K ---"
  grep -vE "Waiting|■" "$LOGDIR/lane$K.log" | tail -3 | sed 's/^/    /'
done
