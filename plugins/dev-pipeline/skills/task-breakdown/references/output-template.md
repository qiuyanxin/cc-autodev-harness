# Output Format Template

Generate execution document strictly following these 5 sections. Format and content requirements are mandatory.

---

## 1 Version Goal

2-4 sentences: what problem this version solves, what capability it delivers.

Include an overview flow diagram:

```
┌──────────────────────────────────────┐
│  Step A → Step B → Step C → Step D   │
│        ↓                             │
│  Step E → Step F                     │
└──────────────────────────────────────┘
```

---

## 2 System Flows (Pipeline)

Each Pipeline uses an ASCII flow diagram:
- Each node is a **system runtime step** (not a task)
- Nodes wrapped in boxes with 1-line description
- Parallel steps arranged horizontally
- Convergence points shown with merge arrows

Format:

```
Pipeline 1: [Pipeline Name]

┌─────────────────┐
│  Step Name       │  Brief description
└───────┬─────────┘
        ↓
        ├──────────────────────┬──────────────────┐
        ↓                      ↓                  ↓
┌──────────────┐    ┌──────────────┐   ┌──────────────┐
│ Parallel A    │    │ Parallel B   │   │ Parallel C    │
└──────┬───────┘    └──────┬───────┘   └──────┬───────┘
       └──────────────────┼────────────────────┘
                          ↓
               ┌─────────────────┐
               │  Convergence     │
               └─────────────────┘
```

---

## 3 Task Dependency Graph

ASCII graph showing all task dependencies:
- Each task: `W-number (Role)` + task name
- `→` or `↓` for dependency direction
- Independent tasks marked `(can start immediately)`
- Same level = can parallelize

---

## 4 Task List

Numbering uses **parent-child structure**:
- W1 is parent task (module name)
- W1-1, W1-2 are child tasks (executable work items)

Each child task uses unified template:

```markdown
### W1 Parent Task Name

---

#### W1-1 Child Task Name

| Field | Content |
| ----- | ------- |
| Owner | Role name (e.g. "Full-stack Lead") |
| Duration | Xd (≤ 1d) |
| Input | Required data/dependencies |
| Output | Deliverables |
| Upstream | Dependency task number or "None" |
| Downstream | Which task uses this or "None" |
| Approach | Brief steps (engineering-level, no code) |
| Acceptance | Verifiable completion criteria |
```

---

## 5 Parallelizable Tasks

Group by role, listing tasks that can start independently:

```
AI Lead:
- W?-? Task name
- W?-? Task name

Full-stack Lead:
- W?-? Task name
```

End with critical path and estimated total duration:

```
Critical Path: W1-1 → W1-2 → W2-2 → W3-1
Estimated Duration: Xd
```
