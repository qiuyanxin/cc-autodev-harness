#!/bin/bash
# capture-failure.sh — PostToolUseFailure hook (async)
# Records tool call failures to failures.jsonl for /evolve-rules analysis.

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"')
TOOL_INPUT=$(echo "$INPUT" | jq -c '.tool_input // {}')
ERROR=$(echo "$INPUT" | jq -r '.error // "no error message"')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
CWD=$(echo "$INPUT" | jq -r '.cwd // ""')
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

if [ -z "$CWD" ]; then
  exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "$0")/../scripts" && pwd)"
source "$SCRIPT_DIR/resolve-project-dir.sh"

PROJECT_DIR=$(resolve_project_dir "$CWD")
if [ -z "$PROJECT_DIR" ]; then
  exit 0
fi

mkdir -p "$PROJECT_DIR" 2>/dev/null
FAILURE_LOG="$PROJECT_DIR/failures.jsonl"

# Truncate long values to avoid huge log lines
ERROR_TRUNC=$(echo "$ERROR" | head -c 500)
INPUT_TRUNC=$(echo "$TOOL_INPUT" | head -c 500)

echo "{\"ts\":\"$TIMESTAMP\",\"session\":\"$SESSION_ID\",\"tool\":\"$TOOL_NAME\",\"input\":$INPUT_TRUNC,\"error\":$(echo "$ERROR_TRUNC" | jq -Rs .)}" >> "$FAILURE_LOG"

exit 0
