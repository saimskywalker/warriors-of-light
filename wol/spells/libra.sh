#!/usr/bin/env bash
# Libra — status: who holds the heavy queue, heavy processes, memory, recent runs.
WOL="$(cd "$(dirname "$0")/.." && pwd)"
if [[ "$(uname)" == Darwin ]]; then free="$(sysctl -n kern.memorystatus_level)%"
else free="$(awk '/MemTotal/{t=$2}/MemAvailable/{a=$2}END{print int(a*100/t)}' /proc/meminfo)%"; fi
echo "free memory: $free   local-only commands: $([[ -e "$WOL/allow-local" ]] && echo ALLOWED || echo blocked)"
if [[ -d "$WOL/heavy.lock" ]]; then
  echo "queue: held by pid $(cat "$WOL/heavy.lock/pid" 2>/dev/null) :: $(cut -c1-100 "$WOL/heavy.lock/cmd" 2>/dev/null)"
else echo "queue: free"; fi
echo "heavy processes:"
ps -Ao pid,etime,%cpu,rss,comm | awk 'NR>1 && $5 ~ /(dart|flutter|java|gradle|node|xcodebuild|cargo|rustc|go)/ {printf "  %-7s %-11s cpu=%-5s rss=%4dMB %s\n",$1,$2,$3,$4/1024,$5}' | head -15
echo "recent runs:"
tail -n 8 "$WOL/slow.log" 2>/dev/null | sed 's/^/  /' | cut -c1-160
