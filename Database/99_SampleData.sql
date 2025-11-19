-- =============================================
-- Collection Management System - Sample Data
-- Purpose: Populate tables with sample data for testing
-- =============================================

USE CollectionManagementDB;
GO

-- =============================================
-- 1. INSERT SAMPLE CUSTOMERS
-- =============================================
SET IDENTITY_INSERT Customers ON;

INSERT INTO Customers (
    CustomerID, CustomerCode, FirstName, MiddleName, LastName,
    DateOfBirth, Gender, PrimaryMobileNumber, PrimaryEmail,
    CurrentAddressLine1, CurrentCity, CurrentState, CurrentPincode, CurrentCountry,
    Occupation, EmploymentType, MonthlyIncome,
    PreferredLanguage, IsActive, CreatedDate
)
VALUES
    (1, 'CUST001', 'John', NULL, 'Doe', '1985-06-15', 'Male', '+919876543210', 'john.doe@example.com',
     'Flat 101, Green Park Society', 'Mumbai', 'Maharashtra', '400001', 'India',
     'Software Engineer', 'Salaried', 75000.00, 'English', 1, GETDATE()),

    (2, 'CUST002', 'Jane', 'Marie', 'Smith', '1990-03-22', 'Female', '+919876543211', 'jane.smith@example.com',
     'House 45, Sector 17', 'Pune', 'Maharashtra', '411017', 'India',
     'Business Owner', 'Self-Employed', 120000.00, 'English', 1, GETDATE()),

    (3, 'CUST003', 'Robert', NULL, 'Johnson', '1982-11-08', 'Male', '+919876543212', 'robert.j@example.com',
     'Villa 23, Palm Heights', 'Bangalore', 'Karnataka', '560001', 'India',
     'Manager', 'Salaried', 95000.00, 'English', 1, GETDATE()),

    (4, 'CUST004', 'Mary', 'Elizabeth', 'Williams', '1988-07-19', 'Female', '+919876543213', 'mary.w@example.com',
     'Apartment 302, Blue Ridge', 'Delhi', 'Delhi', '110001', 'India',
     'Teacher', 'Salaried', 55000.00, 'Hindi', 1, GETDATE()),

    (5, 'CUST005', 'James', 'Edward', 'Brown', '1975-09-12', 'Male', '+919876543214', 'james.b@example.com',
     'Plot 67, Model Town', 'Jaipur', 'Rajasthan', '302001', 'India',
     'Farmer', 'Self-Employed', 45000.00, 'Hindi', 1, GETDATE()),

    (6, 'CUST006', 'Patricia', NULL, 'Garcia', '1992-01-25', 'Female', '+919876543215', 'patricia.g@example.com',
     'House 12, Civil Lines', 'Ahmedabad', 'Gujarat', '380001', 'India',
     'Doctor', 'Salaried', 150000.00, 'Gujarati', 1, GETDATE());

SET IDENTITY_INSERT Customers OFF;
GO

-- =============================================
-- 2. INSERT SAMPLE LOAN ACCOUNTS
-- =============================================
SET IDENTITY_INSERT LoanAccounts ON;

