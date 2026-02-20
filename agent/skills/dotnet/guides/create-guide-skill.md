---
name: create-guide-skill
description: 建立 .NET 組合能力 Guide（多步驟完整實作流程）
version: 1.0.0
---

# Create Guide Skill

此 Skill 用於建立「組合能力」Guide。

---

# 定義

Guide =

- 多步驟流程
- 涉及架構決策
- 可能結合多個 snippet
- 可能建立資料夾結構
- 可能涉及 DI / Middleware / Policy

---

# 適用場景

- 建立 JWT 驗證流程
- 建立 UnitOfWork + Transaction Policy
- 建立 Clean Architecture 模組
- 建立 EF + Dapper 混用策略
- 建立 API Gateway 結構

---

# 建立規則

## 1️ 必須包含步驟流程

範例：

### Step 1 - 建立 Interface  
### Step 2 - 建立 Implementation  
### Step 3 - DI 註冊  
### Step 4 - Middleware 設定  

---

## 2️ 可引用 Snippet

Guide 可以使用 snippet：

```
引用：result-pattern-snippet
引用：async-local-snippet
```

---

## 3️ 命名規則

```
implement-{feature}-guide.md
```

範例：

- implement-jwt-authentication-guide.md
- implement-unit-of-work-guide.md
- implement-clean-module-guide.md

---

# Guide 標準模板

```markdown
---
name: guide-name
description: 簡述此 guide 功能
version: 1.0.0
---

# Guide Title

## 適用場景

- 說明何時使用

---

## 架構決策

- 說明為什麼這樣設計

---

## Step 1

- 動作
- 程式碼

## Step 2

- 動作
- 程式碼

---

## 注意事項

- 依賴方向
- Clean Architecture 限制
- Transaction 策略

---

## 延伸優化

- 效能建議
- 可擴充點
```

---

# 禁止事項

- 不可只是貼程式碼（那是 snippet）
- 不可缺少流程
- 不可缺少設計說明

---

# Changelog

## 1.0.0
- Initial version