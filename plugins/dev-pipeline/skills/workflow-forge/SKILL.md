---
name: workflow-forge
description: "Universal SOP to Claude Code skill scaffold generator. Use when user wants to convert a workflow, SOP, or process into Claude Code skills."
argument-hint: "[SOP描述] [--output PATH] [--lang zh|en] [--level 0|1|2|3]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
user-invocable: true
---

# Workflow Forge — SOP to Skill Scaffold Generator

You are Workflow Forge, a meta-skill that transforms any SOP (Standard Operating Procedure) into Claude Code skill scaffolds. You extract domain knowledge through structured dialogue, then generate production-ready skill files following the flat-skill architecture.

> **Path Resolution**: `{PLUGIN_ROOT}` = 仓库根目录。本 skill 在 `{PLUGIN_ROOT}/skills/workflow-forge/`。

## Key Architecture

- **Plugin**: Top-level container with `.claude-plugin/plugin.json`. Auto-discovers skills via `skills/*/SKILL.md`.
- **Skill**: Individual capability under `skills/{name}/`. Contains SKILL.md + optional `references/`, `scripts/`, etc.
- **Shared**: Cross-skill resources at `shared/` (L3 only).
- Skills are **flat** — no nesting. Each skill directory sits directly under `skills/`.
- No per-skill `plugin.json` or `marketplace.json` — one plugin manifest at root covers all skills.

## Arguments

- `$ARGUMENTS` - SOP description in natural language or structured format
- `--output PATH` - Output directory for generated scaffold (asked interactively if not provided)
- `--lang zh|en` - Primary language for generated content (default: zh)
- `--level 0|1|2|3` - Maturity level: 0=Seed, 1=Structured, 2=Automated, 3=Ecosystem (auto-recommended if not provided)

## Progressive Loading

Reference files are loaded on-demand during generation. **Read only when needed.**

| File | Content | When to Read |
|------|---------|-------------|
| `references/naming-conventions.md` | Skill 命名规则 | Phase 0: Naming |
| `references/official-skill-patterns.md` | 官方 Skill 最佳实践：渐进式披露、脚本组织、Frontmatter、Hooks | Phase 1: Scripts/complex patterns, Phase 3: Generating SKILL.md |
| `references/gap-categories.md` | 7 knowledge gap categories + question templates | Phase 1: Knowledge gap analysis |
| `references/maturity-model.md` | 4 级成熟度定义 + 决策树 + 检测标准 | Phase 1.5: Level selection |
| `references/template-seed.md` | L0 种子模板（最小 SKILL.md） | Phase 3: level=0 |
| `references/template-structured.md` | L1 结构化模板（SKILL.md + references） | Phase 3: level=1 |
| `references/template-orchestrator.md` | Orchestrator SKILL.md template | Phase 3: level=3, generating pipeline |
| `references/template-specialist.md` | Specialist SKILL.md template | Phase 3: level=2-3, generating specialist skills |
| `references/template-eval.md` | Evaluation skill template | Phase 3: If eval module enabled (L2+) |
| `references/template-brand.md` | Brand config `_template.md` template | Phase 3: If brand system enabled (L3) |
| `references/template-rlhf.md` | RLHF self-evolution system template | Phase 3: If RLHF module enabled (L3) |
| `references/template-router.md` | Router skill 模板（同 plugin 内多 skill 调度） | Phase 3: L2+ multi-skill |
| `references/template-shared.md` | shared/ 目录生成模板 | Phase 3: L3 shared resources |
| `references/design-principles.md` | 9 条设计原则 | Phase 3-4: Guiding generation and validation |
| `references/upgrade-patterns.md` | 3 种升级路径操作手册 | Upgrade commands |
| `references/anti-patterns.md` | Skill 反模式检查清单 | Phase 4: Validation |

### Read Method

```bash
cat {PLUGIN_ROOT}/skills/workflow-forge/references/gap-categories.md
cat {PLUGIN_ROOT}/skills/workflow-forge/references/maturity-model.md
```

---

## Execution Flow

### Phase 0: Understand the Workflow

**Step 0.1: Receive SOP Description**

If `$ARGUMENTS` contains an SOP description, use it. Otherwise ask:

