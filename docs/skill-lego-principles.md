# Skill LEGO Principles

## 概述

LEGO 原則強調 Skills 應該像樂高積木一樣：最小化、模組化、可組合。

**版本：** v1.0
**最後更新：** 2026-02-26

---

## 一、核心原則

### 1.1 最小化（One Thing）

每個 Skill 只解決一個問題：

- ✅ **Good**: `unit-of-work` 只處理交易邊界
- ❌ **Bad**: `backend-patterns` 包含所有後端模式

### 1.2 模組化（Modular）

Skills 應該獨立且可替換：

- ✅ **Good**: 可以單獨使用 `unit-of-work` 或 `outbox`
- ❌ **Bad**: `unit-of-work` 強制依賴 `outbox`

### 1.3 可組合（Composable）

Skills 可以組合使用：

- ✅ **Good**: `dmis` structure + `unit-of-work` pattern + `outbox` pattern
- ❌ **Bad**: 所有功能都在一個 skill 中

---

## 二、拆分策略

### 2.1 何時拆分

拆分大型 Skill 當：
- Skill 內容超過 5000 words
- Skill 涵蓋多個不相關的概念
- Skill 可以明顯分為多個獨立功能

### 2.2 拆分範例

**Before (Monolithic):**
```
skills/dotnet/backend/
└── skill.mdc (5000+ lines, 包含所有後端知識)
```

**After (LEGO-style):**
```
skills/dotnet/
├── structures/
│   ├── clean/
│   └── dmis/
├── patterns/
│   ├── unit-of-work/
│   ├── outbox/
│   └── domain-event/
├── templates/
│   ├── api-adapter/
│   └── docker-compose/
└── generators/
    ├── create-module/
    └── create-aggregate/
```

---

## 三、組合使用

### 3.1 常見組合

**Structure + Patterns:**
- `dmis` + `unit-of-work` + `outbox` + `domain-event`

**Generator + Patterns:**
- `create-clean-module` + `unit-of-work` + `result-wrapper`

**Template + Patterns:**
- `create-api-adapter` + `retry-policy` + `execution-tracking`

### 3.2 組合原則

- Skills 應該可以獨立使用
- 組合時不應該有衝突
- 組合應該增強功能，而非重複

---

## 四、避免重複

### 4.1 內容重複

- ❌ 多個 skills 包含相同的程式碼範例
- ✅ 使用 references/ 目錄共享內容

### 4.2 概念重複

- ❌ `unit-of-work` 和 `transaction-policy` 重複說明交易
- ✅ `unit-of-work` 專注邊界控制，`transaction-policy` 專注策略

---

## 五、最佳實踐

1. **保持獨立性**：每個 skill 應該可以單獨使用
2. **明確職責**：清楚定義 skill 解決的問題
3. **避免依賴**：不要強制依賴其他 skills
4. **可組合性**：設計時考慮組合使用
5. **文檔清晰**：說明如何與其他 skills 組合

---

**維護者：** 開發團隊
**審核者：** 架構團隊
