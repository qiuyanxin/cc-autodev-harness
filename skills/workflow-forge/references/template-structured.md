# L1 Structured SKILL.md Template

从 L0 Seed 升级而来。SKILL.md 变为导航 + 核心流程，领域知识沉淀到 references/ 目录。

**Source pattern:** Simplified from `template-specialist.md`, removing RLHF/Brand sections.

---

## 生成位置

```
{output_path}/{name}/SKILL.md
{output_path}/{name}/references/*.md
```

## Template

````markdown
---
name: {{skill_name}}
description: "{{skill_description}}"
argument-hint: "{{argument_hint}}"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Agent
user-invocable: true
---

# {{Display Name}}

> **Path Resolution**: `{PLUGIN_ROOT}` = 仓库根目录。

{{role_definition}}

## Progressive Loading

This skill uses progressive loading: detailed knowledge is split into `references/` files. **Read only when needed.**

### Reference File Index

| File | Content | When to Read |
|------|---------|-------------|
{{#each reference_files}}
| `references/{{filename}}` | {{description}} | {{when_to_read}} |
{{/each}}

### Read Method

```bash
cat {PLUGIN_ROOT}/skills/{{skill_name}}/references/{{example_reference}}
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
````

---

## Fill Instructions

| Placeholder | Source | Example |
|------------|--------|---------|
| `{{skill_name}}` | From architecture table | `content-research` |
| `{{skill_description}}` | One-line with trigger phrase | `"Use this skill when researching trending topics and generating content briefs"` |
| `{{argument_hint}}` | Key parameters | `"[主题] [--depth shallow\|deep]"` |
| `{{role_definition}}` | 1-2 sentences defining the agent persona | `"You are a content strategist who..."` |
| `{{reference_files}}` | Domain knowledge files from Phase 1 | methodology.md, criteria.md |
| `{{methodology_summary}}` | Core approach summary | Concise framework description |
| `{{steps}}` | Detailed execution steps | Numbered steps with instructions |
| `{{trigger_command}}` | Slash command from architecture | `research` |

---

## 与 template-specialist.md 的区别

| 特性 | L1 Structured | L2/L3 Specialist |
|------|---------------|-------------------|
| Progressive Loading 表 | ✓ | ✓ |
| Reference File Index | ✓ | ✓ |
| RLHF 章节 | 无 | 可选 |
| Brand 章节 | 无 | 可选 |
| scripts/ 目录 | 无 | L2+ |
| 知识抽取指南 | ✓（见下） | 无（已抽取） |
| 升级信号提示 | ✓（见下） | 无 |

---

## 知识抽取指南

从 L0 升级到 L1 时，以下内容应从 SKILL.md 移到 references/：

| 内容类型 | 示例 | 建议文件名 |
|----------|------|-----------|
| 方法论框架 | 评分维度、分析模型 | `methodology.md` |
| 评分标准 | 质量评判细则、合格/不合格定义 | `criteria.md` |
| 查找表 | 分类映射、模板选择矩阵 | `lookup-tables.md` |
| 示例库 | 好/坏输出范例 | `examples.md` |
| 行业知识 | 领域术语、最佳实践 | `domain-knowledge.md` |
| 提示词模板 | 重复使用的 prompt 结构 | `prompt-templates.md` |

**保留在 SKILL.md 中的内容：**
- Frontmatter（name, description, argument-hint）
- Progressive Loading 表
- 核心执行流程（Step 1, 2, 3...）
- 输出格式定义
- 用法示例

---

## 升级到 L2 的信号

出现以下情况时，考虑升级到 L2 Automated：

1. SKILL.md 中有 3+ 处 bash/python 代码块执行确定性操作
2. 反复执行相同的文件解析、数据转换、或 git 操作
3. 需要质量门控（自动化评估 + 分数阈值）
4. 操作中有"同样输入→同样输出"的步骤（应脚本化）