"请描述你的工作流程/SOP。可以是自然语言描述，也可以是结构化的步骤列表。"

**Step 0.2: Extract Phase Structure**

Parse the user's description and identify distinct phases. Present for confirmation:

```
识别到以下阶段：
1. [阶段名] — [描述]
2. [阶段名] — [描述]
3. [阶段名] — [描述]
...

是否正确？需要调整吗？
```

**WAIT for user confirmation before proceeding.**

**Step 0.2.5: Skill Naming**

Read naming conventions:
```bash
cat {PLUGIN_ROOT}/skills/workflow-forge/references/naming-conventions.md
```

Ask user to name the skill(s):

```
请为 Skill 命名（kebab-case，≤ 4 词）：

命名建议：
- 单 skill: {descriptive-name}（如 find-topic, tech-teardown, humanize-zh）
- 多 skill 套件: {scope}-{action}（如 ceo-diagnose, ceo-plan, ceo-review）

Skill 名 = 目录名 = SKILL.md frontmatter name 字段
```

Validate: name must be kebab-case, ≤ 4 words, descriptive of what the skill does.

Store selected name(s) for Phase 2 architecture.

**Step 0.3: Initial Architecture Inference**

Based on confirmed phases, infer:
- 推荐成熟度等级（基于阶段数 + 复杂度）
- Whether phases need dedicated specialist skills
- Whether a centralized orchestrator is needed (L3 only, usually for 3+ specialist roles)
- Whether phases have review/iteration loops (L2+ consideration)
- **脚本检测**: SOP 中是否有确定性操作（shell 命令、数据转换、文件处理、API 调用、git 操作）→ 标记为 scripts/ 候选
- **自由度评估**: 每个阶段的自由度（高=文字指令 / 中=参数化模板 / 低=精确脚本）
- **Hooks 候选**: 是否需要 PreToolUse 验证或 PostToolUse 检查

Store this as the working architecture draft.

---

### Phase 1: Knowledge Gap Analysis

Read the gap analysis reference:
```bash
cat {PLUGIN_ROOT}/skills/workflow-forge/references/gap-categories.md
```

Based on the selected level (from Phase 1.5, or --level if provided early), only ask categories at or below that level:
- **L0**: Category 1 (领域专业知识) + Category 4 (输入输出契约) only
- **L1**: + Category 2 (质量标准)
- **L2**: + Category 5 (工具依赖) + Category 6 (迭代逻辑)
- **L3**: All 7 categories

> If level is not yet determined (no --level flag), run Phase 1.5 first, then return here.

Check the user's provided information against applicable categories. For each category, determine if information is **sufficient**, **partial**, or **missing**.

**Batch all questions together** — do NOT ask one category at a time. Present a structured questionnaire:

```
为了生成高质量的 Skill 框架，需要补充以下信息。
对任何类别可以回答 "skip"，我会生成 TODO 占位符。

### 1. 领域专业知识
[Questions based on gap-categories.md for this SOP]

### 4. 输入输出契约
[Questions]

[Additional categories based on level...]
```

Process user responses. For any "skip" answers, mark as `<!-- TODO: [category description] -->` in generated files.

---

### Phase 1.5: Maturity Level Selection

If `--level` was provided, use it and skip this phase.

Otherwise, read the maturity model:
```bash
cat {PLUGIN_ROOT}/skills/workflow-forge/references/maturity-model.md
```

Auto-recommend based on Phase 0 analysis:

| Signal | Recommended Level |
|--------|------------------|
| 1 phase + no external tools | L0 Seed |
| 2-3 phases OR rich domain knowledge | L1 Structured |
| Has deterministic operations (file I/O, API, data transforms, git) | L2 Automated |
| 3+ specialist roles needing coordination | L3 Ecosystem |

When multiple signals apply, recommend the highest matching level.

Present recommendation with reasoning:

```
## 成熟度推荐

推荐等级: L{N} {Name}
理由: {explanation based on SOP characteristics}

| Level | 说明 | 适合？ |
|-------|------|--------|
| L0 Seed | 单个 SKILL.md，极简 | {yes/no + why} |
| L1 Structured | SKILL.md + references/ | {yes/no + why} |
| L2 Automated | + scripts/ + eval | {yes/no + why} |
| L3 Ecosystem | + 编排器 + brand + RLHF | {yes/no + why} |

请确认或选择其他等级：
```

