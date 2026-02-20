---
name: create-clean-module-skill
description: 建立符合 Clean Architecture + CQRS + DDD 的模組結構（UseCase 驅動 + Model 驅動）
version: 2.0.0
---

# Create Clean Module Skill

建立一個新的業務模組，符合：

- Clean Architecture
- CQRS
- DDD Aggregate 對齊
- 可拆分為 Microservice
- 行為層與模型層分離

---

# 架構核心原則

## 行為層（UseCase 驅動）

- API
- Application

依據「Action」分類

例如：

- Login
- CreateOrder
- CancelOrder

---

## 模型層（Model 驅動）

- Domain
- Infrastructure

依據「Entity / Aggregate」分類

例如：

- User
- Order
- Product

---

# Step 1：建立 API 結構（UseCase 驅動）

```
API
└── Modules
    └── {ModuleName}
        └── {Action}
            ├── {Action}Endpoint.cs
            ├── {Action}Request.cs
            ├── {Action}Response.cs
            └── {Action}Mapper.cs
```

## 範例

```csharp
public class LoginRequest
{
    public string Username { get; set; }
    public string Password { get; set; }
}
```

---

# Step 2：建立 Application 結構（CQRS）

```
Application
└── Modules
    └── {ModuleName}
        ├── Commands
        │   └── {Action}
        │       ├── {Action}Command.cs
        │       ├── {Action}Handler.cs
        │       └── {Action}Result.cs
        │
        └── Queries
```

## 範例

```csharp
public record LoginCommand(string Username, string Password);

public class LoginHandler
{
    public Task<LoginResult> Handle(LoginCommand command)
    {
        // use case logic
    }
}
```

---

# Step 3：建立 Domain 結構（Aggregate 驅動）

```
Domain
└── Modules
    └── {ModuleName}
        ├── Aggregates
        │   └── {Entity}
        │       ├── {Entity}.cs
        │       ├── I{Entity}Repository.cs
        │       └── {Entity}DomainService.cs
        │
        ├── ValueObjects
        └── DomainEvents
```

## 範例

```csharp
public class User : AggregateRoot
{
    public Guid Id { get; private set; }
    public string Username { get; private set; }

    public User(string username)
    {
        Username = username;
    }
}
```

---

# Step 4：建立 Infrastructure 結構（實作 Domain）

```
Infrastructure
└── Modules
    └── {ModuleName}
        └── Persistence
            └── {Entity}
                ├── {Entity}Repository.cs
                ├── {Entity}DataModel.cs
                ├── {Entity}Configuration.cs
                └── {Entity}Mapper.cs
```

若有 Query Side：

```
Infrastructure
└── Modules
    └── {ModuleName}
        └── ReadModels
            ├── {Entity}ReadModel.cs
            └── {Entity}QueryService.cs
```

---

# 依賴方向（不可違反）

```
API → Application → Domain
Infrastructure → Domain
```

❌ Domain 不可依賴 Infrastructure  
❌ Application 不可依賴 API  

---

# 結構哲學

| 層 | 分類方式 |
|----|----------|
| API | Action |
| Application | Action |
| Domain | Entity |
| Infrastructure | Entity |

---

# 禁止事項

- 在 Controller 寫商業邏輯
- 在 Domain 使用 EF / Dapper
- 在 Infrastructure 寫業務判斷
- 跨模組直接引用 Aggregate

---

# 模組可拆原則

若未來拆成 Microservice：

只需移動：

```
Domain/Modules/{ModuleName}
Infrastructure/Modules/{ModuleName}
Application/Modules/{ModuleName}
API/Modules/{ModuleName}
```

即可獨立部署。

---

# 注意事項

- 一個 UseCase 對應一個 Handler
- 一個 Aggregate 對應一個 Repository
- QuerySide 不使用 Domain Entity

---

# Changelog

## 2.0.0
- 改為 UseCase + Model 雙驅動架構
- 支援 Microservice 拆分
- 支援 CQRS ReadSide 分離