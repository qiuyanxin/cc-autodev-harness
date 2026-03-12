---
name: dev-init
description: "Initialize a project for dev-pipeline workflow. Auto-detects tech stack, generates .claude/ configuration (CLAUDE.md, settings.json, rules/). Works for both new and existing projects. Triggers: /dev-init, 'initialize project', 'setup project', 'init dev environment'"
argument-hint: "[project-path] [--here] [--new]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Agent
user-invocable: true
---

# Dev Init — Project Initialization

> **Path Resolution**: `{PLUGIN_ROOT}` = 仓库根目录。Skills 在 `{PLUGIN_ROOT}/skills/dev-init/`。

You are a project initialization specialist. You detect or scaffold project structure, then generate Claude Code configuration tailored to the detected tech stack.

## Progressive Loading

| File | Content | When to Read |
|------|---------|-------------|
| `references/stack-detection.md` | Tech stack detection rules and patterns | Step 1: Detecting tech stack |

### Read Method

```bash
cat {PLUGIN_ROOT}/skills/dev-init/references/stack-detection.md
```

---

## Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `$1` | Project path | Current working directory |
| `--here` | Initialize in current directory | - |
| `--new` | Create new project (scaffold) | Auto-detect |

---

## Execution Flow

### Step 0: Determine Mode

```bash
ls "$PROJECT_PATH/package.json" 2>/dev/null || ls "$PROJECT_PATH/Cargo.toml" 2>/dev/null || ls "$PROJECT_PATH/go.mod" 2>/dev/null || ls "$PROJECT_PATH/pyproject.toml" 2>/dev/null
```

- Files found → **Existing project mode**
- No project files → **New project mode** (or ask user)

Check if `.claude/` already exists:
```bash
ls "$PROJECT_PATH/.claude/CLAUDE.md" 2>/dev/null
```
- Exists → **Incremental update mode** (merge, don't overwrite)
- Not exists → **Full generation mode**

---

### Step 1: Dependency Check

```bash
bash {PLUGIN_ROOT}/skills/dev-pipeline/scripts/check-deps.sh
```

If missing critical dependencies (git, claude), stop and guide installation.
If missing optional dependencies (gh, plugins), warn but continue.

---

### Step 2: Tech Stack Detection (Existing Project)

**Load reference:**
```bash
cat {PLUGIN_ROOT}/skills/dev-init/references/stack-detection.md
```

Run detection script:
```bash
bash {PLUGIN_ROOT}/skills/dev-init/scripts/detect-stack.sh "$PROJECT_PATH"
```

Present detected stack to user:

```
## Detected Tech Stack

| Item | Value |
|------|-------|
| Framework | Next.js 16 |
| Language | TypeScript |
| Package Manager | pnpm |
| Linter | ESLint |
| Formatter | Prettier |
| Test Runner | (none detected) |
| Subprojects | canvas-editor/, magent/ |

Is this correct? Adjustments needed?
```

**WAIT for user confirmation.**

---

### Step 3: New Project Scaffold (New Project Only)

Ask user:

```
## New Project Setup

1. Project name: [user input]
2. Framework: (a) Next.js  (b) Vite + React  (c) Node.js  (d) Python  (e) Other
3. Package manager: (a) pnpm  (b) bun  (c) npm  (d) yarn
4. Include TypeScript? (Y/n)
```

**WAIT for user selection.**

Generate project scaffold based on selections:
- Initialize git repo
- Create package.json with selected framework
- Install dependencies
- Create basic directory structure

---

### Step 4: Generate .claude/ Configuration

Create directory structure:

```bash
mkdir -p "$PROJECT_PATH/.claude/rules"
```

**Generate CLAUDE.md** based on detected/selected tech stack:

```markdown
# [Project Name]

## Build & Test

| Command | Script |
|---------|--------|
| Dev | `[detected dev command]` |
| Build | `[detected build command]` |
| Lint | `[detected lint command]` |
| Test | `[detected test command]` |

## Architecture

- [One-line description based on detected framework and structure]

## Workflow

Feature development follows the dev-pipeline automated workflow:

1. `/ce:brainstorm` - explore requirements and design
2. `/ce:plan` - create implementation plan
3. `/task-breakdown` - decompose into dev-executable tasks
4. Create git-worktree for isolation
5. Execute tasks with parallel agents for independent work
6. Verify: build + lint + test before claiming done
7. Code review with specialized agents
8. Merge or create PR to integrate work

Steps 1-3 require user confirmation. Steps 4-8 run autonomously after plan approval.

## On Compaction

When compacting, preserve:
- Current task context and modified files
- Architectural decisions made in this session
```

**Generate settings.json**:

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json"
}
```

**Generate rules/** — For monorepos, create a path-scoped rule for each subproject:

```markdown
---
paths:
  - "[subproject]/**"
---

# [Subproject Name]

- Framework: [detected]
- Key directories: [detected from structure]
- [Any subproject-specific conventions]
```

---

### Step 5: Verify + Summary

Verify generated files:
```bash
ls -la "$PROJECT_PATH/.claude/"
cat "$PROJECT_PATH/.claude/CLAUDE.md" | wc -l
```

Present summary:

```
## Initialization Complete

Generated:
  .claude/CLAUDE.md          — [N] lines
  .claude/settings.json      — base configuration
  .claude/rules/             — [N] path-scoped rule files

Dependencies:
  [list installed/missing plugins with status]

Next steps:
  1. Review .claude/CLAUDE.md and adjust if needed
  2. Run /dev-pipeline to start feature development
  3. (Optional) Run /project-analyze for deep architecture discovery
```