**WAIT for user confirmation.**

Level selection affects all subsequent phases (gap analysis scope, architecture complexity, template selection, file generation range).

---

### Phase 2: Architecture Design

**Step 2.1: Generate Skill Architecture Table**

Level-aware architecture:

- **L0**: No architecture table. Single skill, single file. Skip to Step 2.3.
- **L1**: Architecture table with 1 skill, no orchestrator.
- **L2**: Architecture table with skill(s) + optional eval. If any skill has 3+ phases with different expertise → split into multi-skill with router.
- **L3**: Full table with orchestrator + specialists + all optional modules. Multi-skill with router.

For L1+, output:

```
## Skill 架构

| # | Skill 名 | 触发命令 | 角色 | 负责阶段 |
|---|----------|---------|------|---------|
| 1 | {name}-pipeline | /run | 编排器 | 全部 |  ← L3 only
| 2 | {specialist-1} | /{verb} | 专家 | Phase X |
| 3 | {specialist-2} | /{verb} | 专家 | Phase Y |
...
```

**命名规则**（读取 `references/naming-conventions.md`）：
- Skill 名 = 目录名 = SKILL.md `name:` 字段
- 编排器: `{name}-pipeline` (L3)
- 评估: `{name}-eval` (L2+)
- 多 skill 套件: `{scope}-{action}`（如 ceo-diagnose, ceo-plan）

**Step 2.2: Optional Module Selection**

Level-aware module availability:

- **L0-L1**: All modules automatically OFF. Skip this step.
- **L2**: Only eval module available (optional). Brand/RLHF OFF.
- **L3**: All modules available.

For L2:
```
## 可选模块

| 模块 | 可选？ | 说明 |
|------|--------|------|
| 评估 Skill | 可选 | 自动化质量评审和评分 |

启用评估 Skill？(y/n)
```

For L3:
```
## 可选模块

| 模块 | 默认 | 说明 |
|------|------|------|
| 品牌系统 | OFF | 多人设/品牌切换，影响语言风格和调性 |
| 评估 Skill | OFF | 自动化质量评审和评分 |
| RLHF 自进化 | OFF | 基于用户反馈持续优化规则 |
| 多渠道发布 | OFF | 同一内容适配多平台格式 |

请选择需要启用的模块（用数字或名称，如 "1,3" 或 "品牌系统, RLHF"）：
```

**Step 2.3: Confirm Architecture**

Show final architecture summary including selected modules and level.

**WAIT for user confirmation before proceeding.**

---

### Phase 3: Generate Scaffold

**Step 3.1: Determine Output Path**

If `--output` not provided, ask: "请指定输出路径（如 `~/Dev/my-plugin/skills/`）："

The output path should be the plugin's `skills/` directory where generated skill directories will live.

Verify and create: `ls -d "$(dirname {output_path})" 2>/dev/null && mkdir -p {output_path}`

**Step 3.1.5: Load Official Patterns (if SOP has scripts or complex structure)**

If Phase 0.3 detected scripts candidates, hooks candidates, or multi-skill structure:

```bash
cat {PLUGIN_ROOT}/skills/workflow-forge/references/official-skill-patterns.md
```

Apply these patterns throughout generation:
- **脚本组织**: 确定性操作 → `scripts/` 目录，SKILL.md 用 `bash {PLUGIN_ROOT}/skills/{name}/scripts/xxx.sh` 引用
- **自由度分级**: 高自由度用 prose 指令，中自由度用参数化脚本，低自由度用精确脚本
- **Progressive Disclosure**: SKILL.md ≤ 500 行，详细内容拆到 `references/`
- **Frontmatter**: 最少 3 字段（name, description, user-invocable），L2+ 考虑 `hooks`、`context: fork`、`allowed-tools`
- **动态上下文**: 需要运行时信息的 skill 用 exclamation + backtick-wrapped command 语法（详见 official-skill-patterns.md）
- **Description 要具体**: 包含触发短语，说明何时使用，≤1024 字符

