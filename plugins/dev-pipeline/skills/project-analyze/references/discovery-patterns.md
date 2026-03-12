# 架构识别方法论

## 一、分层发现方法

不预设层级名称（如 lib/services），而是从代码的**调用关系**中发现层级。

### 1.1 入口识别

入口 = 被外部（用户/浏览器/API 调用方）直接触达的代码。

| 框架 | 入口标志 | 常见目录 |
|------|---------|---------|
| Next.js | `page.tsx`, `route.ts` | `app/`, `pages/` |
| Express/Koa | `app.listen()`, router | `src/routes/`, `src/api/` |
| React SPA | `index.tsx`, Router | `src/pages/`, `src/views/` |
| CLI | `bin/`, `commander`/`yargs` | `src/commands/` |
| Library/SDK | `index.ts` exports | `src/` root |

### 1.2 层级判定规则

```
                  被外部直接访问？
                  │
                  ├─ 是 → 入口层（页面/路由/CLI 命令）
                  │
                  └─ 否 → 被入口层调用？
                         │
                         ├─ 是 → 是否调用同级其他模块？
                         │       │
                         │       ├─ 是（组合多个模块） → 编排层
                         │       │
                         │       └─ 否（单一职责） → 能力层
                         │
                         └─ 否 → 是否只被引用、不含逻辑？
                                 │
                                 ├─ 是 → 配置层
                                 └─ 否 → 工具/辅助层
```

### 1.3 常见层级模式

以下是**常见**的层级模式，供参考但不强制套用：

| 模式 | 层级 | 典型目录名 |
|------|------|-----------|
| 前端全栈 | 页面 → 组件 → hooks → 工具库 → 配置 | app/ → components/ → hooks/ → lib/ → config/ |
| 后端 API | 路由 → 控制器 → 服务 → 数据访问 → 模型 | routes/ → controllers/ → services/ → repositories/ → models/ |
| 全栈混合 | 页面/API → 组件 → 编排 → 能力 → 配置 | app/ → components/ → services/ → lib/ → config/ |
| 微服务 | 网关 → 服务 → 领域 → 基础设施 | gateway/ → services/ → domain/ → infra/ |

## 二、模块边界识别

### 2.1 Import 分析

```
对于同一层内的目录 A 和 B：

A 引用 B？  B 引用 A？  关系
   否          否       完全隔离（可并行开发）
   是          否       A 依赖 B（单向）
   否          是       B 依赖 A（单向）
   是          是       循环依赖（需重构）
```

分析方法：
1. 在模块 A 的文件中 grep `from '../B/` 或 `from '@/B/` 等 import 路径
2. 反向在模块 B 中 grep A 的引用
3. 画出依赖矩阵

### 2.2 隔离性分级

| 级别 | 说明 | 可并行开发？ |
|------|------|-------------|
| 完全隔离 | 零 import 关系 | 是 |
| 单向依赖 | A→B 但 B 不知道 A | B 可独立，A 受限 |
| 双向弱耦合 | 通过接口/类型关联 | 有条件 |
| 紧耦合 | 直接 import 具体实现 | 否 |

## 三、状态性判定

### 3.1 无状态 vs 有状态

| 特征 | 无状态 | 有状态 |
|------|--------|--------|
| 函数签名 | `(input) → output` | `(state, input) → void` 或修改 state |
| 数据传递 | 通过参数和返回值 | 通过共享对象/闭包/类实例 |
| 可测试性 | mock IO → 断言输出 | 需要构造初始 state → 断言 state 变化 |
| 复用性 | 高（任何上下文都能调用） | 低（绑定特定业务流程） |
| 典型代码 | 工具函数、转换器、API 客户端 | 流水线、状态机、工厂编排 |

### 3.2 判定信号

```
函数/类如何处理数据？
  │
  ├─ 入参 → 处理 → 返回值（不修改入参）
  │   └─→ 无状态
  │
  ├─ 接收 state 对象 → 读写 state → 不返回或返回 void
  │   └─→ 有状态
  │
  ├─ 类实例维护内部状态（this.xxx = ...）
  │   └─→ 有状态
  │
  └─ 混合：部分步骤无状态、部分步骤修改共享对象
      └─→ 编排层（组合无状态能力，管理状态流转）
```

## 四、架构模式识别

### 4.1 常见模式及识别信号

| 模式 | 识别信号 | 查找方法 |
|------|---------|---------|
| **工厂模式** | 抽象基类 + 多个子类 + `create()` 方法 | grep `extends.*Factory\|Base` |
| **流水线** | state 对象 + 多个顺序步骤 + runner | grep `pipeline\|PipelineState\|runner` |
| **Builder** | 链式调用 `.set().with().build()` | grep `return this\|\.build()` |
| **Strategy/Preset** | 配置对象选择不同行为 | grep `preset\|strategy\|config.*mode` |
| **Plugin** | 注册 + 发现 + 生命周期 | grep `register\|plugin\|middleware` |
| **Repository** | 数据访问抽象 | grep `find\|create\|update\|delete.*repository` |
| **Event/Observer** | 事件发射 + 监听 | grep `emit\|on\|addEventListener\|subscribe` |

### 4.2 模式组合

项目中的模式经常组合出现：

```
工厂 + 流水线 = 多步骤工厂流水线（如 DataFactory → CampaignFactory → ContentFactory）
Strategy + 工厂 = 可配置的工厂（通过 preset 切换行为）
Builder + 工厂 = Fluent API 构建复杂对象
```

## 五、可复用能力识别

### 5.1 识别标准

一个函数/模块被视为"可复用能力"需满足：

| 条件 | 说明 |
|------|------|
| 无状态 | 入参→返回值，不依赖外部 state |
| 单一职责 | 做一件事（一次 LLM 调用、一次转换、一次上传） |
| 明确签名 | 输入类型和输出类型清晰 |
| 可独立调用 | 不需要特定的编排上下文就能使用 |

### 5.2 能力分类

| 类别 | 特征 | 示例 |
|------|------|------|
| **AI 能力** | 调用 LLM/AI 服务 | 品牌提取、内容生成、策略规划 |
| **转换能力** | 数据格式 A→B | JSON→Canvas、Markdown→HTML |
| **IO 能力** | 单次外部操作 | 文件上传、网页爬取、截图 |
| **查询能力** | 搜索/筛选/查找 | 模板选择、配置查找 |
| **工具能力** | 通用计算 | 颜色处理、坐标变换、日期计算 |

### 5.3 能力组合矩阵

盘点完能力后，生成组合矩阵：

```
行 = 业务场景（当前 + 潜在）
列 = 已有能力模块
单元格 = ✅ 直接复用 | 🔧 需适配 | - 不需要
```

这个矩阵帮助回答："如果要做新业务 X，已有能力能覆盖多少？"
