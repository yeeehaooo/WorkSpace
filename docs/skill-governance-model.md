# Skill Governance Model

## 概述

本文檔定義了 SystexWorkSpace 的 Skill Store 治理模型，明確各層級的權責分離和設計原則。

**版本：** v1.0
**最後更新：** 2025-01-15

---

## 一、核心設計原則

### 1.1 Workspace = 能力倉庫（只提供）

**原則：**
- ✅ Workspace 只提供技能包，不強迫使用
- ✅ 不猜測專案需求
- ✅ 不自動 fallback
- ✅ 不建立 dependency graph

**實作：**
- `skills/` 目錄存放所有可用的技能包
- 專案透過 `project-profile.json` 明確選擇需要的技能
- Loader 只讀取明確指定的技能，不做任何推斷

### 1.2 Project = Skill Selector（自己選）

**原則：**
- ✅ 專案明確列出要使用的技能
- ✅ 不寫就不用
- ✅ 沒有隱性行為

**實作：**
- 每個專案在 `Projects/{ProjectName}/.ai/project-profile.json` 中定義：
  ```json
  {
    "governance": "v1",
    "skills": [
      "dotnet/structures/dmis",
      "_shared/core"
    ]
  }
  ```

### 1.3 Loader = Dumb Loader（傻瓜載入器）

**原則：**
- ✅ 讀取 profile
- ✅ 載入 agent + skills
- ✅ 產生 90-active-skills.mdc
- ✅ 結束

**禁止：**
- ❌ 自動偵測技術棧
- ❌ 自動 fallback
- ❌ 自動 dependency binding
- ❌ 隱性技能載入

---

## 二、權責分離定義

### 2.1 四層架構

| 層級 | 目錄 | 定位 | 責任 |
|------|------|------|------|
| **Governance Layer** | `agent/` | 治理邏輯 | 原則、審核策略、版本管理 |
| **Skill Layer** | `skills/` | 企業內部 Skill Store | 結構規範、patterns、templates、可重用技能 |
| **External Skills** | `.claude/skills/` | 外部官方/第三方技能 | Claude 官方技能、第三方技能包 |
| **Runtime Layer** | `.cursor/`<br>`tools/`<br>`adapters/` | 實際載入 | 載入、轉換、產生規則檔案 |

### 2.2 詳細權責

#### `agent/` - Governance Policy

**責任：**
- 定義 AI 行為原則
- 架構設計規範（Clean Architecture、CQRS）
- 命名約定、例外處理政策
- 安全指引
- 版本化治理策略

**禁止：**
- 不包含工具特定指令
- 不包含專案特定規則
- 不包含大型實作片段（屬於 skills）

**版本化：**
- `agent/v1/` - 當前治理版本
- `agent/v2/` - 未來版本（當有 breaking changes）
- 版本升級需明確遷移策略

#### `skills/` - 企業內部 Skill Store

**責任：**
- 可重用的實作 playbook
- 模板（scaffolds、snippets）
- 模式（Domain、Repository、Module layout）
- 效能指引
- 共享文件/除錯 playbook

**組織方式：**
- `skills/_shared/` - 跨技術共享技能
- `skills/dotnet/` - .NET 特定技能
  - `structures/` - 架構結構（clean、dmis）- 定義專案結構和層級組織
  - `patterns/` - 設計模式 - 行為模式擴展，對現有架構「加上某種設計能力」
  - `templates/` - 模板 - 可重用的程式碼模板和片段
  - `generators/` - 生成器 - 建立完整模組的生成工具
- `skills/meta/` - 技能元資料

**Patterns 定位說明：**
- Patterns 是**行為模式擴展**，不是 generator
- Patterns 不產生專案結構，不建立完整模組
- Patterns 只定義行為規則和實作方式
- Patterns 可組合使用（如 DMIS structure + unit-of-work pattern + outbox pattern）
- 每個 pattern 都是獨立的 folder-based skill，使用統一的 `skill.mdc` 格式

**禁止：**
- 不包含治理規則（屬於 agent）
- 不包含工具適配器行為（屬於 adapters）
- 不包含機密、token、憑證