INSERT INTO LoanAccounts (
    LoanAccountID, LoanAccountNumber, CustomerID,
    ProductType, ProductCategory, LineOfBusiness,
    SanctionedAmount, DisbursedAmount, DisbursementDate,
    EMIAmount, EMIFrequency, InterestRate, TenureMonths, RemainingTenureMonths,
    CurrentPrincipalOutstanding, CurrentInterestOutstanding, CurrentPenalCharges, CurrentLateFees,
    CurrentDPD, LastPaymentDate, LastPaymentAmount, NextEMIDueDate,
    LoanStatus, IsSecured, IsActive, CreatedDate
)
VALUES
    (1, 'LN-001', 1, 'FPO Loan', 'Secured', 'Agriculture',
     500000.00, 500000.00, '2023-01-15',
     15000.00, 'Monthly', 10.50, 48, 36,
     380000.00, 12000.00, 5000.00, 2000.00,
     15, '2024-10-15', 15000.00, '2024-11-15',
     'Active', 1, 1, GETDATE()),

    (2, 'LN-002', 2, 'AVCF Loan', 'Unsecured', 'Corporate',
     1000000.00, 1000000.00, '2023-03-20',
     30000.00, 'Monthly', 12.00, 36, 24,
     650000.00, 18000.00, 8000.00, 3000.00,
     30, '2024-09-20', 30000.00, '2024-11-20',
     'Active', 0, 1, GETDATE()),

    (3, 'LN-003', 3, 'FPO Loan', 'Secured', 'Agriculture',
     300000.00, 300000.00, '2023-06-10',
     10000.00, 'Monthly', 9.75, 36, 24,
     180000.00, 5000.00, 2000.00, 1000.00,
     45, '2024-08-10', 10000.00, '2024-11-10',
     'Active', 1, 1, GETDATE()),

    (4, 'LN-004', 4, 'Corporate Loan', 'Unsecured', 'Corporate',
     750000.00, 750000.00, '2023-02-28',
     25000.00, 'Monthly', 11.50, 36, 24,
     480000.00, 15000.00, 10000.00, 4000.00,
     60, '2024-07-28', 25000.00, '2024-11-28',
     'Active', 0, 1, GETDATE()),

    (5, 'LN-005', 5, 'Agri-Corporate', 'Secured', 'Agriculture',
     400000.00, 400000.00, '2023-04-05',
     12000.00, 'Monthly', 10.00, 48, 36,
     320000.00, 9000.00, 3000.00, 1500.00,
     20, '2024-10-05', 12000.00, '2024-11-05',
     'Active', 1, 1, GETDATE()),

    (6, 'LN-006', 6, 'FPO Loan', 'Secured', 'Agriculture',
     600000.00, 600000.00, '2023-05-12',
     18000.00, 'Monthly', 10.25, 36, 24,
     420000.00, 12000.00, 6000.00, 2500.00,
     90, '2024-05-12', 18000.00, '2024-12-12',
     'Active', 1, 1, GETDATE());

SET IDENTITY_INSERT LoanAccounts OFF;
GO

-- =============================================
-- 3. INSERT SAMPLE COLLECTION CASES
-- =============================================
SET IDENTITY_INSERT CollectionCases ON;

INSERT INTO CollectionCases (
    CaseID, CaseNumber, CustomerID, LoanAccountID,
    CurrentDPD, DPDBucket, CurrentOutstandingAmount, OverdueAmount,
    CaseStatus, CasePriority, PriorityScore,
    BehavioralScore, ProbabilityOfPayment, RiskCategory,
    TotalContactAttempts, SuccessfulContactCount,
    TotalAmountCollected, IsActive, CreatedDate
)
VALUES
    (1, 'CASE-001', 1, 1, 15, 'Bucket-1', 399000.00, 30000.00,
     'InProgress', 'Medium', 60, 70, 75.50, 'Low',
     5, 3, 15000.00, 1, GETDATE()),

    (2, 'CASE-002', 2, 2, 30, 'Bucket-1', 679000.00, 60000.00,
     'Contacted', 'High', 75, 65, 68.20, 'Medium',
     8, 5, 30000.00, 1, GETDATE()),

    (3, 'CASE-003', 3, 3, 45, 'Bucket-2', 188000.00, 45000.00,
     'PTPActive', 'High', 80, 50, 55.30, 'High',
     12, 7, 20000.00, 1, GETDATE()),

    (4, 'CASE-004', 4, 4, 60, 'Bucket-2', 509000.00, 150000.00,
     'FieldVisit', 'Critical', 95, 40, 45.80, 'High',
     15, 6, 50000.00, 1, GETDATE()),

    (5, 'CASE-005', 5, 5, 20, 'Bucket-1', 333500.00, 24000.00,
     'InProgress', 'Medium', 65, 75, 78.90, 'Low',
     6, 4, 12000.00, 1, GETDATE()),

    (6, 'CASE-006', 6, 6, 90, 'Bucket-3', 440500.00, 162000.00,
     'LegalAction', 'Critical', 100, 20, 25.40, 'Very High',
     20, 4, 36000.00, 1, GETDATE());

