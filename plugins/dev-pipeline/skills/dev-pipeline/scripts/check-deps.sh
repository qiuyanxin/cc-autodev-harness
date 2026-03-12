#!/usr/bin/env bash
# Check required dependencies for dev-pipeline
# Exit codes: 0 = all deps present, 1 = missing deps (info printed to stdout)

set -euo pipefail

MISSING=()
INSTALL_CMDS=()

# Check gh CLI
if ! command -v gh &>/dev/null; then
  MISSING+=("gh CLI")
  INSTALL_CMDS+=("brew install gh && gh auth login")
fi

# Check git
if ! command -v git &>/dev/null; then
  MISSING+=("git")
  INSTALL_CMDS+=("brew install git")
fi

# Check Claude Code plugins by looking at settings
CLAUDE_SETTINGS="$HOME/.claude/settings.json"

if [ -f "$CLAUDE_SETTINGS" ]; then
  # Check superpowers plugin
  if ! grep -q '"superpowers@claude-plugins-official": true' "$CLAUDE_SETTINGS" 2>/dev/null; then
    MISSING+=("superpowers plugin")
    INSTALL_CMDS+=("claude plugin marketplace add github:obra/superpowers && claude plugin install superpowers@claude-plugins-official")
  fi

  # Check compound-engineering plugin
  if ! grep -q '"compound-engineering@compound-engineering-plugin": true' "$CLAUDE_SETTINGS" 2>/dev/null; then
    MISSING+=("compound-engineering plugin (optional, enables advanced review)")
    INSTALL_CMDS+=("claude plugin marketplace add github:EveryInc/compound-engineering-plugin && claude plugin install compound-engineering@compound-engineering-plugin")
  fi
else
  MISSING+=("Claude Code settings (run claude at least once)")
fi

# Output results
if [ ${#MISSING[@]} -eq 0 ]; then
  echo "OK: All dependencies present"
  exit 0
else
  echo "MISSING DEPENDENCIES:"
  for i in "${!MISSING[@]}"; do
    echo "  - ${MISSING[$i]}"
    echo "    Install: ${INSTALL_CMDS[$i]}"
  done
  echo ""
  echo "Note: After installing plugins, restart Claude Code for changes to take effect."
  exit 1
fi
