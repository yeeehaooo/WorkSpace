# Skill Content Update Checklist

## 概述

本檢查清單用於確保每個 Skill 在更新後符合 Antigravity Agent Skills 標準。

**版本：** v1.0
**最後更新：** 2026-02-26

---

## 一、Frontmatter 檢查

### 1.1 基本欄位

- [ ] `name` 存在且符合命名規範
- [ ] `type` 存在且為有效值（structure | pattern | template | generator）
- [ ] `version` 存在且格式正確

### 1.2 Description 增強

- [ ] 包含核心描述（1-2句話）
- [ ] 包含 "Use when" 區塊（至少 3-5 個場景）
- [ ] 包含 "Triggers" 區塊（至少 3-5 個關鍵字）
- [ ] 使用場景具體、可識別
- [ ] 關鍵字涵蓋常見用戶表達方式

### 1.3 Tags

- [ ] `tags` 欄位存在
- [ ] 至少包含 3 個 tags
- [ ] Tags 符合類型規範：
  - Patterns: `dotnet`, `pattern`, `clean-architecture`, `[specific-pattern]`
  - Structures: `dotnet`, `structure`, `architecture`, `[structure-name]`
  - Generators: `dotnet`, `generator`, `scaffolding`, `[generator-type]`
  - Templates: `dotnet`, `template`, `boilerplate`, `[template-type]`

---

## 二、檔案結構檢查

### 2.1 檔案命名

- [ ] 檔案已重新命名為 `SKILL.md`
- [ ] 舊檔案 `skill.mdc` 已移除或保留作為備份

### 2.2 目錄結構

- [ ] Skill 目錄結構正確
- [ ] 可選目錄已建立（如需要）：
  - [ ] `scripts/`（如有可執行腳本）
  - [ ] `references/`（如有參考文件）
  - [ ] `assets/`（如有輸出資源）

---

## 三、內容結構檢查

### 3.1 必要區塊

- [ ] **Purpose** 區塊存在且簡潔明確（1-2句話）
- [ ] **Scope** 區塊存在且列出適用場景
- [ ] **Rules** 區塊存在且結構化、可執行
- [ ] **Anti-Patterns** 區塊存在且具體、可避免
- [ ] **Examples** 區塊存在且最小化但完整

### 3.2 可選區塊

- [ ] **When to Use** 區塊（如果 description 中未完全涵蓋）
- [ ] **Combination Examples** 區塊（如適用）
- [ ] **References** 區塊（如有外部參考）

---

## 四、內容品質檢查

### 4.1 簡潔性

- [ ] 移除冗餘說明（假設 Claude 已經很聰明）
- [ ] 避免重複 governance 規則（應引用 `/agent`）
- [ ] 內容長度適中（SKILL.md < 5000 words）
- [ ] 如果內容過長，已拆分到 `references/` 目錄

### 4.2 語法與格式

- [ ] 使用命令式語法（imperative form）
- [ ] Markdown 格式正確
- [ ] 程式碼範例格式正確
- [ ] 無拼寫錯誤

### 4.3 程式碼範例

- [ ] 程式碼範例最小化但完整
- [ ] 所有範例可執行
- [ ] 範例符合最佳實踐
- [ ] 範例有適當註解

---

## 五、Progressive Disclosure 檢查

### 5.1 內容分層

- [ ] 核心內容在 SKILL.md 中
- [ ] 詳細內容在 `references/` 中（如適用）
- [ ] 可執行腳本在 `scripts/` 中（如適用）
- [ ] 模板檔案在 `assets/` 中（如適用）

### 5.2 引用方式

- [ ] SKILL.md 中正確引用 `references/` 檔案
- [ ] 引用說明清楚（何時讀取該檔案）
- [ ] 避免深度嵌套引用（最多一層）

---

## 六、類型特定檢查

### 6.1 Patterns

- [ ] 強調何時使用該 pattern
- [ ] 提供與其他 patterns 的組合範例（如適用）
- [ ] 說明與 Clean Architecture 的整合方式
- [ ] 列出相關 anti-patterns

### 6.2 Structures

- [ ] 明確架構層級職責
- [ ] 提供專案結構視覺化說明（如適用）
- [ ] 說明與 patterns 的組合使用
- [ ] 列出技術棧要求

### 6.3 Generators

- [ ] 明確生成範圍和輸出
- [ ] 提供使用範例和參數說明
- [ ] 說明生成後的後續步驟
- [ ] 列出可選參數和配置

### 6.4 Templates

- [ ] 提供模板變數說明
- [ ] 說明客製化方式
- [ ] 提供使用場景範例
- [ ] 列出模板依賴

### 6.5 Shared Skills

- [ ] 確保跨專案適用性
- [ ] 移除專案特定內容
- [ ] 提供通用化範例
- [ ] 說明適用範圍

---

## 七、向後相容性檢查

### 7.1 引用更新

- [ ] 所有引用路徑已更新（從 `skill.mdc` 到 `SKILL.md`）
- [ ] 專案 profile 中的引用正確
- [ ] 文件中的引用已更新

### 7.2 功能驗證

- [ ] 舊格式仍可正常運作（過渡期）
- [ ] 新格式功能正常
- [ ] 無破壞性變更

---

## 八、驗證工具

### 8.1 自動驗證

使用以下工具進行自動驗證：

```powershell
# 驗證單個 skill
.\tools\validate-skill-content.ps1 -SkillPath "skills/dotnet/patterns/unit-of-work"

# 驗證所有 skills
.\tools\validate-skill-content.ps1 -AllSkills
```

### 8.2 驗證項目

工具會檢查：
- Frontmatter 完整性
- Description 格式
- Tags 存在性
- 內容結構
- 程式碼範例語法

---

## 九、更新記錄

完成更新後，記錄：

- [ ] 更新日期
- [ ] 更新人員
- [ ] 主要變更內容
- [ ] 驗證結果

---

## 十、範例檢查清單

### 完成範例：unit-of-work

```
✅ Frontmatter 符合新標準
✅ Description 包含 "Use when" 和 "Triggers"
✅ Tags 已設定（4個：dotnet, pattern, clean-architecture, transaction）
✅ 檔案已重新命名為 SKILL.md
✅ 內容結構清晰（Purpose, Scope, Rules, Anti-Patterns, Examples）
✅ 內容長度適中（約 2000 words）
✅ 程式碼範例可執行
✅ 無重複 governance 內容
✅ 使用命令式語法
✅ 無 scripts/references/assets 目錄（不需要）
```

---

**維護者：** 開發團隊
**審核者：** 架構團隊
