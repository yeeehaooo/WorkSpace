# Token 優化最終方案

## 問題

即使移除路徑引用，token 消耗仍達 **25.5 萬 tokens**。

## 根本原因分析

1. **`.cursorignore` 未排除 `skills/` 目錄**：
   - Cursor 可能自動掃描整個 `skills/` 目錄
   - 導致所有 SKILL.md 文件被載入

2. **規則檔案中提及 `/skills/` 路徑**：
   - 即使只是提及，也可能觸發掃描
   - 需要完全移除所有路徑引用

3. **對話歷史累積**：
   - 多次查詢可能累積大量內容
   - 需要考慮對話歷史的影響

## 最終解決方案

### 1. 更新 `.cursorignore`

**加入：**
```
skills/
```

**目的：** 防止 Cursor 自動掃描 `skills/` 目錄

### 2. 移除規則檔案中的所有路徑引用

**已更新：**
- `.cursor/rules/00-bootstrap.mdc`：移除 `/skills/` 和 `/.claude/skills/` 路徑
- `.cursor/rules/20-skill-loading.mdc`：移除所有 `/skills/` 路徑引用
- `.cursor/rules/25-skill-metadata.mdc`：簡化外部 skills 說明

### 3. `90-active-skills.mdc` 格式

**已優化：**
- 完全移除路徑，只保留 skill 名稱和描述
- 格式：`skill-name - description | Tags: ...`

## 預期效果

**目標：**
- 基礎查詢：< 5,000 tokens
- 僅載入 metadata，不掃描 skills 目錄

**關鍵改變：**
- `.cursorignore` 排除 `skills/` 目錄
- 規則檔案中完全移除路徑引用
- `90-active-skills.mdc` 只包含名稱和描述

## 驗證步驟

1. ✅ 更新 `.cursorignore`
2. ✅ 移除規則檔案中的路徑引用
3. ✅ `90-active-skills.mdc` 已移除路徑
4. ⏳ 測試 token 消耗

## 如果問題仍然存在

可能需要：
1. 檢查 Cursor 的索引設定
2. 檢查是否有其他配置檔案
3. 考慮將 skills 移到 workspace 外部
4. 使用 Cursor 的 exclude 設定

---

**日期：** 2026-02-26
**狀態：** ✅ 完成
