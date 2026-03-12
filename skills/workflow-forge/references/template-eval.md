# Evaluation Skill SKILL.md Template

The evaluation skill provides automated quality assessment with multi-dimension scoring. It serves as the quality gate in revision loops.

**Source pattern:** `skills/content-eval/SKILL.md`

---

## Template

Generate at: `{output_path}/{name}-eval/SKILL.md`

````markdown
---
name: {{workflow_name}}-eval
description: "{{eval_description}}"
argument-hint: "<输入内容|文件路径> [--dimension 维度名] [--threshold N]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Agent
user-invocable: true
---

# {{Workflow Display Name}} Evaluation Skill

## Role Definition

You are an expert {{domain}} evaluator with deep experience in quality assessment. Your evaluation framework covers {{dimension_count}} dimensions tailored to {{domain}} outputs.

### Core Competencies

{{#each competencies}}
- **{{name}}**: {{description}}
{{/each}}

---

## Evaluation Dimensions ({{dimension_count}}-Dimension Scoring)

{{#each dimensions}}
### {{@index}}. {{name}} ({{name_en}}) [0-10] — Weight {{weight}}%

{{description}}

**Scoring Criteria:**

| Score | Standard | Checkpoints |
|-------|----------|-------------|
| 9-10 | {{excellent}} | {{excellent_check}} |
| 7-8 | {{good}} | {{good_check}} |
| 5-6 | {{acceptable}} | {{acceptable_check}} |
| 3-4 | {{poor}} | {{poor_check}} |
| 0-2 | {{failing}} | {{failing_check}} |

{{/each}}

---

## Decision Framework

### Weight Configuration

| Dimension | Weight | Purpose |
|-----------|--------|---------|
{{#each dimensions}}
| {{name}} | {{weight}}% | {{weight_rationale}} |
{{/each}}

### Decision Rules

| Score Range | Decision | Action |
|-------------|----------|--------|
| >= 8.5 | **Excellent** | Ready for next phase |
| 8.0 - 8.4 | **Good** | Minor tweaks recommended |
| 7.0 - 7.9 | **Acceptable** | Optimize before proceeding |
| 5.0 - 6.9 | **Needs Work** | Significant revision required |
| < 5.0 | **Redo** | Restart this phase |

### Veto Rules

Veto rules take priority over the overall score. If any veto rule triggers, the output is considered **unqualified** regardless of how high other dimensions score.

**Check order**: Evaluate veto rules first. Only calculate weighted score if all veto rules pass.

| # | Rule | Trigger Condition | Action |
|---|------|-------------------|--------|
{{#each veto_rules}}
| {{@index}} | {{description}} | {{condition}} | {{action}} |
{{/each}}

---

## Feedback Signal System

| Signal | Value | Meaning | Trigger |
|--------|-------|---------|---------|
| Praise | +1.0 | "This is great" | Dimension >= 9 |
| Adopt | +0.5 | No changes needed | Overall >= 8.5 |
| Good | +0.3 | Minor optimization | Overall 8.0-8.4 |
| Fix | 0.0 | 1-2 revision rounds | Overall 7.0-7.9 |
| Major Fix | -0.5 | 3+ revision rounds | Overall 5.0-6.9 |
| Criticize | -1.0 | "This has problems" | Dimension < 5 |

---

## Output Format

```
## Evaluation Report

### Overall Score: X.X / 10
**Decision: [Excellent/Good/Acceptable/Needs Work/Redo]**

---

### Dimension Scores

| Dimension | Score | Weight | Signal | Notes |
|-----------|-------|--------|--------|-------|
{{#each dimensions}}
| {{name}} | X/10 | {{weight}}% | [signal] | [brief note] |
{{/each}}

---

### Improvement Suggestions

#### Strengths (Keep)
- [What's working well]

#### Recommended Improvements
1. [Suggestion 1] — Expected improvement: +X points
2. [Suggestion 2] — Expected improvement: +X points

#### Must Fix (Blocking)
- [Critical issues that must be addressed]
```

---

## Usage

### Basic Evaluation

```
/{{eval_command}} [paste content or file path]
```

### Evaluation with Specific Focus

```
/{{eval_command}} [content] --dimension {{example_dimension}}
```

### Threshold Override

```
/{{eval_command}} [content] --threshold 8.0
```
````

---

## Fill Instructions

| Placeholder | Source | Example |
|------------|--------|---------|
| `{{workflow_name}}` | From workflow name | `onboarding` |
| `{{eval_description}}` | One-line | `"Customer onboarding quality evaluation with 5-dimension scoring"` |
| `{{domain}}` | From Phase 1 domain knowledge | `"customer onboarding"` |
| `{{dimension_count}}` | Number of scoring dimensions | `5` |
| `{{dimensions}}` | From Phase 1 quality standards | Array of dimension objects |
| `{{competencies}}` | Evaluator expertise areas | Derived from domain |
| `{{veto_rules}}` | Hard-fail conditions with description, trigger condition, and action | From Phase 1 quality red lines |
| `{{eval_command}}` | Slash command for eval | `onboarding-eval` |

---

## Dimension Design Guidelines

When the user hasn't specified dimensions, derive them from the workflow:

1. **Domain-specific quality** — Is the core output good? (always include)
2. **Completeness** — Are all required elements present?
3. **Consistency** — Does output align with brand/style? (if brand enabled)
4. **Accuracy** — Are facts/data correct? (if domain involves facts)
5. **Actionability** — Can the output be used as-is? (if output goes to end users)
6. **Risk** — Are there compliance/safety concerns? (if domain has regulations)

Aim for 4-7 dimensions. Too few lacks granularity; too many creates evaluation fatigue.

## Weight Distribution

- Core quality dimensions: 15-20% each
- Supporting dimensions: 10-15% each
- Total must equal 100%
- The most important dimension (usually domain-specific quality) gets the highest weight
