# Skill Migration Guide

## 概述

本指南說明如何將現有的 `skill.mdc` 檔案遷移到符合 Antigravity Agent Skills 標準的 `SKILL.md` 格式。

**版本：** v1.0
**最後更新：** 2026-02-26

---

## 一、遷移目標

### 1.1 結構變更

**Before:**
```
skills/dotnet/patterns/unit-of-work/
└── skill.mdc
```

**After:**
```
skills/dotnet/patterns/unit-of-work/
├── SKILL.md          (required, 重新命名自 skill.mdc)
├── scripts/          (optional, 可執行腳本)
├── references/       (optional, 參考文件)
└── assets/           (optional, 輸出資源)
```

### 1.2 Frontmatter 增強

**Before:**
```yaml
---
name: unit-of-work
description: Provide transactional boundary control for write operations
type: pattern
version: 1.2.1
---
```

**After:**
```yaml
---
name: unit-of-work
description: |
  Provide transactional boundary control for write operations in .NET applications.

  Use when:
  - Implementing command handlers that require database transactions
  - Managing transaction boundaries in Clean Architecture applications
  - Coordinating multiple repository operations atomically
  - Handling nested transactions in scoped dependency injection scenarios

  Triggers: "transaction", "unit of work", "atomic operation", "transaction boundary", "UoW"
type: pattern
version: 1.2.1
tags:
  - dotnet
  - clean-architecture
  - transaction
  - cqrs
---
```

---

## 二、遷移步驟

### 步驟 1: 準備工作

1. 備份現有的 `skill.mdc` 檔案
2. 確認 skill 的類型和用途
3. 準備增強 description 的內容

### 步驟 2: 增強 Frontmatter

#### 2.1 Description 增強

必須包含：
- **核心描述**：一句話說明 skill 的用途
- **Use when**：明確列出使用場景（至少 3-5 個）
- **Triggers**：列出關鍵字（用於自動觸發）

**撰寫範例：**
```yaml
description: |
  [一句話核心描述]

  Use when:
  - [具體場景 1]
  - [具體場景 2]
  - [具體場景 3]

  Triggers: "[關鍵字1]", "[關鍵字2]", "[關鍵字3]"
```

#### 2.2 新增 Tags

根據 skill 類型設定 tags：

- **Patterns**: `dotnet`, `pattern`, `clean-architecture`, `[specific-pattern]`
- **Structures**: `dotnet`, `structure`, `architecture`, `[structure-name]`
- **Generators**: `dotnet`, `generator`, `scaffolding`, `[generator-type]`
- **Templates**: `dotnet`, `template`, `boilerplate`, `[template-type]`

至少需要 3-5 個 tags。

### 步驟 3: 檔案重新命名

```powershell
# 重新命名檔案
Rename-Item -Path "skill.mdc" -NewName "SKILL.md"
```

### 步驟 4: 內容結構優化

確保 SKILL.md 包含以下區塊：

1. **Purpose**：簡潔明確（1-2句話）
2. **Scope**：列出適用場景
3. **Rules**：結構化、可執行
4. **Anti-Patterns**：具體、可避免
5. **Examples**：最小化但完整

### 步驟 5: Progressive Disclosure 優化

- 檢查內容長度（SKILL.md 應 < 5000 words）
- 如果內容過長，拆分到 `references/` 目錄
- 識別可提取為 `scripts/` 的重複程式碼
- 識別可提取為 `assets/` 的模板檔案

### 步驟 6: 建立目錄結構（如需要）

```powershell
# 建立可選目錄
New-Item -ItemType Directory -Path "scripts" -Force
New-Item -ItemType Directory -Path "references" -Force
New-Item -ItemType Directory -Path "assets" -Force
```

---

## 三、使用自動遷移工具

### 3.1 工具位置

`tools/migrate-skill-to-antigravity.ps1`

### 3.2 使用方法

```powershell
# 遷移單個 skill
.\tools\migrate-skill-to-antigravity.ps1 -SkillPath "skills/dotnet/patterns/unit-of-work"

# 批次遷移所有 skills
.\tools\migrate-skill-to-antigravity.ps1 -AllSkills
```

### 3.3 工具功能

1. 讀取 `skill.mdc` 或 `skill.md`
2. 增強 description（如果太簡短）
3. 新增 tags（基於 type 和內容分析）
4. 重新命名為 `SKILL.md`
5. 建立 `scripts/`, `references/`, `assets/` 目錄結構
6. 驗證內容結構
7. 檢查內容長度
8. 產生遷移報告

---

## 四、驗證檢查清單

完成遷移後，使用以下檢查清單驗證：

- [ ] Frontmatter 符合新標準
- [ ] Description 包含 "Use when" 和 "Triggers"
- [ ] Tags 已設定（至少3個）
- [ ] 檔案已重新命名為 `SKILL.md`
- [ ] 內容結構清晰（Purpose, Scope, Rules, Anti-Patterns, Examples）
- [ ] 內容長度適中（< 5000 words）
- [ ] 程式碼範例可執行
- [ ] 無重複 governance 內容
- [ ] 使用命令式語法
- [ ] 已建立必要的 scripts/references/assets 目錄（如需要）

---

## 五、向後相容性

### 5.1 過渡期支援

在過渡期間（至少 3 個月），系統同時支援：
- `skill.mdc`（舊格式）
- `SKILL.md`（新格式）

### 5.2 載入優先順序

Loader 會按以下順序尋找 skill 檔案：
1. `SKILL.md`（優先）
2. `skill.mdc`（fallback）
3. `skill.md`（fallback）

---

## 六、常見問題

### Q1: 如果 description 已經很完整，還需要增強嗎？

**A:** 是的。即使 description 已經完整，也需要加入 "Use when" 和 "Triggers" 區塊，以支援自動觸發機制。

### Q2: Tags 是必需的嗎？

**A:** 是的。Tags 用於技能分類和搜尋，至少需要 3 個 tags。

### Q3: 必須建立 scripts/references/assets 目錄嗎？

**A:** 不是。這些目錄是可選的，只有在需要時才建立。

### Q4: 內容長度超過 5000 words 怎麼辦？

**A:** 將詳細內容拆分到 `references/` 目錄，在 SKILL.md 中保留核心說明和引用。

### Q5: 如何處理現有專案的引用？

**A:** 更新所有引用路徑，從 `skill.mdc` 改為 `SKILL.md`。過渡期間，系統會自動 fallback 到舊格式。

---

## 七、參考文件

- [Skill Description Guidelines](./skill-description-guidelines.md)
- [Skill Content Update Checklist](./skill-content-update-checklist.md)
- [Antigravity Integration](./antigravity-integration.md)
- [Skill Governance Model](./skill-governance-model.md)

---

**維護者：** 開發團隊
**審核者：** 架構團隊
