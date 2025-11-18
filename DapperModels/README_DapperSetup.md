# Dapper Setup Guide for Collection Management System

## Overview
This folder contains C# model classes and repository examples for using Dapper ORM with the Collection Management System database.

## Prerequisites

### NuGet Packages Required
Install the following NuGet packages in your .NET project:

```bash
dotnet add package Dapper --version 2.1.24
dotnet add package Microsoft.Data.SqlClient --version 5.1.5
dotnet add package Microsoft.Extensions.Configuration --version 8.0.0
dotnet add package Microsoft.Extensions.Configuration.Json --version 8.0.0
```

## Project Structure

```
DapperModels/
├── Customer.cs                    # Customer entity model
├── CollectionCase.cs              # Collection Case entity model
├── PromiseToPay.cs               # Promise to Pay entity model
├── DapperContext.cs              # Database context for connection management
├── CaseRepository.cs             # Repository with Dapper operations
├── appsettings.json              # Configuration file with connection strings
└── README_DapperSetup.md         # This file
```

## Configuration

### 1. Update Connection String
Edit `appsettings.json` and update the connection string:

```json
{
  "ConnectionStrings": {
    "CollectionManagementDB": "Server=YOUR_SERVER;Database=CollectionManagementDB;User Id=YOUR_USER;Password=YOUR_PASSWORD;TrustServerCertificate=True;"
  }
}
```

For Azure SQL Database:
```json
{
  "ConnectionStrings": {
    "CollectionManagementDB": "Server=tcp:yourserver.database.windows.net,1433;Initial Catalog=CollectionManagementDB;Persist Security Info=False;User ID=your_username;Password=your_password;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }
}
```

### 2. Register Services (ASP.NET Core)

In your `Program.cs` or `Startup.cs`:

```csharp
using CollectionManagementSystem.Data;
using CollectionManagementSystem.Data.Repositories;

var builder = WebApplication.CreateBuilder(args);

// Register DapperContext
builder.Services.AddSingleton<DapperContext>();

// Register Repositories
builder.Services.AddScoped<ICaseRepository, CaseRepository>();
builder.Services.AddScoped<IPTPRepository, PTPRepository>();

// ... rest of your service registrations

var app = builder.Build();
```

## Usage Examples

### 1. Basic Query Example

```csharp
using CollectionManagementSystem.Data;
using Dapper;

public class ExampleService
{
    private readonly DapperContext _context;

    public ExampleService(DapperContext context)
    {
        _context = context;
    }

    public async Task<Customer> GetCustomerByIdAsync(long customerId)
    {
        using var connection = _context.CreateConnection();

        var sql = "SELECT * FROM Customers WHERE CustomerID = @CustomerId";

        return await connection.QueryFirstOrDefaultAsync<Customer>(
            sql,
            new { CustomerId = customerId }
        );
    }
}
```

### 2. Using Repository Pattern

```csharp
public class CollectionController : ControllerBase
{
    private readonly ICaseRepository _caseRepository;

    public CollectionController(ICaseRepository caseRepository)
    {
        _caseRepository = caseRepository;
    }

    [HttpGet("cases/{id}")]
    public async Task<IActionResult> GetCaseDetails(long id)
    {
        var caseDetails = await _caseRepository.GetCaseDetailsByIdAsync(id);

        if (caseDetails == null)
            return NotFound();

        return Ok(caseDetails);
    }

    [HttpGet("agent/worklist")]
    public async Task<IActionResult> GetWorklist(long userId)
    {
        var worklist = await _caseRepository.GetAgentWorklistAsync(userId);
        return Ok(worklist);
    }

    [HttpGet("dashboard/metrics")]
    public async Task<IActionResult> GetDashboardMetrics(long? userId = null)
    {
        var metrics = await _caseRepository.GetDashboardMetricsAsync(userId);
        return Ok(metrics);
    }
}
```

### 3. Multi-Mapping Example

```csharp
public async Task<IEnumerable<CollectionCase>> GetCasesWithCustomerAsync()
{
    using var connection = _context.CreateConnection();

    var sql = @"
        SELECT
            cc.*,
            c.*
        FROM CollectionCases cc
        INNER JOIN Customers c ON cc.CustomerID = c.CustomerID
        WHERE cc.IsActive = 1";

    var cases = await connection.QueryAsync<CollectionCase, Customer, CollectionCase>(
        sql,
        (collectionCase, customer) =>
        {
            collectionCase.Customer = customer;
            return collectionCase;
        },
        splitOn: "CustomerID"
    );

    return cases;
}
```

### 4. Stored Procedure Example

