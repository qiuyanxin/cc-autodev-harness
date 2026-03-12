# Quality Checklist

Must pass all items before outputting. **Fix any failures before output.**

---

## Red-Line Rules (violation = must fix)

- [ ] **No code snippets** — no SQL, TypeScript, Python, or any code
- [ ] **No data structure definitions** — no table schemas, interfaces, types
- [ ] **No product/marketing language** — no "empower", "deliver exceptional experience"
- [ ] **Assignees are roles not names** — e.g. "Full-stack Lead", "AI Lead"

---

## Task Quality (every task must satisfy)

- [ ] **Every task ≤ 1 day** — tasks exceeding 1 day must be split
- [ ] **Every task has clear input/output** — cannot be empty or vague
- [ ] **Every task has verifiable acceptance criteria** — must be testable/observable
- [ ] **Upstream/downstream references are correct** — IDs exist and direction is correct

---

## Structural Integrity

- [ ] **Pipelines cover all system flows** — including internal flows, not just user-visible
- [ ] **No circular dependencies in task graph** — check dependency chains for loops
- [ ] **Parallelizable tasks identified and listed** — tasks independent of critical path grouped separately

---

## Common Issues

| Issue | How to Check |
|-------|-------------|
| Task too large | Check duration column, > 1d must split |
| Missing dependency | Check if input data has a corresponding upstream task output |
| Missing Pipeline | Check for "hidden" internal flows (scheduled tasks, data sync, background processing) |
| Role mismatch | Check if each task's role matches its technical domain |
| Vague acceptance | "Done", "Implemented" don't count — must be specific and testable |
