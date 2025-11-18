# Collection Management Database - SSDT Project

This is the SQL Server Data Tools (SSDT) project for the Collection Management System database.

## Project Structure

```
CollectionManagementDB.SSDT/
├── Tables/                    # 47 database tables
│   ├── Customers.sql
│   ├── LoanAccounts.sql
│   ├── CollectionCases.sql
│   └── ...
├── Views/                     # 4 database views
│   ├── vw_ActiveCasesDetail.sql
│   ├── vw_PTPDashboard.sql
│   ├── vw_FieldVisitSummary.sql
│   └── vw_PaymentSummary.sql
├── StoredProcedures/         # 5 stored procedures
│   ├── sp_GetCaseDetailsByCaseID.sql
│   ├── sp_GetAgentWorklist.sql
│   ├── sp_CreatePromiseToPay.sql
│   ├── sp_RecordPayment.sql
│   └── sp_GetDashboardMetrics.sql
├── Sequences/                # 2 sequences
│   ├── seq_PTPNumber.sql
│   └── seq_PaymentNumber.sql
├── PostDeployment/           # Post-deployment scripts
│   ├── Script.PostDeployment.sql
│   ├── SeedData_DPDBucketConfiguration.sql
│   ├── SeedData_Roles.sql
│   └── SeedData_SystemConfiguration.sql
├── Security/                 # Security objects (schemas, roles, etc.)
├── PreDeployment/           # Pre-deployment scripts
├── CollectionManagementDB.sqlproj       # SSDT Project file
├── CollectionManagementDB.Local.publish.xml   # Local deployment profile
└── CollectionManagementDB.Azure.publish.xml   # Azure deployment profile
```

## Database Objects Summary

- **Tables**: 47 tables covering all aspects of the collection management system
  - Core: Customers, LoanAccounts, CollectionCases
  - Users & Teams: Users, Teams, Roles, Performance Metrics
  - Communication: CustomerInteractions, VoiceCalls, SMS, Email, WhatsApp
  - Payments: PromiseToPay, PaymentTransactions, Settlements
  - Field Operations: FieldVisits, Evidence, Routes, Location Tracking
  - Workflow: Strategies, Rules, Escalations, Scoring
  - System: Documents, Audit, Configuration, Error Logs

- **Views**: 4 views for common query patterns
- **Stored Procedures**: 5 key procedures for Dapper integration
- **Sequences**: 2 sequences for auto-generating reference numbers

## Prerequisites

- **Visual Studio 2019 or later** with SQL Server Data Tools (SSDT)
- **SQL Server 2019 or later** OR **Azure SQL Database**
- **.NET Framework 4.8** or later

## Getting Started

### 1. Open the Project

1. Open Visual Studio
2. File → Open → Project/Solution
3. Navigate to `CollectionManagementDB.SSDT`
4. Open `CollectionManagementDB.sqlproj`

### 2. Build the Project

1. Right-click on the project in Solution Explorer
2. Select "Build"
3. Check the Output window for any errors

### 3. Deploy to Local SQL Server

#### Using Visual Studio:

1. Right-click on the project
2. Select "Publish..."
3. Click "Load Profile" and select `CollectionManagementDB.Local.publish.xml`
4. Update the connection string if needed
5. Click "Publish"

#### Using Command Line:

```powershell
# Using SqlPackage.exe
SqlPackage.exe /Action:Publish /SourceFile:"CollectionManagementDB.dacpac" /TargetConnectionString:"Server=(localdb)\MSSQLLocalDB;Database=CollectionManagementDB;Integrated Security=true"

# Using MSBuild
msbuild CollectionManagementDB.sqlproj /t:Build /p:Configuration=Release
```

### 4. Deploy to Azure SQL Database

1. Update `CollectionManagementDB.Azure.publish.xml` with your Azure SQL connection details
2. Right-click on the project → Publish
3. Load the Azure publish profile
4. Click "Publish"

## Post-Deployment

After deployment, the following seed data will be automatically loaded:

