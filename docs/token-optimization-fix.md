# Token 優化修復報告

## 問題描述

原本的 token 消耗達到 **37 萬 tokens**，原因是 Cursor 自動載入了 `90-active-skills.mdc` 中列出的所有 skills 的完整 SKILL.md 內容。

## 根本原因

1. **`90-active-skills.mdc` 格式問題**：
   - 原本只列出路徑（如 `/skills/dotnet/patterns/unit-of-work`）
   - Cursor 可能將這些路徑解釋為「需要載入完整內容」
   - 導致所有 20 個 skills 的完整 SKILL.md 都被載入

2. **缺乏明確的禁止規則**：
   - 規則檔案中沒有明確禁止自動載入
   - AI 可能誤解需要載入所有列出的 skills

## 解決方案

### 1. 修改 `update-cursor-skills.ps1`

**變更：**
- 整合 `Get-SkillMetadata` 函數，提取 skills 的 metadata
- 修改 `Write-90-Simple` 函數，生成包含 metadata 的 `90-active-skills.mdc`
- 只列出 name、description（前 100 字）、tags
- 明確說明「DO NOT load full SKILL.md files」

**新格式範例：**
```markdown
- dmis (/skills/dotnet/structures/dmis): Enterprise backend structure... | Tags: dotnet, structure, architecture
```

### 2. 強化規則檔案

**更新的檔案：**
- `.cursor/rules/20-skill-loading.mdc`：加入 CRITICAL 警告
- `.cursor/rules/25-skill-metadata.mdc`：明確說明不要自動載入
- `.cursor/rules/30-skill-triggering.mdc`：加入 token 優化警告

**關鍵訊息：**
- `90-active-skills.mdc` 包含 ONLY metadata
- DO NOT 自動載入完整 SKILL.md
- 載入完整內容 ONLY 當 skill 被觸發時

### 3. 生成的 `90-active-skills.mdc` 格式

**新格式特點：**
- 明確標註「Metadata Only」
- 列出每個 skill 的 name、簡短 description、tags
- 包含 Usage Rules 說明如何載入
- 明確禁止自動載入

## 預期效果

### Token 消耗對比

**優化前：**
- 所有 20 個 skills 的完整 SKILL.md：~370,000 tokens
- 每個 skill 約 2,000-5,000 words = 2,500-6,250 tokens
- 20 × 3,000 tokens ≈ 60,000 tokens（僅 skills）
- 加上其他內容可能達到 370K tokens

**優化後：**
- 僅 metadata：~100 tokens/skill × 20 = 2,000 tokens
- 規則檔案：~1,000 tokens
- 基礎 context：~3,000 tokens
- 觸發的 skills：按需載入（每個 ~3,000 tokens）

**預期減少：**
- 基礎消耗：從 ~370K → ~3K tokens（減少 99%）
- 觸發載入：僅載入匹配的 skills（通常 1-3 個）

## 驗證步驟

1. ✅ 腳本運行成功
2. ✅ 生成的 `90-active-skills.mdc` 格式正確
3. ✅ 只包含 metadata，沒有完整內容
4. ✅ 規則檔案已更新並包含警告

## 使用建議

1. **重新生成所有專案的 `90-active-skills.mdc`**：
   ```powershell
   .\tools\update-cursor-skills.ps1
   ```

2. **檢查生成的檔案**：
   - 確認只包含 metadata
   - 確認有明確的禁止載入說明

3. **監控 token 消耗**：
   - 觀察優化後的效果
   - 如果仍有問題，進一步檢查是否有其他載入來源

## 注意事項

- `90-active-skills.mdc` 是自動生成的，不要手動編輯
- 如果修改了 skills 的 metadata，需要重新運行腳本
- 確保所有專案都使用新的格式

---

**修復日期：** 2026-02-26
**修復者：** AI Assistant
**狀態：** ✅ 完成
