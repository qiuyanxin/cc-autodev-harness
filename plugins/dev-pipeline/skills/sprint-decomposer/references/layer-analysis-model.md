# 6-Layer Business Analysis Model

按 6 层模型分析需求涉及的模块，确保全面覆盖从用户入口到商业变现的完整链路。

## Layer Definitions

| Layer | Name | Core Question | Examples |
|-------|------|---------------|----------|
| L1 | 入口层 (Entry) | 用户怎么来？ | SEO landing page, 广告投放, 社交分享, 邀请链接 |
| L2 | 交付层 (Delivery) | 用户拿到什么？ | AI 生成的网站, 编辑器, 预览, 导出 |
| L3 | 服务层 (Service) | 用户持续得到什么？ | 自动更新, 数据分析, 模板推荐, 客服 |
| L4 | 账户层 (Account) | 用户身份怎么管？ | 注册登录, 权限, 团队协作, 个人设置 |
| L5 | 基础设施 (Infra) | 系统怎么跑？ | 部署, CDN, 数据库, 队列, 监控 |
| L6 | 商业层 (Business) | 公司怎么赚钱？ | 订阅计划, 支付, 用量计费, 升级引导 |

## Analysis Process

For each layer, produce this inventory:

```markdown
### L{N} — {Layer Name}

**Current State**: ✅ built / ⚠️ partial / ❌ missing

**Existing Capabilities:**
- {capability 1}: {status}
- {capability 2}: {status}

**This Sprint Needs:**
- {what to build or complete}

**Blockers:**
- ⛔ {unresolved dependency or unknown}
```

## Layer Label Mapping (for Linear)

| Layer | Label | Color |
|-------|-------|-------|
| L1 | `L1-入口层` | `#4C9AFF` (blue) |
| L2 | `L2-交付层` | `#36B37E` (green) |
| L3 | `L3-服务层` | `#FF8B00` (orange) |
| L4 | `L4-账户层` | `#6554C0` (purple) |
| L5 | `L5-基础设施` | `#97A0AF` (gray) |
| L6 | `L6-商业层` | `#FF5630` (red) |

## Scope Decision Guide

Not every sprint touches all 6 layers. Use this to decide what's in scope:

| Condition | Action |
|-----------|--------|
| Layer has ❌ missing and is on critical path | Must build this sprint |
| Layer has ⚠️ partial and blocks other work | Must complete this sprint |
| Layer has ✅ built and no changes needed | Skip — document as "no change" |
| Layer has ❌ missing but NOT on critical path | Flag as future work, don't block |
| Unknown / needs research | Mark ⛔, create research task (🔬) |
