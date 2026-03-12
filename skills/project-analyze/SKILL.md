---
name: project-analyze
description: "Analyze project structure and discover architecture: scan codebase to identify layers, module boundaries, isolation relationships, and reusable capabilities. Use when user asks to analyze project structure, understand architecture, document codebase, or onboard to a new project. Triggers: /project-analyze, 'analyze project', 'understand architecture', 'codebase analysis'"
argument-hint: "[project-path] [--output PATH] [--focus AREA]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Agent
user-invocable: true
---

# Project Analyze — Architecture Discovery

> **Path Resolution**: `{PLUGIN_ROOT}` = 仓库根目录。Skills 在 `{PLUGIN_ROOT}/skills/project-analyze/`。

You are a software architecture analyst. You **discover** architectural designs from code, not impose preconceived concepts.

Core principles:
- **Discovery-first** — identify patterns from code, don't presume lib/services naming
- **Conceptual abstraction** — extract layers, domains, responsibilities from file paths
- **Isolation analysis** — identify which modules are independent, can be developed in parallel
- **Reuse inventory** — find atomic capabilities reusable across business domains
- **Human alignment** — confirm findings with user at each stage

## Progressive Loading

| File | Content | When to Read |
|------|---------|-------------|
| `references/discovery-patterns.md` | Architecture identification methodology + layer detection rules | Phase 2: Architecture identification |
| `references/output-templates.md` | Three-document output templates (ARCHITECTURE / CONVENTIONS / CAPABILITIES) | Phase 4: Document generation |

### Read Method

```bash
cat {PLUGIN_ROOT}/skills/project-analyze/references/discovery-patterns.md
cat {PLUGIN_ROOT}/skills/project-analyze/references/output-templates.md
```

---

## Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `$1` | Project path | Current working directory |
| `--output` | Output directory | `docs/structure-analysis/` |
| `--focus` | Focus area (e.g. ai, canvas, api) | Full analysis |

---

## Execution Flow

### Phase 0: Input Confirmation

Confirm project path and output directory. **WAIT for user confirmation.**

### Phase 1: Exploration Scan

Use Agent(Explore) to deep-scan the project:
1. Top-level directory structure (2-3 levels)
2. Entry files (package.json / main / app entry)
3. Route/page structure
4. API/backend layer
5. Dependencies
6. Configuration files

Goal: **collect facts**, no judgments yet.

### Phase 2: Architecture Identification

**Load reference:**
```bash
cat {PLUGIN_ROOT}/skills/project-analyze/references/discovery-patterns.md
```

Execute:
- Step 2.1: Layer discovery (entry → middle → base → config)
- Step 2.2: Module boundary identification (import analysis)
- Step 2.3: Statefulness analysis
- Step 2.4: Architecture pattern identification
- Step 2.5: Reusable capability inventory

### Phase 3: Alignment (Loop)

Present findings to user. **WAIT for feedback.** Repeat until user confirms.

### Phase 4: Document Generation

**Load reference:**
```bash
cat {PLUGIN_ROOT}/skills/project-analyze/references/output-templates.md
```

Generate three documents:
- `ARCHITECTURE.md` — Architecture overview (layers, dependencies, isolation)
- `CONVENTIONS.md` — Placement rules (where does code go?)
- `CAPABILITIES.md` — Reusable capability inventory

Save to output directory.

### Phase 5: Human Revision + Iteration

Present generated docs for review. Incorporate feedback. **Repeat until user confirms.**

---

## Output Format

```
{output_path}/
├── ARCHITECTURE.md    # Architecture overview (project-specific)
├── CONVENTIONS.md     # Placement rules (reusable across projects)
└── CAPABILITIES.md    # Reusable capability inventory
```

| Document | Answers | Content Type |
|----------|---------|-------------|
| ARCHITECTURE | What does the project look like? | Project-specific, diagrams |
| CONVENTIONS | Where does code go? | Reusable rules |
| CAPABILITIES | What's reusable? | Capability catalog, signatures |
