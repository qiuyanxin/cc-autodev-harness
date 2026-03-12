# Official Skill & Plugin Patterns

> 基于 Claude Code 官方文档 + 社区最佳实践提炼。生成 scaffold 时参考。

---

## 1. SKILL.md Frontmatter 完整字段

```yaml
---
name: my-skill                          # 必填，kebab-case，≤64 字符
description: "What this skill does"     # 强烈推荐，第三人称，包含触发短语
argument-hint: "[arg] [--flag VALUE]"   # 可选，自动补全提示
allowed-tools: Read, Write, Edit, Bash  # 可选，skill 激活时自动授权的工具
user-invocable: true                    # 默认 true，false = 仅 Claude 自动调用
disable-model-invocation: false         # true = 仅手动 /invoke，不自动加载
model: sonnet                           # 可选，skill 激活时的模型
context: fork                           # 可选，fork = 在子 agent 中运行
agent: Explore                          # context: fork 时指定子 agent 类型
hooks:                                  # 可选，skill 生命周期 hooks
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate.sh"
---
```

### 何时用哪些字段

| 场景 | 推荐字段 |
|------|---------|
| L0 Seed（最简） | `name`, `description`, `user-invocable` |
| L1 Structured | + `argument-hint`, `allowed-tools` |
| L2 Automated（有脚本） | + `hooks`（脚本验证） |
| L3 子 agent 委派 | + `context: fork`, `agent` |
| 纯知识型 skill | `user-invocable: false`，`disable-model-invocation: false` |

---

## 2. Progressive Disclosure（渐进式披露）

### 核心原则

