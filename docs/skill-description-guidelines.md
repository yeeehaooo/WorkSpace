# Skill Description Guidelines

## 概述

本文件定義 Skill 的 `description` 欄位撰寫規範，確保 AI 能夠準確判斷何時使用該 skill。

**版本：** v1.0
**最後更新：** 2026-02-26

---

## 一、Description 的重要性

`description` 是 Skill 自動觸發的核心機制。AI 會根據 description 內容判斷是否應該載入該 skill。

**關鍵原則：**
- Description 必須清楚說明「何時使用」該 skill
- 包含具體的使用場景和觸發關鍵字
- 所有 "When to Use" 資訊都應該放在 description 中，而不是 SKILL.md body

---

## 二、Description 結構

### 2.1 標準格式

```yaml
description: |
  [一句話核心描述]

  Use when:
  - [具體場景 1]
  - [具體場景 2]
  - [具體場景 3]

  Triggers: "[關鍵字1]", "[關鍵字2]", "[關鍵字3]"
```

### 2.2 各部分說明

#### 核心描述（第一段）

- **長度**：1-2 句話
- **內容**：說明 skill 的核心功能和用途
- **語氣**：使用命令式或描述式

**範例：**
```
Provide transactional boundary control for write operations in .NET Clean Architecture applications.
```

#### Use when（使用場景）

- **數量**：至少 3-5 個具體場景
- **格式**：使用項目符號（bullet points）
- **內容**：具體、可識別的使用情境

**範例：**
```
Use when:
- Implementing command handlers that require database transactions
- Managing transaction boundaries across multiple repository operations
- Coordinating atomic operations in Clean Architecture applications
- Handling nested transactions in scoped dependency injection scenarios
- Preventing repository-level transaction management anti-patterns
```

#### Triggers（觸發關鍵字）

- **格式**：逗號分隔的字串列表
- **內容**：用戶可能使用的關鍵字或短語
- **數量**：至少 3-5 個關鍵字

**範例：**
```
Triggers: "transaction", "unit of work", "atomic operation", "transaction boundary", "UoW"
```

---

## 三、撰寫最佳實踐

### 3.1 好的 Description 範例

#### Pattern Skill（unit-of-work）

```yaml
description: |
  Provide transactional boundary control for write operations in .NET Clean Architecture applications.

  Use when:
  - Implementing command handlers that require database transactions
  - Managing transaction boundaries across multiple repository operations
  - Coordinating atomic operations in Clean Architecture applications
  - Handling nested transactions in scoped dependency injection scenarios
  - Preventing repository-level transaction management anti-patterns

  Triggers: "transaction", "unit of work", "atomic operation", "transaction boundary", "UoW", "database transaction"
```

#### Structure Skill（dmis）

```yaml
description: |
  Enterprise backend structure built on Clean Architecture, DDD, CQRS, and Vertical Slice API Design with Dapper-first persistence.

  Use when:
  - Creating new enterprise backend projects
  - Implementing Clean Architecture with DDD and CQRS
  - Building vertical slice API endpoints
  - Using Dapper as primary persistence mechanism
  - Organizing modules by UseCase-driven and Model-driven separation

  Triggers: "dmis structure", "clean architecture", "enterprise backend", "DDD CQRS", "vertical slice", "dapper"
```

#### Generator Skill（create-clean-module）

```yaml
description: |
  Generate a new business module following Clean Architecture, CQRS, and DDD principles with UseCase-driven and Model-driven separation.

  Use when:
  - Creating a new business module in Clean Architecture project
  - Generating module structure with CQRS separation
  - Scaffolding DDD aggregates and value objects
  - Setting up module with proper layer organization

  Triggers: "create module", "generate module", "new module", "scaffold module", "module structure"
```

#### Template Skill（create-api-adapter）

```yaml
description: |
  Create adapter structure for integrating third-party APIs in Clean Architecture applications.

  Use when:
  - Integrating external APIs or services
  - Creating HTTP client adapters for third-party services
  - Implementing API integration with error handling
  - Setting up adapter pattern for external dependencies

  Triggers: "api adapter", "third-party api", "external service", "http client adapter", "api integration"
```

### 3.2 避免的錯誤

#### ❌ 太簡短

```yaml
description: Create API adapter
```

#### ❌ 缺少使用場景

```yaml
description: |
  Create adapter structure for integrating third-party APIs.
  # 缺少 "Use when" 和 "Triggers"
```

#### ❌ 使用場景太抽象

```yaml
description: |
  Create API adapter.

  Use when:
  - When you need it
  - When it's useful
  # 太抽象，無法判斷
```

#### ✅ 正確範例

```yaml
description: |
  Create adapter structure for integrating third-party APIs in Clean Architecture applications.

  Use when:
  - Integrating external APIs or services
  - Creating HTTP client adapters for third-party services
  - Implementing API integration with error handling

  Triggers: "api adapter", "third-party api", "external service", "http client adapter"
```

---

## 四、不同類型 Skill 的 Description 重點

### 4.1 Patterns

**重點：**
- 強調何時使用該 pattern
- 說明解決的問題
- 列出常見應用場景

**範例關鍵字：**
- Pattern 名稱
- 解決的問題（如 "transaction management", "event handling"）
- 相關技術（如 "clean architecture", "cqrs"）

### 4.2 Structures

**重點：**
- 說明架構類型和特點
- 列出適用專案類型
- 說明技術棧要求

**範例關鍵字：**
- 架構名稱（如 "clean architecture", "dmis"）
- 技術棧（如 ".NET", "Dapper", "CQRS"）
- 專案類型（如 "enterprise backend", "microservice"）

### 4.3 Generators

**重點：**
- 說明生成內容
- 列出使用時機
- 說明生成後的結構

**範例關鍵字：**
- 生成動作（如 "create", "generate", "scaffold"）
- 生成目標（如 "module", "aggregate", "repository"）
- 相關架構（如 "clean architecture", "DDD"）

### 4.4 Templates

**重點：**
- 說明模板用途
- 列出適用場景
- 說明可客製化內容

**範例關鍵字：**
- 模板類型（如 "api adapter", "docker compose"）
- 使用場景（如 "containerization", "api integration"）
- 相關技術（如 "docker", "http client"）

---

## 五、驗證檢查

完成 description 撰寫後，檢查：

- [ ] 包含核心描述（1-2句話）
- [ ] 包含 "Use when" 區塊（至少 3-5 個場景）
- [ ] 包含 "Triggers" 區塊（至少 3-5 個關鍵字）
- [ ] 使用場景具體、可識別
- [ ] 關鍵字涵蓋常見用戶表達方式
- [ ] 無拼寫錯誤
- [ ] 格式正確（YAML 多行字串）

---

## 六、工具支援

### 6.1 自動驗證

使用 `tools/validate-skill-content.ps1` 驗證 description：

```powershell
.\tools\validate-skill-content.ps1 -SkillPath "skills/dotnet/patterns/unit-of-work"
```

### 6.2 自動增強

使用 `tools/migrate-skill-to-antigravity.ps1` 自動增強 description：

```powershell
.\tools\migrate-skill-to-antigravity.ps1 -SkillPath "skills/dotnet/patterns/unit-of-work" -EnhanceDescription
```

---

## 七、參考範例

查看以下 skills 的 description 作為參考：

- `skills/dotnet/patterns/unit-of-work/SKILL.md`
- `skills/dotnet/structures/dmis/SKILL.md`
- `skills/dotnet/generators/create-clean-module/SKILL.md`

---

**維護者：** 開發團隊
**審核者：** 架構團隊
