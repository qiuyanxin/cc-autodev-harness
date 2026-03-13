# cc-autodev-harness

Claude Code plugin marketplace for automated development workflows.

## Install

```bash
claude plugin marketplace add qiuyanxin/cc-autodev-harness
claude plugin install dev-pipeline@cc-autodev-harness
```

Restart Claude Code after installation.

## Plugins

| Plugin | Description |
|--------|-------------|
| **dev-pipeline** | Automated 8-step pipeline: brainstorm → plan → task-breakdown → worktree → parallel execution → verification → review → integration |
| **self-evolution** | 自进化系统：自动捕获失败、按需注入项目规则、递归进化开发经验 |

### dev-pipeline

自动化开发流程插件，提供从需求分析到代码集成的完整 pipeline。

```bash
claude plugin install dev-pipeline@cc-autodev-harness
```

See [dev-pipeline README](./plugins/dev-pipeline/README.md) for full documentation.

### self-evolution

Claude Code 自进化系统 —— 通过 4 层架构（Capture → Storage → Distill → Inject）实现从原始失败信号到结构化规则的闭环进化。

```bash
claude plugin install self-evolution@cc-autodev-harness
```

**核心能力：**
- **自动捕获** — 工具调用失败时自动记录到 `failures.jsonl`
- **规则注入** — 每次用户输入时，按关键词匹配注入项目级规则到 Claude 上下文
- **进化引擎** — `/evolve-rules` 分析积累的失败和反馈，提炼出可复用规则
- **Compaction 保护** — 上下文压缩前提醒保存 session 中的教训

**依赖：** `jq`（`brew install jq`）

See [self-evolution README](./plugins/self-evolution/README.md) for full documentation.
