# Specialist Skill SKILL.md Template

Specialist skills handle a single phase or capability in the workflow. They contain deep domain knowledge and may use progressive loading for large knowledge bases.

**Source pattern:** `skills/writer-write/SKILL.md`

---

## Template

Generate at: `{output_path}/{skill-name}/SKILL.md`

````markdown
---
name: {{skill_name}}
description: "{{skill_description}}"
argument-hint: "{{argument_hint}}"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Agent
user-invocable: true
---

# {{Display Name}}

> **Path Resolution**: `{PLUGIN_ROOT}` = 仓库根目录。Skills 在 `{PLUGIN_ROOT}/skills/{name}/`，共享资源在 `{PLUGIN_ROOT}/shared/`。

{{role_definition}}

## Progressive Loading

This skill uses progressive loading: detailed knowledge is split into `references/` files. **Read only when needed.**

### Reference File Index

| File | Content | When to Read |
|------|---------|-------------|
{{#each reference_files}}
| `references/{{filename}}` | {{description}} | {{when_to_read}} |
{{/each}}
{{#if brand_enabled}}
| `brands/*.md` | Brand configuration files | When applying brand template |
{{/if}}

### Read Method

```bash
cat {PLUGIN_ROOT}/skills/{{skill_name}}/references/{{example_reference}}
{{#if brand_enabled}}
cat {PLUGIN_ROOT}/skills/{{skill_name}}/brands/{brand-file}.md
{{/if}}
```

---

## Core Methodology

{{methodology_summary}}

{{#if has_methodology_table}}
### {{methodology_name}}

| Dimension | Core Function | Key Question |
|-----------|--------------|-------------|
{{#each methodology_dimensions}}
| **{{name}}** | {{function}} | {{question}} |
{{/each}}
{{/if}}

---

## Execution Flow

{{#if has_persistent_output}}
### Step 0.A: Incremental Mode Detection

Check if output already exists:

```bash
ls {{output_dir}}/{{output_file}} 2>/dev/null
```

- If exists → Read existing content, enter **incremental update** mode (preserve structure, update changed sections)
- If not exists → Enter **full generation** mode

{{#if incremental_note}}
> {{incremental_note}}
{{/if}}
{{/if}}

{{#if has_config_dir}}
### Step 0.B: Load Configuration

List available {{config_type}} configurations:

```bash
ls {PLUGIN_ROOT}/skills/{{skill_name}}/{{config_dir_name}}/*.md
```

Ask user to select a {{config_type}} or skip:

"请选择 {{config_type}} 配置（可跳过使用默认）："

If selected:
```bash
cat {PLUGIN_ROOT}/skills/{{skill_name}}/{{config_dir_name}}/{selected}.md
```

Apply configuration throughout execution.

#### Config Directory: {{config_dir_name}}/

Runtime-selectable configurations in `{PLUGIN_ROOT}/skills/{{skill_name}}/{{config_dir_name}}/`.

| File | Description | When to Use |
|------|-------------|-------------|
{{#each config_files}}
| `{{filename}}` | {{description}} | {{when}} |
{{/each}}
| `_template.md` | Schema for creating new configs | Adding new {{config_type}} |
{{/if}}

{{#if brand_enabled}}
### Step 0.C: Brand Configuration

Ask user: "请选择人设配置（可跳过）："

If brand selected:
```bash
cat {PLUGIN_ROOT}/skills/{{skill_name}}/brands/{brand-file}.md
```

Apply brand voice, style constraints, and content boundaries throughout creation.
{{/if}}

{{#each steps}}
### Step {{number}}: {{title}}

{{instructions}}

{{#if reads_reference}}
**Load reference:**
```bash
cat {PLUGIN_ROOT}/skills/{{skill_name}}/references/{{reference_file}}
```
{{/if}}

{{#if has_output}}
**Output:** `{{output_path}}`
{{/if}}

{{#if wait_for_user}}
**WAIT for user confirmation.**
{{/if}}

{{/each}}

{{#if has_rlhf}}
---

## RLHF Self-Evolution

This skill supports feedback-driven evolution. See `references/rlhf-loop.md` for the full mechanism.

### Per-Session Flow

1. Read evolution state: `cat {PLUGIN_ROOT}/skills/{{skill_name}}/references/evolution-state.yaml`
2. Apply high-scoring rules during creation
3. Collect feedback after user review
4. Update rule scores
5. Check if consolidation is needed (every 10 sessions)

### Evolution Triggers

| Command | Action |
|---------|--------|
| "进化报告" | Output current rule scores |
| "整合规则" | Run consolidation now |
| "A/B 测试" | Generate two versions with different rule sets |
| "探索模式" | Try low-confidence rules |
{{/if}}

---

## Output Format

{{output_format_description}}

```
{{output_structure}}
```

---

## Usage Examples

### Example 1: Basic Usage

```
User: /{{trigger_command}} {{example_input}}
Agent: [Executes full workflow]
```

{{#if brand_enabled}}
### Example 2: With Brand

```
User: /{{trigger_command}} {{example_input}} --brand {{example_brand}}
Agent: [Applies brand voice throughout]
```
{{/if}}
````

---

## Fill Instructions

| Placeholder | Source | Example |
|------------|--------|---------|
| `{{skill_name}}` | From architecture table | `customer-assessment` |
| `{{skill_description}}` | One-line with trigger phrase | `"Use this skill when evaluating customer readiness and needs"` |
| `{{argument_hint}}` | Key parameters | `"[客户名] [--type enterprise\|smb]"` |
| `{{role_definition}}` | 1-2 sentences defining the agent persona | `"You are an expert customer success analyst..."` |
| `{{reference_files}}` | Domain knowledge files from Phase 1 | methodology.md, criteria.md, etc. |
| `{{methodology_summary}}` | Core approach summary from Phase 1 domain knowledge | Concise framework description |
| `{{steps}}` | Detailed execution steps for this phase | Numbered steps with instructions |
| `{{trigger_command}}` | Slash command from architecture table | `assess` |
| `{{has_persistent_output}}` | Does this skill produce files that persist? | `true` if writes to disk |
| `{{output_dir}}` | Directory where output is saved | `{company_dir}` |
| `{{output_file}}` | Main output file name | `prd.md` |
| `{{has_config_dir}}` | Does this skill need runtime-selectable configs? | `true` if multiple types/templates |
| `{{config_dir_name}}` | Config directory name | `templates`, `channels`, `presets` |
| `{{config_type}}` | Human-readable config type | `产品类型模板`, `渠道配置` |
| `{{config_files}}` | Array of config files | `[{filename, description, when}]` |

---

## Key Patterns from Source

1. **Role definition** — First paragraph establishes the agent persona and expertise
2. **Progressive loading** — Reference index table with "When to Read" column prevents unnecessary context loading
3. **Read method** — Explicit `cat` commands show how to load references
4. **Methodology table** — Structured overview before detailed steps
5. **Incremental detection** — Step 0.A checks for existing output to enable update-vs-create mode
6. **Config directory** — Step 0.B loads runtime-selectable configurations (templates, channels, presets)
7. **Brand integration** — Step 0.C for brand selection when brand module is enabled
8. **RLHF integration** — Optional section for feedback-driven evolution
9. **Output format** — Clear specification of what the skill produces
10. **Usage examples** — Show real invocation patterns

## Reference File Generation

For each specialist skill, create reference files in `{output_path}/{skill-name}/references/` containing domain knowledge collected in Phase 1. Structure each file as:

```markdown
# {{Topic Name}}

## Overview
{{Brief description of this knowledge area}}

## {{Section 1}}
{{Detailed knowledge from Phase 1 answers}}

## {{Section 2}}
{{More domain-specific content}}
```

Keep reference files focused on a single topic. If a topic exceeds ~500 lines, split into multiple files and update the progressive loading index.
