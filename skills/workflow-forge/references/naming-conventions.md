# Skill Naming Conventions (Quick Reference)

> 浓缩自 `CONVENTIONS.md`，供 Phase 0 命名和 Phase 2 架构命名使用。

---

## Skill 命名规则

- **kebab-case**，全小写，英文，≤ 4 词
- 目录名 = SKILL.md `name:` 字段（必须一致）
- 描述性命名，说明 skill 做什么

### 命名模式

| 情况 | 命名模式 | 示例 |
|------|---------|------|
| 单 skill | `{descriptive-name}` | `find-topic`, `tech-teardown`, `humanize-zh` |
| 多 skill 套件 | `{scope}-{action}` | `ceo-diagnose`, `ceo-plan`, `ceo-review` |
| 编排器 (L3) | `{name}-pipeline` | `article-pipeline`, `company-pipeline` |
| 评估 (L2+) | `{name}-eval` | `content-eval`, `plan-decompose-eval` |
| Router 入口 | `{scope}` 或 `{scope}-plan` | `ceo-plan`（路由到 ceo-diagnose 等） |

---

## Skill 架构命名规则

| 角色 | 命名模式 | 示例 |
|------|---------|------|
| 专家 skill | `{descriptive-name}` | `writer-write`, `find-topic` |
| 编排器 (L3) | `{name}-pipeline` | `article-pipeline` |
| 评估 (L2+) | `{name}-eval` | `content-eval` |

---

## SKILL.md Frontmatter

最小 frontmatter（3 字段即可）：

```yaml
---
name: skill-name
description: "Use this skill when... (具体触发短语)"
user-invocable: true
---
```

完整 frontmatter（L2+）：

```yaml
---
name: skill-name
description: "Use this skill when... (具体触发短语)"
argument-hint: "[arg] [--flag VALUE]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Agent
user-invocable: true
---
```

---

## 目录结构

Skills 平铺在 `skills/` 下，无嵌套：

```
{plugin-root}/
├── .claude-plugin/
│   └── plugin.json         # 整个 plugin 一个 manifest
├── skills/
│   ├── skill-a/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── skill-b/
│   │   ├── SKILL.md
│   │   └── scripts/
│   └── skill-c/
│       └── SKILL.md
└── shared/                  # L3 跨 skill 共享
    ├── references/
    └── scripts/
```

Skills 由 Claude Code 通过 `skills/*/SKILL.md` 模式自动发现，无需在 plugin.json 中列出。