SET IDENTITY_INSERT CollectionCases OFF;
GO

-- =============================================
-- 4. INSERT SAMPLE PAYMENT TRANSACTIONS
-- =============================================
SET IDENTITY_INSERT PaymentTransactions ON;

INSERT INTO PaymentTransactions (
    PaymentTransactionID, TransactionNumber, CustomerID, LoanAccountID, CaseID,
    PaymentDate, PaymentAmount, Currency,
    PaymentMode, PaymentChannel, PaymentSource,
    PaymentStatus, AllocationStatus, AllocatedAmount,
    ReceiptNumber, IsReceiptSent
)
VALUES
    (1, 'TXN-001', 1, 1, 1,
     DATEADD(HOUR, -2, GETDATE()), 1500.00, 'INR',
     'Bank Transfer', 'Online', 'Customer',
     'Success', 'Allocated', 1500.00,
     'RCP-001', 1),

    (2, 'TXN-002', 2, 2, 2,
     DATEADD(DAY, -1, GETDATE()), 2000.00, 'INR',
     'UPI', 'Mobile', 'Customer',
     'Success', 'Allocated', 2000.00,
     'RCP-002', 1),

    (3, 'TXN-003', 3, 3, 3,
     DATEADD(HOUR, -5, GETDATE()), 500.00, 'INR',
     'Cash', 'Branch', 'Customer',
     'Pending', 'Pending', 0.00,
     'RCP-003', 0),

    (4, 'TXN-004', 4, 4, 4,
     DATEADD(DAY, -2, GETDATE()), 3500.00, 'INR',
     'Cheque', 'Branch', 'Customer',
     'Success', 'Allocated', 3500.00,
     'RCP-004', 1),

    (5, 'TXN-005', 5, 5, 5,
     DATEADD(HOUR, -1, GETDATE()), 1200.00, 'INR',
     'Bank Transfer', 'Online', 'Customer',
     'Success', 'Allocated', 1200.00,
     'RCP-005', 1),

    (6, 'TXN-006', 6, 6, 6,
     DATEADD(DAY, -3, GETDATE()), 800.00, 'INR',
     'UPI', 'Mobile', 'Customer',
     'Failed', 'Failed', 0.00,
     NULL, 0);

SET IDENTITY_INSERT PaymentTransactions OFF;
GO

-- =============================================
-- 5. INSERT SAMPLE USERS (for assignment)
-- =============================================
SET IDENTITY_INSERT Users ON;

INSERT INTO Users (
    UserID, UserCode, Username, FirstName, LastName, Email,
    MobileNumber, UserRole, IsActive, CreatedDate
)
VALUES
    (1, 'USR001', 'admin', 'Admin', 'User', 'admin@nabkisan.com',
     '+919999999999', 'Admin', 1, GETDATE()),

    (2, 'USR002', 'collector1', 'Rahul', 'Kumar', 'rahul.kumar@nabkisan.com',
     '+919999999998', 'Collector', 1, GETDATE()),

    (3, 'USR003', 'collector2', 'Priya', 'Sharma', 'priya.sharma@nabkisan.com',
     '+919999999997', 'Collector', 1, GETDATE());

SET IDENTITY_INSERT Users OFF;
GO

-- =============================================
-- 6. CREATE VIEW FOR BORROWER LIST
-- =============================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_BorrowerList')
    DROP VIEW vw_BorrowerList;
GO

