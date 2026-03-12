# Knowledge Gap Categories

7 categories to check against any SOP description. For each category, determine what information the user has already provided and what is missing.

## Usage

For each category:
1. Check if the user's SOP description already covers it
2. If **sufficient** — skip, no questions needed
3. If **partial** — ask targeted follow-up questions
4. If **missing** — ask the full question set for that category

Present all questions as a single batch. User can answer "skip" for any category.

## Level Filter

Only ask categories at or below the selected maturity level:

| Level | Categories to Ask |
|-------|------------------|
| L0 Seed | 1 (领域专业知识) + 4 (输入输出契约) |
| L1 Structured | L0 + 2 (质量标准) |
| L2 Automated | L1 + 5 (工具依赖) + 6 (迭代逻辑) |
| L3 Ecosystem | All 7 categories |

Categories below the selected level: mark as "skip" automatically, do not ask.

---

## Category 1: Domain Expertise (领域专业知识)

**Minimum Level: L0** (always ask)

**What to check:** Does each phase have enough methodology/framework detail for Claude to execute it?

**Trigger:** Always check — this is the core knowledge for specialist skills.

**Questions when missing:**

- 每个阶段的核心方法论或框架是什么？
  - 例如：写作阶段用"金字塔原理"，评估阶段用"7维度评分"
- 是否有行业最佳实践可以参考？
- 每个阶段需要什么专业知识？（如果需要跨学科视角，请列出学科）
- 是否有现成的参考材料、模板、或范例可以提供？
- 这个 SOP 的各阶段需要的专业知识是否差异大到需要"换一个专家"？
  - 例如: 竞品分析 vs PRD 撰写 vs 版本规划 → 3 个不同专家
  - 如果是 → 建议拆分为同一插件下的多个 skill（见 template-router.md）
- 是否有分类/类型需要不同的处理规则？
  - 例如: AI 产品 vs 网站 vs 落地页各有不同的 PRD 模板
  - 如果是 → 建议创建 config 目录（如 templates/、channels/）

**Output location:** Specialist skill `references/` directory files. Multi-skill → router + sub-skills. Config types → config directory.

---

## Category 2: Quality Standards (质量标准)

**Minimum Level: L1**

**What to check:** How to judge if output is good or bad at each phase.

**Trigger:** Check when the SOP implies quality gates or review steps.

**Questions when missing:**

- 每个阶段的输出如何判断好坏？有没有评分标准？
- 什么样的输出算"合格"？什么算"优秀"？
- 是否有红线/底线（不可触碰的质量问题）？
- 是否需要自动化评估，还是全靠人工判断？

**Output location:** Eval skill scoring dimensions, or inline quality gates in specialist SKILL.md.

---

## Category 3: Brand / Style (品牌/风格)

**Minimum Level: L3**

**What to check:** Whether the workflow needs persona/brand consistency across outputs.

**Trigger:** Check when outputs are user-facing content (articles, emails, reports, marketing materials).

**Questions when missing:**

- 输出内容是否需要保持统一的品牌调性/人设？
- 是否有多个品牌/人设需要切换？
- 品牌调性包括哪些方面？（语言风格、正式程度、情感基调、标志性表达等）
- 是否有现成的品牌手册或风格指南可以参考？

**Output location:** `brands/_template.md` in relevant specialist plugins.

**If skipped:** Brand module disabled, no `brands/` directory generated.

---

## Category 4: Input/Output Contracts (输入输出契约)

**Minimum Level: L0** (always ask)

**What to check:** The data shape flowing between phases.

**Trigger:** Always check — this defines how plugins communicate.

**Questions when missing:**

- 每个阶段的输入是什么？（文件格式、数据结构、来源）
- 每个阶段的输出是什么？（文件格式、存放路径、命名规则）
- 阶段之间如何传递数据？（文件路径、环境变量、用户确认）
- 最终产出物是什么？（格式、交付方式）
- 是否有中央数据模型被多个阶段/角色共同读写？
  - 例如: tasks.jsonl 被 CEO/CPO/CMO 共同操作
  - 如果是 → 建议创建 shared/references/{schema}.md 和 shared/scripts/{crud}.py
- 输出是否需要支持增量更新（而非每次重建）？
  - 例如: 第二次运行时更新已有 PRD 而非重写
  - 如果是 → 在 Phase 0 加入增量检测逻辑（见 template-specialist.md Step 0.A）

**Output location:** Orchestrator SKILL.md phase definitions + specialist SKILL.md input/output sections. Shared data models → `shared/` directory.

---

## Category 5: Tool Dependencies (工具依赖)

**Minimum Level: L2**

**What to check:** External APIs, scripts, CLI tools, MCP servers needed.

**Trigger:** Check when any phase involves non-Claude operations (image generation, publishing, data fetching).

**Questions when missing:**

- 是否有外部 API 需要调用？（如 OpenAI API、数据库、第三方服务）
- 是否有 Python/Node 脚本需要执行？
- 是否需要 MCP 服务器？（如浏览器自动化、文件系统操作）
- 是否有环境变量或密钥需要配置？
- 是否有脚本/操作被多个 skill 共同使用？
  - 例如: git commit 脚本、数据 CRUD 脚本、dashboard 渲染
  - 如果是 → 建议放到 shared/scripts/（见 template-shared.md）

**Output location:** Specialist SKILL.md prerequisites section + skill `scripts/` directory. Shared scripts → shared/scripts/.

**If skipped:** No `scripts/` directory, no external tool references.

---

## Category 6: Iteration Logic (迭代逻辑)

**Minimum Level: L2**

**What to check:** Whether any phase has review-revise loops.

**Trigger:** Check when the SOP mentions review, approval, or quality gates.

**Questions when missing:**

- 是否有评审-修改循环？哪些阶段需要？
- 循环的退出条件是什么？（评分达标/最大轮次/人工确认）
- 最大修改轮次是多少？
- 超过最大轮次后怎么处理？（人工介入/降级发布/放弃）
- 是否需要 git 版本管理来追踪变更？
  - 如果是 → 建议使用 git-safe-commit 模式（见 template-shared.md）
  - Tag 约定是什么？（如 cycle/YYYY-MM、review/YYYY-MM、retro/YYYY-MM）

**Output location:** Orchestrator SKILL.md revision loop logic + eval plugin integration. Git tracking → shared/scripts/git-safe-commit.sh.

**If skipped:** No revision loops in orchestrator, single-pass execution.

---

## Category 7: Feedback Evolution (反馈进化)

**Minimum Level: L3**

**What to check:** Whether the system should learn and improve from usage.

**Trigger:** Check when the SOP will be used repeatedly (not one-off tasks).

**Questions when missing:**

- 这个工作流会反复使用吗？频率如何？
- 是否需要系统从用户反馈中学习和进化？
- 反馈信号有哪些？（显式评分、修改轮次、用户是否采用）
- 是否需要 A/B 测试能力？
- 进化的规则应该存储在哪里？

**Output location:** RLHF reference files in primary specialist skill.

**If skipped:** No RLHF system, static rules.

---

## Aggregation Rules

After collecting answers:

1. **Sufficient answers** → Directly used to fill `{{placeholder}}` in templates
2. **Partial answers** → Fill what's available, mark gaps as `<!-- TODO: [specific gap] -->`
3. **Skipped categories** → Generate valid structure with `<!-- TODO: [category] - user skipped, fill before production use -->`
4. **Category 3 skip** → Disable brand module entirely
5. **Category 6 skip** → Use single-pass (no revision loop) in orchestrator
6. **Category 7 skip** → Disable RLHF module entirely
