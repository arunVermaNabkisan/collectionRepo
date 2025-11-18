# Collection Management API

ASP.NET Core 8 Web API for NABKISAN Finance Limited Collection Management System

## Overview

This API provides comprehensive endpoints for managing the complete collection lifecycle for an NBFC (Non-Banking Financial Company), including:

- **Case Management** - Collection case creation, assignment, tracking, and resolution
- **Promise to Pay (PTP)** - PTP creation, monitoring, and fulfillment tracking
- **Payment Processing** - Multi-mode payment recording, reconciliation, and reporting
- **Field Visits** - Field collection visit planning, execution, and outcome tracking
- **Customer Interactions** - Multi-channel communication logging and analysis
- **Dashboard & Analytics** - Real-time metrics and KPI tracking

## Technology Stack

- **.NET 8.0** - Latest LTS version of .NET
- **ASP.NET Core Web API** - RESTful API framework
- **Dapper** - High-performance micro-ORM for database operations
- **SQL Server** - Database (supports both on-premise and Azure SQL)
- **JWT Authentication** - Secure token-based authentication
- **Serilog** - Structured logging
- **Swagger/OpenAPI** - API documentation and testing

## Project Structure

```
CollectionManagementAPI/
├── Controllers/          # API endpoints
│   └── CasesController.cs
├── Services/            # Business logic layer
│   ├── ICaseService.cs
│   └── CaseService.cs
├── Repositories/        # Data access layer
│   ├── IGenericRepository.cs
│   ├── ICaseRepository.cs
│   ├── CaseRepository.cs
│   ├── ICustomerRepository.cs
│   ├── IPTPRepository.cs
│   ├── IPaymentRepository.cs
│   ├── IFieldVisitRepository.cs
│   └── IInteractionRepository.cs
├── Models/              # Domain entities
│   ├── Customer.cs
│   ├── CollectionCase.cs
│   ├── PromiseToPay.cs
│   ├── LoanAccount.cs
│   ├── User.cs
│   ├── PaymentTransaction.cs
│   ├── FieldVisit.cs
│   ├── CustomerInteraction.cs
│   └── DapperContext.cs
├── DTOs/               # Data Transfer Objects
│   ├── CaseDTO.cs
│   ├── PTPDTO.cs
│   ├── PaymentDTO.cs
│   └── CommonDTO.cs
├── Middleware/         # Custom middleware
│   └── ExceptionHandlingMiddleware.cs
├── Program.cs          # Application entry point
└── appsettings.json    # Configuration

```

## Getting Started

### Prerequisites

- .NET 8.0 SDK or later
- SQL Server 2019+ or Azure SQL Database
- Visual Studio 2022 / VS Code / Rider

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd collectionRepo/CollectionManagementAPI
   ```

2. **Update database connection string**

   Edit `appsettings.json` and update the connection string:
   ```json
   "ConnectionStrings": {
     "DefaultConnection": "Server=your-server;Database=CollectionManagementDB;User Id=your-user;Password=your-password;TrustServerCertificate=True;"
   }
   ```

3. **Run database migrations**

   Execute the SQL scripts from the `/Database` folder in order:
   ```
   00_DatabaseInitialization.sql
   01_CoreTables.sql
   02_UserAndTeamTables.sql
   03_CommunicationTables.sql
   04_PTPAndPaymentTables.sql
   05_FieldVisitTables.sql
   06_StrategyAndWorkflowTables.sql
   07_DocumentAndAuditTables.sql
   08_ViewsAndStoredProcedures.sql
   ```

4. **Restore NuGet packages**
   ```bash
   dotnet restore
   ```

5. **Build the project**
   ```bash
   dotnet build
   ```

6. **Run the application**
   ```bash
   dotnet run
   ```

The API will be available at:
- HTTPS: `https://localhost:5001`
- HTTP: `http://localhost:5000`
- Swagger UI: `https://localhost:5001` (root path in development)

## API Endpoints

### Cases API (`/api/cases`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/cases/{id}` | Get case details by ID |
| GET | `/api/cases/worklist/{userId}` | Get agent worklist |
| GET | `/api/cases/status/{status}` | Get cases by status |
| GET | `/api/cases/statistics` | Get case statistics |
| GET | `/api/cases/overdue-ptp` | Get cases with overdue PTPs |
| POST | `/api/cases` | Create a new case |
| PUT | `/api/cases/{id}/status` | Update case status |
| POST | `/api/cases/assign` | Assign case to user |

### Example Requests

**Get Case by ID**
```http
GET /api/cases/123
Authorization: Bearer {token}
```

**Create a New Case**
```http
POST /api/cases
Authorization: Bearer {token}
Content-Type: application/json

{
  "customerID": 1001,
  "loanAccountID": 2001,
  "currentDPD": 15,
  "dpdBucket": "Bucket-1",
  "currentOutstandingAmount": 50000,
  "overdueAmount": 15000,
  "assignedToUserID": 5,
  "createdBy": 1
}
```

