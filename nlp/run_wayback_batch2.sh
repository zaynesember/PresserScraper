#!/bin/bash
# Self-gating batch-2 launcher for the 339-member Wayback expansion.
#
# IA's CDX endpoint throttles by serving SLOW and/or EMPTY responses that are
# indistinguishable from an empty archive (the lantos lesson), so launching
# while throttled wastes hours and recovers nothing. This wrapper probes CDX
# health every 15 min and starts the real run only after TWO consecutive
# healthy probes (>=1 data row, under 8s). Gives up after ~12h of gating.
#
# Roster: wayback_targets_batch2.csv (re-run 2026-08-03 after the date fix:
# ALL member caches were cleared, so every member re-fetches and re-extracts).
# Roster note: wayback_targets_batch2.csv = 16 originals + top-75 ranked expansion
# hosts (cumulative over batch1 -- a full run rewrites external/wayback/ from
# the roster's caches only, so every batch roster must contain its
# predecessors). Recovered members resolve instantly from cache.
#
# Detached use (machine plugged in, LID OPEN):
#   nohup caffeinate -i bash nlp/run_wayback_batch2.sh >> ~/wayback_batch2.log 2>&1 &
set -euo pipefail
cd /Users/zaynesember/GitRepos/pressR

if pgrep -f "nlp/run_wayback.R" > /dev/null; then
  echo "run_wayback.R already running -- refusing a second process"
  exit 1
fi

# What the gate is really testing is whether CDX returns DATA -- an empty or
# error response is indistinguishable from an empty archive and would write a
# member off (the lantos lesson). Latency is a throughput concern, not a
# correctness one, so the bar is deliberately loose: the first version demanded
# <8s (calibrated on a 1.5s day) and would have idled through a healthy 12.2s
# CDX for the full 12h window and then quit. Most of this run needs no CDX at
# all -- 50 of the 91 rostered hosts have a cached universe, and the article
# endpoint (the bulk of the work) is a separate, unthrottled service.
PROBE_URL="http://web.archive.org/cdx/search/cdx?url=kanjorski.house.gov/*&collapse=urlkey&filter=statuscode:200&filter=mimetype:text/html&fl=timestamp,original&from=20050101&to=20061231&limit=50"
CDX_MAX_S="${CDX_MAX_S:-25}"
ok_streak=0
for i in $(seq 1 48); do
  t=$(curl -sS --max-time 40 "$PROBE_URL" -o /tmp/cdx_gate.txt -w '%{time_total}' 2>/dev/null || echo 99)
  # grep -c PRINTS 0 and EXITS 1 on no match, so `|| echo 0` appended a second
  # zero and the numeric test below choked on "0\n0"
  rows=$(grep -c '^[0-9]' /tmp/cdx_gate.txt 2>/dev/null || true); rows=${rows:-0}
  usable=$(awk -v t="$t" -v m="$CDX_MAX_S" 'BEGIN{print (t+0 < m+0) ? 1 : 0}')
  echo "$(date '+%m-%d %H:%M') gate probe $i: ${t}s, ${rows} rows (need rows>=1 and <${CDX_MAX_S}s)"
  if [ "$rows" -ge 1 ] && [ "$usable" -eq 1 ]; then ok_streak=$((ok_streak+1)); else ok_streak=0; fi
  if [ "$ok_streak" -ge 2 ]; then echo "CDX returning data -- launching batch 2"; break; fi
  sleep 300
done
if [ "$ok_streak" -lt 2 ]; then
  echo "CDX never came back healthy within the gate window -- giving up"
  exit 2
fi

WAYBACK_TARGETS=/Users/zaynesember/GitRepos/pressR/nlp/crosswalks/wayback_targets_batch2.csv \
WAYBACK_MAXART=1500 \
Rscript nlp/run_wayback.R
echo "=== batch 2 done $(date) -- verify by counts (per-member table above), not exit codes ==="
