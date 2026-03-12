# Linear API Integration Patterns

通过 Linear GraphQL API 创建和管理 issue 的模式参考。

## 认证

```bash
curl -X POST https://api.linear.app/graphql \
  -H "Authorization: $LINEAR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query": "..."}'
```

API Key 从环境变量 `LINEAR_API_KEY` 读取。

## 常用查询

### 获取 Team 和 Project 信息

```graphql
{
  viewer {
    id
    name
    email
  }
  teams {
    nodes {
      id
      name
      key
    }
  }
  projects {
    nodes {
      id
      name
      slugId
    }
  }
}
```

### 获取 Workflow States

```graphql
{
  workflowStates {
    nodes {
      id
      name
      type
      team {
        key
      }
    }
  }
}
```

### 获取 Labels

```graphql
{
  team(id: "$TEAM_ID") {
    labels {
      nodes {
        id
        name
      }
    }
  }
}
```

## 创建操作

### 创建 Project

```graphql
mutation {
  projectCreate(input: { name: "project-name", teamIds: ["$TEAM_ID"] }) {
    success
    project {
      id
      name
      slugId
    }
  }
}
```

### 创建 Label

```graphql
mutation {
  issueLabelCreate(
    input: { name: "label-name", color: "#4C9AFF", teamId: "$TEAM_ID" }
  ) {
    success
    issueLabel {
      id
      name
    }
  }
}
```

### 创建 Issue

```graphql
mutation {
  issueCreate(
    input: {
      title: "issue title"
      description: "markdown description"
      teamId: "$TEAM_ID"
      projectId: "$PROJECT_ID"
      labelIds: ["$LABEL_ID_1", "$LABEL_ID_2"]
      stateId: "$STATE_ID"
      priority: 2
    }
  ) {
    success
    issue {
      id
      identifier
      title
      url
    }
  }
}
```

Priority: 0=No priority, 1=Urgent, 2=High, 3=Medium, 4=Low

### 创建阻塞关系

```graphql
mutation {
  issueRelationCreate(
    input: {
      issueId: "$BLOCKED_ISSUE_ID"
      relatedIssueId: "$BLOCKER_ISSUE_ID"
      type: blocks
    }
  ) {
    success
  }
}
```

注意: `issueId` 是被阻塞的 issue，`relatedIssueId` 是阻塞者。

## 批量创建模式

由于 Linear GraphQL 不支持原生批量 mutation，使用循环逐个创建：

```bash
# 1. 先创建所有 labels，收集 IDs
# 2. 再创建所有 issues，收集 IDs
# 3. 最后创建所有 blocking relations
```

关键：创建顺序必须是 labels → issues → relations，因为后续步骤需要前面的 ID。

## Symphony 集成

创建完 issues 后，更新 `WORKFLOW.md` 的 `project_slug` 字段为新 project 的 `slugId`，Symphony 就能轮询到这些 issues 并分发给 agent。

```yaml
tracker:
  kind: linear
  project_slug: "{slugId}"
  active_states:
    - "📒 Todo"
    - In Progress
```