**Immutable 原則：**
- Skill 是 immutable 的
- 不要修改現有技能（如 `dmis`）
- 如果需要新版本，建立新資料夾（如 `dmis-v2`）
- 專案自己改 profile 來選擇版本

**Patterns 詳細說明：**
- Patterns 位於 `skills/dotnet/patterns/` 目錄
- 每個 pattern 是一個 folder-based skill，包含 `skill.mdc` 文件
- Patterns 是**行為模式擴展**，不是 generator
- Patterns 不產生專案結構，不建立完整模組
- Patterns 只定義行為規則和實作方式
- Patterns 可組合使用，形成 Architecture Composition Engine

**Patterns 使用範例：**
```json
{
  "governance": "v1",
  "skills": [
    "dotnet/structures/dmis",
    "dotnet/patterns/unit-of-work",
    "dotnet/patterns/outbox",
    "dotnet/patterns/execution-tracking"
  ]
}
```

**可用的 Patterns：**
- `unit-of-work` - 交易邊界控制
- `domain-event` - 領域事件發布
- `transaction-policy` - 交易策略定義
- `caching-strategy` - 快取策略
- `pipeline-decorator` - 管道裝飾器
- `execution-tracking` - 執行追蹤
- `outbox` - 交易式輸出盒
- `retry-policy` - 重試策略
- `result-wrapper` - 結果包裝器

#### `.claude/skills/` - 外部官方技能

**責任：**
- Claude 官方技能
- 第三方技能包
- 與企業內部技能分離

**定位：**
- 這是 AI 功能，不是工程架構 skill
- 不參與 loader 流程
- 獨立管理

#### `.cursor/` - Runtime Loading

**責任：**
- 實際載入的規則檔案
- 由 `tools/update-cursor-skills.ps1` 自動產生
- 每個專案有自己的 `90-active-skills.mdc`

**結構：**
```
Projects/{ProjectName}/.cursor/rules/90-active-skills.mdc
```

**內容範例：**
```markdown
---
alwaysApply: true
---

# Governance
- /agent/v1

# Active Skills
Use the following skill packs as reference:
- /skills/_shared/core
- /skills/dotnet/structures/dmis

Notes:
- This file is auto-generated.
- DO NOT EDIT MANUALLY.
```

---

## 三、Governance Version 規則

### 3.1 版本化策略

**當前版本：** `agent/v1/`

**版本語義：**
- **Major (v1 → v2)** - Breaking governance changes
- **Minor (v1.0 → v1.1)** - 新增規則
- **Patch (v1.0.0 → v1.0.1)** - 澄清或文件更新

### 3.2 版本共存

**原則：**
- ✅ 多個 governance 版本可以共存
- ✅ 專案透過 `project-profile.json` 選擇版本
- ✅ 不同專案可以使用不同版本

**範例：**
```json
{
  "governance": "v1",  // 或 "v2"
  "skills": [...]
}
```

### 3.3 升級策略

**如何升級 governance：**
1. 建立新版本資料夾（如 `agent/v2/`）
2. 定義遷移指南
3. 專案負責人根據需求選擇升級
4. 不強迫所有專案同時升級

---

## 四、Loader 設計理念

### 4.1 Dumb Loader 原則

**核心設計：**
- 極簡設計，無魔法
- 只做明確指定的事情
- 不推斷、不猜測

**流程：**
1. 讀取 `Projects/{ProjectName}/.ai/project-profile.json`
2. 載入 `agent/{governance}/` 整個資料夾
3. 載入 `skills/{skillPath}` 明確列表
4. 驗證路徑是否存在（不存在則警告）
5. 產生 `Projects/{ProjectName}/.cursor/rules/90-active-skills.mdc`
6. 結束

### 4.2 禁止事項

**嚴格禁止：**
- ❌ **不允許 detection** - 不自動偵測技術棧
- ❌ **不允許 fallback** - 不自動 fallback 到預設架構
- ❌ **不允許 implicit skill** - 不自動加入隱性技能
- ❌ **不允許 dependency binding** - 不自動解析依賴關係
- ❌ **不允許 override** - 不支援 `.ai/skills.json` override 機制

**原因：**
- 明確性優於便利性
- 可審核優於自動化
- 可版本化優於隱性行為

### 4.3 Migration 策略

