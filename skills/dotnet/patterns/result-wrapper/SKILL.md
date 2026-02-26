---
name: result-wrapper
description: |
  Use Result wrapper pattern for explicit error handling without exceptions in .NET applications.

  Use when:
  - Handling business errors explicitly without exceptions
  - Building functional error handling pipelines
  - Separating business errors from system errors
  - Creating composable error handling flows
  - Implementing railway-oriented programming patterns

  Triggers: "result wrapper", "result pattern", "error handling", "railway oriented", "functional error", "maybe pattern"
type: pattern
version: 1.2.1
tags:
  - dotnet
  - pattern
  - clean-architecture
  - error-handling
  - functional
---

# Result Wrapper Pattern

## Purpose

Use `Result<T>` wrapper pattern for explicit error handling without exceptions.

## Scope

Applies to:
- Domain Layer
- Application Layer
- Infrastructure Layer
- Business error handling

## Rules

- Use `Result<T>` for business errors (validation, business rules)
- Use exceptions for system errors (null reference, out of memory)
- `Result<T>` is immutable
- Chain operations using `Map`, `Bind`, `Match` methods
- Extract values explicitly (no implicit unwrapping)
- `Result<T>` type defined in Application layer
- Domain operations return `Result<T>` for business failures

## Anti-Patterns

- Using exceptions for business errors
- Implicit unwrapping of `Result<T>` values
- Mixing business errors with system errors
- Not handling `Result<T>` failures
- Returning `Result<T>` from infrastructure (should convert exceptions)

## Minimal Example

```csharp
// Application Layer
public class Result<T>
{
  public bool IsSuccess { get; }
  public T? Value { get; }
  public string? Error { get; }
  public ErrorCode? ErrorCode { get; }

  private Result(bool isSuccess, T? value, string? error, ErrorCode? errorCode = null)
  {
    IsSuccess = isSuccess;
    Value = value;
    Error = error;
    ErrorCode = errorCode;
  }

  public static Result<T> Success(T value) => new(true, value, null);
  public static Result<T> Failure(string error, ErrorCode? errorCode = null) => new(false, default, error, errorCode);

  public Result<TOut> Map<TOut>(Func<T, TOut> mapper)
  {
    return IsSuccess ? Result<TOut>.Success(mapper(Value!)) : Result<TOut>.Failure(Error!, ErrorCode);
  }

  public Result<TOut> Bind<TOut>(Func<T, Result<TOut>> binder)
  {
    return IsSuccess ? binder(Value!) : Result<TOut>.Failure(Error!, ErrorCode);
  }

  public TOut Match<TOut>(Func<T, TOut> onSuccess, Func<string, TOut> onFailure)
  {
    return IsSuccess ? onSuccess(Value!) : onFailure(Error!);
  }
}

// Domain Usage
public class Order : AggregateRoot
{
  public Result<Order> Create(CreateOrderRequest request)
  {
    if (request.Items.Count == 0)
      return Result<Order>.Failure("Order must have at least one item", ErrorCode.OrderEmpty);

    if (request.TotalAmount <= 0)
      return Result<Order>.Failure("Order total must be greater than zero", ErrorCode.InvalidAmount);

    var order = new Order
    {
      Id = Guid.NewGuid(),
      Items = request.Items,
      TotalAmount = request.TotalAmount
    };

    return Result<Order>.Success(order);
  }
}

// Handler Usage
public class CreateOrderHandler : ICommandHandler<CreateOrderCommand>
{
  public async Task<Result<OrderId>> Handle(CreateOrderCommand cmd, CancellationToken ct)
  {
    return await _orderRepo
      .CreateAsync(cmd.Request, ct)
      .Bind(order => SaveOrderAsync(order, ct))
      .Map(order => order.Id);
  }
}
```

## Notes

- Use Result<T> for expected failures (business rules)
- Use exceptions for unexpected failures (system errors)
- Chain operations for functional error handling
- Always handle Result<T> failures explicitly
