---
name: clean
description: |
  Layered architecture with vertical slice organization following Clean Architecture principles.

  Use when:
  - Creating new .NET backend projects requiring strict layer separation
  - Building applications with Clean Architecture principles
  - Implementing vertical slice API organization
  - Projects requiring framework-agnostic domain layer
  - Applications that need CQRS support

  Triggers: "clean architecture", "layered architecture", "vertical slice", "clean structure", "layer separation"
type: structure
version: 1.2.1
tags:
  - dotnet
  - structure
  - architecture
  - clean-architecture
  - vertical-slice
---

# Clean Structure

## Purpose

Layered architecture with vertical slice organization following Clean Architecture principles.

## Scope

Applies to:
- Clean Architecture projects
- Projects requiring strict layer separation
- .NET backend applications
- API projects with vertical slice organization

## Rules

### Architectural Layers

Four-layer architecture:
1. **API Layer**: Entry point, endpoints, request/response handling
2. **Application Layer**: Use cases, command/query handlers, orchestration
3. **Domain Layer**: Business logic, entities, value objects, domain services
4. **Infrastructure Layer**: Data access, external services, framework implementations

### Dependency Direction

- API → Application → Domain
- Infrastructure → Application / Domain
- Domain MUST NOT depend on any outer layer
- Application MUST NOT depend on API or Infrastructure directly

### Layer Responsibilities

**API Layer:**
- Entry point (ASP.NET Core Web API)
- Vertical slice organization: `Modules/{ModuleName}/{UseCase}/`
- Endpoint / Request / Response separation
- Mapping between API DTO and Application DTO
- Pipeline configuration, authentication, logging

**Application Layer:**
- Use case coordination
- Command / Query handlers
- Result abstraction
- Cross-cutting concerns (via decorators)

**Domain Layer:**
- Business entities and aggregates
- Value objects
- Domain services
- Business rules and invariants
- Framework-agnostic

**Infrastructure Layer:**
- Data access implementations
- External service integrations
- Framework-specific implementations
- Caching, logging, security

### Folder Organization

```
Project/
├── API/
│   └── Modules/
│       └── {ModuleName}/
│           └── {UseCase}/
│               ├── {UseCase}Endpoint.cs
│               ├── {UseCase}Request.cs
│               ├── {UseCase}Response.cs
│               └── {UseCase}Mapper.cs
├── Application/
│   └── Modules/
│       └── {ModuleName}/
│           ├── Commands/
│           └── Queries/
├── Domain/
│   └── Modules/
│       └── {ModuleName}/
│           ├── Entities/
│           ├── ValueObjects/
│           └── Services/
└── Infrastructure/
    ├── Persistence/
    ├── ExternalServices/
    └── Security/
```

## Anti-Patterns

- Domain depending on outer layers
- Business logic in Controllers
- Framework dependencies in Domain layer
- Direct Infrastructure access from API layer
- Application layer depending on API layer
- Shared Controllers or Services across modules

## Minimal Example

```
Project/
├── API/
│   └── Modules/
│       └── Orders/
│           └── CreateOrder/
│               ├── CreateOrderEndpoint.cs
│               ├── CreateOrderRequest.cs
│               ├── CreateOrderResponse.cs
│               └── CreateOrderMapper.cs
├── Application/
│   └── Modules/
│       └── Orders/
│           └── Commands/
│               └── CreateOrder/
│                   ├── CreateOrderCommand.cs
│                   └── CreateOrderHandler.cs
├── Domain/
│   └── Modules/
│       └── Orders/
│           ├── Order.cs
│           └── IOrderRepository.cs
└── Infrastructure/
    └── Persistence/
        └── OrderRepository.cs
```

## Combination with Patterns

This structure works well with:
- **Unit of Work Pattern**: Transaction management
- **Domain Events Pattern**: Event-driven architecture
- **Outbox Pattern**: Reliable event publishing
- **CQRS Pattern**: Command/Query separation

## Notes

- Use dependency injection for layer communication
- Keep domain layer pure (no framework references)
- Use vertical slices for API organization
- Implement CQRS when read/write models diverge
