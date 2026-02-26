# Antigravity Integration

## 概述

本文件說明 SystexWorkSpace Skills 如何整合 Antigravity Agent Skills 標準。

**版本：** v1.0
**最後更新：** 2026-02-26

---

## 一、整合目標

### 1.1 標準化

- 符合 Antigravity Agent Skills 規範
- 使用標準的 SKILL.md 格式
- 支援 Progressive Disclosure

### 1.2 相容性

- 向後相容現有 skills
- 支援雙格式（skill.mdc 和 SKILL.md）
- 平滑遷移路徑

---

## 二、核心特性

### 2.1 Progressive Disclosure

三層載入系統：
1. Metadata（常駐）
2. SKILL.md Body（觸發載入）
3. Bundled Resources（按需載入）

### 2.2 Description-based Triggering

- 基於 description 的自動觸發
- 包含 "Use when" 和 "Triggers"
- AI 自動判斷何時使用 skill

### 2.3 LEGO 原則

- 最小化設計
- 模組化結構
- 可組合使用

---

## 三、結構對照

### 3.1 Antigravity 標準

```
skill-name/
├── SKILL.md
├── scripts/
├── references/
└── assets/
```

### 3.2 SystexWorkSpace 實現

```
skills/dotnet/patterns/unit-of-work/
├── SKILL.md          (符合 Antigravity 標準)
├── scripts/          (可選)
├── references/       (可選)
└── assets/           (可選)
```

---

## 四、遷移狀態

### 4.1 已完成

- ✅ 所有 20 個 skills 已更新為 SKILL.md 格式
- ✅ Frontmatter 包含完整的 description
- ✅ 所有 skills 已新增 tags
- ✅ Cursor Rules 已更新支援新格式

### 4.2 進行中

- 🔄 建立 scripts/、references/、assets/ 目錄（按需）
- 🔄 驗證自動觸發機制

---

## 五、使用方式

### 5.1 在 Cursor 中使用

Skills 會根據用戶請求自動觸發：
- 明確提及 skill 名稱
- Description 匹配
- Tag 匹配
- Context 匹配

### 5.2 在專案中啟用

透過 `project-profile.json` 選擇需要的 skills：

```json
{
  "governance": "v1",
  "skills": [
    "dotnet/structures/dmis",
    "dotnet/patterns/unit-of-work"
  ]
}
```

---

## 六、參考資源

- [Antigravity Skills Documentation](https://www.huanlintalk.com/2026/01/get-started-authoring-antigravity-skills.html)
- [Skill Migration Guide](./skill-migration-guide.md)
- [Skill Description Guidelines](./skill-description-guidelines.md)

---

**維護者：** 開發團隊
**審核者：** 架構團隊
