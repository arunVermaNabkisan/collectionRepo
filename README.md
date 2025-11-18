# NABKISAN Collection Management System

A comprehensive collection management system built with .NET 8, Blazor Server, and SQL Server. This system helps manage borrowers, loans, payments, and collection activities for financial institutions.

## Solution Structure

The solution consists of three main projects:

### 1. **CollectionManagementBlazor** (Startup Project)
- **Type**: Blazor Server Application
- **Purpose**: Web-based user interface
- **Port**: https://localhost:7002 (HTTPS) / http://localhost:5002 (HTTP)
- **Technology**: ASP.NET Core 8.0 Blazor Server

### 2. **CollectionManagementAPI**
- **Type**: ASP.NET Core Web API
- **Purpose**: RESTful API backend for data operations
- **Port**: https://localhost:5001 (HTTPS) / http://localhost:5000 (HTTP)
- **Technology**: ASP.NET Core 8.0, Dapper, SQL Server

### 3. **CollectionManagementDB.SSDT**
- **Type**: SQL Server Database Project (SSDT)
- **Purpose**: Database schema and deployment
- **Technology**: SQL Server, SSDT

## Getting Started

### Prerequisites

- .NET 8.0 SDK or later
- Visual Studio 2022 (recommended) or Visual Studio Code
- SQL Server 2019 or later
- SQL Server Management Studio (optional)

### Opening the Solution

1. Open `CollectionManagement.sln` in Visual Studio 2022
2. The solution will load all three projects

### Setting Up the Database

1. Open the `CollectionManagementDB.SSDT` project
2. Update the connection string in publish profile (if needed)
3. Right-click on the project and select "Publish"
4. Follow the wizard to deploy the database to your SQL Server instance

Alternatively, you can use the SQL scripts in the `Database/` folder.

### Configuring the API

1. Open `CollectionManagementAPI/appsettings.json`
2. Update the connection string to point to your SQL Server:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=YOUR_SERVER;Database=CollectionManagementDB;Integrated Security=true;TrustServerCertificate=true;"
  }
}
```

### Configuring the Blazor App

1. Open `CollectionManagementBlazor/appsettings.json`
2. Ensure the API URL is correct:
```json
{
  "ApiSettings": {
    "BaseUrl": "https://localhost:5001"
  }
}
```

## Running the Application

### Option 1: Using Visual Studio (Recommended)

1. Right-click on `CollectionManagementBlazor` in Solution Explorer
2. Select "Set as Startup Project"
3. Press F5 or click "Start Debugging"
4. The Blazor UI will open in your default browser

**Note**: You'll need to run both the API and Blazor projects. You can configure multiple startup projects:
- Right-click on the solution
- Select "Properties" → "Startup Project"
- Choose "Multiple startup projects"
- Set both `CollectionManagementAPI` and `CollectionManagementBlazor` to "Start"

### Option 2: Using .NET CLI

**Terminal 1 (API):**
```bash
cd CollectionManagementAPI
dotnet run
```

**Terminal 2 (Blazor):**
```bash
cd CollectionManagementBlazor
dotnet run
```

Then open your browser and navigate to: https://localhost:7002

## Project Features

### Blazor UI Features
- **Dashboard**: Overview of collection activities
- **Borrower Management**: Add, edit, and view borrower information
- **Loan Management**: Track and manage loan accounts
- **Payment Processing**: Record and track payments
- **Collection Activities**: Manage collection tasks and follow-ups
- **Responsive Design**: Works on desktop, tablet, and mobile devices

### API Features
- RESTful endpoints for all CRUD operations
- JWT authentication support
- Swagger/OpenAPI documentation
- Comprehensive error handling
- Logging with Serilog
- Input validation with FluentValidation
- Repository pattern with Dapper

### Database Features
- Normalized relational schema
- Foreign key constraints
- Indexes for performance
- Stored procedures for complex operations
- Sample data scripts

## Solution File

The `CollectionManagement.sln` file includes:
- All project references
- Build configurations (Debug/Release)
- Project dependencies
- Solution-level settings

## Startup Configuration

The **CollectionManagementBlazor** project is configured as the primary startup project. Its startup behavior is defined in:

**File**: `CollectionManagementBlazor/Properties/launchSettings.json`

**Default Profile**: `https`
- **Launch Browser**: Yes
- **Application URL**: https://localhost:7002;http://localhost:5002
- **Environment**: Development

**Entry Point**: `CollectionManagementBlazor/Pages/_Host.cshtml`

## Documentation

Detailed documentation for each project:
- [API Documentation](CollectionManagementAPI/README.md)
- [Blazor UI Documentation](CollectionManagementBlazor/README.md)
- [Database Documentation](DATABASE_README.md)
- [Functional Requirements](NABKISAN_Collections_FRD_FInal%201.md)
- [Process Flows](NABKISAN_Process_Flows%20(2).md)

## Architecture

```
┌─────────────────────────────────────┐
│   Blazor Server UI (Port 7002)     │
│   - Razor Components                │
│   - SignalR for real-time updates   │
└─────────────┬───────────────────────┘
              │ HTTP/HTTPS
              ▼
┌─────────────────────────────────────┐
│   Web API (Port 5001)               │
│   - Controllers                      │
│   - Services                         │
│   - Repositories                     │
└─────────────┬───────────────────────┘
              │ ADO.NET/Dapper
              ▼
┌─────────────────────────────────────┐
│   SQL Server Database               │
│   - Tables                           │
│   - Stored Procedures                │
│   - Views                            │
└─────────────────────────────────────┘
```

## Technology Stack

- **Frontend**: Blazor Server, Bootstrap 5, HTML5, CSS3
- **Backend**: ASP.NET Core 8.0 Web API
- **Database**: SQL Server 2019+
- **ORM**: Dapper
- **Authentication**: JWT Bearer Tokens
- **Logging**: Serilog
- **Validation**: FluentValidation
- **Documentation**: Swagger/OpenAPI

## Development Workflow

1. Make changes to the Blazor UI or API code
2. Build the solution (Ctrl+Shift+B)
3. Run the projects (F5)
4. Test changes in the browser
5. Update database schema in SSDT project if needed
6. Commit changes to git

## Troubleshooting

### API Not Responding
- Check if the API project is running
- Verify the port in launchSettings.json matches appsettings.json
- Check firewall settings

### Database Connection Errors
- Verify SQL Server is running
- Check connection string in appsettings.json
- Ensure database is deployed
- Verify SQL Server authentication mode

### Blazor App Not Loading
- Clear browser cache
- Check browser console for errors
- Verify SignalR connection
- Ensure ports 5002/7002 are not in use

### Bootstrap CSS Not Loading
- Download Bootstrap from https://getbootstrap.com/
- Place files in `CollectionManagementBlazor/wwwroot/css/bootstrap/`

## Contributing

1. Create a feature branch
2. Make your changes
3. Test thoroughly
4. Submit a pull request

## License

Proprietary - NABKISAN Collection Management System

## Support

For technical support or questions, contact the development team.

---

**Note**: This is the startup solution file. Set `CollectionManagementBlazor` as the startup project to run the web interface.
