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

## Hook 输入输出格式

所有 hooks 通过 **stdin** 接收 JSON，通过 **stdout** 输出注入到 Claude 上下文的文本。

### inject-skills.sh (UserPromptSubmit)

**输入 (stdin):**
```json
{
  "prompt": "用户的原始输入文本",
  "cwd": "/Users/you/code/myproject"
}
```

**输出 (stdout):** 匹配到规则时输出 XML block，Claude 会将其作为上下文接收：
```xml
<skill-bank-context>
Known issues for this project (avoid these):
- 规则 1
- 规则 2
</skill-bank-context>
```

无匹配或 `general` 为空时无输出。

### capture-failure.sh (PostToolUseFailure)

**输入 (stdin):**
```json
{
  "tool_name": "Bash",
  "tool_input": { "command": "pnpm build" },
  "error": "Error: Module not found...",
  "session_id": "abc123",
  "cwd": "/Users/you/code/myproject"
}
```

**输出:** 无 stdout 输出（async hook）。写入 `failures.jsonl`：
```json
{"ts":"2026-03-13T10:00:00Z","session":"abc123","tool":"Bash","input":{"command":"pnpm build"},"error":"Error: Module not found..."}
```

### pre-compact-learn.sh (PreCompact)

**输入 (stdin):**
```json
{
  "cwd": "/Users/you/code/myproject"
}
```

**输出 (stdout):** 固定提醒文本：
```xml
<pre-compact-reminder>
Context is about to be compacted. Before losing session details, check:
1. Did you make mistakes the user corrected? → Save to memory/feedback_*.md
2. Did you discover project patterns worth remembering? → Save to memory/
3. If you created new memory files, update MEMORY.md index.
</pre-compact-reminder>
```

### init-project-data.sh (SessionStart)

**输入 (stdin):**
```json
{
  "cwd": "/Users/you/code/myproject"
}
```

**输出:** 无。静默创建目录和文件。

## 自定义 Domain

在 `skill-bank.json` 中添加新 domain 只需两步：

1. **添加关键词模式**（`domainKeywords`）：
```json
"domainKeywords": {
  "build": "build|deploy|lint|test|compile|ci|cd",
  "style": "theme|style|color|font|css|tailwind|dark.?mode",
  "database": "db|database|migration|prisma|supabase|postgres"
}
```

2. **添加规则列表**（`commonMistakes`）：
```json
"commonMistakes": {
  "general": ["规则始终注入"],
  "build": ["pnpm build 前先 cd 到子项目"],
  "style": ["Tailwind v4 不再需要 @tailwind 指令"],
  "database": ["migration 前先备份"]
}
```

关键词模式支持正则（grep -iE），大小写不敏感。

## 手动添加反馈

除了自动捕获失败，你也可以手动添加反馈供 `/evolve-rules` 分析：

```bash
# 在项目数据目录创建反馈文件
cat > ~/.claude/projects/-Users-you-code-myproject/memory/feedback_auth-bug.md << 'EOF'
---
name: auth-bug-fix
description: Supabase auth token 过期时不应该静默失败
type: feedback
---

Supabase auth token 过期后，API 请求静默返回空数据而非 401 错误。

**Why:** 之前 Claude 修 bug 时没有检查 token 过期场景，导致数据丢失。
**How to apply:** 所有 Supabase 请求需要先检查 session 有效性。
EOF
```

`/evolve-rules` 会读取所有 `feedback_*.md` 文件，提炼后归档到 `memory/archive/`。

## ${CLAUDE_PLUGIN_ROOT} 机制

`hooks.json` 中使用 `${CLAUDE_PLUGIN_ROOT}` 环境变量引用脚本路径：

```json
"command": "${CLAUDE_PLUGIN_ROOT}/hooks/inject-skills.sh"
```

Claude Code 在执行 hook 时，会自动将 `${CLAUDE_PLUGIN_ROOT}` 替换为插件的实际安装路径。这保证了：
- 插件从 GitHub 安装或本地目录安装都能正常工作
- 脚本路径不需要硬编码
- 多用户环境下路径自动适配

## 排错

| 问题 | 原因 | 解决 |
|------|------|------|
| `inject-skills.sh` 无输出 | skill-bank.json 不存在或规则为空 | 检查项目数据目录下是否有 skill-bank.json |
| `jq: command not found` | 未安装 jq | `brew install jq` |
| hook 超时 | skill-bank.json 过大或磁盘慢 | 清理 failures.jsonl，运行 /evolve-rules |
| 新项目无 skill-bank | init-project-data.sh 未触发 | 确认插件已启用：`settings.json` 中 `"self-evolution@cc-autodev-harness": true` |
| 规则未注入 | prompt 关键词未命中 domainKeywords | 检查 domainKeywords 正则是否覆盖你的用词 |

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
