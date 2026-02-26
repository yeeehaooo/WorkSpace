---
name: create-clean-module
description: |
  Generate a new business module following Clean Architecture, CQRS, and DDD principles with UseCase-driven and Model-driven separation.

  Use when:
  - Creating a new business module in Clean Architecture project
  - Generating module structure with CQRS separation
  - Scaffolding DDD aggregates and value objects
  - Setting up module with proper layer organization
  - Adding new bounded context to existing system

  Triggers: "create module", "generate module", "new module", "scaffold module", "module structure"
type: generator
version: 1.2.1
tags:
  - dotnet
  - generator
  - scaffolding
  - clean-architecture
  - ddd
  - cqrs
---

# Create Clean Module

## Purpose

Create a new business module following Clean Architecture, CQRS, and DDD principles with UseCase-driven and Model-driven separation.

## Scope

Applies to:
- Clean Architecture projects
- CQRS projects
- DDD projects
- Projects using DMIS or Clean structure

## Rules

### Architecture Layers

**Behavior Layer (UseCase-driven):**
- API: Organized by Action (e.g., Login, CreateOrder, CancelOrder)
- Application: Organized by Action with Commands/Queries

**Model Layer (Model-driven):**
- Domain: Organized by Entity/Aggregate (e.g., User, Order, Product)
- Infrastructure: Organized by Entity

### Folder Structure

**API Layer:**
```
API/Modules/{ModuleName}/{Action}/
├── {Action}Endpoint.cs
├── {Action}Request.cs
├── {Action}Response.cs
└── {Action}Mapper.cs
```

**Application Layer:**
```
Application/Modules/{ModuleName}/
├── Commands/{Action}/
│   ├── {Action}Command.cs
│   ├── {Action}Handler.cs
│   └── {Action}Result.cs
└── Queries/{Action}/
    ├── {Action}Query.cs
    ├── {Action}Handler.cs
    └── {Action}Result.cs
```

**Domain Layer:**
```
Domain/Modules/{ModuleName}/
├── Aggregates/{Entity}/
│   ├── {Entity}.cs
│   ├── I{Entity}Repository.cs
│   └── {Entity}DomainService.cs
├── ValueObjects/
└── DomainEvents/
```

**Infrastructure Layer:**
```
Infrastructure/Modules/{ModuleName}/
└── Persistence/{Entity}/
    ├── {Entity}Repository.cs
    ├── {Entity}DataModel.cs
    ├── {Entity}Configuration.cs
    └── {Entity}Mapper.cs
```

### Dependency Direction

- API → Application → Domain
- Infrastructure → Domain
- Domain MUST NOT depend on Infrastructure
- Application MUST NOT depend on API

## Generation Steps

1. **Create Module Folders**: Create folder structure in all layers
2. **Generate Domain Entities**: Create aggregate root and repository interface
3. **Generate Application Handlers**: Create command/query handlers
4. **Generate API Endpoints**: Create endpoint, request, response, mapper
5. **Generate Infrastructure**: Create repository implementation and data models
6. **Register Dependencies**: Add DI registrations

## Anti-Patterns

- Business logic in Controller
- EF / Dapper in Domain
- Business logic in Infrastructure
- Cross-module direct Aggregate references
- One UseCase per Handler violation
- QuerySide using Domain Entity

## Minimal Example

**API:**
```csharp
public class LoginRequest
{
    public string Username { get; set; }
    public string Password { get; set; }
}

public class LoginResponse
{
    public string Token { get; set; }
    public DateTime ExpiresAt { get; set; }
}

public class LoginEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("/auth/login", HandleAsync)
            .WithName("Login")
            .Produces<LoginResponse>();
    }

    private async Task<IResult> HandleAsync(LoginRequest request, IMediator mediator)
    {
        var command = new LoginCommand(request.Username, request.Password);
        var result = await mediator.Send(command);
        return Results.Ok(result);
    }
}
```

**Application:**
```csharp
public record LoginCommand(string Username, string Password);

public class LoginHandler : ICommandHandler<LoginCommand, LoginResult>
{
    private readonly IUserRepository _userRepo;
    private readonly ITokenService _tokenService;

    public async Task<LoginResult> Handle(LoginCommand command, CancellationToken ct)
    {
        var user = await _userRepo.FindByUsernameAsync(command.Username, ct);
        if (user == null || !user.VerifyPassword(command.Password))
        {
            return LoginResult.Failed("Invalid credentials");
        }

        var token = _tokenService.GenerateToken(user);
        return LoginResult.Success(token);
    }
}
```

**Domain:**
```csharp
public class User : AggregateRoot
{
    public Guid Id { get; private set; }
    public string Username { get; private set; }
    public string PasswordHash { get; private set; }

    public bool VerifyPassword(string password)
    {
        return BCrypt.Net.BCrypt.Verify(password, PasswordHash);
    }
}
```

## Usage

When generating a module, specify:
- Module name (e.g., "Orders", "Users", "Products")
- Primary entity name (e.g., "Order", "User", "Product")
- Initial use cases (e.g., "CreateOrder", "GetOrder")

## Notes

- Module name should be plural (e.g., "Orders", not "Order")
- Entity name should be singular (e.g., "Order", not "Orders")
- Use PascalCase for all names
- Follow existing project naming conventions
