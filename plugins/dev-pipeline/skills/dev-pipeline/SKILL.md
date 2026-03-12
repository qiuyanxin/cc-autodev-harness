---
name: dev-pipeline
description: "Use when starting feature development, building new functionality, or running the full dev workflow. Routes to: dev-init (project setup), task-breakdown (requirement decomposition), project-analyze (architecture discovery), workflow-forge (SOP to skill). Triggers: /dev-pipeline, 'start development', 'build feature', 'new feature'"
argument-hint: "[auto] [feature description]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Agent
user-invocable: true
---

# Dev Pipeline — Automated Development Workflow

> **Path Resolution**: `{PLUGIN_ROOT}` = 仓库根目录。

You are a development workflow orchestrator. You detect project state, check dependencies, and route to the appropriate skill or execute the full automated pipeline.

---

## Available Operations

| Command | Skill | Description | When to Use |
|---------|-------|-------------|-------------|
| `/dev-init` | `skills/dev-init/SKILL.md` | Project initialization (new or existing) | Setting up a project for the first time |
| `/task-breakdown` | `skills/task-breakdown/SKILL.md` | Requirement → executable task decomposition | After plan is ready, before execution |
| `/project-analyze` | `skills/project-analyze/SKILL.md` | Codebase architecture discovery | Before planning, to understand existing code |
| `/workflow-forge` | `skills/workflow-forge/SKILL.md` | Convert SOP → Claude Code skill scaffold | When creating new skills from workflows |
| `/sprint-decomposer` | `skills/sprint-decomposer/SKILL.md` | PRD → agent-executable tasks + Linear sync | After plan is ready, when Linear sync needed |

---

## Execution Flow

### Phase 0: Dependency Check + Smart Routing

**Step 0.1: Check dependencies**

```bash
bash {PLUGIN_ROOT}/skills/dev-pipeline/scripts/check-deps.sh
```

If missing dependencies are found, guide installation before proceeding.

**Step 0.2: Detect existing artifacts**

```bash
ls docs/designs/*.md 2>/dev/null && echo "[design]: exists"
ls docs/plans/*.md 2>/dev/null && echo "[plan]: exists"
ls docs/tasks/*.md 2>/dev/null && echo "[tasks]: exists"
ls .claude/CLAUDE.md 2>/dev/null && echo "[init]: exists"
```

**Step 0.3: Route or run full pipeline**

If user provided `auto` argument or a feature description → run full pipeline (Phase 1).
Otherwise, recommend next action based on state:

```
## Current State

- [init]: [exists/missing]
- [design]: [exists/missing]
- [plan]: [exists/missing]
- [tasks]: [exists/missing]

## Recommended: /[next-command]
Reason: [why this is the logical next step]

Select an operation:
1. /dev-init — Initialize project for dev-pipeline
2. /dev-pipeline auto [feature] — Run full automated pipeline
3. /task-breakdown — Decompose requirements into tasks (technical pipeline focus)
4. /sprint-decomposer — Decompose requirements into tasks + sync to Linear (business layer focus)
5. /project-analyze — Analyze codebase architecture
6. /workflow-forge — Convert SOP to skill
```

**WAIT for user selection.**

---

### Phase 1: Full Automated Pipeline

When user selects `auto` or provides a feature description, execute the full pipeline.

**Steps 1-3: User Confirmation Required**

1. **Brainstorm** — Detect if `ce:brainstorm` is available (CE plugin installed), otherwise use `superpowers:brainstorming`. Explore requirements, produce design doc → save to `docs/designs/YYYY-MM-DD-<topic>-design.md`

2. **Plan** — Detect if `ce:plan` is available, otherwise use `superpowers:writing-plans`. Create implementation plan → save to `docs/plans/YYYY-MM-DD-<topic>-plan.md`

3. **Task Breakdown** — Load and execute:
   ```bash
   cat {PLUGIN_ROOT}/skills/task-breakdown/SKILL.md
   ```
   Produce task list → save to `docs/tasks/YYYY-MM-DD-<topic>-tasks.md`

Present summary of design + plan + tasks to user. **WAIT for user approval before continuing.**

**Steps 4-8: Autonomous Execution (after user approves)**

4. **Create Worktree** — Detect if `superpowers:using-git-worktrees` is available. If yes, use it. If no, run manually:
   ```bash
   git worktree add ../worktree-<feature> -b feature/<feature>
   ```

5. **Execute Tasks** — Analyze task dependency graph from Step 3 output. Use `superpowers:dispatching-parallel-agents` for independent tasks (no upstream dependencies). Execute dependent tasks sequentially.

6. **Verify** — In the worktree, run build + lint + test:
   ```bash
   # detect and run project's build/lint/test commands
   ```
   If verification fails, attempt fix (max 3 rounds). If still failing after 3 rounds → stop and present errors to user for decision.

7. **Review** — Detect if `ce:review` is available. If yes, use it (29 specialized agents). If no, use `superpowers:requesting-code-review`. Save review to `docs/reviews/YYYY-MM-DD-<topic>-review.md`. If review finds issues → auto-fix (max 3 rounds). If still not passing → stop and wait for user decision.

8. **Integrate** — Detect if `superpowers:finishing-a-development-branch` is available. If yes, use it. If no, check for `gh` CLI:
   - `gh` available → create PR
   - `gh` not available → prompt user to merge manually or install gh

### Phase 2: Post-Execution Summary

```
## Pipeline Complete

### Artifacts
- Design: docs/designs/YYYY-MM-DD-<topic>-design.md
- Plan: docs/plans/YYYY-MM-DD-<topic>-plan.md
- Tasks: docs/tasks/YYYY-MM-DD-<topic>-tasks.md
- Review: docs/reviews/YYYY-MM-DD-<topic>-review.md
- Branch: feature/<topic>
- PR: [URL if created]

### Next Steps
- Review and merge the PR
- Use `compound-docs` to capture learnings (if CE plugin installed)
```
