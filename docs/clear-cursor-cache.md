# 清除 Cursor Cache 指南

## 問題診斷

根據 token 消耗記錄：
- **Cache Read: 254,464 tokens** ← 這是主要問題
- Input: 5,368 tokens（正常）
- Output: 966 tokens（正常）

**結論：** Cursor 從 cache 中讀取了大量舊內容（可能是之前載入的所有 skills）。

## 解決方案

### 方法 1: 清除 Cursor Cache（推薦）

1. **關閉 Cursor**
2. **刪除 Cache 目錄**：
   - Windows: `%APPDATA%\Cursor\Cache`
   - 或使用命令：
     ```powershell
     Remove-Item -Recurse -Force "$env:APPDATA\Cursor\Cache"
     ```
3. **重新啟動 Cursor**

### 方法 2: 重新索引 Workspace

1. 在 Cursor 中：
   - 打開命令面板（Ctrl+Shift+P）
   - 搜尋 "Reload Window" 或 "Developer: Reload Window"
   - 執行後 Cursor 會重新索引

### 方法 3: 確認 `.cursorignore` 生效

1. 確認 `.cursorignore` 包含：
   ```
   skills/
   ```
2. 重新啟動 Cursor
3. 檢查 Cursor 是否仍掃描 `skills/` 目錄

### 方法 4: 手動清除特定 Cache

如果知道 cache 位置，可以：
1. 關閉 Cursor
2. 刪除 workspace 相關的 cache
3. 重新啟動

## 驗證

清除 cache 後：
1. 重新測試 "show all skills" 查詢
2. 檢查 token 消耗記錄
3. 確認 Cache Read 應該大幅降低

## 預期結果

清除 cache 後：
- **Cache Read**: 應該 < 10,000 tokens
- **Total Tokens**: 應該 < 15,000 tokens
- 只有 metadata 被載入，沒有完整 SKILL.md 內容

---

**日期：** 2026-02-26
**狀態：** 🔄 待驗證
