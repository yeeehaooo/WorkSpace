# 專案層級 Skill Rules 指南

## 概述

專案層級的 Skill Rules 允許您為特定專案定義自動觸發的 skills，確保開發 .NET API 時自動應用相關的 patterns 和最佳實踐。

---

## 建立專案層級 Rule

### 步驟 1: 建立 `.cursor/rules/` 目錄

在專案根目錄下建立：
```
Projects/{ProjectName}/.cursor/rules/
```

### 步驟 2: 建立 Rule 檔案

建立檔案：`40-dotnet-api-skills.mdc`

**範例：**
```markdown
---
globs: *.cs,*.csproj,*.sln,*.slnx
description: .NET API development skills and patterns
---

# .NET API Development Skills

When developing .NET API in this project, automatically apply the following skills:
...
```

### 步驟 3: 設定 globs

使用 `globs` 來指定哪些檔案會觸發這個 rule：

```yaml
globs: *.cs,*.csproj,*.sln,*.slnx
```

這表示當編輯 `.cs`、`.csproj`、`.sln`、`.slnx` 檔案時，這個 rule 會自動生效。

---

## Rule 內容結構

### 1. 結構 Skills（Structure）

定義專案使用的架構結構：

```markdown
**dmis** - Enterprise backend structure
- **Always applies** to this project
- **Load**: `/skills/dotnet/structures/dmis/SKILL.md`
- **Key principles**: Clean Architecture, DDD, CQRS, Vertical Slice
```

### 2. Pattern Skills（模式）

列出常用的 patterns，並說明何時觸發：

```markdown
**unit-of-work**
- **When**: Command handlers, database transactions
- **Triggers**: "transaction", "atomic", "command handler"
- **Load**: `/skills/dotnet/patterns/unit-of-work/SKILL.md`
```

### 3. Generator Skills（生成器）

用於建立新程式碼的 generators：

```markdown
**create-domain-aggregate**
- **When**: Creating aggregate roots
- **Triggers**: "aggregate", "aggregate root"
- **Load**: `/skills/dotnet/generators/create-domain-aggregate/SKILL.md`
```

---

## 觸發機制

### 自動觸發條件

Rule 中定義的 skills 會在以下情況自動觸發：

1. **明確提及**：用戶提到 skill 名稱
2. **描述匹配**：用戶請求匹配 skill 描述
3. **標籤匹配**：用戶請求匹配 skill 標籤
4. **上下文匹配**：當前上下文暗示需要該 skill

### 範例

**用戶請求：**
```
「建立一個新的 command handler 來處理訂單建立」
```

**AI 流程：**
1. ✅ 讀取 `40-dotnet-api-skills.mdc` rule（因為編輯 `.cs` 檔案）
2. ✅ 識別「command handler」→ 匹配 `unit-of-work` 和 `result-wrapper`
3. ✅ 載入 `unit-of-work/SKILL.md` 和 `result-wrapper/SKILL.md`
4. ✅ 根據 skills 指引建立 command handler

---

## 專案特定規則

可以在 rule 中定義專案特定的規則：

```markdown
## Project-Specific Rules

### API Layer
- Vertical slice: `Modules/{ModuleName}/{UseCase}/`
- Files: Endpoint, Request, Response, Mapper
- Use Result<T> for all responses

### Application Layer
- Commands: `Modules/{ModuleName}/Commands/`
- Queries: `Modules/{ModuleName}/Queries/`
- MUST use Result<T> for all handlers
```

---

## 常見場景範例

### 場景 1: 建立 API Endpoint

**Rule 定義：**
```markdown
**Creating API Endpoint:**
→ Load `dmis` structure + `result-wrapper` pattern
```

**用戶請求：**
```
「建立一個新的 API endpoint 來查詢使用者」
```

**AI 動作：**
- 載入 `dmis/SKILL.md`（結構指引）
- 載入 `result-wrapper/SKILL.md`（錯誤處理）
- 遵循 vertical slice 組織
- 使用 Result<T> 作為回應

---

### 場景 2: 建立 Command Handler