- **SKILL.md 是目录**：核心流程 + 引用索引，≤500 行
- **引用一层深**：SKILL.md → references/*.md，不要嵌套引用链
- **未读取 = 零消耗**：未访问的文件不占 context token
- **按需读取**：只在对应阶段读取需要的 reference

### 目录结构模式

```
# 简单 skill（L0-L1）
skill-name/
├── SKILL.md              # 核心（≤500 行）
└── references/
    └── detailed-guide.md

# 中等 skill（L2）
skill-name/
├── SKILL.md              # 核心（≤500 行）
├── references/
│   ├── patterns.md       # 方法论/模式
│   └── advanced.md       # 高级技巧
├── examples/
│   └── sample-output.md  # 输出示例
└── scripts/
    └── validate.sh       # 验证脚本

# 复杂 skill（L3）
skill-name/
├── SKILL.md              # 核心（≤500 行）
├── references/
│   ├── methodology.md
│   ├── criteria.md
│   └── lookup-tables.md
├── examples/
│   ├── basic.md
│   └── advanced.md
├── scripts/
│   ├── process.sh
│   └── validate.py
└── assets/
    └── template.json     # 配置模板
```

### SKILL.md 中的引用表（Progressive Loading Table）

```markdown
## Progressive Loading

| File | Content | When to Read |
|------|---------|-------------|
| `references/methodology.md` | 评分框架 | Step 2: 评估 |
| `references/criteria.md` | 质量标准 | Step 3: 打分 |

### Read Method
\`\`\`bash
cat {PLUGIN_ROOT}/skills/{skill-name}/references/methodology.md
\`\`\`
```

---

## 3. 脚本组织（scripts/）

### 何时用脚本

| 信号 | 建议 |
|------|------|
| SKILL.md 中 3+ 处相同的 bash 代码块 | 提取到 scripts/ |
| 确定性操作（同输入→同输出） | 脚本化 |
| 文件解析、数据转换、格式化 | 脚本化 |
| git 操作（commit, branch, PR） | 脚本化 |
| 需要错误处理 + 重试逻辑 | 脚本化 |

### 脚本引用模式

```markdown
# 在 SKILL.md 中引用脚本
bash {PLUGIN_ROOT}/skills/{skill-name}/scripts/validate.sh "$input"
bash {PLUGIN_ROOT}/skills/{skill-name}/scripts/format-output.py "$file"
```

### 自由度分级

| 级别 | 描述 | 适用场景 | 实现方式 |
|------|------|---------|---------|
| 高自由度 | 文字指令，Claude 自行决定执行方式 | 创意性任务、分析任务 | SKILL.md 中的 prose 指令 |
| 中自由度 | 伪代码/参数化脚本 | 有最佳实践但允许变化 | 带参数的脚本模板 |
| 低自由度 | 精确脚本，逐行执行 | 脆弱操作、一致性要求高 | scripts/ 中的可执行脚本 |

### 脚本命名规范

- kebab-case：`validate-output.sh`、`format-report.py`
- Python 用 snake_case：`process_data.py`（PEP8）
- 脚本必须可执行：`chmod +x`
- 在 SKILL.md 中说明脚本用途和参数

---

## 4. Skills 层级（Plugin 内 Skill 组织）

### 单 Skill

```
skills/
└── my-skill/
    ├── SKILL.md
    └── references/
```

### 多 Skill 套件（Router 模式）

Skills 平铺在 `skills/` 下，无嵌套：

```
skills/
├── ceo-plan/SKILL.md          # Router（入口，< 150 行）
├── ceo-diagnose/              # Sub-skill 1
│   ├── SKILL.md
│   └── references/
├── ceo-roadmap/SKILL.md       # Sub-skill 2
└── ceo-review/SKILL.md        # Sub-skill 3
```

### L3 Ecosystem（编排器 + 多 Skill）

All skills flat under `skills/`, shared at plugin root:

```
{plugin-root}/
├── .claude-plugin/
│   └── plugin.json            # 一个 manifest 覆盖所有 skills
├── skills/
│   ├── writer-write/          # 专家 skill 1
│   │   ├── SKILL.md
│   │   └── references/
│   ├── content-eval/          # 评估 skill
│   │   └── SKILL.md
│   └── article-pipeline/      # 编排器
│       └── SKILL.md
└── shared/                    # 跨 skill 共享
    ├── references/
    └── scripts/
```

---

## 5. 动态上下文注入

SKILL.md 支持 `` !`command` `` 语法，在 skill 内容发送给 Claude 前执行命令，输出替换占位符：

```markdown
---
name: pr-review
context: fork
agent: Explore
---

## Context
- PR diff: !`gh pr diff`
- Changed files: !`gh pr diff --name-only`

## Instructions
Review the above PR changes...
```

适用于：需要运行时动态信息的 skill（git status、环境信息、当前分支等）。

---

## 6. 子 Agent 委派（context: fork）

skill 可以在独立子 agent 上下文中运行：

```yaml
---
name: deep-research
context: fork
agent: Explore        # 或 general-purpose, Plan
model: sonnet
---
```

- SKILL.md 内容变成子 agent 的 prompt
- 子 agent 无法访问对话历史
- 适用于：独立任务、不需要对话上下文的操作
- 子 agent 类型：`Explore`（只读）、`Plan`（只读）、`general-purpose`（全工具）

---

## 7. Hooks 集成

skill 可定义生命周期 hooks：

```yaml
---
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/security-check.sh"
          timeout: 30
  PostToolUse:
    - matcher: "Write"
      hooks:
        - type: command
          command: "./scripts/validate-output.sh"
---
```

适用于 L2+：
- 脚本输出验证
- 安全检查
- 格式化 lint

---

## 8. Description 最佳实践

官方建议 description 要"激进"（pushy），因为 Claude 倾向于少触发 skill：

```yaml
# BAD — 太模糊
description: "Helps with documents"

# GOOD — 具体触发短语
description: "Use this skill when processing Excel files. Handles spreadsheets, .xlsx files, pivot tables, and data analysis in Excel format."
```

规则：
- 以 "Use this skill when..." 开头（推荐）
- 包含具体触发短语
- ≤1024 字符
- 说明什么时候**不**应该使用（如有必要）

---

## 9. 评估驱动开发

官方推荐的 skill 质量保障流程：

1. **无 skill 基线**：先让 Claude 不用 skill 执行任务，记录失败点
2. **创建评估场景**：≥3 个测试场景覆盖失败点
3. **建立基线**：记录无 skill 时的表现
4. **最小指令**：写最少的 SKILL.md 内容
5. **迭代优化**：跑评估 → 识别差距 → 补充指令
6. **跨模型测试**：用 Haiku、Sonnet、Opus 分别测试

---

## 10. 官方反模式补充

| 反模式 | 说明 |
|--------|------|
| Windows 路径 | 用 `/` 不用 `\` |
| 提供过多替代方案 | 选一个默认方案 |
| 深度嵌套引用 | references/ 只一层深 |
| 时间敏感信息 | 不要写"截止 2024 年" |
| 假设工具已安装 | 检查可用性再调用 |
| 模糊 description | 要包含具体触发短语 |
| SKILL.md > 500 行 | 拆分到 references/ |
| 所有内容塞一个文件 | 用 progressive disclosure |

---

## 11. 社区 Skill Creator 参考

| 工具 | URL | 特点 |
|------|-----|------|
| Anthropic 官方 skill-creator | `anthropics/skills` | 参考实现，定义标准 |
| claude-code-skill-factory | `alirezarezvani/claude-code-skill-factory` | 5 个引导 agent + 10 个命令 |
| agent-skill-creator | `FrancyJGLisboa/agent-skill-creator` | 5 阶段自动管线 + 安全扫描 |
| Obra Superpowers | `obra/superpowers` | 完整开发方法论 + 20+ skill |
| Skill Builder | `metaskills/skill-builder` | 教育型模板 + sub-agent 转换指南 |
