# Collection Management System - Deployment Guide

## Overview
This guide will help you set up and deploy the Collection Management System with dynamic data from SQL Server database.

## Prerequisites
- Visual Studio 2022 (or later)
- .NET 8.0 SDK
- SQL Server 2019 or later
- IIS (for production deployment)

## Step 1: Database Setup

### 1.1 Create Database
Open SQL Server Management Studio (SSMS) and run the scripts in the following order:

```sql
-- Navigate to the Database folder and execute scripts in order:
1. 00_DatabaseInitialization.sql
2. 01_CoreTables.sql
3. 02_UserAndTeamTables.sql
4. 03_CommunicationTables.sql
5. 04_PTPAndPaymentTables.sql
6. 05_FieldVisitTables.sql
7. 06_StrategyAndWorkflowTables.sql
8. 07_DocumentAndAuditTables.sql
9. 08_ViewsAndStoredProcedures.sql
10. 99_SampleData.sql (NEW - Contains sample data)
```

### 1.2 Verify Database Creation
After running all scripts, verify:
- Database name: `CollectionManagementDB`
- Total tables: 50+ tables
- Sample data: 6 customers, 6 loans, 6 collection cases, 6 payment transactions

Run this query to verify sample data:
```sql
USE CollectionManagementDB;

SELECT 'Customers' AS TableName, COUNT(*) AS RecordCount FROM Customers
UNION ALL
SELECT 'LoanAccounts', COUNT(*) FROM LoanAccounts
UNION ALL
SELECT 'CollectionCases', COUNT(*) FROM CollectionCases
UNION ALL
SELECT 'PaymentTransactions', COUNT(*) FROM PaymentTransactions;
```

Expected output:
```
TableName              RecordCount
-----------------      -----------
Customers              6
LoanAccounts           6
CollectionCases        6
PaymentTransactions    6
```

## Step 2: Configure Connection String

