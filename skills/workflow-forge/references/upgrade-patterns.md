# Upgrade Patterns — Skill 升级路径

3 种升级路径的操作手册。每种路径有明确的触发信号、操作步骤和验证标准。

---

## L0 → L1: extract-knowledge（知识抽取）

### 触发信号

- SKILL.md 超过 200 行
- 跨 session 重复提供相同领域知识
- 方法论、评分标准、示例等占 SKILL.md 的 40%+ 篇幅
- 用了 3-5 次后发现知识需要独立维护

### 操作步骤

1. **识别知识段落**
   扫描 SKILL.md，标记以下内容类型：
   - 方法论框架（评分维度、分析模型）
   - 评分/判断标准（合格定义、红线）
   - 查找表（分类映射、选择矩阵）
   - 示例库（好/坏输出范例）
   - 行业知识（领域术语、最佳实践）

2. **按读取时机分组**
   将知识段落按 "何时需要读取" 分组为独立 reference 文件：
   - 每个 Step 需要的知识 → 对应 reference 文件
   - 始终需要的知识 → 保留在 SKILL.md 或放入 `core.md`
   - 按需查阅的知识 → 独立 reference 文件

3. **创建 references/ 目录**
   ```bash
   mkdir -p {skill_path}/references/
   ```

4. **生成 reference 文件**
   每个文件聚焦单一主题，结构：
   ```markdown
   # {Topic Name}
   ## Overview
   {Brief description}
   ## {Section 1}
   {Extracted knowledge}
   ```

5. **更新 SKILL.md**
   - 添加 Progressive Loading 表
   - 用 `cat {PLUGIN_ROOT}/skills/{skill-name}/references/{file}` 替换内联知识
   - 更新行数目标: < 350

### 验证标准

- [ ] SKILL.md < 350 行
- [ ] 每个 reference 文件聚焦单一主题
- [ ] Progressive Loading 表包含所有 reference 文件
- [ ] 所有 `cat` 命令路径正确
- [ ] 功能与升级前完全一致

---

## L1 → L2: extract-scripts（脚本抽取）

### 触发信号

- SKILL.md 中有 3+ 处 bash/python 代码块执行确定性操作
- 反复执行相同的文件解析、数据转换、或 git 操作
- 需要质量门控（自动化评估 + 分数阈值）
- 有 "同样输入 → 同样输出" 的操作步骤

### 操作步骤

1. **扫描确定性操作**
   识别 SKILL.md 中的代码块，分类：
   | 类型 | 示例 | 脚本化？ |
   |------|------|---------|
   | 文件解析 | 读取 JSON/YAML 并提取字段 | ✓ |
   | 数据转换 | 格式转换、模板填充 | ✓ |
   | Git 操作 | add + commit + push | ✓ |
   | 格式校验 | 检查文件结构、字段完整性 | ✓ |
   | 创意生成 | 写文章、取标题 | ✗（非确定性） |
   | 决策判断 | 选择方案、评估质量 | ✗（需要 Claude） |

2. **创建 scripts/ 目录**
   ```bash
   mkdir -p {skill_path}/scripts/
   ```

3. **生成脚本文件**
   每个确定性操作一个脚本：
   - 文件名：`{operation}.sh` 或 `{operation}.py`
   - 接受参数，输出结果到 stdout
   - 添加错误处理和使用说明

4. **更新 SKILL.md**
   将内联代码块替换为脚本调用：
   ```bash
   # Before (内联)
   git add -A && git commit -m "..." && git push

   # After (脚本)
   bash {PLUGIN_ROOT}/skills/{skill-name}/scripts/safe-commit.sh "commit message"
   ```

5. **可选：生成 eval skill**
   如果需要质量门控：
   - 读取 `template-eval.md` 模板
   - 生成独立 eval skill（`{name}-eval/SKILL.md`）

### 验证标准

- [ ] SKILL.md 中无 3+ 行的内联 bash/python 代码块
- [ ] 每个脚本可独立运行（有使用说明）
- [ ] 脚本只处理确定性操作
- [ ] SKILL.md 通过 `bash scripts/xxx.sh` 调用脚本
- [ ] 功能与升级前完全一致

---

## L2 → L3: split-phases（阶段拆分）

### 触发信号

- SKILL.md > 400 行（即使抽取了知识和脚本）
- 有 3+ 个需要不同专业知识的阶段
- 需要多角色协作（如研究员 + 写手 + 编辑）
- 需要多品牌/人设切换
- 需要自进化规则（RLHF）

### 操作步骤

1. **分析阶段结构**
   识别可独立调用的阶段，判断：
   - 各阶段需要的专业知识是否不同？
   - 各阶段可以独立使用吗？
   - 各阶段的输入输出边界清晰吗？

2. **每个独立阶段 → 专家 skill**
   使用 `template-specialist.md` 为每个阶段生成：
   - `skills/{specialist}/SKILL.md`
   - `skills/{specialist}/references/`（从原 skill 迁移相关知识）

3. **生成编排器**
   使用 `template-orchestrator.md` 生成串联各专家的 pipeline：
   - `skills/{name}-pipeline/SKILL.md`
   - 定义阶段顺序、数据传递方式、质量门控点

4. **共享知识处理**
   跨专家的共同知识：
   - 方案 A：抽取到 `shared/` 目录，各 skill 通过路径引用
   - 方案 B：放在编排器的 references/ 中，执行时传递给专家

5. **可选模块**
   - Brand 系统：使用 `template-brand.md` 生成品牌配置
   - RLHF 系统：使用 `template-rlhf.md` 生成自进化机制

### 验证标准

- [ ] 每个专家 SKILL.md < 500 行
- [ ] 编排器能正确调用所有专家 skill
- [ ] 各专家可独立使用（不依赖编排器也能运行）
- [ ] 无重复知识（共享内容已提取到 shared/）
- [ ] 功能与升级前完全一致

---

## 通用原则

1. **功能不变** — 升级只改变组织结构，不改变行为
2. **逐步升级** — 不跳级（L0 不能直接到 L3）
3. **用户确认** — 每次升级前展示变更计划，等待确认
4. **可回退** — 保留升级前的文件备份建议
