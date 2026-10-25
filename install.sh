#!/usr/bin/env bash
# airbag installer — macOS / Linux / WSL
# Installs into ~/.claude without overwriting anything you already have.
#   ./install.sh            install / update
#   ./install.sh --uninstall remove airbag files (leaves your own files alone)
set -euo pipefail

REPO_URL="https://github.com/iqbalmbadhan/airbag.git"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
SELF="${BASH_SOURCE[0]:-}"
SRC_DIR=""
if [ -n "$SELF" ] && [ -f "$SELF" ]; then SRC_DIR="$(cd "$(dirname "$SELF")" && pwd)"; fi

# Not run from a clone (e.g. piped from curl)? Fetch the repo to a temp folder first.
if [ -z "$SRC_DIR" ] || [ ! -f "$SRC_DIR/claude/skills/app-audit/SKILL.md" ]; then
  command -v git >/dev/null || { echo "git is required"; exit 1; }
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  git clone --depth 1 --quiet "$REPO_URL" "$TMP/airbag"
  SRC_DIR="$TMP/airbag"
fi
SRC="$SRC_DIR/claude"

RULES="$CLAUDE_DIR/rules/airbag.md"
SKILL="$CLAUDE_DIR/skills/app-audit"
GUIDE="$CLAUDE_DIR/claude-security-guidance.md"
SETTINGS="$CLAUDE_DIR/settings.json"

if [ "${1:-}" = "--uninstall" ]; then
  rm -f "$RULES"
  if [ -f "$SKILL/.airbag" ]; then rm -rf "$SKILL"; elif [ -d "$SKILL" ]; then echo "• left $SKILL alone (not installed by airbag)"; fi
  if [ -f "$GUIDE" ] && cmp -s "$GUIDE" "$SRC/claude-security-guidance.md"; then rm -f "$GUIDE"; fi
  echo "airbag removed. Permission rules in $SETTINGS were left in place — remove them by hand if you want."
  exit 0
fi

mkdir -p "$CLAUDE_DIR/rules" "$CLAUDE_DIR/skills"

# 1. Always-on rules. Installed as a user-level rule file so your own ~/.claude/CLAUDE.md is untouched.
cp "$SRC/CLAUDE.md" "$RULES"
echo "✓ rules      → $RULES"

# 2. /app-audit skill
if [ -d "$SKILL" ] && [ ! -f "$SKILL/.airbag" ]; then
  mv "$SKILL" "$SKILL.backup-$(date +%Y%m%d%H%M%S)"
  echo "  (existing app-audit skill backed up)"
fi
rm -rf "$SKILL"
cp -R "$SRC/skills/app-audit" "$SKILL"
touch "$SKILL/.airbag"
echo "✓ skill      → $SKILL  (run /app-audit)"

# 3. Guidance for the security-guidance plugin (only if you don't have one)
if [ -f "$GUIDE" ] && ! cmp -s "$GUIDE" "$SRC/claude-security-guidance.md"; then
  echo "• kept your existing $GUIDE (see claude/claude-security-guidance.md to merge)"
else
  cp "$SRC/claude-security-guidance.md" "$GUIDE"
  echo "✓ guidance   → $GUIDE"
fi

# 4. Permission rules — merged, never overwritten
if [ ! -f "$SETTINGS" ]; then
  cp "$SRC/settings.json" "$SETTINGS"
  echo "✓ settings   → $SETTINGS"
elif command -v python3 >/dev/null; then
  python3 - "$SETTINGS" "$SRC/settings.json" <<'PY'
import json, sys, shutil, time
dst, src = sys.argv[1], sys.argv[2]
try:
    cur = json.load(open(dst))
except Exception as e:
    print(f"• could not parse {dst} ({e}); merge claude/settings.json by hand"); sys.exit(0)
add = json.load(open(src))["permissions"]
perm = cur.setdefault("permissions", {})
changed = False
for key, rules in add.items():
    lst = perm.setdefault(key, [])
    for r in rules:
        if r not in lst:
            lst.append(r); changed = True
if changed:
    shutil.copy(dst, f"{dst}.backup-{time.strftime('%Y%m%d%H%M%S')}")
    json.dump(cur, open(dst, "w"), indent=2); open(dst, "a").write("\n")
    print(f"✓ settings   → merged permission rules into {dst} (backup saved)")
else:
    print("✓ settings   → permission rules already present")
PY
else
  echo "• python3 not found: merge claude/settings.json into $SETTINGS by hand"
fi

cat <<'EOF'

airbag is installed. Next:
  1. Recommended: in Claude Code run   /plugin install security-guidance@claude-plugins-official
  2. Start a new session and check     /context   (airbag.md under Memory files)
  3. Audit any project with            /app-audit
EOF
