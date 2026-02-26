---
name: create-repository
description: |
  Generate Repository implementation for Domain Repository Interface using EF Core or Dapper in Infrastructure layer.

  Use when:
  - Implementing repository interface defined in Domain layer
  - Creating data access layer with EF Core or Dapper
  - Building repository pattern implementations
  - Scaffolding persistence layer for aggregates
  - Implementing read/write separation (CQRS)

  Triggers: "create repository", "generate repository", "repository implementation", "EF repository", "Dapper repository"
type: generator
version: 1.2.1
tags:
  - dotnet
  - generator
  - scaffolding
  - repository
  - persistence
---

# Create Repository

## Purpose

Implement Domain Repository Interface with EF Core or Dapper.

## Scope

Applies to:
- Infrastructure Layer
- Projects using Repository pattern
- EF Core or Dapper implementations

## Rules

- Repository implements interface defined in Domain layer
- Repository only performs data operations
- Repository does NOT commit or manage transactions
- Support both EF Core and Dapper implementations
- Use UnitOfWork for transaction management

## Generation Output

**EF Core Repository:**
```csharp
public class {Entity}Repository : I{Entity}Repository
{
    private readonly AppDbContext _db;

    public {Entity}Repository(AppDbContext db)
    {
        _db = db;
    }

    public async Task<{Entity}?> GetByIdAsync(Guid id, CancellationToken ct = default)
    {
        return await _db.Set<{Entity}>().FindAsync(new object[] { id }, ct);
    }

    public async Task AddAsync({Entity} entity, CancellationToken ct = default)
    {
        await _db.Set<{Entity}>().AddAsync(entity, ct);
    }

    public Task UpdateAsync({Entity} entity, CancellationToken ct = default)
    {
        _db.Set<{Entity}>().Update(entity);
        return Task.CompletedTask;
    }

    public async Task DeleteAsync(Guid id, CancellationToken ct = default)
    {
        var entity = await GetByIdAsync(id, ct);
        if (entity != null)
        {
            _db.Set<{Entity}>().Remove(entity);
        }
    }
}
```

**Dapper Repository:**
```csharp
public class {Entity}Repository : I{Entity}Repository
{
    private readonly IDbSession _session;

    public {Entity}Repository(IDbSession session)
    {
        _session = session;
    }

    public async Task<{Entity}?> GetByIdAsync(Guid id, CancellationToken ct = default)
    {
        const string sql = "SELECT * FROM {TableName} WHERE Id = @Id";
        return await _session.QueryFirstOrDefaultAsync<{Entity}>(sql, new { Id = id }, ct);
    }

    public async Task AddAsync({Entity} entity, CancellationToken ct = default)
    {
        const string sql = "INSERT INTO {TableName} (Id, ...) VALUES (@Id, ...)";
        await _session.ExecuteAsync(sql, entity, ct);
    }

    public async Task UpdateAsync({Entity} entity, CancellationToken ct = default)
    {
        const string sql = "UPDATE {TableName} SET ... WHERE Id = @Id";
        await _session.ExecuteAsync(sql, entity, ct);
    }

    public async Task DeleteAsync(Guid id, CancellationToken ct = default)
    {
        const string sql = "DELETE FROM {TableName} WHERE Id = @Id";
        await _session.ExecuteAsync(sql, new { Id = id }, ct);
    }
}
```

## Anti-Patterns

- Repository calling external API directly
- Repository containing business logic
- Repository calling `SaveChanges()` or `CommitAsync()`
- Repository managing transactions
- Repository interface in Infrastructure layer

## Notes

- Repository should only perform data operations
- Use UnitOfWork for transaction management
- Repository interface should be in Domain layer
- Implementation should be in Infrastructure layer
