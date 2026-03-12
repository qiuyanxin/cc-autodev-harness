# dev-pipeline

Automated development pipeline plugin for Claude Code. Takes you from requirements to merged PR with minimal manual intervention.

## Pipeline

```
/dev-pipeline auto "feature description"

  User confirms (steps 1-3):           Autonomous (steps 4-8):
  ┌──────────┐ ┌──────┐ ┌─────────┐   ┌─────────┐ ┌─────────┐ ┌────────┐ ┌────────┐ ┌───────────┐
  │Brainstorm│→│ Plan │→│  Tasks  │──→│Worktree │→│Execute  │→│Verify  │→│Review  │→│ Integrate │
  └──────────┘ └──────┘ └─────────┘   └─────────┘ └─────────┘ └────────┘ └────────┘ └───────────┘
       ↕            ↕         ↕              Autonomous after user approval
   User confirms each step              - Parallel agents for independent tasks
                                         - Auto-fix on review failure (max 3 rounds)
                                         - Creates PR or prompts merge
```

## Installation

```bash
# 1. Add marketplace
claude plugin marketplace add qiuyanxin/cc-autodev-harness

# 2. Install plugin
claude plugin install dev-pipeline@cc-autodev-harness

# 3. Restart Claude Code to activate
```

## Skills

| Skill | Command | Description |
|-------|---------|-------------|
| **dev-pipeline** | `/dev-pipeline` | Router + full pipeline orchestration. Detects project state and routes to the right skill, or runs the complete 8-step automated pipeline |
| **dev-init** | `/dev-init` | Initialize any project (new or existing) for the dev-pipeline workflow. Auto-detects tech stack, generates `.claude/` config (CLAUDE.md, settings.json, path-scoped rules) |
| **task-breakdown** | `/task-breakdown` | Convert requirements into dev-executable task documents with Pipeline flow diagrams, dependency graphs, and task cards (granularity ≤ 1 day) |
| **project-analyze** | `/project-analyze` | Discover codebase architecture: layers, module boundaries, isolation relationships, reusable capabilities. Outputs ARCHITECTURE.md, CONVENTIONS.md, CAPABILITIES.md |
| **workflow-forge** | `/workflow-forge` | Transform any SOP or workflow into Claude Code skill scaffolds. Supports 4 maturity levels (L0 Seed → L3 Ecosystem) |

## Quick Start

### Option A: Full Automated Pipeline

```bash
# Initialize your project (run once)
/dev-init

# Build a feature end-to-end
/dev-pipeline auto "Add user authentication with OAuth"
```

Claude will:
1. Explore requirements with you (brainstorm)
2. Create an implementation plan
3. Decompose into executable tasks
4. *After your approval* — automatically create a worktree, execute tasks in parallel, verify builds, run code review, and create a PR

### Option B: Step by Step

```bash
/dev-pipeline          # See current state, get next-step recommendation
/task-breakdown        # Decompose a requirement doc into tasks
/project-analyze       # Understand an unfamiliar codebase
/workflow-forge        # Turn a workflow into a reusable skill
```

### Option C: Initialize an Existing Project

```bash
# In your project directory
/dev-init --here

# For a new project
/dev-init my-new-app --new
```

`dev-init` will:
- Detect your tech stack (framework, package manager, linter, test runner)
- Generate `.claude/CLAUDE.md` with build commands and workflow config
- Create path-scoped rules for monorepo subprojects
- Check and install missing plugin dependencies

## Dependencies

### Required

| Dependency | Purpose | Auto-Install |
|-----------|---------|:------------:|
| **git** | Version control, worktree isolation | No |
| **superpowers plugin** | Worktree management, parallel agents, verification, branch finishing | Yes |

### Recommended

| Dependency | Purpose | Auto-Install |
|-----------|---------|:------------:|
| **compound-engineering plugin** | Advanced brainstorming, planning, 29 specialized review agents | Yes |
| **gh CLI** | Automatic PR creation | No (prompted) |

Missing dependencies are detected automatically. The plugin provides installation commands and falls back gracefully when optional dependencies are absent.

## Fallback Behavior

The pipeline adapts to what's installed:

