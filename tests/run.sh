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

# Plugin mode: spells run from the plugin folder, config and state come
# from the project. A project config overrides the defaults.
P="$(mktemp -d)"; git -C "$P" init -q -b feature/x
ok() { if eval "$2"; then pass=$((pass + 1)); else fail=$((fail + 1)); echo "FAIL plugin $1"; fi; }
for f in .claude-plugin/plugin.json .claude-plugin/marketplace.json hooks/hooks.json; do ok "json $f" "jq empty '$SRC/$f'"; done
(cd "$P" && "$SRC/bin/wol" init flutter >/dev/null)
ok "init writes config" "grep -q 'preset: flutter' '$P/.claude/wol/config.sh'"
echo "WOL_PROTECTED='main|trunk'" >>"$P/.claude/wol/config.sh"
pdecide() { jq -n --arg c "$1" '{tool_input:{command:$c}}' | CLAUDE_PROJECT_DIR="$P" "$SRC/wol/spells/protect.sh" | jq -rs '.[0].hookSpecificOutput.permissionDecision // "allow"'; }
ok "project config overrides" "[[ \$(pdecide 'git push origin trunk') == deny ]]"
ok "defaults still apply" "[[ \$(pdecide 'flutter test') == deny ]]"
ok "wol slow is the queue" "[[ \$(pdecide \"wol slow 'flutter test test/a_test.dart'\") == allow ]]"
ok "install-path wol slow" "[[ \$(pdecide \".claude/wol/bin/wol slow 'flutter test test/a_test.dart'\") == allow ]]"
(cd "$P" && CLAUDE_PROJECT_DIR="$P" "$SRC/bin/wol" slow 'true' 2>/dev/null)
ok "state lives in the project" "grep -q 'END exit=0' '$P/.claude/wol/slow.log' && [[ -f '$P/.claude/wol/.gitignore' ]]"
ok "plugin folder stays clean" "[[ ! -e '$SRC/wol/slow.log' && ! -e '$SRC/wol/heavy.lock' ]]"
ok "state is ignored by git" "[[ -z \$(git -C '$P' status --porcelain -uall -- .claude/wol | grep -v config.sh | grep -v thresholds.md | grep -v .gitignore) ]]"
rm -rf "$P"

# Uninstall leaves nothing of ours
"$SRC/uninstall.sh" "$T" >/dev/null
if [[ -e "$T/.claude/wol" ]] || ls "$T/.claude/agents/"*.md >/dev/null 2>&1 || jq -e '.hooks.PreToolUse // [] | length > 0' "$T/.claude/settings.local.json" >/dev/null; then
  fail=$((fail + 1)); echo "FAIL uninstall left files or hooks"
else pass=$((pass + 1)); fi

echo "pass=$pass fail=$fail"
(( fail == 0 ))
