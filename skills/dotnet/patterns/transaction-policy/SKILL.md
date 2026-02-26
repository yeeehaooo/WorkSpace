---
name: transaction-policy
description: |
  Define explicit transaction policies for different operation types and consistency requirements in .NET applications.

  Use when:
  - Different operations require different transaction isolation levels
  - Implementing explicit transaction policies per operation type
  - Handling complex consistency requirements
  - Building systems with varying transaction needs
  - Enforcing transaction boundaries via decorators or middleware

  Triggers: "transaction policy", "isolation level", "transaction strategy", "consistency requirement", "transaction configuration"
type: pattern
version: 1.2.1
tags:
  - dotnet
  - pattern
  - clean-architecture
  - transaction
  - consistency
---

# Transaction Policy Pattern

## Purpose

Define explicit transaction policies for different operation types and consistency requirements.

## Scope

Applies to:
- Application Layer
- Infrastructure Layer
- Operations with varying consistency requirements

## Rules

- Explicit transaction policies per operation type
- Support for different isolation levels when needed
- Policy enforcement via decorators or middleware
- Policies can be composed for complex scenarios
- Policy interfaces defined in Application layer
- Policy implementations in Infrastructure layer

## Anti-Patterns

- One-size-fits-all transaction policy
- Implicit transaction boundaries
- Ignoring isolation level requirements
- Over-using distributed transactions
- Policies with business logic

## Minimal Example

```csharp
// Application Layer
public interface ITransactionPolicy
{
  IsolationLevel IsolationLevel { get; }
  TimeSpan? Timeout { get; }
  bool ReadOnly { get; }
}

public class ReadCommittedPolicy : ITransactionPolicy
{
  public IsolationLevel IsolationLevel => IsolationLevel.ReadCommitted;
  public TimeSpan? Timeout => TimeSpan.FromSeconds(30);
  public bool ReadOnly => false;
}

public class SerializablePolicy : ITransactionPolicy
{
  public IsolationLevel IsolationLevel => IsolationLevel.Serializable;
  public TimeSpan? Timeout => TimeSpan.FromSeconds(60);
  public bool ReadOnly => false;
}

// Usage in Handler
public class TransferFundsHandler : ICommandHandler<TransferFundsCommand>
{
  private readonly IUnitOfWork _uow;
  private readonly ITransactionPolicy _policy;

  public async Task<Result> Handle(TransferFundsCommand cmd, CancellationToken ct)
  {
    await _uow.BeginAsync(_policy, ct);
    try
    {
      // Transfer logic...
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

## Notes

- Use appropriate isolation levels for each operation
- Consider performance implications of higher isolation levels
- Policies should be composable for complex scenarios
