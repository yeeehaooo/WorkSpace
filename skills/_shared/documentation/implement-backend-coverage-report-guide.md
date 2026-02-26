---
name: implement-backend-coverage-report-guide
description: |
  Generate .NET backend project test coverage reports with HTML output for code quality analysis.

  Use when:
  - Setting up test coverage reporting for .NET projects
  - Generating HTML coverage reports for analysis
  - Integrating coverage reports into CI/CD pipelines
  - Monitoring test coverage metrics
  - Ensuring code quality standards

  Triggers: "coverage report", "test coverage", "code coverage", "coverage html", "coverage analysis"
type: template
version: 1.2.1
tags:
  - guide
  - template
  - testing
  - coverage
  - quality
---

# Backend Coverage Report Guide

此 Guide 用於產生後端專案的單元測試覆蓋率報告。

## Purpose

Generate comprehensive test coverage reports for .NET backend projects with HTML output.

## Scope

適用於：
- .NET 6+
- xUnit / NUnit / MSTest
- CI Pipeline
- 本地開發檢查

## Prerequisites

專案必須包含：

```
YourProject.sln
├── src/
│   └── YourProject.Api
│   └── YourProject.Application
│   └── YourProject.Domain
│
└── tests/
    └── YourProject.Tests
```

## Step-by-Step Process

### Step 1: 確認專案結構

確認：
- Solution 存在
- 至少一個 Test Project
- Test Project 使用 `Microsoft.NET.Test.Sdk`

### Step 2: 安裝 Coverlet 套件（若尚未安裝）

在測試專案執行：

```bash
dotnet add package coverlet.collector
```

或確認 csproj 內有：

```xml
<ItemGroup>
  <PackageReference Include="coverlet.collector" Version="*" />
</ItemGroup>
```

### Step 3: 執行測試並產生覆蓋率

在 solution 根目錄執行：

```bash
dotnet test --collect:"XPlat Code Coverage"
```

執行後會產生：

```
TestResults/{guid}/coverage.cobertura.xml
```

### Step 4: 產生 HTML 報告（推薦）

安裝 ReportGenerator：

```bash
dotnet tool install -g dotnet-reportgenerator-globaltool
```

產生報告：

```bash
reportgenerator \
-reports:TestResults/**/coverage.cobertura.xml \
-targetdir:CoverageReport \
-reporttypes:Html
```

### Step 5: 查看報告

打開：

```
CoverageReport/index.html
```

即可查看：
- Line Coverage
- Branch Coverage
- Class Coverage
- Method Coverage

## CI Pipeline 使用範例

### Azure DevOps

```yaml
- script: dotnet test --collect:"XPlat Code Coverage"
  displayName: Run tests with coverage
```

## Anti-Patterns

- 不要測 Infrastructure EF configuration
- 優先測 Application / Domain
- 覆蓋率 ≠ 測試品質

## 常見問題

### 覆蓋率為 0%

請確認：
- 測試專案有參考被測試專案
- 有正確使用 Fact / TestMethod
- 未排除 Assembly

### 排除某些資料夾

在測試專案加上：

```xml
<PropertyGroup>
  <ExcludeByFile>**/Migrations/*.cs</ExcludeByFile>
</PropertyGroup>
```

## 進階優化

可加入：
- fail under threshold
- branch coverage 檢查
- SonarQube 整合

## Notes

- 覆蓋率是工具，不是目標
- 專注於測試品質而非覆蓋率數字
- 排除不需要測試的程式碼（如 Migrations）
