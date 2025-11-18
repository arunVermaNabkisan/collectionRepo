/*
Post-Deployment Script Template
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.
 Use SQLCMD syntax to include a file in the post-deployment script.
 Example:      :r .\myfile.sql
 Use SQLCMD syntax to reference a variable in the post-deployment script.
 Example:      :setvar TableName MyTable
               SELECT * FROM [$(TableName)]
--------------------------------------------------------------------------------------
*/

-- =============================================
-- Collection Management System
-- Post-Deployment Script (Main)
-- =============================================
-- This script orchestrates the execution of all post-deployment scripts
-- in the correct order to seed initial data into the database.
-- All individual scripts use MERGE statements for idempotency.
-- =============================================

PRINT '========================================';
PRINT 'Starting Post-Deployment Data Seeding';
PRINT 'Database: $(DatabaseName)';
PRINT 'Executed: ' + CONVERT(NVARCHAR(50), GETDATE(), 120);
PRINT '========================================';
PRINT '';

-- =============================================
-- 1. Seed DPD Bucket Configuration
-- =============================================
PRINT 'Step 1: Seeding DPD Bucket Configuration...';
:r .\SeedData_DPDBucketConfiguration.sql
PRINT '';

-- =============================================
-- 2. Seed Roles
-- =============================================
PRINT 'Step 2: Seeding Roles...';
:r .\SeedData_Roles.sql
PRINT '';

-- =============================================
-- 3. Seed System Configuration
-- =============================================
PRINT 'Step 3: Seeding System Configuration...';
:r .\SeedData_SystemConfiguration.sql
PRINT '';

-- =============================================
-- Post-Deployment Complete
-- =============================================
PRINT '========================================';
PRINT 'Post-Deployment Data Seeding Completed Successfully';
PRINT 'Completed: ' + CONVERT(NVARCHAR(50), GETDATE(), 120);
PRINT '========================================';
GO
