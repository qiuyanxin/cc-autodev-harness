# Self-Evolution Plugin

Claude Code 自进化系统 —— 自动捕获开发失败、按需注入项目规则、递归进化开发经验。

## 核心思想

受 [SkillRL](https://github.com/aiming-lab/SkillRL) 启发：既然无法训练模型，就训练提示词。通过 4 层架构实现从 **原始信号** 到 **结构化规则** 的闭环进化。

```
L0 Capture    hooks 自动捕获失败和上下文
     ↓
L1 Storage    skill-bank.json + failures.jsonl + memory/
     ↓
L2 Distill    /evolve-rules 分析模式、提炼规则
     ↓
L3 Inject     每次 prompt 自动注入相关规则到 Claude 上下文
```

## 安装

插件随 `cc-autodev-harness` marketplace 安装：

```bash
# 在 ~/.claude/settings.json 的 enabledPlugins 中添加：
"self-evolution@cc-autodev-harness": true
```

首次 session 启动时，`init-project-data.sh` 会自动创建项目数据目录和默认 skill-bank。

## 运作机制

### Hooks

| Hook | 事件 | 模式 | 作用 |
|------|------|------|------|
| `inject-skills.sh` | UserPromptSubmit | sync | 读取用户 prompt 关键词，匹配 skill-bank 中的 domain，将相关规则注入 Claude 上下文 |
| `capture-failure.sh` | PostToolUseFailure | async | 将工具调用失败（工具名、输入、错误信息）追加到 `failures.jsonl` |
| `pre-compact-learn.sh` | PreCompact | sync | 在 context compaction 前提醒 Claude 保存本次 session 的教训 |
| `init-project-data.sh` | SessionStart | sync | 初始化项目数据目录，从模板创建 skill-bank.json 和 MEMORY.md |

### 数据流

```
用户输入 prompt
    │
    ├─→ inject-skills.sh 读取 prompt 关键词
    │       │
    │       ├─→ 匹配 skill-bank.json 中的 domainKeywords
    │       │
    │       └─→ 输出 <skill-bank-context> 到 Claude 上下文
    │
    └─→ Claude 执行任务
            │
            ├─ 成功 → 无操作
            │
            └─ 失败 → capture-failure.sh 追加到 failures.jsonl
```

### skill-bank.json 结构

```json
{
  "_meta": {
    "version": 1,
    "lastEvolved": "2026-03-13",
    "totalFeedbackProcessed": 0
  },
  "domainKeywords": {
    "build": "build|deploy|lint|test|compile",
    "style": "theme|style|color|font|css"
  },
  "commonMistakes": {
    "general": ["规则始终注入，不需要关键词匹配"],
    "build": ["匹配 build 关键词时注入"],
    "style": ["匹配 style 关键词时注入"]
  }
}
```

- `domainKeywords`：每个 domain 的正则关键词模式，用于匹配用户 prompt
- `commonMistakes`：按 domain 分类的规则列表，`general` 始终注入
- 新增 domain 只需在两个字段中各加一项

### /evolve-rules 进化流程

当积累了足够的失败记录和反馈后，运行 `/evolve-rules`：

1. **Gather** — 读取 failures.jsonl、feedback_*.md、skill-bank.json、.claude/rules/
2. **Analyze** — 聚类失败模式，计数，交叉比对已有规则
3. **Propose** — 生成 Evolution Report（新增 / 强化 / 晋升 / 废弃）
4. **Review** — 展示报告，等待人工审批
5. **Apply** — 更新 skill-bank.json，归档已处理的反馈

约束条件：
- 每轮最多新增 5 条规则
- 仅提取出现 >= 2 次的模式
- 命中 >= 5 次且有明确路径范围的规则可晋升到 `.claude/rules/`

### 规则生命周期

```
原始信号 (failures.jsonl / feedback_*.md)
    ↓  /evolve-rules 提炼
skill-bank.json 中的 commonMistakes
    ↓  命中 >= 5 次 + 路径明确
.claude/rules/*.md (路径作用域规则)
    ↓  模式稳定 + 跨项目适用
正式 Skill (SKILL.md)
```

## 项目数据目录

数据存储在 `~/.claude/projects/-<cwd-path-hashed>/`，与项目 1:1 对应：

```
~/.claude/projects/-Users-you-code-myproject/
├── skill-bank.json        # 规则库
├── failures.jsonl         # 失败日志
└── memory/
    ├── MEMORY.md           # 索引
    ├── feedback_*.md       # 手动反馈
    └── archive/            # 已处理的反馈归档
```

## 依赖

- `jq` — hooks 解析 JSON 输入和 skill-bank.json（`brew install jq`）
- `bash` — 所有 hooks 使用 bash 脚本

## 文件清单

```
plugins/self-evolution/
├── .claude-plugin/
│   └── plugin.json                 # 插件元数据
├── hooks/
│   ├── hooks.json                  # Hook 事件绑定声明
│   ├── inject-skills.sh            # 关键词匹配 → 规则注入
│   ├── capture-failure.sh          # 失败捕获 → JSONL 日志
│   └── pre-compact-learn.sh        # Compaction 前学习提醒
├── scripts/
│   ├── resolve-project-dir.sh      # CWD → 项目数据目录映射
│   └── init-project-data.sh        # 首次启动初始化
├── skills/
│   └── evolve-rules/SKILL.md       # /evolve-rules 进化引擎
├── templates/
│   └── skill-bank-default.json     # 新项目的空白模板
└── README.md
```

## License

MIT