**Update Case Status**
```http
PUT /api/cases/123/status
Authorization: Bearer {token}
Content-Type: application/json

{
  "newStatus": "Resolved",
  "subStatus": "PTP Kept",
  "remarks": "Payment received",
  "modifiedBy": 5
}
```

## Authentication

The API uses JWT Bearer token authentication. To access protected endpoints:

1. Obtain a JWT token through the authentication endpoint
2. Include the token in the Authorization header:
   ```
   Authorization: Bearer {your-jwt-token}
   ```

### JWT Configuration

Update JWT settings in `appsettings.json`:
```json
"JwtSettings": {
  "SecretKey": "your-secret-key-min-32-characters",
  "Issuer": "CollectionManagementAPI",
  "Audience": "CollectionManagementClient",
  "ExpiryInMinutes": 480
}
```

## Response Format

All API responses follow a standard format:

**Success Response**
```json
{
  "success": true,
  "message": "Success",
  "data": { ... },
  "errors": null,
  "timestamp": "2024-11-18T10:30:00Z"
}
```

**Error Response**
```json
{
  "success": false,
  "message": "Error occurred",
  "data": null,
  "errors": ["Error detail 1", "Error detail 2"],
  "timestamp": "2024-11-18T10:30:00Z"
}
```

## Logging

The API uses Serilog for structured logging. Logs are written to:
- Console (for development)
- File: `logs/collectionapi-{Date}.txt` (rolling daily logs)

Log levels:
- **Information** - Normal operations
- **Warning** - Unexpected behavior that doesn't stop execution
- **Error** - Errors and exceptions
- **Critical** - Critical failures

## Configuration

### Database Settings
```json
"DatabaseSettings": {
  "CommandTimeout": 30,
  "EnableRetryOnFailure": true,
  "MaxRetryCount": 3,
  "MaxRetryDelay": 30
}
```

### CORS Configuration

By default, CORS is configured to allow all origins in development. For production, update the CORS policy in `Program.cs`:

```csharp
builder.Services.AddCors(options =>
{
    options.AddPolicy("Production", policy =>
    {
        policy.WithOrigins("https://your-frontend-domain.com")
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});
```

## Error Handling

Global exception handling is implemented via `ExceptionHandlingMiddleware`. All unhandled exceptions are:
1. Logged with full stack trace
2. Returned as standardized error responses
3. Never expose sensitive information to clients

## Performance Considerations

- **Dapper** is used for high-performance data access
- Database queries are optimized with proper indexing
- Connection pooling is enabled by default
- Async/await pattern used throughout for better scalability

## Security Best Practices

1. **Never commit sensitive data** - Use environment variables or Azure Key Vault for production
2. **Update JWT secret** - Change the default secret key in production
3. **Enable HTTPS** - Always use HTTPS in production
4. **Input Validation** - All DTOs have validation attributes
5. **SQL Injection Prevention** - Parameterized queries via Dapper

## Development vs Production

### Development
- Swagger UI enabled at root path
- Detailed error messages
- Console logging
- CORS allows all origins

### Production
- Swagger UI disabled (or secured)
- Generic error messages
- File-based logging only
- Restricted CORS policy
- Use Azure Key Vault for secrets
- Enable Application Insights

## Testing

Run tests using:
```bash
dotnet test
```

## API Documentation

When running in development mode, visit the root URL to access Swagger UI:
- Local: `https://localhost:5001`

Swagger provides:
- Interactive API documentation
- Request/response examples
- Try-it-out functionality
- Schema definitions

## Deployment

### Azure App Service

1. Publish the application:
   ```bash
   dotnet publish -c Release -o ./publish
   ```

2. Deploy to Azure App Service via Azure CLI, Visual Studio, or GitHub Actions

3. Configure Application Settings in Azure Portal with production values

### Docker

Create a `Dockerfile`:
```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["CollectionManagementAPI.csproj", "./"]
RUN dotnet restore
COPY . .
RUN dotnet build -c Release -o /app/build

FROM build AS publish
RUN dotnet publish -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "CollectionManagementAPI.dll"]
```

Build and run:
```bash
docker build -t collection-api .
docker run -p 8080:80 collection-api
```

## Monitoring

Recommended monitoring tools:
- **Application Insights** - Application performance monitoring
- **Seq** - Structured log analysis
- **Health Checks** - Built-in health check endpoint at `/health`

## Support

For issues and questions:
- Check the API documentation at `/swagger`
- Review the database schema in `/Database` folder
- Consult the BRD document: `NABKISAN_Collections_FRD_FInal 1.md`

## License

© 2024 NABKISAN Finance Limited. All rights reserved.

## Version History

- **v1.0.0** (2024-11-18) - Initial release
  - Case Management API
  - Core infrastructure setup
  - JWT authentication
  - Swagger documentation
