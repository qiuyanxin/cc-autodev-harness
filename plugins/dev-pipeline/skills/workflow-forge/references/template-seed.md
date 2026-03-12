# L0 Seed SKILL.md Template

极简模板。单文件包含一切：流程 + 知识 + 输出格式。无 references/、无编排器、无脚本。

**Source pattern:** Minimal viable skill — 5 分钟内从 SOP 到可用 skill。

---

## 生成位置

```
{output_path}/{name}/SKILL.md
```

## Template

````markdown
---
name: {{skill_name}}
description: "{{skill_description}}"
argument-hint: "{{argument_hint}}"
user-invocable: true
---

# {{Display Name}}

{{role_definition}}

## Execution Flow

{{#each steps}}
### Step {{number}}: {{title}}

{{instructions}}

{{#if has_output}}
**Output:** `{{output_path}}`
{{/if}}

{{#if wait_for_user}}
**WAIT for user confirmation.**
{{/if}}

{{/each}}

## Output Format

{{output_format_description}}

```
{{output_structure}}
```

## Usage Examples

```
User: /{{trigger_command}} {{example_input}}
Agent: [Executes full workflow]
```
````

---

## Fill Instructions

| Placeholder | Source | Example |
|------------|--------|---------|
| `{{skill_name}}` | From user's SOP name, kebab-case | `meeting-notes` |
| `{{skill_description}}` | One-line SOP summary with trigger phrase | `"Use this skill when organizing meeting notes into structured action items"` |
| `{{argument_hint}}` | Key parameters | `"[会议日期] [--format brief\|detailed]"` |
| `{{role_definition}}` | 1-2 sentences defining the agent persona | `"You are a meeting facilitator who..."` |
| `{{steps}}` | Execution steps extracted from SOP | Numbered steps with instructions |
| `{{trigger_command}}` | Slash command derived from SOP verb | `notes` |

---

## 与 template-specialist.md 的区别

| 特性 | L0 Seed | L2/L3 Specialist |
|------|---------|-------------------|
| Progressive Loading 表 | 无 | 有 |
| references/ 目录 | 无 | 有 |
| RLHF 章节 | 无 | 可选 |
| Brand 章节 | 无 | 可选 |
| Methodology Table | 无（知识直接内联在 steps 中） | 有 |
| Reference File Generation | 无 | 有详细指引 |
| SKILL.md 行数上限 | 200 | 500 |

---

## Key Principles

1. **All-in-one** — 所有知识直接写在 steps 中，不拆分 reference 文件
2. **No overhead** — 不生成 plugin.json、README、scripts/
3. **Fast iteration** — 用户可以直接编辑单个 SKILL.md 快速调整
4. **Upgrade-ready** — 结构与 L1 兼容，升级时只需提取知识到 references/
