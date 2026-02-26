---
name: unit-of-work
description: |
  Provide transactional boundary control for write operations in .NET Clean Architecture applications.

  Use when:
  - Implementing command handlers that require database transactions
  - Managing transaction boundaries across multiple repository operations
  - Coordinating atomic operations in Clean Architecture applications
  - Handling nested transactions in scoped dependency injection scenarios
  - Preventing repository-level transaction management anti-patterns

  Triggers: "transaction", "unit of work", "atomic operation", "transaction boundary", "UoW", "database transaction"
type: pattern
version: 1.2.1
tags:
  - dotnet
  - pattern
  - clean-architecture
  - transaction
  - cqrs
---

# Unit of Work Pattern

## Purpose

Provide transactional boundary control for write operations while maintaining Clean Architecture layer separation.

## Scope

Applies to:
- Application Layer
- Infrastructure Layer
- Command handlers requiring database transactions
- Multi-repository operations requiring atomicity

## Rules

- Handler controls transaction boundary via `BeginAsync()` / `CommitAsync()` / `RollbackAsync()`
- Repository never commits or manages transactions
- `IUnitOfWork` defined in Application layer, implemented in Infrastructure layer
- Infrastructure uses `IDbSession` internally (not exposed to Application)
- Automatic rollback on `Dispose()` if transaction started but not committed
- Nested transactions must be supported (same instance per request via Scoped DI)

## Anti-Patterns

- Auto transaction middleware that starts transaction for every request
- Repository calling `SaveChanges()` or `CommitAsync()`
- Application layer depending on `IDbSession` directly
- Transaction started in constructor instead of explicit `BeginAsync()`
- Handler not controlling transaction boundary

## Minimal Example

```csharp
// Application Layer
public interface IUnitOfWork : IDisposable
{
  Task BeginAsync(CancellationToken cancellationToken = default);
  Task CommitAsync(CancellationToken cancellationToken = default);
  Task RollbackAsync(CancellationToken cancellationToken = default);
}

// Infrastructure Layer
public class DapperUnitOfWork : IUnitOfWork
{
  private readonly IDbSession _session;
  private bool _transactionStarted = false;

  public DapperUnitOfWork(IDbSession session)
  {
    _session = session;
  }

  public async Task BeginAsync(CancellationToken cancellationToken = default)
  {
    if (!_transactionStarted)
    {
      await _session.BeginTransactionAsync(cancellationToken);
      _transactionStarted = true;
    }
  }

  public async Task CommitAsync(CancellationToken cancellationToken = default)
  {
    if (_transactionStarted)
    {
      await _session.CommitTransactionAsync(cancellationToken);
      _transactionStarted = false;
    }
  }

  public async Task RollbackAsync(CancellationToken cancellationToken = default)
  {
    if (_transactionStarted)
    {
      await _session.RollbackTransactionAsync(cancellationToken);
      _transactionStarted = false;
    }
  }

  public void Dispose()
  {
    if (_transactionStarted)
    {
      _session.RollbackTransactionAsync().GetAwaiter().GetResult();
    }
  }
}

// Handler Usage
public class CreateOrderHandler : ICommandHandler<CreateOrderCommand>
{
  private readonly IUnitOfWork _uow;
  private readonly IOrderRepository _orderRepo;
  private readonly IInventoryRepository _inventoryRepo;

  public async Task<Result> Handle(CreateOrderCommand cmd, CancellationToken ct)
  {
    await _uow.BeginAsync(ct);
    try
    {
      var order = new Order(cmd.OrderId, cmd.Items);
      await _orderRepo.AddAsync(order, ct);

      foreach (var item in cmd.Items)
      {
        await _inventoryRepo.ReserveAsync(item.ProductId, item.Quantity, ct);
      }

      await _uow.CommitAsync(ct);
      return Result.Success();
    }
    catch
    {
      await _uow.RollbackAsync(ct);
      throw;
    }
  }
}
```

## Combination with Other Patterns

This pattern works well with:
- **Outbox Pattern**: Use UnitOfWork to ensure outbox messages are committed atomically with domain changes
- **Domain Events**: Publish domain events after successful commit
- **Execution Tracking**: Track transaction boundaries in execution logs

## Notes

- UnitOfWork should be registered as Scoped in DI container
- Each HTTP request should have its own UnitOfWork instance
- Dispose pattern ensures rollback if handler fails to commit explicitly