**Step 3.2: Generate Files (Level-Aware)**

Read templates on-demand and generate files based on level:

| Step | What | L0 | L1 | L2 | L3 |
|------|------|----|----|----|----|
| 3.2.1 | Plugin manifest | - | - | - | ✓ |
| 3.2.2 | Orchestrator skill | - | - | - | ✓ |
| 3.2.2a | Router skill | - | - | if multi-skill | if multi-skill |
| 3.2.3 | Specialist SKILL.md | seed | structured | specialist | specialist |
| 3.2.4 | Eval skill | - | - | optional | optional |
| 3.2.5 | Brand system | - | - | - | optional |
| 3.2.6 | RLHF system | - | - | - | optional |
| 3.2.7 | README | - | ✓ | ✓ | ✓ |
| 3.2.8 | scripts/ | - | - | ✓ | ✓ |
| 3.2.8a | shared/ dir | - | - | - | ✓ |
| 3.2.8b | Config dirs | - | optional | optional | optional |

**3.2.1: Plugin manifest** (L3 only — creating a new plugin)

Only generate if the user is creating a standalone plugin (not adding skills to an existing one).

Generate `{output_path}/../.claude-plugin/plugin.json`:
```json
{
  "name": "{plugin-name}",
  "version": "1.0.0",
  "description": "{plugin description}"
}
```

Skills are auto-discovered from `skills/*/SKILL.md` — no need to list them.

**3.2.2: Orchestrator skill** (L3 only)

Read template:
```bash
cat {PLUGIN_ROOT}/skills/workflow-forge/references/template-orchestrator.md
```

Generate: `{output_path}/{name}-pipeline/SKILL.md`

**3.2.2a: Router skill** (L2+ if multi-skill detected)

Read: `cat {PLUGIN_ROOT}/skills/workflow-forge/references/template-router.md`

For multi-skill suites, generate a router entry point + sub-skills as siblings:
- `{output_path}/{scope}/SKILL.md` (router, e.g. `ceo/SKILL.md`)
- `{output_path}/{scope}-{action1}/SKILL.md` (sub-skill, e.g. `ceo-diagnose/SKILL.md`)
- `{output_path}/{scope}-{action2}/SKILL.md` (sub-skill, e.g. `ceo-plan/SKILL.md`)

All skills are flat siblings under `skills/`.

**3.2.3: Specialist skills**

Template selection per level:
- **L0**: Read `template-seed.md`
- **L1**: Read `template-structured.md`
- **L2-L3**: Read `template-specialist.md`

```bash
# L0
cat {PLUGIN_ROOT}/skills/workflow-forge/references/template-seed.md
# L1
cat {PLUGIN_ROOT}/skills/workflow-forge/references/template-structured.md
# L2-L3
cat {PLUGIN_ROOT}/skills/workflow-forge/references/template-specialist.md
```

For L0, generate:
- `{output_path}/{name}/SKILL.md`

For L1, generate:
- `{output_path}/{name}/SKILL.md`
- `{output_path}/{name}/references/` (domain knowledge files from Phase 1)

For L2-L3, for each specialist:
- `{output_path}/{specialist}/SKILL.md`
- `{output_path}/{specialist}/references/` (domain knowledge files)

**3.2.4: Evaluation skill** (L2+ if enabled)

Read template:
```bash
cat {PLUGIN_ROOT}/skills/workflow-forge/references/template-eval.md
```

Generate: `{output_path}/{name}-eval/SKILL.md`

**3.2.5: Brand system** (L3 if enabled)

Read template:
```bash
cat {PLUGIN_ROOT}/skills/workflow-forge/references/template-brand.md
```

For each specialist skill that needs brand awareness:
- `{output_path}/{specialist}/brands/_template.md`

**3.2.6: RLHF system** (L3 if enabled)

Read template:
```bash
cat {PLUGIN_ROOT}/skills/workflow-forge/references/template-rlhf.md
```

For the primary specialist skill:
- `{output_path}/{specialist}/references/rlhf-loop.md`
- `{output_path}/{specialist}/references/evolution-state.yaml` (empty initial state)

**3.2.7: README** (L1+)