```csharp
public async Task<long> CreatePTPAsync(PromiseToPay ptp)
{
    using var connection = _context.CreateConnection();

    var parameters = new DynamicParameters();
    parameters.Add("@CaseID", ptp.CaseID);
    parameters.Add("@CustomerID", ptp.CustomerID);
    parameters.Add("@LoanAccountID", ptp.LoanAccountID);
    parameters.Add("@PromisedAmount", ptp.PromisedAmount);
    parameters.Add("@PromisedDate", ptp.PromisedDate);
    parameters.Add("@ConfidenceLevel", ptp.ConfidenceLevel);
    parameters.Add("@CreatedByUserID", ptp.CreatedByUserID);
    parameters.Add("@Remarks", ptp.Remarks);
    parameters.Add("@NewPTPID", dbType: DbType.Int64, direction: ParameterDirection.Output);

    await connection.ExecuteAsync(
        "sp_CreatePromiseToPay",
        parameters,
        commandType: CommandType.StoredProcedure
    );

    return parameters.Get<long>("@NewPTPID");
}
```

### 5. Transaction Example

```csharp
public async Task<bool> ProcessPaymentWithAllocationAsync(PaymentTransaction payment)
{
    using var connection = _context.CreateConnection();
    connection.Open();
    using var transaction = connection.BeginTransaction();

    try
    {
        // Insert payment
        var paymentId = await connection.ExecuteScalarAsync<long>(
            @"INSERT INTO PaymentTransactions (TransactionNumber, CustomerID, PaymentAmount, ...)
              VALUES (@TransactionNumber, @CustomerID, @PaymentAmount, ...);
              SELECT CAST(SCOPE_IDENTITY() as bigint);",
            payment,
            transaction
        );

        // Insert payment allocation
        await connection.ExecuteAsync(
            @"INSERT INTO PaymentAllocation (PaymentTransactionID, LoanAccountID, ...)
              VALUES (@PaymentTransactionID, @LoanAccountID, ...)",
            new { PaymentTransactionID = paymentId, ... },
            transaction
        );

        // Update case
        await connection.ExecuteAsync(
            @"UPDATE CollectionCases
              SET TotalAmountCollected = TotalAmountCollected + @Amount
              WHERE CaseID = @CaseID",
            new { Amount = payment.PaymentAmount, CaseID = payment.CaseID },
            transaction
        );

        transaction.Commit();
        return true;
    }
    catch
    {
        transaction.Rollback();
        throw;
    }
}
```

### 6. Bulk Insert Example

```csharp
public async Task<int> BulkInsertCustomersAsync(IEnumerable<Customer> customers)
{
    using var connection = _context.CreateConnection();

    var sql = @"
        INSERT INTO Customers (CustomerCode, FirstName, LastName, PrimaryMobileNumber, ...)
        VALUES (@CustomerCode, @FirstName, @LastName, @PrimaryMobileNumber, ...)";

    return await connection.ExecuteAsync(sql, customers);
}
```

## Best Practices

### 1. Always Use Parameters
```csharp
// Good
var sql = "SELECT * FROM Customers WHERE CustomerID = @CustomerId";
await connection.QueryAsync<Customer>(sql, new { CustomerId = id });

// Bad - SQL Injection risk!
var sql = $"SELECT * FROM Customers WHERE CustomerID = {id}";
```

### 2. Use Async Methods
```csharp
// Good
await connection.QueryAsync<Customer>(sql, parameters);

// Avoid
connection.Query<Customer>(sql, parameters); // Blocking call
```

### 3. Dispose Connections Properly
```csharp
// Good - using statement ensures disposal
using var connection = _context.CreateConnection();

// Also good - explicit using block
using (var connection = _context.CreateConnection())
{
    // Your code
}
```

### 4. Use Transactions for Multiple Operations
```csharp
using var connection = _context.CreateConnection();
connection.Open();
using var transaction = connection.BeginTransaction();

try
{
    // Multiple operations
    transaction.Commit();
}
catch
{
    transaction.Rollback();
    throw;
}
```

## Additional Models to Create

You can create similar model classes for other tables:
- `LoanAccount.cs`
- `User.cs`
- `PaymentTransaction.cs`
- `FieldVisit.cs`
- `CustomerInteraction.cs`
- etc.

Follow the same pattern as shown in the existing model classes.

## Performance Tips

1. **Use Views**: For complex queries, create database views and map to DTOs
2. **Query Multiple Result Sets**: Use `QueryMultipleAsync` for related data
3. **Buffering**: Set `buffered: false` for large result sets to reduce memory usage
4. **Command Timeout**: Increase for long-running queries
5. **Connection Pooling**: Enabled by default in SQL Server

## Troubleshooting

### Common Issues

1. **Connection String Error**
   - Verify server name, database name, credentials
   - Check firewall settings for SQL Server

2. **Mapping Errors**
   - Ensure property names match column names
   - Use column aliases if names differ

3. **Timeout Errors**
   - Increase command timeout in configuration
   - Optimize slow queries

## Additional Resources

- [Dapper Documentation](https://github.com/DapperLib/Dapper)
- [Dapper Tutorial](https://www.learndapper.com/)
- [SQL Server Best Practices](https://docs.microsoft.com/en-us/sql/relational-databases/best-practices/)

## Support

For issues or questions about the database schema or Dapper implementation, please refer to the main project documentation.
