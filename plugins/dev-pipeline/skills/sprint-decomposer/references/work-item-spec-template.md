# Work Item Spec Template

Agent 可执行的工作项模板。兼容 task-breakdown 的 W-numbered 格式，增加 Layer、Priority、Agent Notes、Key Files 字段。

## Template

```markdown
### W{P} {Parent Module Name}

---

#### W{P}-{C} {Task Title}

| Field | Content |
| ----- | ------- |
| Owner | Role name (e.g. "Full-stack Lead") |
| Duration | Xd (≤ 1d) |
| Layer | L{N}-{Layer Name} |
| Priority | P{1-4} ({Urgent/High/Medium/Low}) |
| Input | Required data/dependencies from upstream |
| Output | Deliverables (must be verifiable) |
| Upstream | W{X}-{Y} or "None (can start immediately)" |
| Downstream | W{X}-{Y} or "None" |
| Approach | Brief engineering-level steps (no code) |
| Acceptance | Verifiable completion criteria (checkbox format) |

**Key Files:**
- `path/to/relevant/file.ts`
- `path/to/another/file.ts`

**Agent Notes:**
- {Execution hints, gotchas, constraints}
- {Common pitfalls to avoid}
```

## Field Rules

### Compatibility with task-breakdown

The first 8 fields (Owner through Acceptance) match task-breakdown's unified template exactly. The additional fields (Layer, Priority, Key Files, Agent Notes) are extensions that provide richer context for agent execution and Linear sync.

Downstream consumers that only read task-breakdown format will still work — they can ignore the extra fields.

### Priority Mapping (for Linear)

| Level | Linear | Meaning |
|-------|--------|---------|
| P1 | Urgent (1) | Critical path, blocks other tasks |
| P2 | High (2) | Core flow, must complete |
| P3 | Medium (3) | Important but non-blocking |
| P4 | Low (4) | Can defer to next sprint |

### Status Mapping (for Linear)

| Condition | Initial State |
|-----------|--------------|
| No upstream dependency | Todo (agent can pick up immediately) |
| Has unfinished upstream | Planning (waiting) |
| Is a blocker | Todo + blocker label (⛔) |

### Layer Labels

| Layer | Label | Meaning |
|-------|-------|---------|
| L1 | L1-入口层 | User acquisition channels |
| L2 | L2-交付层 | User-facing product features |
| L3 | L3-服务层 | Ongoing operational services |
| L4 | L4-账户层 | User identity management |
| L5 | L5-基础设施 | Infrastructure and platform |
| L6 | L6-商业层 | Business model and monetization |

### Acceptance Criteria Rules

1. Each criterion must be objectively verifiable (not "looks good")
2. Prefer command/API verification (e.g. `pnpm lint passes`)
3. Functional criteria describe specific actions + expected results
4. Performance constraints must be quantified (e.g. `< 8s`, `≥ 4.5:1`)
