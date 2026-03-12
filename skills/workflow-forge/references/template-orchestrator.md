# Orchestrator SKILL.md Template

The orchestrator is the central pipeline skill that coordinates all specialist skills. It manages workflow state, phase transitions, and user interactions.

**Source pattern:** `skills/article-pipeline/SKILL.md`

---

## Template

Generate at: `{output_path}/{name}-pipeline/SKILL.md`

````markdown
---
name: {{workflow_name}}-pipeline
description: "{{workflow_description_one_line}}"
argument-hint: "{{argument_hint}}"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Agent
user-invocable: true
---

# {{Workflow Display Name}} Pipeline

> **Path Resolution**: `{PLUGIN_ROOT}` = 仓库根目录。Skills 在 `{PLUGIN_ROOT}/skills/{name}/`，共享资源在 `{PLUGIN_ROOT}/shared/`。

{{workflow_description_paragraph}}

## Trigger Phrases

- `/{{trigger_command}}`
- `/{{trigger_command_alt}}`
- "{{natural_language_trigger_1}}"
- "{{natural_language_trigger_2}}"

## Prerequisites

The following sibling skills must be installed in the same plugin:

| Skill | Purpose |
|-------|---------|
{{#each specialist_skills}}
| `{{name}}` | {{purpose}} |
{{/each}}

---

## Workflow Steps

### Phase 0: Project Setup

**Step 0.1: Initialize State**

```yaml
state:
  current_phase: 0
  revision_count: 0
{{#if brand_enabled}}
  selected_brand: null
  brand_abbrev: "default"
{{/if}}
  output_base: null
  output_path: null
```

**Step 0.2: Load Configuration**

Check if config file exists:
```bash
cat {PLUGIN_ROOT}/config.yaml
```

**Case A — Config exists** (has `output_base` value):
- Skip path setup
- Ask user: "新建任务，还是继续已有任务？"
  - **新建** → proceed to Phase 1
  - **继续** → list existing folders, let user pick, resume from appropriate phase

**Case B — Config does NOT exist** (first run):
- Ask user: "请设置默认输出目录："
- Save to config:
  ```bash
  echo "output_base: {user_input}" > {PLUGIN_ROOT}/config.yaml
  ```

{{#if brand_enabled}}
**Step 0.3: Brand/Persona Selection (Optional)**

Ask user: "请选择人设配置（可跳过）："

Available brands:

| Brand File | Abbreviation | Description |
|------------|--------------|-------------|
| Skip | `default` | 使用默认风格 |

<!-- TODO: Populate with actual brand files after first brand is created -->

If brand selected:
1. Set `brand_abbrev` to filename without `.md`
2. Load: `cat {PLUGIN_ROOT}/skills/{{primary_specialist}}/brands/{brand-file}.md`
{{/if}}

---

{{#each phases}}
### Phase {{number}}: {{name}}

{{description}}

{{#each steps}}
**Step {{../number}}.{{@index}}: {{title}}**

{{#if invokes_skill}}
Invoke: `/{{skill_command}}`

{{skill_instructions}}
{{else}}
{{instructions}}
{{/if}}

{{#if wait_for_user}}
**WAIT for user confirmation before proceeding.**
{{/if}}

{{/each}}

{{#if has_revision_loop}}
**Revision Loop:**

```
WHILE (current_score < {{pass_score}}) AND (revision_count < {{max_revisions}}):
    1. Revise based on feedback
    2. Re-invoke /{{eval_command}}
    3. revision_count += 1
END WHILE
```

Exit conditions (any one):
- Score >= {{pass_score}}
- revision_count = {{max_revisions}} → Notify user for manual evaluation
{{/if}}

---

{{/each}}

## Output File Structure

```
{output_base}/{{output_folder_pattern}}/
{{output_tree}}
```

---

## Usage Examples

### Example 1: Quick Start

```
User: /{{trigger_command}}
      {{example_input}}

Agent: [Follows all phases automatically]
```

---

## Configuration

### Review Score Threshold

Default passing score: **{{pass_score}}**

### Maximum Revisions

Default: **{{max_revisions}} times**
````

---

## Fill Instructions

| Placeholder | Source | Example |
|------------|--------|---------|
| `{{workflow_name}}` | From Phase 2 architecture | `onboarding` |
| `{{workflow_description_one_line}}` | Concise pipeline description | `"End-to-end customer onboarding: intake → assessment → setup → training"` |
| `{{argument_hint}}` | Main arguments the pipeline accepts | `"[客户名] [--brand NAME] [--skip-training]"` |
| `{{trigger_command}}` | Primary slash command | `onboarding-pipeline` |
| `{{specialist_skills}}` | From Phase 2 architecture table | List of all sibling skills |
| `{{phases}}` | From Phase 0 confirmed phases | Each phase becomes a ### section |
| `{{primary_specialist}}` | The main content-creating specialist | `writer-write` equivalent |
| `{{pass_score}}` | From Phase 1 quality standards | `9` (0-10 scale) |
| `{{max_revisions}}` | From Phase 1 iteration logic | `3` |
| `{{output_folder_pattern}}` | Output organization pattern | `{brand_abbrev}/{YYYY-MM-DD}-{title}` |

---

## Key Patterns from Source

1. **State initialization** — Always define state at the start with all variables
2. **Config persistence** — Use `config.yaml` for output_base and other persistent settings
3. **Brand selection** — Optional step early in the flow, affects downstream skills
4. **Skill invocation** — Use `/command` syntax to invoke sibling skills
5. **Revision loops** — WHILE loop with score threshold and max revision count
6. **User confirmation gates** — Explicit "WAIT" markers at key decision points
7. **Path convention** — `{PLUGIN_ROOT}/skills/{sibling}/` for cross-skill references
