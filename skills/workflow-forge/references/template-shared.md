# Shared Directory Template

The `shared/` directory holds cross-skill resources: references, scripts, templates, and accumulated knowledge. It prevents duplication (AP-3) and enables ecosystem-level patterns.

**Source pattern:** `shared/` in claude-toolkit

---

## Directory Structure

Generate at: `{output_path}/../shared/` (at plugin root level, alongside `skills/`)

```
shared/
├── references/              # Cross-skill shared knowledge
│   ├── rlhf-loop.md        # RLHF framework (if enabled)
│   └── {schema}.md          # Shared data schemas
├── scripts/                 # Cross-skill shared scripts
│   ├── git-safe-commit.sh   # Safe git operations (if git enabled)
│   └── {crud}.py            # Data CRUD operations (if central data model)
├── templates/               # Shared output templates
│   └── {report}.md          # Report templates used by eval/review
└── knowledge-base/          # Accumulated experience (grows over time)
    ├── README.md
    ├── decision-patterns/   # Past decisions and their outcomes
    ├── review-learnings/    # Retrospective insights
    └── industry-benchmarks/ # Domain-specific reference data
```

---

## Access Pattern

Skills access shared resources via path from plugin root:

```bash
# From any skill's SKILL.md
cat {PLUGIN_ROOT}/shared/references/{file}.md
cat {PLUGIN_ROOT}/shared/scripts/{script}.sh
```

---

## When to Generate Each Subdirectory

| Subdirectory | Condition | Contents |
|-------------|-----------|----------|
| `references/` | Always (L3) | Shared schemas, RLHF framework |
| `scripts/` | Central data model OR git operations | CRUD scripts, git-safe-commit |
| `templates/` | Multiple skills produce similar reports | Report templates, eval templates |
| `knowledge-base/` | Workflow is recurring + needs learning | README + empty subdirectories |

---

## knowledge-base/ README Template

Generate at: `{output_path}/../shared/knowledge-base/README.md`

```markdown
# Knowledge Base

Accumulated experience from running {{workflow_name}}. Updated after each cycle.

## Structure

- `decision-patterns/` — Key decisions and their outcomes
- `review-learnings/` — Insights from retrospectives and reviews
- `industry-benchmarks/` — Domain-specific reference data and standards

## Contributing

After each review/retrospective cycle, extract:
1. Decisions that worked well → `decision-patterns/YYYY-MM-topic.md`
2. Mistakes and root causes → `review-learnings/YYYY-MM-topic.md`
3. Updated benchmarks → `industry-benchmarks/topic.md`

## Format

Each entry should include:
- **Context**: What was the situation?
- **Decision/Learning**: What happened?
- **Outcome**: What was the result?
- **Recommendation**: What to do next time?
```

---

## Shared Script Patterns

### git-safe-commit.sh

Generate when any skill uses git operations:

```bash
#!/usr/bin/env bash
set -euo pipefail

COMPANY_DIR="${1:?Usage: git-safe-commit.sh <dir> <message> [tag] [tag-message]}"
MSG="${2:?Commit message required}"
TAG="${3:-}"
TAG_MSG="${4:-$MSG}"

cd "$COMPANY_DIR"
git rev-parse --git-dir > /dev/null 2>&1 || { echo "Not a git repo: $COMPANY_DIR"; exit 1; }

if [ -n "$(git status --porcelain)" ]; then
  git add -A
  git commit -m "$MSG"
  echo "Committed: $MSG"
else
  echo "No changes to commit"
fi

if [ -n "$TAG" ]; then
  git tag -f "$TAG" -m "$TAG_MSG"
  echo "Tagged: $TAG"
fi
```

### Data CRUD Pattern

Generate when a central data model (e.g., tasks.jsonl) is shared across skills:

```python
#!/usr/bin/env python3
"""CRUD operations for {{data_model_name}}."""

import json, sys, os
from datetime import datetime

DATA_FILE = os.path.join(os.path.dirname(__file__), '..', '..', '{{data_file_path}}')

def list_items(**filters):
    """List items with optional filters."""
    # Filter by status, category, priority, etc.
    pass

def add_item(item: dict):
    """Append a new item."""
    pass

def update_item(item_id: str, updates: dict):
    """Update fields on an existing item."""
    pass

if __name__ == '__main__':
    # CLI: list [--status X], add <json>, update <id> <json>
    pass
```

---

## Fill Instructions

| Placeholder | Source | Example |
|------------|--------|---------|
| `{{shared_files}}` | List of shared resource paths | `["references/rlhf-loop.md", "scripts/git-safe-commit.sh"]` |
| `{{data_model_name}}` | Central data model name | `tasks` |
| `{{data_file_path}}` | Path to data file from shared/ | `company/tasks.jsonl` |