### 2.1 Update API Configuration
Open `CollectionManagementAPI/appsettings.json` and update the connection string:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=YOUR_SERVER_NAME;Database=CollectionManagementDB;User Id=YOUR_USERNAME;Password=YOUR_PASSWORD;TrustServerCertificate=True"
  }
}
```

**Important Security Note:**
- For production, use Windows Authentication instead of SQL authentication
- Store sensitive credentials in Azure Key Vault or similar secret management service
- Use User Secrets for local development

### 2.2 Update Blazor Configuration
Open `CollectionManagementBlazor/appsettings.json` and verify the API base URL:

```json
{
  "ApiSettings": {
    "BaseUrl": "https://localhost:7001"
  }
}
```

Update the port number if your API runs on a different port.

## Step 3: Build and Test Locally

### 3.1 Restore NuGet Packages
Open the solution in Visual Studio and restore NuGet packages:
```
Right-click on Solution → Restore NuGet Packages
```

### 3.2 Build Solution
```
Build → Build Solution (Ctrl+Shift+B)
```

### 3.3 Run Both Projects
1. Set both projects as startup projects:
   - Right-click on Solution → Set Startup Projects
   - Select "Multiple startup projects"
   - Set both `CollectionManagementAPI` and `CollectionManagementBlazor` to "Start"

2. Press F5 to run

3. Verify the following pages load with data from database:
   - Borrowers page: Should show 6 borrowers
   - Payments page: Should show 6 payment transactions
   - Loans page: Should show 6 loan accounts
   - Collections page: Should show 6 collection cases

## Step 4: Publish from Visual Studio

### 4.1 Publish API (Folder Publish)
1. Right-click on `CollectionManagementAPI` project
2. Select "Publish"
3. Select "FolderProfile" from the dropdown
4. Click "Publish"
5. Files will be published to: `CollectionManagementAPI\bin\Release\net8.0\publish\`

### 4.2 Publish Blazor App (Folder Publish)
1. Right-click on `CollectionManagementBlazor` project
2. Select "Publish"
3. Select "FolderProfile" from the dropdown
4. Click "Publish"
5. Files will be published to: `CollectionManagementBlazor\bin\Release\net8.0\publish\`

### 4.3 Publish to IIS
1. Install IIS with ASP.NET Core Hosting Bundle:
   - Download from: https://dotnet.microsoft.com/download/dotnet/8.0
   - Install "ASP.NET Core Runtime - Windows Hosting Bundle"

2. Create IIS Sites:

   **API Site:**
   - Site Name: CollectionManagementAPI
   - Physical Path: Point to API publish folder
   - Port: 8001 (or your preferred port)
   - Application Pool: .NET v8.0 (No Managed Code)

   **Blazor Site:**
   - Site Name: CollectionManagement
   - Physical Path: Point to Blazor publish folder
   - Port: 8000 (or your preferred port)
   - Application Pool: .NET v8.0 (No Managed Code)

3. Update `appsettings.json` in Blazor publish folder:
   ```json
   {
     "ApiSettings": {
       "BaseUrl": "http://localhost:8001"
     }
   }
   ```

4. Update connection string in API publish folder's `appsettings.json`

5. Start both sites in IIS Manager

## Step 5: Verify Dynamic Data Flow

### 5.1 Test Borrowers Page
1. Navigate to Borrowers page
2. Verify you see 6 borrowers with names:
   - John Doe
   - Jane Smith
   - Robert Johnson
   - Mary Williams
   - James Brown
   - Patricia Garcia

3. Test search functionality

### 5.2 Test Payments Page
1. Navigate to Payments page
2. Verify you see 6 payment transactions
3. Check that metrics are calculated correctly:
   - Total Payments Today
   - Total Revenue
   - Pending Payments
4. Click "View Receipt" on any payment to test modal

### 5.3 Test Loans Page
1. Navigate to Loans page
2. Verify you see 6 loan accounts
3. Check that portfolio metrics are displayed:
   - Total Portfolio
   - Outstanding Balance
   - Current Loans
   - Delinquent Loans

### 5.4 Test Collections Page
1. Navigate to Collections page
2. Verify you see 6 collection cases
3. Check that case statuses are displayed correctly

## Step 6: Troubleshooting

### Issue: No data displayed
**Solution:**
1. Check browser console for errors (F12)
2. Verify API is running and accessible
3. Check CORS settings in API if API and Blazor are on different domains
4. Verify database connection string is correct
5. Check that sample data script (99_SampleData.sql) was executed successfully

### Issue: CORS errors
**Solution:**
Add CORS policy in `CollectionManagementAPI/Program.cs`:
```csharp
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowBlazor",
        policy =>
        {
            policy.WithOrigins("http://localhost:8000", "https://localhost:7000")
                  .AllowAnyHeader()
                  .AllowAnyMethod();
        });
});

// After app.UseRouting();
app.UseCors("AllowBlazor");
```

### Issue: SQL Connection errors
**Solution:**
1. Verify SQL Server is running
2. Check firewall allows SQL Server connections
3. Verify user credentials have access to database
4. Test connection string using SSMS

### Issue: Build errors
**Solution:**
1. Clean and rebuild solution
2. Delete `bin` and `obj` folders
3. Restore NuGet packages
4. Ensure .NET 8.0 SDK is installed

## Step 7: Next Steps

### Add More Data
To add more sample data, you can:
1. Use SSMS to insert data directly
2. Create additional SQL scripts
3. Use the API endpoints (once POST endpoints are implemented)

### Enable Authentication
For production:
1. Implement JWT authentication in API
2. Add authentication middleware in Blazor
3. Secure all API endpoints with [Authorize] attribute

### Configure Logging
1. Update Serilog configuration in appsettings.json
2. Set up log aggregation service (e.g., Seq, Application Insights)
3. Monitor application logs for errors

### Performance Optimization
1. Enable response caching
2. Implement pagination for large datasets
3. Add database indexes as needed
4. Configure connection pooling

## Support

For issues or questions:
1. Check the console logs (F12 in browser)
2. Check API logs (configured in Serilog)
3. Review SQL Server error logs
4. Check IIS logs if deployed to IIS

## Summary

You have successfully:
- ✅ Created SQL database with all tables
- ✅ Populated database with sample data
- ✅ Created API controllers that fetch from database
- ✅ Updated Blazor pages to call API endpoints
- ✅ Created publish profiles for Visual Studio deployment
- ✅ Deployed and tested the application

Your Collection Management System is now running with dynamic data from SQL Server!
