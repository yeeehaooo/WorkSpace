---
name: dmis
description: |
  Enterprise backend structure built on Clean Architecture, DDD, CQRS, and Vertical Slice API Design with Dapper-first persistence.

  Use when:
  - Creating new enterprise backend projects
  - Implementing Clean Architecture with DDD and CQRS
  - Building vertical slice API endpoints
  - Using Dapper as primary persistence mechanism
  - Organizing modules by UseCase-driven and Model-driven separation

  Triggers: "dmis structure", "clean architecture", "enterprise backend", "DDD CQRS", "vertical slice", "dapper"
type: structure
version: 1.2.1
tags:
  - dotnet
  - structure
  - architecture
  - clean-architecture
  - ddd
  - cqrs
  - vertical-slice
  - dapper
---

# DMIS Enterprise Structure

## Purpose

Enterprise backend structure built on Clean Architecture, DDD, CQRS, and Vertical Slice API Design with Dapper-first persistence.

## Scope

Applies to:
- Enterprise backend projects
- Clean Architecture projects
- DDD projects
- CQRS projects
- Projects using Dapper for persistence

## Rules

### Architectural Layers

Four-layer architecture:
1. **Api**: Entry point, vertical slice endpoints
2. **Application**: Use case coordination, command/query handlers
3. **Domain**: Aggregates, value objects, domain services
4. **Infrastructure**: Dapper persistence, external services

Dependency direction:
- Api → Application → Domain
- Infrastructure → Application / Domain
- Domain MUST NOT depend on any outer layer

### Layer Responsibilities

**Api Layer:**
- Entry point (ASP.NET Core Web API)
- Vertical slice module organization: `Modules/{ModuleName}/{UseCase}/`
- Endpoint / Request / Response separation
- Mapping between API DTO and Application DTO
- Pipeline configuration, authentication, logging

**Application Layer:**
- Use case coordination
- Command / Query handlers: `Modules/{ModuleName}/Commands/` and `Queries/`
- Result abstraction, UnitOfWork abstraction, Workflow abstraction
- Decorator-based cross-cutting concerns

**Domain Layer:**
- Aggregate Roots, Value Objects, Domain Guards, Smart Enums
- Domain Exceptions, Error Codes
- Pure business rules only, no framework references

**Infrastructure Layer:**
- Dapper implementation (primary persistence)
- EF Core (optional secondary ORM)
- Repository implementation, Query Services (Read side of CQRS)
- Redis cache, JWT authentication, encryption services, logging

### Folder Organization

**Api:** `Modules/{ModuleName}/{UseCase}/` (Endpoint, Request, Response, Mapping)

**Application:** `Modules/{ModuleName}/Commands/` and `Queries/`

**Domain:** `Modules/{ModuleName}/` and `Kernel/` (AggregateRoot, IRepository, Guards, SmartEnums, ErrorCodes)

**Infrastructure:** `Persistence/` (Dappers, Repositories, QueryServices, ReadModels, DataModels), `Security/`, `Caching/`, `Logging/`

### Persistence Strategy

- Primary: Dapper
- Transaction handling via UnitOfWork abstraction
- CQRS separation: Write → Repository, Read → QueryService + ReadModel

### Cross-Cutting Strategy

- Decorator pattern (Application layer)
- Middleware / Filters (Api layer)
- No business logic in middleware

## Anti-Patterns

- Domain referencing Infrastructure
- Api referencing Infrastructure directly
- Business logic inside Controllers
- EF DbContext used directly inside Application
- Dapper used outside Infrastructure
- Framework references in Domain layer
- Shared Controller dumping in Api layer

## Minimal Example

```
DMIS_Backend/
├── DMIS_Backend.Api/
│   └── Modules/
│       └── Orders/
│           └── CreateOrder/
│               ├── CreateOrderEndpoint.cs
│               ├── CreateOrderRequest.cs
│               ├── CreateOrderResponse.cs
│               └── CreateOrderMapper.cs
├── DMIS_Backend.Application/
│   └── Modules/
│       └── Orders/
│           ├── Commands/
│           │   └── CreateOrder/
│           │       ├── CreateOrderCommand.cs
│           │       └── CreateOrderHandler.cs
│           └── Queries/
│               └── GetOrder/
│                   ├── GetOrderQuery.cs
│                   └── GetOrderHandler.cs
├── DMIS_Backend.Domain/
│   ├── Kernel/
│   │   ├── AggregateRoot.cs
│   │   ├── IRepository.cs
│   │   └── Guards.cs
│   └── Modules/
│       └── Orders/
│           ├── Order.cs
│           ├── IOrderRepository.cs
│           └── ValueObjects/
│               └── OrderStatus.cs
└── DMIS_Backend.Infrastructure/
    └── Persistence/
        ├── Dappers/
        │   └── OrderDapper.cs
        ├── Repositories/
        │   └── OrderRepository.cs
        └── QueryServices/
            └── OrderQueryService.cs
```

## Combination with Patterns

This structure works well with:
- **Unit of Work Pattern**: Transaction management with Dapper
- **Domain Events Pattern**: Event-driven architecture
- **Outbox Pattern**: Reliable event publishing
- **Caching Strategy**: Redis caching for read models

## Notes

- Dapper is primary persistence mechanism
- Use UnitOfWork for transaction management
- Separate read and write models (CQRS)
- Use vertical slices for API organization
- Keep domain layer pure (no framework references)
