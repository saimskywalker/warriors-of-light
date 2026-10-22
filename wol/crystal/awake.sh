#!/usr/bin/env bash
# Keep the machine awake during Laguna's run.   awake.sh start | stop | status
# shellcheck source=/dev/null
source "$(dirname "$0")/../lib.sh"; wol_state; PID="$STATE/awake.pid"
running() { [[ -f "$PID" ]] && kill -0 "$(cat "$PID")" 2>/dev/null; }
case "${1:-status}" in
  start)
    running && { echo "already awake"; exit 0; }
    if command -v caffeinate >/dev/null; then nohup caffeinate -dims >/dev/null 2>&1 &
    elif command -v systemd-inhibit >/dev/null; then nohup systemd-inhibit --what=sleep:idle sleep infinity >/dev/null 2>&1 &
    else echo "no caffeinate or systemd-inhibit: the machine may sleep"; exit 0; fi
    echo $! >"$PID"; echo "awake (pid $!)";;
  stop) running && kill "$(cat "$PID")"; rm -f "$PID"; echo "awake off";;
  *) running && echo "awake (pid $(cat "$PID"))" || echo "not awake";;
esac
