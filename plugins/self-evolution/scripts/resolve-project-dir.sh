#!/bin/bash
# resolve-project-dir.sh — Shared utility
# Derives the Claude Code project data directory from a CWD path.
# Usage: source this file, then call resolve_project_dir "$CWD"
#
# Claude Code convention: /Users/foo/bar → ~/.claude/projects/-Users-foo-bar/

resolve_project_dir() {
  local cwd="$1"
  if [ -z "$cwd" ]; then
    return 1
  fi
  # Replace / with - (Claude Code convention)
  local hash
  hash=$(echo "$cwd" | tr '/' '-')
  echo "$HOME/.claude/projects/${hash}"
}
