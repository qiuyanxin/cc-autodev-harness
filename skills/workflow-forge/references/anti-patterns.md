# SOP Anti-Patterns（反模式清单）

从 claude-toolkit skill 生态提炼的 7 个 SOP 设计反模式。workflow-forge 在 Phase 4 校验时参照此清单。

---

## AP-1: 巨型 SKILL.md（> 500 行）

**症状:** 把所有操作模式、知识、流程塞进一个文件。

**案例:** company-pipeline 742 行，含 7 个独立操作（A-G），每个操作都有完整的执行流程。

**检测:** `wc -l SKILL.md` > 500

**规则:** 单个 SKILL.md body 不超过 500 行。超过时：
- 知识抽取到 references/（→ L1）
- 确定性操作脚本化（→ L2）
- 多模式拆分为多 skill（→ L3）

---

## AP-2: 内联确定性操作

**症状:** 文件解析、git commit、数据转换以文本指令写在 SKILL.md 中，Claude 每次重新"理解"并执行。

**案例:** claude-toolkit 中 23 处 `git add -A && git commit -m "..."` 作为文本指令内联。

**检测:** SKILL.md 中有 3+ 处相似的 bash/python 代码块。

**规则:** 确定性操作（同样输入 → 同样输出）用脚本封装，只有脚本的输出进入 context window。区分：
- 确定性：文件解析、git 操作、数据转换、格式校验 → 脚本
- 非确定性：创意生成、决策判断、质量评估 → 保留在 SKILL.md

---

## AP-3: 跨角色知识复制

**症状:** 相同的方法论、框架、流程在多个 skill 中完全重复。

**案例:** rlhf-loop.md 在 CEO/CPO/CMO 三个角色中各维护一份（286/348/336 行，总计 970 行重复）。

**检测:** 两个 reference 文件的内容相似度 > 70%。

**规则:** 共享知识抽取到 `shared/references/` 目录，各 skill 通过路径引用：
```bash
cat {PLUGIN_ROOT}/shared/references/{shared_file}.md
```

---

## AP-4: RLHF 内联评估

**症状:** 每个 skill 都内联 60-70 行几乎相同的评估流程，仅评估维度不同。

**案例:** CEO/CPO/CMO 各有 ~70 行 RLHF 评估代码（结构完全相同，只有维度表不同）。

**检测:** 多个 SKILL.md 中有结构相似的评估章节。

**规则:** 评估流程模板化到共享参考文件。每个 skill 只声明自己的评估维度表，评估执行逻辑引用共享模板。

---

## AP-5: 多模式单入口

**症状:** 一个 skill 通过 `--mode` 参数切换完全不同的执行流，各模式间共享逻辑 < 30%。

**案例:** CEO 的 plan/roadmap/review 三种模式，每种模式有独立的完整流程，仅共享 Phase 0 的上下文读取。

**检测:** SKILL.md 中有 3+ 个 `if mode == "..."` 分支，且分支间代码重叠率低。

**规则:** 如果模式间共享 < 30% 的逻辑，拆为独立 skill：
- 每个模式 → 独立 skill
- 共享逻辑 → 抽取到 shared reference
- 原入口 → 薄路由器（显示帮助 + 调用子 skill）

---

## AP-6: 缺少脚本层

**症状:** 整个 plugin 没有 scripts/ 目录，所有操作靠 Claude 文本指令执行。

**案例:** claude-toolkit 早期 5 个 skill 0 个脚本目录。任务 CRUD、git 操作、dashboard 渲染全部内联。

**检测:** `find {PLUGIN_ROOT}/skills -name "scripts" -type d` 返回空。

**规则:** 重复 3+ 次的确定性操作必须脚本化。L2+ 的 skill 必须有 scripts/ 目录。

---

## AP-7: Level 不匹配

**症状:** 简单 SOP 生成了完整 L3 生态（编排器 + 品牌 + RLHF），产生大量永远不用的空壳文件。

**检测:**
- 编排器只调用 1 个专家 → 不需要编排器
- Brand 目录存在但只有空模板 → 不需要 Brand
- RLHF 文件存在但从未更新 → 不需要 RLHF

**规则:** 用成熟度模型匹配复杂度。从 L0 开始，按需升级：
- 不要预设"以后可能需要"而提前生成
- 每次升级都要有明确的触发信号
- 宁可升级 3 次，不要一步到位生成用不到的结构

---

## AP-8: 单 Skill 多模式（应拆为多 Skill）

**症状:** 一个 SKILL.md 中有 3+ 个完全不同的执行路径，通过 --mode 参数切换。

**案例:** ceo-plan 最初把 diagnose/roadmap/review 三个流程塞在一个 SKILL.md 中（557 行）。

**检测:** SKILL.md 中有 3+ 个 `if mode == "..."` 或 `### 操作 X / Y / Z` 独立执行路径。

**规则:** 如果模式间共享逻辑 < 30%，拆为 plugin 下的独立 skills + 一个 router skill：
- 每个模式 → `skills/{scope}-{mode}/SKILL.md`（平铺，非嵌套）
- 共享上下文 → `shared/references/` 目录
- 入口 → router skill（见 template-router.md）
- Skills 由 Claude Code 通过 `skills/*/SKILL.md` 自动发现

---

## AP-9: 缺少增量检测

**症状:** skill 每次运行都全新生成输出，无法识别已有产出并增量更新。

**案例:** CPO 的 PRD skill 每次都从零生成 prd.md，即使只需要更新一个章节。

**检测:** 产生持久化输出的 SKILL.md 中没有 `ls {output} 2>/dev/null` 或类似检查。

**规则:** 产生持久化输出的 skill 应在 Phase 0 检测已有输出，提供增量更新选项：
- 检查已有输出文件 → 存在则读取并进入更新模式
- 新增字段标记哪些部分变更 → 只重新生成变更部分
- 见 template-specialist.md Step 0.A

---

## Phase 4 检查清单

生成 scaffold 后，逐项检查：

| # | 检查项 | 严重度 | 自动修复？ |
|---|--------|--------|-----------|
| AP-1 | 任何 SKILL.md > 500 行？ | 🔴 高 | 建议拆分方案 |
| AP-2 | SKILL.md 中有 3+ 处相似 bash 代码块？ | 🟡 中 | 建议脚本化 |
| AP-3 | 2+ 文件中有相似内容（> 20 行）？ | 🟡 中 | 建议共享 |
| AP-4 | 多个 skill 有相似评估章节？ | 🟡 中 | 建议模板化 |
| AP-5 | 任何 skill 有 3+ 个 mode 分支？ | 🟡 中 | 建议拆分 |
| AP-6 | L2+ 缺少 scripts/ 目录？ | 🟡 中 | 建议添加 |
| AP-7 | 实际复杂度 < 生成 level？ | 🟡 中 | 建议降级 |
| AP-8 | 任何 skill 有 3+ 个独立执行路径？ | 🔴 高 | 拆分为多 skill + router |
| AP-9 | 持久输出的 skill 缺少增量检测？ | 🟡 中 | 添加 Phase 0 检测 |