| Capability | With CE Plugin | Without CE Plugin |
|-----------|---------------|-------------------|
| Brainstorm | `ce:brainstorm` + `document-review` | `superpowers:brainstorming` |
| Plan | `ce:plan` | `superpowers:writing-plans` |
| Execute | `ce:work` + git-worktree | `superpowers:executing-plans` + manual worktree |
| Review | `ce:review` (29 specialized agents) | `superpowers:requesting-code-review` |
| Integration | `finishing-a-development-branch` | Manual merge prompt |

## Artifact Output

All pipeline artifacts are saved to `docs/` with consistent naming:

```
docs/
├── designs/              ← Brainstorm output
│   └── 2025-03-12-user-auth-design.md
├── plans/                ← Implementation plan
│   └── 2025-03-12-user-auth-plan.md
├── tasks/                ← Task decomposition
│   └── 2025-03-12-user-auth-tasks.md
├── reviews/              ← Code review results
│   └── 2025-03-12-user-auth-review.md
└── structure-analysis/   ← Architecture discovery (from /project-analyze)
    ├── ARCHITECTURE.md
    ├── CONVENTIONS.md
    └── CAPABILITIES.md
```

## How It Works

### Pipeline Phases

| Phase | What Happens | User Action |
|-------|-------------|-------------|
| 1. Brainstorm | Explore requirements, produce design doc | Confirm design |
| 2. Plan | Create technical implementation plan | Confirm plan |
| 3. Task Breakdown | Decompose into Pipeline flows + dependency graph + task cards | Approve to start |
| 4. Worktree | Create isolated git worktree for the feature | Automatic |
| 5. Execute | Dispatch independent tasks to parallel agents | Automatic |
| 6. Verify | Run build + lint + test in worktree | Auto-fix (max 3 rounds) |
| 7. Review | Multi-agent code review | Auto-fix (max 3 rounds) |
| 8. Integrate | Create PR or merge | Automatic |

If verification or review fails after 3 auto-fix attempts, the pipeline pauses and presents the issues for your decision.

### Dependency Detection

On first run, `check-deps.sh` scans for:
- `gh` CLI availability
- Superpowers plugin installation status
- Compound Engineering plugin installation status

Missing plugins are installed automatically via `claude plugin install`. A session restart is required after plugin installation.

### Tech Stack Detection

`dev-init` uses `detect-stack.sh` to identify:
- Package manager (pnpm, bun, npm, yarn, cargo, go)
- Framework (Next.js, Vite, Nuxt, Angular, etc.)
- Language (TypeScript, JavaScript, Rust, Go, Python)
- Linter/Formatter (ESLint, Biome, Prettier)
- Test runner (Vitest, Jest, Pytest)
- Monorepo subprojects

## Plugin Structure

```
plugins/dev-pipeline/
├── .claude-plugin/plugin.json
├── skills/
│   ├── dev-pipeline/              ← Router (132 lines)
│   │   ├── SKILL.md
│   │   └── scripts/check-deps.sh
│   ├── dev-init/                  ← Project initialization (225 lines)
│   │   ├── SKILL.md
│   │   ├── references/stack-detection.md
│   │   └── scripts/detect-stack.sh
│   ├── task-breakdown/            ← Task decomposition (134 lines)
│   │   ├── SKILL.md
│   │   └── references/
│   │       ├── output-template.md
│   │       └── quality-checklist.md
│   ├── project-analyze/           ← Architecture discovery (117 lines)
│   │   ├── SKILL.md
│   │   └── references/
│   │       ├── discovery-patterns.md
│   │       └── output-templates.md
│   └── workflow-forge/            ← SOP → Skill generator (501 lines)
│       ├── SKILL.md
│       └── references/ (16 files)
└── shared/
    └── references/
        └── docs-path-convention.md
```

## Configuration

After running `/dev-init`, your project will have:

```
your-project/
└── .claude/
    ├── CLAUDE.md           ← Build commands + architecture + workflow config
    ├── settings.json       ← Hooks (optional)
    └── rules/              ← Path-scoped rules for subprojects
        ├── frontend.md     ← paths: ["src/frontend/**"]
        └── api.md          ← paths: ["src/api/**"]
```

CLAUDE.md follows the [official best practices](https://code.claude.com/docs/en/best-practices): under 200 lines, specific and verifiable instructions, no redundant information.

## Upgrading

```bash
# Update to latest version
claude plugin update dev-pipeline@cc-autodev-harness

# Restart Claude Code to apply
```

## License

MIT
