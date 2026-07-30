#!/bin/bash
# Tier-A pilot runner: discovery + walks + item fetches. Single lane against
# webharvest.gov -- never run two of these. Network stages only; extraction
# (04) and staging (05) run offline afterwards.
#
# Launch detached, machine plugged in, LID OPEN (caffeinate blocks idle sleep
# but a lid close still kills the connections):
#   nohup caffeinate -i bash nara/run_tierA.sh >> ~/nara_tierA.log 2>&1 &
# Watch:  tail -f ~/nara_tierA.log
set -euo pipefail
cd /Users/zaynesember/GitRepos/pressR

if pgrep -f "nara/R/0[13]_" > /dev/null; then
  echo "a nara crawler process is already running -- refusing a second lane"
  exit 1
fi

# Pacing: the limiter trips after ~70 SUSTAINED requests even at the
# robots-compliant 10s spacing (first pilot run, 2026-07-30). ~30-request
# bursts with ~7 min of full silence between them stay near the morning
# probe cadence that never tripped. Override per-run if probing thresholds.
export NARA_BURST="${NARA_BURST:-30}"
export NARA_REST="${NARA_REST:-420}"

echo "=== nara tier-A pilot start $(date) ==="
Rscript nara/R/01_discover.R
echo "--- discovery done $(date) ---"
Rscript nara/R/03_walk.R
echo "=== network done $(date) ==="
echo "next (offline): Rscript nara/R/04_extract.R, review QA, then 05_stage.R"