**Rule 定義：**
```markdown
**Creating Command Handler:**
→ Load `unit-of-work` + `result-wrapper` + `execution-tracking`
```

**用戶請求：**
```
「建立一個 command handler 來建立訂單」
```

**AI 動作：**
- 載入 `unit-of-work/SKILL.md`（交易管理）
- 載入 `result-wrapper/SKILL.md`（錯誤處理）
- 載入 `execution-tracking/SKILL.md`（可觀測性）
- 實作符合所有 patterns 的 handler

---

### 場景 3: 建立 Domain Aggregate

**Rule 定義：**
```markdown
**Creating Domain Aggregate:**
→ Load `create-domain-aggregate` + `domain-event` (if needed)
```

**用戶請求：**
```
「建立一個 Order aggregate，當訂單建立時要發布事件」
```

**AI 動作：**
- 載入 `create-domain-aggregate/SKILL.md`（生成器）
- 載入 `domain-event/SKILL.md`（事件機制）
- 生成符合 DDD 原則的 aggregate
- 包含事件發布邏輯

---

## 最佳實踐

### 1. 保持 Rule 簡潔

- ✅ 只列出專案實際使用的 skills
- ✅ 明確說明觸發條件
- ✅ 避免冗長的說明

### 2. 使用 Progressive Disclosure

- ✅ 在 rule 中只引用 skill 路徑
- ✅ 不要複製 skill 內容到 rule
- ✅ 讓 AI 按需載入完整 SKILL.md

### 3. 專案特定規則

- ✅ 定義專案特定的資料夾結構
- ✅ 說明專案特定的命名慣例
- ✅ 列出專案特定的 anti-patterns

### 4. 多個 Skills 組合

- ✅ 說明哪些 skills 可以組合使用
- ✅ 提供常見的組合場景
- ✅ 避免載入不相關的 skills

---

## 範例檔案

### 完整範例

參考：
- **模板**：`.cursor/rules/_templates/40-dotnet-api-skills.mdc.template`
- **實際使用**：`Projects/O1MS10825060010_DMIS_Backend/.cursor/rules/40-dotnet-api-skills.mdc`

### 複製到新專案

```powershell
# 從模板複製
Copy-Item ".cursor\rules\_templates\40-dotnet-api-skills.mdc.template" `
  "Projects\{NewProject}\.cursor\rules\40-dotnet-api-skills.mdc"

# 根據專案需求修改內容
```

---

## 驗證

### 測試 Rule 是否生效

1. 開啟專案中的 `.cs` 檔案
2. 詢問 AI：「建立一個新的 command handler」
3. 檢查 AI 是否自動載入相關 skills
4. 確認生成的程式碼符合 skills 指引

### 檢查 Token 消耗

- ✅ 只有被觸發的 skills 會被載入
- ✅ Metadata 階段：~100 tokens/skill
- ✅ 完整內容：~3,000 tokens/skill
- ❌ 不應該載入所有 skills（會導致 370K+ tokens）

---

## 注意事項

### 1. Rule 優先順序

- 專案層級 rules 優先於 workspace 層級 rules
- 但 governance rules (`/agent`) 始終最高優先級

### 2. Skill 載入策略

- Rule 只是「引用」skills，不「包含」skills 內容
- AI 會根據觸發條件按需載入完整 SKILL.md
- 不要將 skill 內容複製到 rule 中

### 3. 與 `90-active-skills.mdc` 的關係

- `90-active-skills.mdc` 列出專案可用的 skills（metadata）
- Rule 定義何時自動觸發這些 skills
- 兩者配合使用，實現自動化 skill 應用

---

## 總結

專案層級的 Skill Rules 讓您可以：

1. ✅ **自動化**：開發時自動應用相關 skills
2. ✅ **標準化**：確保專案遵循一致的 patterns
3. ✅ **效率**：減少重複說明，提高開發效率
4. ✅ **品質**：透過 skills 確保程式碼品質

**關鍵原則：**
- 🎯 Rule 定義「何時」使用 skills
- 🎯 Skills 定義「如何」實作
- 🎯 按需載入，不要預載所有內容
