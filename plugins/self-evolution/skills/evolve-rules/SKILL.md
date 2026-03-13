---
name: evolve-rules
description: Use when accumulated feedback and failure patterns need to be distilled into project rules. Triggers include completing a major feature, after a series of debugging sessions, or when the user explicitly asks to evolve or update rules.
---

# Evolve Rules

Analyze accumulated feedback memories and failure logs, distill actionable rules, update skill-bank.json and .claude/rules/. Follows recursive evolution: gather evidence, extract patterns, propose changes, human review, apply.

## Process

### Step 1: Gather Evidence

Read all sources in parallel. Derive the project data directory from the current working directory using Claude Code convention (`~/.claude/projects/-<cwd-with-slashes-replaced>/`).

1. `<project-data-dir>/failures.jsonl`
2. All `<project-data-dir>/memory/feedback_*.md` files
3. `<project-data-dir>/skill-bank.json`
4. All `.claude/rules/*.md` files in the project

If failures.jsonl does not exist or is empty, and no feedback_*.md files exist, report "No evidence to process" and stop.

### Step 2: Analyze Patterns

For each failure/feedback entry:
- **Cluster** similar failures by tool + error pattern
- **Count** occurrences per pattern
- **Cross-reference** with existing rules in skill-bank.json — is it already covered?
- **Classify** domain: match to existing domains in skill-bank.json, or propose a new domain (also add its keywords to `domainKeywords`)

Threshold: only extract patterns with **>= 2 occurrences**.

### Step 3: Propose Changes

Generate an Evolution Report with four sections:

**New Rules (+)** — patterns not covered by existing rules
| # | Domain | Rule | Evidence count | Source |
|---|--------|------|---------------|--------|

**Strengthened (~)** — existing rules that need refinement (still triggered despite the rule)
| # | Current rule | Proposed change | Reason |
|---|-------------|----------------|--------|

**Promoted (up)** — skill-bank rules to move into .claude/rules/ (>= 5 hits + clear path scope)
| # | Rule | Target file | Reason |
|---|------|------------|--------|

**Deprecated (-)** — rules with no evidence in the analyzed data
| # | Domain | Rule | Reason |
|---|--------|------|--------|

Constraints:
- Max 5 new rules per evolution cycle
- Each rule must be a concrete, actionable statement (not vague advice)
- Prefer specific rules over general ones

### Step 4: Human Review

Present the Evolution Report. Wait for explicit approval before making any changes. The user may:
- Approve all (`y`)
- Reject all (`n`)
- Edit specific items

**NO CHANGES WITHOUT APPROVAL.**

### Step 5: Apply

After approval:
1. Update `skill-bank.json` — bump `_meta.version`, update `lastEvolved`, add/modify/remove rules. If a new domain was proposed, add it to both `commonMistakes` and `domainKeywords`.
2. Update `.claude/rules/*.md` if promotions were approved
3. Move processed `feedback_*.md` files to `memory/archive/` (rename with date prefix)
4. Clear processed lines from `failures.jsonl` (rewrite without processed entries, or truncate if all processed)
5. Update `memory/MEMORY.md` index if new memory files were created or archived
6. Read back updated files to confirm correctness

### Output

After completion, print a summary:
```
Evolution v{N} complete:
- {X} new rules added
- {Y} rules strengthened
- {Z} rules promoted to path-scoped
- {W} rules deprecated
- {F} feedback files archived
- {L} failure records processed
```
