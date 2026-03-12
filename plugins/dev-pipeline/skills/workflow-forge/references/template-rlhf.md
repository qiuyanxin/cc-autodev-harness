# RLHF Self-Evolution System Template

The RLHF system enables specialist skills to learn and improve from user feedback over repeated use. It tracks rules, scores them based on feedback, and evolves the rule set.

**Source pattern:** `skills/writer-write/references/rlhf-loop.md`

---

## Template

Generate at: `{output_path}/{skill-name}/references/rlhf-loop.md`

````markdown
# RLHF Loop — {{Plugin Display Name}} Self-Evolution System

## Core Concept

Traditional feedback is passive collection. RLHF Loop is active evolution.

- **Passive**: Record what user says, accumulate rules
- **Active**: System self-organizes, tests, optimizes, and retires rules

## RLHF Loop Architecture

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│    ┌──────────┐    ┌──────────┐    ┌──────────┐        │
│    │ Generate │───>│ Feedback │───>│  Reward  │        │
│    │ (生成)   │    │ (反馈)   │    │ (建模)   │        │
│    └──────────┘    └──────────┘    └──────────┘        │
│          ^                               │              │
│          │                               v              │
│    ┌──────────┐                    ┌──────────┐        │
│    │  Apply   │<───────────────────│  Update  │        │
│    │ (应用)   │                    │ (更新)   │        │
│    └──────────┘                    └──────────┘        │
│          │                               │              │
│          │         ┌──────────┐          │              │
│          └────────>│Consolidate│<────────┘              │
│                    │ (整合)   │                         │
│                    └──────────┘                         │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Five-Phase Cycle

### Phase 1: Generate

Execute based on current rule set.

**Input:** {{input_description}} + current rules
**Output:** {{output_description}} + metadata (which rules were applied)

**Key:** Record which rules were applied for later attribution.

### Phase 2: Feedback Collection

Collect explicit and implicit user feedback.

**Explicit feedback:**
- "This part is good" / "This part needs work"
- "Change it to this"
- Score (if user provides one)

**Implicit feedback:**
- Did user request revisions? (No revision = positive signal)
- How many revision rounds? (Fewer = better)
- Did user adopt the output?

**Key:** Proactively ask for structured feedback.

### Phase 3: Reward Modeling

Convert feedback into rule scores.

**Rule Score Calculation:**
```
Rule Score = Σ(application_count × feedback_signal) / total_applications

Feedback signals:
  +1.0 = Explicit praise
  +0.5 = Adopted without changes
  +0.0 = Minor changes made
  -0.5 = Major changes needed
  -1.0 = Explicit criticism
```

**Rule Confidence:**
```
Confidence = 1 - 1/(application_count + 1)

1 application:  50% confidence
5 applications: 83% confidence
10 applications: 91% confidence
```

### Phase 4: Policy Update

Update rule set based on scores.

**Rule Mutation Strategy:**

| Score Range | Confidence | Action |
|-------------|-----------|--------|
| > 0.7 | > 80% | **Strengthen**: Raise priority, consider generalizing |
| 0.3 - 0.7 | > 80% | **Maintain**: Continue observing |
| < 0.3 | > 80% | **Weaken**: Lower priority, consider retiring |
| Any | < 50% | **Explore**: Increase application to collect data |

**Rule Generalization:**
When a specific rule scores high, extract a more abstract version.

Example:
- Specific: "{{specific_rule_example}}"
- Generalized: "{{generalized_rule_example}}"
- Further: "{{abstract_rule_example}}"

**Rule Specialization:**
When an abstract rule fails in certain contexts, split into conditional rules.

### Phase 5: Consolidate

Periodic optimization (every 10 sessions or user-triggered):

1. **Deduplicate** — Merge semantically similar rules
2. **Resolve conflicts** — Keep higher-scoring rule when rules contradict
3. **Organize hierarchy** — Structure rules as a tree
4. **Clean dead rules** — Remove long-unused or consistently low-scoring rules
5. **Detect overfitting** — Identify overly specific, non-generalizable rules

## Data Structures

### Rule Structure

