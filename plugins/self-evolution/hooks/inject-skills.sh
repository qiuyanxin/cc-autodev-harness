#!/bin/bash
# inject-skills.sh — UserPromptSubmit hook (sync)
# Reads user prompt keywords, matches against skill-bank.json domains,
# injects relevant "common mistakes" rules into Claude's context via stdout.

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""')
CWD=$(echo "$INPUT" | jq -r '.cwd // ""')

if [ -z "$CWD" ]; then
  exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "$0")/../scripts" && pwd)"
source "$SCRIPT_DIR/resolve-project-dir.sh"

PROJECT_DIR=$(resolve_project_dir "$CWD")
SKILL_BANK="$PROJECT_DIR/skill-bank.json"

if [ ! -f "$SKILL_BANK" ]; then
  exit 0
fi

MATCHES=""

# Read domain keywords mapping from skill-bank.json
# Each domain in commonMistakes is checked against the prompt
DOMAINS=$(jq -r '.commonMistakes // {} | keys[]' "$SKILL_BANK" 2>/dev/null)

for domain in $DOMAINS; do
  # Skip "general" — always included below
  if [ "$domain" = "general" ]; then
    continue
  fi

  # Read keyword patterns for this domain
  KEYWORDS=$(jq -r ".domainKeywords.\"$domain\" // \"\" " "$SKILL_BANK" 2>/dev/null)
  if [ -z "$KEYWORDS" ]; then
    continue
  fi

  # Match prompt against domain keywords (case insensitive)
  if echo "$PROMPT" | grep -qiE "$KEYWORDS"; then
    RULES=$(jq -r ".commonMistakes.\"$domain\" // [] | .[]" "$SKILL_BANK" 2>/dev/null)
    MATCHES="${MATCHES}${RULES}"$'\n'
  fi
done

# General rules — always injected
GENERAL=$(jq -r '.commonMistakes.general // [] | .[]' "$SKILL_BANK" 2>/dev/null)

# Merge, deduplicate, remove empty lines
ALL_RULES=$(printf '%s\n%s' "$GENERAL" "$MATCHES" | sort -u | sed '/^$/d')

if [ -n "$ALL_RULES" ]; then
  echo "<skill-bank-context>"
  echo "Known issues for this project (avoid these):"
  echo "$ALL_RULES" | while IFS= read -r rule; do
    echo "- $rule"
  done
  echo "</skill-bank-context>"
fi

exit 0
