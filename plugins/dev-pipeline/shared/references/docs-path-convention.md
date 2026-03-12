# Cross-Skill Documentation Path Convention

All skills in dev-pipeline-plugin that produce intermediate artifacts MUST follow this path convention to ensure consistency across the pipeline.

## Artifact Paths

| Pipeline Stage | Skill | Output Path | Naming Pattern |
|---------------|-------|-------------|----------------|
| Design | brainstorm (external) | `docs/designs/` | `YYYY-MM-DD-<topic>-design.md` |
| Plan | plan (external) | `docs/plans/` | `YYYY-MM-DD-<topic>-plan.md` |
| Tasks | task-breakdown | `docs/tasks/` | `YYYY-MM-DD-<topic>-tasks.md` |
| Review | review (external) | `docs/reviews/` | `YYYY-MM-DD-<topic>-review.md` |
| Tasks (with Linear) | sprint-decomposer | `docs/tasks/` | `YYYY-MM-DD-<topic>-tasks.md` (includes Linear Sync Summary section) |
| Architecture | project-analyze | `docs/structure-analysis/` | `ARCHITECTURE.md`, `CONVENTIONS.md`, `CAPABILITIES.md` |

## Naming Rules

- `YYYY-MM-DD` — date when the artifact was created
- `<topic>` — kebab-case short description of the feature/task (e.g. `user-auth`, `ai-page-builder`)
- All lowercase, no spaces

## Cross-Skill References

When one skill references another skill's output:
- Use the exact path pattern above
- Use glob to find the most recent artifact: `ls docs/plans/*-<topic>-plan.md 2>/dev/null`
- Never hardcode full dates in cross-references

## Directory Creation

Skills should create directories as needed:
```bash
mkdir -p docs/tasks
```

Do not assume directories exist.