```yaml
- id: rule_001
  category: {{example_category}}
  content: "{{example_rule}}"
  priority: high
  score: 0.85
  confidence: 0.91
  applied_count: 12
  positive_feedback: 9
  negative_feedback: 1
  neutral: 2
  created_at: YYYY-MM-DD
  last_applied: YYYY-MM-DD
  parent_rule: null
  child_rules: []
  conditions: []
  examples:
    good: ["..."]
    bad: ["..."]
```

### Episode Record

```yaml
- episode_id: ep_001
  date: YYYY-MM-DD
  topic: "{{example_topic}}"
  rules_applied: [rule_001, rule_003]
  output_version: 1
  revisions: 2
  final_adopted: true
  explicit_feedback:
    - target: {{feedback_target}}
      signal: +1.0
      comment: "..."
  implicit_signals:
    revision_count: 2
    adopted: true
```

## Implementation Instructions

### Per-Session Flow

```
1. Read rule file (evolution-state.yaml)
2. Select rules to apply (prioritize high-score, high-confidence)
3. Generate output
4. Record applied rule IDs
5. Collect feedback
6. Update rule scores
7. Check if consolidation needed (every 10 sessions)
```

### Exploration Mechanism

To avoid local optima, every 5 sessions:

- Randomly apply a low-confidence rule
- Or try a new variant rule
- Record exploration results

### A/B Testing

When user has time:

```
User: [task description]

Agent: I prepared two versions:

**Version A** (rules: {{rule_set_a}})
[Content A]

**Version B** (rules: {{rule_set_b}})
[Content B]

Which do you prefer? This helps me optimize.
```

## Evolution Trigger Commands

| Command | Action |
|---------|--------|
| "进化报告" / "evolution report" | Output current rule scores |
| "整合规则" / "consolidate" | Run consolidation now |
| "A/B 测试" / "A/B test" | Generate two versions next time |
| "探索模式" / "explore" | Try low-confidence rules |
| "重置规则" / "reset rules" | Clear learning history |
| "导出规则" / "export rules" | Output portable rule file |

## Cold Start Strategy

For new workflows with no history:

1. Use default rules from domain methodology (specialist SKILL.md)
2. Force structured feedback collection for first 5 sessions
3. Enable full RLHF loop after session 5

## File Structure

```
skills/{skill-name}/
├── SKILL.md
└── references/
    ├── rlhf-loop.md              # This file
    ├── learned-patterns.md       # Rule storage (human-readable)
    └── evolution-state.yaml      # Evolution state (scores, episodes)
```
````

---

## Fill Instructions

| Placeholder | Source | Example |
|------------|--------|---------|
| `{{Plugin Display Name}}` | Specialist plugin name | `Customer Assessment` |
| `{{input_description}}` | What goes into the specialist | `"Customer profile + assessment criteria"` |
| `{{output_description}}` | What the specialist produces | `"Readiness report + recommendations"` |
| `{{specific_rule_example}}` | Domain-specific rule | `"Use ROI examples for enterprise clients"` |
| `{{generalized_rule_example}}` | Broader version | `"Use financial metrics for enterprise"` |
| `{{abstract_rule_example}}` | Most abstract | `"Use industry-relevant metrics"` |
| `{{example_category}}` | Rule category name | `"Communication style"` |
| `{{example_rule}}` | Example rule content | `"Keep recommendations to 3-5 items"` |

---

## Additional File: evolution-state.yaml (Initial)

Also generate an empty initial state file at `{output_path}/{skill-name}/references/evolution-state.yaml`:

```yaml
# {{Plugin Display Name}} - Evolution State
# Auto-managed by RLHF Loop system

meta:
  total_sessions: 0
  last_consolidation: null
  avg_revision_count: 0
  adoption_rate: 0

rules: []

episodes: []
```

---

## Key Patterns from Source

1. **Five-phase loop** — Generate → Feedback → Reward → Update → Consolidate
2. **Score + confidence** — Both metrics needed to decide rule fate
3. **Generalization/specialization** — Rules evolve in both directions
4. **Exploration mechanism** — Prevents getting stuck in local optima
5. **A/B testing** — Optional user-driven comparison
6. **Cold start** — Sensible defaults before enough data accumulates
7. **Trigger commands** — User-accessible evolution controls
