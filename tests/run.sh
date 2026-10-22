#!/usr/bin/env bash
# Installs the crew into a throwaway repo and checks every spell decision
# in tests/cases.txt, then the Mini limits and a clean uninstall.
set -uo pipefail
SRC="$(cd "$(dirname "$0")/.." && pwd)"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
git -C "$T" init -q -b feature/login
git -C "$T" -c user.name=t -c user.email=t@t commit -q --allow-empty -m init
"$SRC/install.sh" --preset fullstack "$T" >/dev/null || { echo "install failed"; exit 1; }
S="$T/.claude/wol/spells"
pass=0; fail=0
decide() {
  local tool="$1" input="$2" out
  case "$tool" in
    bash) out="$(jq -n --arg c "$input" '{tool_input:{command:$c}}' | "$S/protect.sh")" ;;
    read) out="$(jq -n --arg f "$input" '{tool_input:{file_path:$f}}' | "$S/shell.sh")" ;;
    sql)  out="$(jq -n --arg s "$input" '{tool_input:{sql:$s}}' | "$S/silence.sh")" ;;
  esac
  jq -r '.hookSpecificOutput.permissionDecision // empty' <<<"$out" 2>/dev/null
}
while IFS='|' read -r want tool input; do
  [[ -z "$want" || "$want" == \#* ]] && continue
  got="$(decide "$tool" "$input")"; got="${got:-allow}"
  if [[ "$got" == "$want" ]]; then pass=$((pass + 1)); else fail=$((fail + 1)); echo "FAIL want=$want got=$got [$tool] $input"; fi
done <"$SRC/tests/cases.txt"

# Mini: soft note at 301 lines, block at 501, nothing for an exempt file
mk() { mkdir -p "$(dirname "$T/$1")"; seq 1 "$2" | sed 's/^/\/\/ line /' >"$T/$1"; jq -n --arg f "$T/$1" '{tool_input:{file_path:$f}}' | "$S/mini.sh"; }
check() { if grep -q "$2" <<<"$3"; then pass=$((pass + 1)); else fail=$((fail + 1)); echo "FAIL mini $1"; fi; }
check soft additionalContext "$(mk lib/a.dart 301)"
check hard '"decision": "block"' "$(mk lib/b.dart 501)"
check exempt '^$' "$(mk lib/c.g.dart 900)"
check test-note additionalContext "$(mk test/d_test.dart 600)"

# Uninstall leaves nothing of ours
"$SRC/uninstall.sh" "$T" >/dev/null
if [[ -e "$T/.claude/wol" ]] || ls "$T/.claude/agents/"*.md >/dev/null 2>&1 || jq -e '.hooks.PreToolUse // [] | length > 0' "$T/.claude/settings.local.json" >/dev/null; then
  fail=$((fail + 1)); echo "FAIL uninstall left files or hooks"
else pass=$((pass + 1)); fi

echo "pass=$pass fail=$fail"
(( fail == 0 ))