CREATE VIEW vw_BorrowerList AS
SELECT
    c.CustomerID,
    c.CustomerCode,
    c.FullName,
    c.FirstName,
    c.LastName,
    c.PrimaryEmail,
    c.PrimaryMobileNumber,
    c.CurrentCity,
    c.CurrentState,
    COUNT(DISTINCT l.LoanAccountID) AS TotalLoans,
    SUM(l.TotalOutstanding) AS TotalOutstanding,
    MAX(l.CurrentDPD) AS MaxDPD,
    c.IsActive
FROM Customers c
LEFT JOIN LoanAccounts l ON c.CustomerID = l.CustomerID
GROUP BY
    c.CustomerID, c.CustomerCode, c.FullName, c.FirstName, c.LastName,
    c.PrimaryEmail, c.PrimaryMobileNumber, c.CurrentCity, c.CurrentState, c.IsActive;
GO

-- =============================================
-- 7. CREATE VIEW FOR PAYMENT LIST
-- =============================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_PaymentTransactionsList')
    DROP VIEW vw_PaymentTransactionsList;
GO

CREATE VIEW vw_PaymentTransactionsList AS
SELECT
    pt.PaymentTransactionID,
    pt.TransactionNumber,
    pt.PaymentDate,
    pt.PaymentAmount,
    pt.PaymentMode,
    pt.PaymentChannel,
    pt.PaymentStatus,
    pt.ReceiptNumber,
    c.FullName AS BorrowerName,
    c.PrimaryEmail AS BorrowerEmail,
    c.PrimaryMobileNumber AS BorrowerPhone,
    l.LoanAccountNumber
FROM PaymentTransactions pt
INNER JOIN Customers c ON pt.CustomerID = c.CustomerID
INNER JOIN LoanAccounts l ON pt.LoanAccountID = l.LoanAccountID;
GO

-- =============================================
-- 8. CREATE VIEW FOR COLLECTION CASES LIST
-- =============================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_CollectionCasesList')
    DROP VIEW vw_CollectionCasesList;
GO

CREATE VIEW vw_CollectionCasesList AS
SELECT
    cc.CaseID,
    cc.CaseNumber,
    cc.CurrentDPD,
    cc.DPDBucket,
    cc.CaseStatus,
    cc.CasePriority,
    cc.CurrentOutstandingAmount,
    cc.OverdueAmount,
    c.FullName AS CustomerName,
    c.PrimaryMobileNumber AS CustomerPhone,
    l.LoanAccountNumber,
    l.ProductType,
    cc.TotalContactAttempts,
    cc.SuccessfulContactCount,
    cc.CreatedDate
FROM CollectionCases cc
INNER JOIN Customers c ON cc.CustomerID = c.CustomerID
INNER JOIN LoanAccounts l ON cc.LoanAccountID = l.LoanAccountID;
GO

-- =============================================
-- 9. CREATE VIEW FOR LOAN ACCOUNTS LIST
-- =============================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_LoanAccountsList')
    DROP VIEW vw_LoanAccountsList;
GO

CREATE VIEW vw_LoanAccountsList AS
SELECT
    l.LoanAccountID,
    l.LoanAccountNumber,
    l.ProductType,
    l.ProductCategory,
    l.SanctionedAmount,
    l.DisbursedAmount,
    l.DisbursementDate,
    l.EMIAmount,
    l.TotalOutstanding,
    l.CurrentDPD,
    l.LoanStatus,
    c.FullName AS CustomerName,
    c.CustomerCode,
    c.PrimaryMobileNumber AS CustomerPhone,
    l.LastPaymentDate,
    l.NextEMIDueDate,
    l.IsActive
FROM LoanAccounts l
INNER JOIN Customers c ON l.CustomerID = c.CustomerID;
GO

PRINT 'Sample data inserted successfully!';
PRINT 'Total Customers: 6';
PRINT 'Total Loan Accounts: 6';
PRINT 'Total Collection Cases: 6';
PRINT 'Total Payment Transactions: 6';
PRINT 'Total Users: 3';
GO
