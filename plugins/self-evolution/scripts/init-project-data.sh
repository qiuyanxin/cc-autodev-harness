#!/bin/bash
# init-project-data.sh — SessionStart hook
# Initializes project data directory with skill-bank.json template if not present.

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // ""')

if [ -z "$CWD" ]; then
  exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/resolve-project-dir.sh"

PROJECT_DIR=$(resolve_project_dir "$CWD")
if [ -z "$PROJECT_DIR" ]; then
  exit 0
fi

# Ensure directories exist
mkdir -p "$PROJECT_DIR/memory/archive" 2>/dev/null

# Initialize skill-bank.json from template if not present
if [ ! -f "$PROJECT_DIR/skill-bank.json" ]; then
  PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
  TEMPLATE="$PLUGIN_ROOT/templates/skill-bank-default.json"
  if [ -f "$TEMPLATE" ]; then
    cp "$TEMPLATE" "$PROJECT_DIR/skill-bank.json"
  fi
fi

# Initialize MEMORY.md if not present
if [ ! -f "$PROJECT_DIR/memory/MEMORY.md" ]; then
  cat > "$PROJECT_DIR/memory/MEMORY.md" << 'MEMEOF'
# Memory Index

## Feedback
(evolve-rules will index feedback files here after processing)

## Project

## User

## Reference
- skill-bank.json: rule bank, read by inject-skills hook, updated by /evolve-rules
MEMEOF
fi

exit 0
