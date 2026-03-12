# dev-pipeline

Automated development pipeline plugin for Claude Code. Takes you from requirements to merged PR with minimal manual intervention.

## Pipeline

```
/dev-pipeline auto "feature description"

  User confirms (steps 1-3):        Autonomous (steps 4-8):
  ┌──────────┐  ┌────────┐  ┌──────────────┐  ┌──────────┐  ┌─────────┐  ┌────────┐  ┌────────┐  ┌───────────┐
  │ Brainstorm│→│  Plan  │→│Task Breakdown│→│ Worktree │→│ Execute │→│ Verify │→│ Review │→│ Integrate │
  └──────────┘  └────────┘  └──────────────┘  └──────────┘  └─────────┘  └────────┘  └────────┘  └───────────┘
```

## Skills

| Skill | Command | Description |
|-------|---------|-------------|
| **dev-pipeline** | `/dev-pipeline` | Router + full pipeline orchestration |
| **dev-init** | `/dev-init` | Project initialization (new or existing) |
| **task-breakdown** | `/task-breakdown` | Requirements → executable task decomposition |
| **project-analyze** | `/project-analyze` | Codebase architecture discovery |
| **workflow-forge** | `/workflow-forge` | Convert SOP → Claude Code skill scaffold |

## Installation

```bash
# Add marketplace and install
claude plugin marketplace add github:<your-username>/dev-pipeline-plugin
claude plugin install dev-pipeline@<marketplace-name>

# Restart Claude Code after installation
```

## Dependencies

### Required
- **git** — version control
- **superpowers plugin** — provides worktree management, parallel agents, verification, branch finishing

### Recommended
- **compound-engineering plugin** — provides advanced brainstorming, planning, 29 specialized review agents
- **gh CLI** — enables automatic PR creation

Missing dependencies are detected automatically by `/dev-init` and `/dev-pipeline`. Installation commands are provided when gaps are found.

## Quick Start

```bash
# 1. Initialize your project
/dev-init

# 2. Start building a feature
/dev-pipeline auto "Add user authentication with OAuth"

# Or step by step
/dev-pipeline        # Shows current state and suggests next action
/task-breakdown      # Decompose requirements into tasks
/project-analyze     # Understand codebase architecture
```

## Artifact Output

All pipeline artifacts are saved to `docs/`:

```
docs/
├── designs/    YYYY-MM-DD-<topic>-design.md
├── plans/      YYYY-MM-DD-<topic>-plan.md
├── tasks/      YYYY-MM-DD-<topic>-tasks.md
├── reviews/    YYYY-MM-DD-<topic>-review.md
└── structure-analysis/
    ├── ARCHITECTURE.md
    ├── CONVENTIONS.md
    └── CAPABILITIES.md
```

## Fallback Behavior

The pipeline adapts to what's installed:

| Capability | With CE Plugin | Without CE Plugin |
|-----------|---------------|-------------------|
| Brainstorm | `ce:brainstorm` | `superpowers:brainstorming` |
| Plan | `ce:plan` | `superpowers:writing-plans` |
| Review | `ce:review` (29 agents) | `superpowers:requesting-code-review` |
| Integration | `finishing-a-development-branch` | Manual merge prompt |

## License

MIT
