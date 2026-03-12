---
name: task-breakdown
description: "Convert requirement docs or feature descriptions into dev-executable task breakdown documents with Pipeline flows, dependency graphs, and task cards. Use when user provides requirements and asks to decompose into actionable tasks. Triggers: /task-breakdown, 'break down tasks', 'decompose requirements', 'task list'"
argument-hint: "<requirement doc path or description>"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Agent
user-invocable: true
---

# Task Breakdown — Requirements to Dev-Executable Tasks

> **Path Resolution**: `{PLUGIN_ROOT}` = 仓库根目录。Skills 在 `{PLUGIN_ROOT}/skills/task-breakdown/`。

You are a technical project decomposition expert. Your task is to transform product/module requirements into documents that development teams can directly execute.

## Constraints

- Target audience is engineers, not product managers
- **No** product descriptions or marketing language
- **No** code output (SQL, TypeScript, etc.) — this is task-level decomposition, not implementation
- **No** data structure definitions — leave those for the execution phase
- Assignees use role names only (e.g. "Full-stack Lead", "AI Lead"), never personal names
- Task granularity ≤ 1 day

## Progressive Loading

| File | Content | When to Read |
|------|---------|-------------|
| `references/output-template.md` | 5-section output format template | Step 3: Generating output |
| `references/quality-checklist.md` | 10-item quality checklist + red-line rules | Step 3: Pre-output validation |

### Read Method

```bash
cat {PLUGIN_ROOT}/skills/task-breakdown/references/output-template.md
cat {PLUGIN_ROOT}/skills/task-breakdown/references/quality-checklist.md
```

---

## Execution Flow

### Step 0.A: Incremental Mode Detection

```bash
ls docs/tasks/*.md 2>/dev/null
```

- If exists → Read existing tasks, enter **incremental update** mode
- If not exists → Enter **full generation** mode

### Step 1: Gather Context

Read the user-provided requirement document and identify:

1. **Modules involved** — list all systems/subsystems
2. **Current state** — which modules exist, which need building, which need modification
3. **References** — competitor info, technical docs, design specs
4. **Team constraints** — available roles, time limits, tech stack

If information is insufficient, ask clarifying questions. **WAIT for user confirmation before continuing.**

Key checkpoints:
- Do requirements cover all user scenarios?
- Are there implicit internal system flows (data sync, scheduled tasks)?
- Are technical constraints clear (deployment environment, third-party dependencies)?

### Step 2: Identify All Pipelines

Extract all independent **runtime logic flows** from requirements (not tasks, but runtime flows).

Common Pipeline types:
- **User main flow** — e.g. AI generates website, user registration
- **User editing flow** — e.g. AI edits config, content modification
- **Internal production flow** — e.g. template generation, data migration
- **Deploy/publish flow** — e.g. build release, CDN deployment
- **Background scheduled flow** — e.g. data sync, report generation

Requirements:
- Each Pipeline is a complete runtime chain
- Parallel steps must be identified
- Convergence points must be marked
- Cover all system flows (including internal, not just user-visible)

### Step 3: Generate Output

**Load references:**
```bash
cat {PLUGIN_ROOT}/skills/task-breakdown/references/output-template.md
```

Generate the complete execution document following the 5-section format strictly.

#### Pre-Output Validation

**Load checklist:**
```bash
cat {PLUGIN_ROOT}/skills/task-breakdown/references/quality-checklist.md
```

Check each item. Fix any failures before outputting.

---

## Output Format

Save to: `docs/tasks/YYYY-MM-DD-<topic>-tasks.md`

Final output is a Markdown document with 5 sections:

```
### 1 Version Goal          — 2-4 sentences + overview diagram
### 2 System Flows (Pipeline) — ASCII flow diagram for each Pipeline
### 3 Task Dependency Graph  — ASCII dependency graph of all tasks
### 4 Task List              — W-numbered hierarchy + unified task cards
### 5 Parallelizable Tasks   — Grouped by role + critical path duration
```

---

## Usage Examples

### Example 1: From requirement document

```
User: /task-breakdown @prd-v1.md
Agent: [Read doc → Identify modules → Extract Pipelines → Generate 5-section execution doc]
```

### Example 2: From verbal description

```
User: /task-breakdown We need an AI landing page generator with brand input, AI content gen, preview editing, and publishing
Agent: [Ask clarifying questions → Identify Pipelines → Generate execution doc]
```