**自動產生預設 profile：**
- 第一次執行時，如果專案沒有 `project-profile.json`
- 自動產生預設 profile：
  ```json
  {
    "governance": "v1",
    "skills": ["_shared/core"]
  }
  ```
- 此 migration 邏輯只保留一個版本週期，未來可刪除

---

## 五、專案微客製化

### 5.1 專案層級客製化

**方式：**
- 專案底下直接放：`Projects/{ProjectName}/.cursor/rules/custom.mdc`
- 不經過 profile
- 平台不管

**範例：**
```
Projects/NewTest/.cursor/rules/
├── 90-active-skills.mdc  (自動產生)
└── custom.mdc            (專案自己管理)
```

### 5.2 切換架構

**方式：**
- 修改 `project-profile.json`：
  ```json
  {
    "governance": "v1",
    "skills": [
      "dotnet/structures/clean"  // 從 dmis 改為 clean
    ]
  }
  ```
- 重新執行 `tools/update-cursor-skills.ps1`
- 結束

---

## 六、架構成熟度

### 6.1 當前成熟度等級

| 等級 | 狀態 |
|------|------|
| 玩具 workspace | ❌ |
| 規則 workspace | ❌ |
| 技能型 workspace | ✅ |
| 治理型 workspace | ✅ |
| 可版本 AI 平台 | ✅ |

**已達到最高等級：可版本 AI 平台**

### 6.2 架構優勢

**以前：**
- Workspace 決定技能
- 自動偵測可能誤判
- Fallback 機制複雜
- 562 行複雜邏輯

**現在：**
- Project 決定技能
- 明確、可審核
- 168 行極簡邏輯
- 可版本化、可 CI、可 Rollback

**未來可擴展能力：**
- governance v1 / v2 共存
- 專案 A 用 clean
- 專案 B 用 dmis
- 專案 C 用 minimal
- Workspace 不再干涉

---

## 七、最佳實踐

### 7.1 Skill 開發

**原則：**
- Skill 是 immutable 的
- 不要修改現有 skill
- 如果需要新版本，建立新資料夾
- Skill 不應該知道 project
- Skill 只描述架構，不判斷 override

**範例：**
```
skills/dotnet/structures/
├── clean/      (v1)
├── dmis/       (v1)
└── dmis-v2/    (新版本，不修改 dmis)
```

### 7.2 Profile 管理

**原則：**
- 每個專案明確列出需要的技能
- 不依賴隱性行為
- 版本控制 `project-profile.json`
- 可審核、可追蹤

### 7.3 團隊協作

**原則：**
- 新專案：建立 `project-profile.json`，明確選擇技能
- 現有專案：根據需求調整 profile
- 架構變更：修改 profile，重新執行 loader
- 版本升級：選擇新的 governance 版本

---

## 八、常見問題

### Q1: 為什麼不自動偵測技術棧？

**A:** 明確性優於便利性。自動偵測可能誤判，且無法版本控制。專案明確指定技能，可審核、可追蹤。

### Q2: 為什麼不支援 fallback？

**A:** Fallback 會造成隱性行為，難以追蹤和審核。專案應該明確選擇技能，而不是依賴隱性 fallback。

### Q3: 為什麼 Skill 是 immutable？

**A:** 確保版本一致性。如果需要新版本，建立新資料夾，專案自己選擇版本。這樣可以避免破壞性變更影響現有專案。

### Q4: 如何切換架構？

**A:** 修改 `project-profile.json` 中的 `skills` 陣列，重新執行 loader。例如從 `dmis` 改為 `clean`。

### Q5: 專案如何微客製化？

**A:** 在專案底下建立 `Projects/{ProjectName}/.cursor/rules/custom.mdc`，不經過 profile，平台不管。

---

## 九、參考文件

- [Enterprise AI Workspace Architecture](./ai-workspace-architecture.md)
- [Agent Governance](../agent/README.md)
- [Skills README](../skills/README.md)
- [Agent Version](../agent/meta/version.md)

---

## 十、變更記錄

| 日期 | 版本 | 變更內容 |
|------|------|----------|
| 2025-01-15 | v1.0 | 初始版本，定義 Skill Governance Model |

---

**維護者：** 開發團隊
**審核者：** 架構團隊