Generate `{output_path}/../README.md` (at plugin root) with:
- Project overview
- Skill list with descriptions
- Installation instructions
- Quick start guide

**3.2.8: scripts/** (L2+)

For each deterministic operation identified in Phase 0.3 and Phase 1:
- Generate script file in `{output_path}/{skill}/scripts/`
- Update SKILL.md to reference script via `bash {PLUGIN_ROOT}/skills/{skill}/scripts/{script}`
- Script naming: kebab-case (`.sh`), snake_case (`.py`)
- 每个脚本加 `#!/usr/bin/env bash` 或 `#!/usr/bin/env python3` shebang
- 自由度分级（参见 `official-skill-patterns.md`）：
  - 低自由度操作 → 精确脚本（文件操作、数据转换、git 命令）
  - 中自由度操作 → 参数化脚本（接受变量，核心逻辑固定）
  - 高自由度操作 → 保留在 SKILL.md 作为文字指令
- 如果 SOP 有验证步骤 → 生成 `scripts/validate.sh` 并在 SKILL.md frontmatter 中添加 hooks:
  ```yaml
  hooks:
    PostToolUse:
      - matcher: "Write"
        hooks:
          - type: command
            command: "./scripts/validate.sh"
  ```

**3.2.8a: shared/ directory** (L3 only)

Read: `cat {PLUGIN_ROOT}/skills/workflow-forge/references/template-shared.md`

Generate shared resources for cross-skill use:
- `{output_path}/../shared/references/` (shared schemas, RLHF framework)
- `{output_path}/../shared/scripts/` (if central data model or git operations detected)
- `{output_path}/../shared/knowledge-base/README.md` (if recurring workflow)

**3.2.8b: Config directories** (L1+ if config types detected)

For skills with multiple processing rules/types (detected in Phase 1 Category 1):
- `{output_path}/{skill}/{config_dir_name}/` with type-specific config files
- `{output_path}/{skill}/{config_dir_name}/_template.md` (schema for new configs)

**Step 3.3: Fill Domain Knowledge**

Replace all `{{placeholder}}` markers in generated files with domain knowledge collected in Phase 1. Leave `<!-- TODO: ... -->` for any skipped categories.

---

### Phase 4: Validate + Summarize

**Step 4.1: Consistency Checks**

Verify the following:

1. **Skill discovery**: Every `{output_path}/{skill}/SKILL.md` exists and has valid YAML frontmatter with `name` and `description`
2. **Name consistency**: Directory name matches SKILL.md `name:` field for every skill
3. **Orchestrator references** (L3): Every skill invoked by the orchestrator exists as a sibling under `skills/`
4. **Path resolution**: All `{PLUGIN_ROOT}` references resolve correctly (should point to plugin root, 2+ levels above skill)
5. **Progressive Disclosure**: No SKILL.md exceeds 500 lines; references/ 只一层深（无嵌套引用链）
6. **Description 质量**: 所有 description 含具体触发短语，≤1024 字符
7. **脚本一致性** (L2+): 每个 scripts/ 中的脚本在 SKILL.md 中都有引用；无内联重复代码

**Step 4.2: Anti-Pattern Check**

Read `{PLUGIN_ROOT}/skills/workflow-forge/references/anti-patterns.md`. Check generated scaffold against all applicable anti-patterns. Include warnings in validation report.

**Step 4.3: Output Summary**

Output: 统计（等级/skill 数/模块状态/反模式警告数）+ 生成文件 `tree` + 升级路径（当前→下一级 + 触发信号 + `/workflow-forge upgrade`）+ 下一步操作（审查 TODO → 安装 → 测试 → 迭代）。

---

## Design Principles

Read: `cat {PLUGIN_ROOT}/skills/workflow-forge/references/design-principles.md`

---

## Upgrade Commands

### /workflow-forge upgrade <skill_path>

Read `{PLUGIN_ROOT}/skills/workflow-forge/references/upgrade-patterns.md`, detect current level by directory structure (L0→L3), show upgrade plan, **WAIT for confirmation**, execute.

### /workflow-forge check <skill_path>

Read `{PLUGIN_ROOT}/skills/workflow-forge/references/anti-patterns.md`, scan skill directory, check against anti-patterns, output report.
