#!/bin/bash
# pre-compact-learn.sh — PreCompact hook (sync)
# Reminds Claude to save lessons learned before context compaction.

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // ""')

if [ -z "$CWD" ]; then
  exit 0
fi

cat << 'EOF'
<pre-compact-reminder>
Context is about to be compacted. Before losing session details, check:
1. Did you make mistakes the user corrected? → Save to memory/feedback_*.md
2. Did you discover project patterns worth remembering? → Save to memory/
3. If you created new memory files, update MEMORY.md index.
Format: frontmatter with name, description, type: feedback. Include **Why:** and **How to apply:** lines.
</pre-compact-reminder>
EOF

exit 0
