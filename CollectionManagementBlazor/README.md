# Collection Management Blazor Application

This is a Blazor Server application for the NABKISAN Collection Management System. It provides a modern web interface for managing borrowers, loans, payments, and collection activities.

## Project Structure

```
CollectionManagementBlazor/
├── Pages/                  # Razor pages
│   ├── _Host.cshtml       # Main host page (entry point)
│   ├── Index.razor        # Home page
│   └── Error.cshtml       # Error page
├── Shared/                # Shared components
│   ├── MainLayout.razor   # Main layout template
│   └── NavMenu.razor      # Navigation menu
├── wwwroot/               # Static files
│   └── css/              # Stylesheets
├── Services/              # Business logic services
├── Models/                # Data models
├── Components/            # Reusable components
├── Program.cs            # Application entry point
├── App.razor             # Root component
└── _Imports.razor        # Global using statements
```

## Prerequisites

- .NET 8.0 SDK or later
- Visual Studio 2022 or Visual Studio Code
- SQL Server (for the API backend)

## Configuration

### API Connection

The Blazor app connects to the Collection Management API. Update the API base URL in:

**appsettings.json** (Production):
```json
{
  "ApiSettings": {
    "BaseUrl": "https://localhost:5001"
  }
}
```

**appsettings.Development.json** (Development):
```json
{
  "ApiSettings": {
    "BaseUrl": "http://localhost:5000"
  }
}
```

## Running the Application

### Using Visual Studio

1. Open `CollectionManagement.sln`
2. Set `CollectionManagementBlazor` as the startup project
3. Press F5 or click "Start Debugging"

### Using .NET CLI

```bash
cd CollectionManagementBlazor
dotnet restore
dotnet run
```

The application will be available at:
- HTTP: http://localhost:5002
- HTTPS: https://localhost:7002

## Startup Configuration

The application startup is configured in `Program.cs`:

- **Razor Pages**: Enabled for hosting Blazor components
- **Blazor Server**: Configured with SignalR for real-time updates
- **HttpClient**: Configured to communicate with the API backend
- **Static Files**: Serves CSS, JavaScript, and other assets

### Launch Settings

The startup configuration is defined in `Properties/launchSettings.json`:

- **Default Profile**: `https` profile (launches with HTTPS)
- **HTTP Port**: 5002
- **HTTPS Port**: 7002
- **Environment**: Development (can be changed to Production)

## Setting as Startup Project

### In Visual Studio:
1. Right-click on `CollectionManagementBlazor` in Solution Explorer
2. Select "Set as Startup Project"
3. The project name will appear in bold

### In Visual Studio Code:
1. Open `launch.json` in `.vscode` folder
2. Set the `program` path to point to the Blazor project DLL:
```json
{
  "program": "${workspaceFolder}/CollectionManagementBlazor/bin/Debug/net8.0/CollectionManagementBlazor.dll"
}
```

## Key Features

- **Blazor Server**: Server-side rendering with real-time UI updates
- **SignalR Integration**: Real-time communication between client and server
- **Responsive Design**: Mobile-friendly Bootstrap-based layout
- **API Integration**: Communicates with the Collection Management API
- **Modular Architecture**: Organized into pages, components, and services

## Main Entry Point

The application starts from:
1. **_Host.cshtml** (`Pages/_Host.cshtml`) - The main HTML host page
2. **Program.cs** - Configures services and middleware
3. **App.razor** - Root Blazor component with routing

## Navigation

The application includes navigation to:
- **Home** (`/`) - Dashboard and overview
- **Borrowers** (`/borrowers`) - Manage borrower information
- **Loans** (`/loans`) - Track and manage loans
- **Payments** (`/payments`) - Record payment transactions
- **Collections** (`/collections`) - Manage collection activities

## Dependencies

The project uses the following NuGet packages:
- Microsoft.AspNetCore.Components.WebAssembly.Server (v8.0.11)

## Running with API

To run the full system:

1. Start the API project first:
```bash
cd CollectionManagementAPI
dotnet run
```

2. Then start the Blazor project:
```bash
cd CollectionManagementBlazor
dotnet run
```

3. Access the Blazor UI at https://localhost:7002

## Troubleshooting

### API Connection Issues
- Ensure the API is running before starting the Blazor app
- Verify the API URL in `appsettings.json` matches the API's listening port
- Check CORS settings in the API if you encounter cross-origin errors

### Bootstrap CSS Not Loading
- Download Bootstrap CSS from https://getbootstrap.com/
- Place `bootstrap.min.css` in `wwwroot/css/bootstrap/`
- Or use a CDN link in `_Host.cshtml`

### Port Already in Use
- Change the ports in `Properties/launchSettings.json`
- Or stop other applications using ports 5002/7002

## Development Notes

- The app uses Blazor Server (not WebAssembly) for better SEO and initial load performance
- Server-side rendering means components run on the server with UI updates sent via SignalR
- State is maintained on the server for each user session
- Consider implementing authentication/authorization for production use

## Next Steps

1. Implement page components for Borrowers, Loans, Payments, and Collections
2. Create service classes to call the API endpoints
3. Add data models matching the API DTOs
4. Implement forms for data entry and editing
5. Add data validation and error handling
6. Implement authentication and authorization
7. Add loading indicators and user feedback
8. Create reusable components for common UI patterns

## Support

For issues or questions, refer to:
- [Blazor Documentation](https://learn.microsoft.com/aspnet/core/blazor/)
- [ASP.NET Core Documentation](https://learn.microsoft.com/aspnet/core/)
