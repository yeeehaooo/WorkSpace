# Skill Combination Examples

## 概述

本文件提供 Skills 組合使用的實際範例。

**版本：** v1.0
**最後更新：** 2026-02-26

---

## 一、常見組合模式

### 1.1 Structure + Patterns

**組合：** `dmis` + `unit-of-work` + `outbox` + `domain-event`

**使用場景：**
- 建立新的企業後端專案
- 需要可靠的事件發布
- 需要交易管理

**範例：**
```json
{
  "governance": "v1",
  "skills": [
    "dotnet/structures/dmis",
    "dotnet/patterns/unit-of-work",
    "dotnet/patterns/outbox",
    "dotnet/patterns/domain-event"
  ]
}
```

### 1.2 Generator + Patterns

**組合：** `create-clean-module` + `unit-of-work` + `result-wrapper`

**使用場景：**
- 生成新模組
- 需要交易管理
- 需要明確錯誤處理

**範例：**
```json
{
  "governance": "v1",
  "skills": [
    "dotnet/generators/create-clean-module",
    "dotnet/patterns/unit-of-work",
    "dotnet/patterns/result-wrapper"
  ]
}
```

### 1.3 Template + Patterns

**組合：** `create-api-adapter` + `retry-policy` + `execution-tracking`

**使用場景：**
- 整合外部 API
- 需要重試機制
- 需要執行追蹤

**範例：**
```json
{
  "governance": "v1",
  "skills": [
    "dotnet/templates/create-api-adapter-skill",
    "dotnet/patterns/retry-policy",
    "dotnet/patterns/execution-tracking"
  ]
}
```

---

## 二、完整專案範例

### 2.1 企業後端專案

```json
{
  "governance": "v1",
  "skills": [
    "dotnet/structures/dmis",
    "dotnet/patterns/unit-of-work",
    "dotnet/patterns/outbox",
    "dotnet/patterns/domain-event",
    "dotnet/patterns/caching-strategy",
    "dotnet/patterns/retry-policy",
    "dotnet/patterns/execution-tracking",
    "dotnet/patterns/result-wrapper",
    "_shared/core"
  ]
}
```

### 2.2 簡單 API 專案

```json
{
  "governance": "v1",
  "skills": [
    "dotnet/structures/clean",
    "dotnet/patterns/result-wrapper",
    "_shared/core"
  ]
}
```

---

## 三、組合注意事項

### 3.1 避免衝突

- 確保 skills 之間沒有衝突的概念
- 如果有多個 skills 處理相同問題，選擇最適合的

### 3.2 優先順序

- Structure skills 通常優先
- Patterns 可以組合多個
- Templates 和 Generators 按需使用

---

**維護者：** 開發團隊
**審核者：** 架構團隊
