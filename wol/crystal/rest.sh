#!/usr/bin/env bash
# The end of Laguna's run: stop the dev stack, release the queue, let the
# machine sleep, and (only if WOL_SHUTDOWN=1, macOS) power it off in 60 s.
#   rest.sh          do it
#   rest.sh --dry    say what would happen, change nothing
WOL="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=/dev/null
source "$WOL/config.sh"
ROOT="$(git -C "$WOL" rev-parse --show-toplevel 2>/dev/null || pwd)"
DRY=0; [[ "${1:-}" == "--dry" ]] && DRY=1
say() { echo "Rest: $*"; }
run() { if (( DRY )); then say "[dry] $*"; else eval "$*" >/dev/null 2>&1 || true; fi; }

[[ "${WOL_STOP_DOCKER:-1}" == 1 ]] && ls "$ROOT"/docker-compose*.y*ml "$ROOT"/compose.y*ml >/dev/null 2>&1 \
  && { say "stopping docker compose"; run "cd '$ROOT' && docker compose stop"; }
command -v adb >/dev/null && { say "stopping Android emulators"; run "adb devices | awk '/^emulator-/{print \$1}' | xargs -I{} adb -s {} emu kill"; }
command -v xcrun >/dev/null && { say "stopping iOS simulators"; run "xcrun simctl shutdown all"; }
say "stopping Gradle / Kotlin daemons"; run "pkill -f 'GradleDaemon|KotlinCompileDaemon'"
say "stopping flutter / dart tools";   run "pkill -f 'flutter_tools|dart.*analysis_server'"
say "releasing the heavy queue";        run "rm -rf '$WOL/heavy.lock'"
say "clearing tonight's permissions";   run "rm -f '$WOL'/crystal/active/*"
say "awake off";                        run "'$WOL/crystal/awake.sh' stop"

if [[ "${WOL_SHUTDOWN:-0}" == 1 && "$(uname)" == Darwin ]]; then
  if (( DRY )); then say "[dry] would power off in 60 s"; exit 0; fi
  nohup bash -c 'sleep 60; osascript -e "tell application \"System Events\" to shut down"' >/dev/null 2>&1 &
  echo $! >"$WOL/crystal/rest.pid"
  say "powering off in 60 s (cancel: kill \$(cat '$WOL/crystal/rest.pid'))"
fi
