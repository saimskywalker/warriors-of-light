#!/usr/bin/env bash
# Mini — PostToolUse on Edit / Write: keeps hand-written files small.
#   past WOL_LOC_SOFT (300): a note back to the agent;
#   past WOL_LOC_HARD (500): a block when a change takes a file over it, or
#   grows one already over it. Growth is measured against git HEAD, so an
#   old big file is never punished for being touched, only for growing.
set -euo pipefail
WOL="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=/dev/null
source "$WOL/config.sh"
f="$(jq -r '.tool_input.file_path // empty')"
[[ -z "$f" || ! -f "$f" ]] && exit 0
grep -Eq "\.(${WOL_LOC_EXT})$" <<<"$f" || exit 0
grep -Eq -- "(${WOL_LOC_EXEMPT})|/\.claude/" <<<"$f" && exit 0
now=$(wc -l <"$f" | tr -d ' ')
root="$(git -C "$(dirname "$f")" rev-parse --show-toplevel 2>/dev/null || true)"
before=0
if [[ -n "$root" ]] && git -C "$root" cat-file -e "HEAD:${f#"$root"/}" 2>/dev/null; then
  before=$(git -C "$root" show "HEAD:${f#"$root"/}" | wc -l | tr -d ' ')
fi
(( now > before )) || exit 0
note() { jq -n --arg c "Mini: $1" '{hookSpecificOutput:{hookEventName:"PostToolUse",additionalContext:$c}}'; exit 0; }
if grep -Eq '(_test\.dart|/test/|/tests/|/__tests__/|\.test\.|\.spec\.)' <<<"$f"; then
  (( now > WOL_LOC_HARD )) && note "test file $f is $now lines (was $before); consider splitting by scenario group."
  exit 0
fi
if (( now > WOL_LOC_HARD )); then
  jq -n --arg r "Mini: $f is now $now lines (was $before). A change may not take a file over $WOL_LOC_HARD or grow one already over it. Move the new cohesive piece out (Dart part/part of, a sibling widget or module), or shrink what you added." \
    '{decision:"block",reason:$r}'
  exit 0
fi
(( now > WOL_LOC_SOFT )) && note "$f is $now lines (was $before). Do not add a new concern here; put the next cohesive piece beside it."
exit 0