1. **DPD Bucket Configuration** - 6 default DPD buckets (Bucket-1 through Bucket-6)
2. **Roles** - 8 default user roles with permissions
3. **System Configuration** - 10 default system settings

All post-deployment scripts are **idempotent** and can be run multiple times safely.

## Deployment Options

### Schema Comparison

To compare your SSDT project with an existing database:

1. Tools → SQL Server → New Schema Comparison
2. Select source (SSDT project) and target (database)
3. Click "Compare"
4. Review differences and generate update script

### Data Comparison

To compare data between databases:

1. Tools → SQL Server → New Data Comparison
2. Select source and target databases
3. Select tables to compare
4. Review differences

## CI/CD Integration

### Azure DevOps Pipeline Example:

```yaml
- task: VSBuild@1
  inputs:
    solution: 'CollectionManagementDB.SSDT/CollectionManagementDB.sqlproj'
    platform: 'Any CPU'
    configuration: 'Release'

- task: SqlDacpacDeploymentOnMachineGroup@0
  inputs:
    DacpacFile: '$(Build.SourcesDirectory)/CollectionManagementDB.SSDT/bin/Release/CollectionManagementDB.dacpac'
    ServerName: '$(SQLServerName)'
    DatabaseName: 'CollectionManagementDB'
    AuthScheme: 'sqlServerAuthentication'
    SqlUsername: '$(SQLUsername)'
    SqlPassword: '$(SQLPassword)'
```

### GitHub Actions Example:

```yaml
- name: Build SSDT Project
  run: |
    msbuild CollectionManagementDB.SSDT/CollectionManagementDB.sqlproj /p:Configuration=Release

- name: Deploy to SQL Server
  run: |
    SqlPackage.exe /Action:Publish /SourceFile:CollectionManagementDB.SSDT/bin/Release/CollectionManagementDB.dacpac /TargetConnectionString:"${{ secrets.SQL_CONNECTION_STRING }}"
```

## Best Practices

1. **Always build before deploying** to catch any syntax errors
2. **Use schema comparison** before deploying to production
3. **Backup your database** before applying changes
4. **Test in development** environment first
5. **Review generated deployment scripts** before execution
6. **Use publish profiles** for different environments
7. **Version control** all changes to the SSDT project

## Troubleshooting

### Build Errors

- Check for circular dependencies between objects
- Ensure all referenced objects exist
- Verify T-SQL syntax is correct

### Deployment Errors

- Check connection string
- Verify user permissions
- Review deployment options in publish profile
- Check for blocking data loss changes

### Foreign Key Errors

If you see foreign key constraint errors during deployment:
1. Check the build order of tables
2. Ensure parent tables are created before child tables
3. Verify foreign key references are correct

## Database Schema Version

- **Project Version**: 1.0.0
- **SQL Server Target**: SQL Server 2019 (150)
- **Azure SQL Database**: Compatible
- **Collation**: SQL_Latin1_General_CP1_CI_AS

## Support

For issues or questions:
- Review the main [DATABASE_README.md](/DATABASE_README.md) in the repository root
- Check the original SQL scripts in the `/Database` folder
- Refer to Microsoft SSDT documentation

## Migration from Original SQL Scripts

This SSDT project was migrated from the original SQL scripts located in `/Database` folder:

- `00_DatabaseInitialization.sql` → Database creation (handled by SSDT)
- `01_CoreTables.sql` → Core tables (Customers, Loans, Cases)
- `02_UserAndTeamTables.sql` → User and team management tables
- `03_CommunicationTables.sql` → Communication channel tables
- `04_PTPAndPaymentTables.sql` → PTP and payment tables
- `05_FieldVisitTables.sql` → Field visit tables
- `06_StrategyAndWorkflowTables.sql` → Strategy and workflow tables
- `07_DocumentAndAuditTables.sql` → Document and audit tables
- `08_ViewsAndStoredProcedures.sql` → Views and stored procedures

All INSERT statements for initial data have been converted to MERGE statements in post-deployment scripts to ensure idempotency.
