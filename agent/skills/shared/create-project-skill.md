---
name: create-project-skill
description: 創建可重複使用的專案 Skill，方便 AGENT 重複使用
version: 1.0.0
---

# Create Project Skill

此 Skill 用於建立新的 Skill，確保：

- 可跨專案使用
- 可抽象
- 不耦合特定專案
- 可版本控管

---

# 創建步驟

## 步驟 1：分析使用者需求

### 判斷是否值得建立 Skill

符合以下條件才建立：

- 重複使用 2 次以上
- 具有標準流程
- 可抽象化
- 可跨 Projects 共用

### 適合建立 Skill 的範例

- 建立第三方 API Adapter
- 建立 Clean Architecture 模組
- 建立 CQRS UseCase
- 建立 Docker Compose 結構

---

## 步驟 2：讀取專案程式碼

- 分析現有結構
- 找出可抽象 Pattern
- 找出命名規則
- 找出 DI 註冊方式

### ❌ 禁止

- 複製具體專案名稱
- 寫死模組名稱

### ✅ 抽象方式

```csharp
public class {Entity}Repository
{
}
```

---

## 步驟 3：確認創建位置

### 分類結構

```
.cursor
└── skills
    ├── shared
    ├── architecture
    ├── api
    ├── domain
    ├── infrastructure
    └── devops
```

### 分類原則

| 類型 | 放置位置 |
|------|----------|
| 通用 Skill | shared |
| Clean Architecture | architecture |
| API Adapter | api |
| Domain 建模 | domain |
| 基礎建設 | infrastructure |
| Docker / CI | devops |

---

## 步驟 4：建立 Skill 檔案

### 檔名規則

```
{action}-{scope}-skill.md
```

例如：

- create-api-adapter-skill.md
- create-domain-aggregate-skill.md
- create-clean-module-skill.md

---

## Skill 標準模板

```markdown
---
name: skill-name
description: 能讓 AGENT 理解用途
version: 1.0.0
---

# Skill Title

## 前置條件

- 條件 1
- 條件 2

## 建立步驟

### Step 1

- 動作
- 動作

### Step 2

- 動作

## 範例

### ✅ 正確

```csharp
// example
```

### ❌ 錯誤

```csharp
// bad example
```

## 注意事項

- 原則 1
- 原則 2
```

---

## 修改 Skill 原則

- 僅修改當前 Skill
- 不得直接修改其他 Skill
- 若重大變更 → 增加 version

---

## Changelog

### 1.0.0
- Initial version