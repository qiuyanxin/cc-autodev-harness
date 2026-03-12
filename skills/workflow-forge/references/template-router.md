# Router Skill SKILL.md Template

Router skills serve as the user-facing entry point for multi-skill suites within the same plugin. They detect context, recommend the best sub-skill, and route execution.

**Key distinction:**
- **Orchestrator**: Cross-skill coordination for pipelines (article-pipeline → writer-write, content-eval, humanize-zh)
- **Router**: Intra-suite coordination (ceo-plan → ceo-diagnose, ceo-roadmap, ceo-review)

**Source pattern:** `skills/ceo-plan/SKILL.md`

---

## Template

Generate at: `{output_path}/{scope}/SKILL.md` (or `{output_path}/{scope}-plan/SKILL.md`)

The router is the `user-invocable: true` entry point. Sub-skills typically have `user-invocable: true` as well (can be called directly).

````markdown
---
name: {{router_name}}
description: "{{router_description}}"
argument-hint: "{{argument_hint}}"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Agent
user-invocable: true
---

# {{Display Name}}

> **Path Resolution**: `{PLUGIN_ROOT}` = 仓库根目录。

{{role_definition}}

---

## Available Operations

| Command | Skill | Description | When to Use |
|---------|-------|-------------|-------------|
{{#each sibling_skills}}
| `/{{command}}` | `skills/{{name}}/SKILL.md` | {{description}} | {{when}} |
{{/each}}

---

## Execution Flow

### Phase 0: Load Context + Smart Routing

**Step 0.1: Load shared context**

```bash
{{#each context_files}}
cat {PLUGIN_ROOT}/{{path}}
{{/each}}
```

**Step 0.2: Detect existing outputs (incremental mode)**

```bash
{{#each sibling_skills}}
ls {{output_path}}/{{output_file}} 2>/dev/null && echo "[{{name}}]: output exists"
{{/each}}
```

**Step 0.3: Recommend next action**

Based on what exists and what's missing, recommend the most logical next step:

{{#each routing_rules}}
- {{condition}} → recommend `/{{command}}` ({{reason}})
{{/each}}

Present recommendation:

```
## 当前状态

{{#each sibling_skills}}
- [{{name}}]: [✅ 已有 / ❌ 未生成]
{{/each}}

## 推荐操作: /{{recommended_command}}
理由: {{recommendation_reason}}

输入操作编号或直接输入命令：
{{#each sibling_skills}}
{{@index}}. /{{command}} — {{description}}
{{/each}}
```

**WAIT for user selection.**

### Phase 1: Route to Sub-Skill

Based on user selection, load and execute the corresponding skill:

```bash
cat {PLUGIN_ROOT}/skills/{{selected_skill}}/SKILL.md
```

Pass through any arguments the user provided.

### Phase 2: Post-Execution Summary

After the sub-skill completes, show status and suggest next steps:

```
## 完成: /{{executed_command}}

### 下一步建议
{{#each next_steps}}
- /{{command}} — {{reason}}
{{/each}}
```
````

---

## Fill Instructions

| Placeholder | Source | Example |
|------------|--------|---------|
| `{{router_name}}` | Router skill name (scope or scope-plan) | `ceo-plan` |
| `{{router_description}}` | One-line with sub-skills listed | `"AI CEO: diagnose + roadmap + review"` |
| `{{role_definition}}` | Broad role covering all sub-skills | `"You are the CEO agent..."` |
| `{{sibling_skills}}` | From Phase 2 architecture | `[{name: "ceo-diagnose", ...}, ...]` |
| `{{context_files}}` | Shared context for all sub-skills | `["shared/references/company-context.md"]` |
| `{{routing_rules}}` | Logic for recommending sub-skills | Based on output existence checks |

---

## Key Patterns

1. **Thin router** — Router itself should be < 150 lines. All domain logic lives in sub-skills.
2. **Smart defaults** — Detect existing outputs and recommend the logical next action.
3. **Incremental awareness** — Check what already exists before suggesting what to do.
4. **Pass-through args** — Router forwards user arguments to the selected sub-skill unchanged.
5. **All skills directly invocable** — Sub-skills can be called without going through the router.
6. **Post-execution guidance** — After each sub-skill, suggest the natural next step.

## Directory Structure

All skills in a suite are flat siblings under `skills/`:

```
{plugin-root}/
├── skills/
│   ├── ceo-plan/
│   │   └── SKILL.md         # Router (entry point, < 150 lines)
│   ├── ceo-diagnose/
│   │   ├── SKILL.md         # Sub-skill 1
│   │   └── references/
│   ├── ceo-roadmap/
│   │   └── SKILL.md         # Sub-skill 2
│   └── ceo-review/
│       └── SKILL.md         # Sub-skill 3
└── shared/
    └── references/           # Cross-skill shared knowledge
        └── ...
```
