---
name: create-domain-aggregate
description: |
  Generate DDD Aggregate Root structure with Repository Interface, ValueObject, and Domain Event following DDD principles.

  Use when:
  - Creating new domain aggregates in DDD projects
  - Generating aggregate root with repository interface
  - Scaffolding value objects and domain events
  - Building domain entities with business invariants
  - Implementing aggregates with identity and business rules

  Triggers: "create aggregate", "generate aggregate", "domain aggregate", "aggregate root", "DDD aggregate"
type: generator
version: 1.2.1
tags:
  - dotnet
  - generator
  - scaffolding
  - ddd
  - domain-driven-design
---

# Create Domain Aggregate

## Purpose

Create a complete DDD Aggregate Root structure following DDD principles.

## Scope

Applies to:
- Domain Layer
- DDD projects
- Clean Architecture projects

## Rules

- Create Aggregate Root class
- Create Repository Interface
- Create ValueObject (optional)
- Create Domain Event (optional)
- Create Domain Exception (optional)
- Aggregate Root must have identity
- Aggregate Root enforces business invariants

## Generation Output

**Aggregate Root:**
```csharp
public class {Entity} : AggregateRoot
{
    public Guid Id { get; private set; }
    // Properties and business methods
}
```

**Repository Interface:**
```csharp
public interface I{Entity}Repository
{
    Task<{Entity}?> GetByIdAsync(Guid id, CancellationToken ct = default);
    Task AddAsync({Entity} entity, CancellationToken ct = default);
    Task UpdateAsync({Entity} entity, CancellationToken ct = default);
    Task DeleteAsync(Guid id, CancellationToken ct = default);
}
```

**ValueObject (optional):**
```csharp
public class {ValueObject} : ValueObject
{
    // Immutable value object
    protected override IEnumerable<object> GetEqualityComponents()
    {
        yield return Property1;
        yield return Property2;
    }
}
```

**Domain Event (optional):**
```csharp
public class {Entity}CreatedEvent : IDomainEvent
{
    public DateTime OccurredOn { get; init; } = DateTime.UtcNow;
    public Guid {Entity}Id { get; init; }
}
```

## Anti-Patterns

- Aggregate Root depending on Infrastructure
- Aggregate Root with framework references
- Repository Interface in Infrastructure layer
- Business logic outside Aggregate Root
- Aggregate Root without identity

## Notes

- Aggregate Root should enforce business invariants
- Repository interface should be in Domain layer
- Value objects should be immutable
- Domain events should represent business facts
