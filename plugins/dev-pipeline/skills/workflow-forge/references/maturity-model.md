# Maturity Model — 渐进式 Skill 成熟度

4 级成熟度模型，从种子到生态。每个 level 的输出范围严格递增。

---

## Level 定义

### L0 Seed（种子）

最小可用单元。一个 SOP 变成一个可运行的 skill。

| 属性 | 值 |
|------|-----|
| 输出 | 单个 SKILL.md（含 frontmatter） |
| 目录结构 | `skills/{name}/SKILL.md` |
| 无 | references/、scripts/、编排器 |
| SKILL.md 行数 | < 200 |
| 适用场景 | 1-2 阶段、无外部工具、刚描述完的 SOP |
| 升级触发 | 用了 3-5 次后发现重复知识需要沉淀 |

### L1 Structured（结构化）

知识从流程中分离，SKILL.md 变为导航 + 核心流程。

| 属性 | 值 |
|------|-----|
| 输出 | SKILL.md + references/ |
| 新增 | Progressive Loading 表、reference 文件 |
| SKILL.md 行数 | < 350（references 无限制） |
| 适用场景 | 丰富领域知识、3+ 阶段、需要知识复用 |
| 升级触发 | 发现重复操作需要脚本化、或需要质量门控 |

### L2 Automated（自动化）

确定性操作脚本化，可选质量评估。支持多 skill 套件。

| 属性 | 值 |
|------|-----|
| 输出 | L1 全部 + scripts/ + eval skill（可选） |
| 新增 | 脚本文件夹、确定性操作封装、自动化评估 |
| 多 skill | 同一 plugin 下可有多个 skills（如 cpo-analyze + cpo-prd + cpo-version），通过 `skills/*/SKILL.md` 自动发现 |
| Config 目录 | 可选：templates/、presets/ 等用于运行时选择不同处理规则 |
| 增量模式 | 持久输出的 skill 在 Phase 0 检测已有输出 → 更新 vs 重建 |
| 适用场景 | 有文件 I/O、数据转换、API 调用、git 操作等确定性操作 |
| 升级触发 | 需要多角色协作、多品牌切换、或自进化规则 |

### L3 Ecosystem（生态）

多 skill 协作生态，编排器调度专家。支持共享资源和 Router skill。

| 属性 | 值 |
|------|-----|
| 输出 | L2 全部 + 编排器 skill + brand 系统（可选） + RLHF（可选） |
| 新增 | Orchestrator skill、品牌配置、自进化系统 |
| shared/ | 跨 skill 共享目录（references/scripts/templates/knowledge-base） |
| Router skill | 多 skill 套件的入口调度器（同 plugin 内路由，区别于跨 skill 编排器） |
| knowledge-base/ | 经验库：decision-patterns、review-learnings、industry-benchmarks |
| Git 事件日志 | 语义 commit + tag 里程碑（cycle/、review/、retro/） |
| 适用场景 | 3+ 专家角色需协调、多品牌/多人设、需要自进化 |

---

## 决策树

基于 Phase 0 阶段结构和 Phase 1 知识缺口自动推荐：

```
SOP 有几个阶段？
├── 1 阶段 + 无外部工具 → L0 Seed
├── 2-3 阶段 OR 丰富领域知识？
│   ├── 有确定性操作（文件解析/API/数据转换/git）？
│   │   ├── 有 3+ 专家角色需要协调？ → L3 Ecosystem
│   │   └── 否 → L2 Automated
│   └── 否 → L1 Structured
└── 4+ 阶段
    ├── 各阶段需要不同专业知识？ → L3 Ecosystem
    └── 否 → L2 Automated
```

简化规则：

| 信号 | 推荐 Level |
|------|-----------|
| 1 阶段 + 无外部工具 | L0 Seed |
| 2-3 阶段 OR 丰富领域知识 | L1 Structured |
| 有确定性操作（文件/API/数据/git） | L2 Automated |
| 3+ 专家角色需协调 | L3 Ecosystem |

> 多个信号同时满足时，取最高 level。

---

## Level 检测标准

对已有 skill 判断当前 level：

| 检查项 | 结果 |
|--------|------|
| 只有 SKILL.md，无 references/ | L0 |
| 有 references/ 目录，无 scripts/ | L1 |
| 有 scripts/ 或独立 eval skill | L2 |
| 有编排器 skill + shared/ 目录 | L3 |

检测命令：
```bash
# 检查 references/ 是否存在
ls {skill_path}/references/ 2>/dev/null

# 检查 scripts/ 是否存在
ls {skill_path}/scripts/ 2>/dev/null

# 检查是否有编排器（sibling skills）
ls {PLUGIN_ROOT}/skills/*-pipeline/SKILL.md 2>/dev/null

# 检查 shared/ 是否存在
ls {PLUGIN_ROOT}/shared/ 2>/dev/null
```

---

## Level 对 Phase 的影响

| Phase | L0 | L1 | L2 | L3 |
|-------|----|----|----|----|
| Phase 1: Gap 分类范围 | Cat 1+4 | + Cat 2 | + Cat 5+6 | 全部 7 类 |
| Phase 2: 架构表 | 无（单 skill） | 1 specialist，无编排器 | specialist(s) + 可选 eval. 3+ phases with different expertise → multi-skill + router | 完整（编排器+专家+模块） |
| Phase 2: 可选模块 | 全部 OFF | 全部 OFF | eval 可选，其余 OFF | 全部可选 |
| Phase 3: Plugin manifest | - | - | - | ✓ (if new plugin) |
| Phase 3: Orchestrator | - | - | - | ✓ |
| Phase 3: Specialist 模板 | seed | structured | specialist | specialist |
| Phase 3: Eval skill | - | - | 可选 | 可选 |
| Phase 3: Brand system | - | - | - | 可选 |
| Phase 3: RLHF system | - | - | - | 可选 |
| Phase 3: README | - | ✓ | ✓ | ✓ |
| Phase 3: scripts/ | - | - | ✓ | ✓ |
| Phase 3: Router skill | - | - | if multi-skill | if multi-skill |
| Phase 3: shared/ dir | - | - | - | ✓ |
| Phase 3: Config dirs | - | optional | optional | optional |
| Phase 4: 反模式检查 | 基础 | 基础 | 完整（含 AP-8/9） | 完整（含 AP-8/9） |
