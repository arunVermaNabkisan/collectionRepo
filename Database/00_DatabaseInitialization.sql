-- =============================================
-- Collection Management System - Database Initialization
-- Purpose: Create Database and execute all table creation scripts
-- =============================================

-- Create Database
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'CollectionManagementDB')
BEGIN
    CREATE DATABASE CollectionManagementDB;
    PRINT 'Database CollectionManagementDB created successfully.';
END
ELSE
BEGIN
    PRINT 'Database CollectionManagementDB already exists.';
END
GO

USE CollectionManagementDB;
GO

-- =============================================
-- Enable necessary database features
-- =============================================

-- Enable snapshot isolation for better concurrency
ALTER DATABASE CollectionManagementDB
SET ALLOW_SNAPSHOT_ISOLATION ON;

ALTER DATABASE CollectionManagementDB
SET READ_COMMITTED_SNAPSHOT ON;

PRINT 'Snapshot isolation enabled.';
GO

-- =============================================
-- EXECUTION INSTRUCTIONS
-- =============================================
/*
After running this initialization script, execute the following scripts in order:

1. 01_CoreTables.sql              - Customer, Loan, and Case tables
2. 02_UserAndTeamTables.sql       - Users, Teams, Roles, and Performance tables
3. 03_CommunicationTables.sql     - Multi-channel communication tables
4. 04_PTPAndPaymentTables.sql     - Promise to Pay and Payment tables
5. 05_FieldVisitTables.sql        - Field visit and evidence tables
6. 06_StrategyAndWorkflowTables.sql - Collection strategies and workflow automation
7. 07_DocumentAndAuditTables.sql  - Documents, Audit trail, and Compliance tables

After all tables are created, run:
8. 08_ViewsAndStoredProcedures.sql - Database views and stored procedures for Dapper
9. 09_InitialDataLoad.sql          - Load initial master data

Note: Each script should be executed in SQL Server Management Studio or Azure Data Studio
*/

-- =============================================
-- VERIFICATION QUERY
-- =============================================
-- Run this after all scripts to verify table creation
/*
SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'dbo'
ORDER BY TABLE_NAME;
*/

PRINT 'Database initialization completed. Execute table creation scripts in order.';
GO
