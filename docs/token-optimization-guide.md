# Token Optimization Guide

## 概述

本指南說明如何優化 SystexWorkSpace Skills 系統的 token 消耗。

**版本：** v1.0
**最後更新：** 2026-02-26

---

## 一、Token 消耗來源

### 1.1 主要消耗點

1. **Cursor Rules** (`.cursor/rules/*.mdc`)
   - 所有規則檔案都會載入
   - 應該保持簡潔

2. **Active Skills Metadata**
   - 每個 skill 的 metadata (~100 tokens)
   - 從 `90-active-skills.mdc` 載入

3. **Triggered Skills**
   - 完整 SKILL.md 內容 (< 5000 words)
   - 僅在 skill 被觸發時載入

4. **Bundled Resources**
   - references/、scripts/、assets/
   - 僅在需要時載入

---

## 二、優化策略

### 2.1 Cursor Rules 優化

**原則：**
- 保持規則檔案簡潔
- 移除重複說明
- 使用簡短、精確的描述
- 避免冗長的範例

**已優化：**
- ✅ 簡化 `.cursor/rules/20-skill-loading.mdc`
- ✅ 簡化 `.cursor/rules/25-skill-metadata.mdc`
- ✅ 簡化 `.cursor/rules/30-skill-triggering.mdc`
- ✅ 移除重複的說明和範例

### 2.2 Progressive Disclosure 嚴格執行

**三層載入系統：**

1. **Metadata (Always)**: ~100 tokens/skill
   - 只載入 name + description + tags
   - 用於 skill discovery

2. **SKILL.md Body (Triggered)**: < 5000 words
   - 僅在 skill 被觸發時載入
   - 不要預先載入所有 skills

3. **Resources (Explicit)**: 按需載入
   - references/: 僅在 SKILL.md 引用或用戶明確要求時
   - scripts/: 直接執行，不載入 context
   - assets/: 用於輸出，不載入 context

### 2.3 Skill Description 優化

**原則：**
- Description 應該簡潔但完整
- 包含 "Use when" 和 "Triggers"
- 避免冗長的說明

**範例：**
```yaml
description: |
  Provide transactional boundary control.

  Use when:
  - Implementing command handlers requiring transactions
  - Managing transaction boundaries

  Triggers: "transaction", "unit of work", "UoW"
```

---

## 三、最佳實踐

### 3.1 規則檔案

- ✅ 保持簡潔（每個規則檔案 < 100 行）
- ✅ 移除重複內容
- ✅ 使用簡短描述
- ❌ 避免冗長範例
- ❌ 避免重複說明

### 3.2 Skill 載入

- ✅ 使用 metadata 進行 discovery
- ✅ 僅載入匹配的 SKILL.md
- ✅ 按需載入 resources
- ❌ 不要預先載入所有 SKILL.md
- ❌ 不要載入不需要的 resources

### 3.3 專案配置

- ✅ 在 `project-profile.json` 中只選擇需要的 skills
- ✅ 避免選擇過多 skills
- ❌ 不要選擇所有可用的 skills

---

## 四、監控與檢查

### 4.1 檢查項目

- [ ] 規則檔案是否簡潔（< 100 行）
- [ ] 是否有重複內容
- [ ] Skills 是否只載入 metadata
- [ ] SKILL.md 是否只在觸發時載入
- [ ] Resources 是否按需載入

### 4.2 Token 估算

**正常情況：**
- Cursor Rules: ~500-1000 tokens
- Active Skills Metadata: ~100 tokens × skills 數量
- Triggered Skills: ~2000-5000 tokens × 觸發數量
- Resources: 按需載入

**優化後預期：**
- 基礎 context: ~1000-2000 tokens
- 每個觸發的 skill: +2000-5000 tokens
- 總計: 通常 < 10000 tokens（除非多個 skills 同時觸發）

---

## 五、常見問題

### Q1: 為什麼 token 消耗還是很大？

**可能原因：**
- 多個 skills 同時觸發
- Skills 內容過長（> 5000 words）
- Resources 被不必要地載入

**解決方案：**
- 檢查哪些 skills 被觸發
- 優化過長的 SKILL.md
- 確保 resources 按需載入

### Q2: 如何減少 metadata 的 token？

**解決方案：**
- 減少 `project-profile.json` 中的 skills 數量
- 只選擇真正需要的 skills
- 優化 description 長度

### Q3: 規則檔案可以更簡潔嗎？

**可以：**
- 移除冗長範例
- 合併重複說明
- 使用更簡短的描述

---

**維護者：** 開發團隊
**審核者：** 架構團隊
