-- =============================================
-- Collection Management System - Core Tables
-- Database: SQL Server
-- Purpose: Customer, Loan, and Case Management
-- =============================================

USE CollectionManagementDB;
GO

-- =============================================
-- 1. CUSTOMER MASTER TABLE
-- =============================================
CREATE TABLE Customers (
    CustomerID BIGINT IDENTITY(1,1) PRIMARY KEY,
    CustomerCode NVARCHAR(50) NOT NULL UNIQUE,

    -- Personal Information
    FirstName NVARCHAR(100) NOT NULL,
    MiddleName NVARCHAR(100) NULL,
    LastName NVARCHAR(100) NOT NULL,
    FullName AS (FirstName + ' ' + ISNULL(MiddleName + ' ', '') + LastName) PERSISTED,
    DateOfBirth DATE NULL,
    Age AS (DATEDIFF(YEAR, DateOfBirth, GETDATE())) PERSISTED,
    Gender NVARCHAR(10) NULL, -- Male, Female, Other

    -- Contact Information
    PrimaryMobileNumber NVARCHAR(15) NOT NULL,
    IsPrimaryMobileVerified BIT DEFAULT 0,
    AlternateMobileNumber NVARCHAR(15) NULL,
    IsAlternateMobileVerified BIT DEFAULT 0,
    PrimaryEmail NVARCHAR(255) NULL,
    IsPrimaryEmailVerified BIT DEFAULT 0,
    AlternateEmail NVARCHAR(255) NULL,

    -- Address Information
    CurrentAddressLine1 NVARCHAR(500) NULL,
    CurrentAddressLine2 NVARCHAR(500) NULL,
    CurrentCity NVARCHAR(100) NULL,
    CurrentState NVARCHAR(100) NULL,
    CurrentPincode NVARCHAR(10) NULL,
    CurrentCountry NVARCHAR(100) DEFAULT 'India',

    PermanentAddressLine1 NVARCHAR(500) NULL,
    PermanentAddressLine2 NVARCHAR(500) NULL,
    PermanentCity NVARCHAR(100) NULL,
    PermanentState NVARCHAR(100) NULL,
    PermanentPincode NVARCHAR(10) NULL,
    PermanentCountry NVARCHAR(100) DEFAULT 'India',

    -- Professional Information
    Occupation NVARCHAR(100) NULL,
    EmploymentType NVARCHAR(50) NULL, -- Salaried, Self-Employed, Farmer, Business, etc.
    EmployerName NVARCHAR(200) NULL,
    MonthlyIncome DECIMAL(18,2) NULL,

    -- Preferences
    PreferredLanguage NVARCHAR(50) DEFAULT 'English',
    PreferredContactTime NVARCHAR(50) NULL, -- Morning, Afternoon, Evening
    PreferredContactMode NVARCHAR(50) NULL, -- Voice, SMS, Email, WhatsApp

    -- KYC Information
    PanNumber NVARCHAR(20) NULL,
    AadharNumber NVARCHAR(20) NULL, -- Encrypted in production
    IsKYCVerified BIT DEFAULT 0,
    KYCVerificationDate DATETIME NULL,

    -- Risk and Scoring
    CustomerRiskScore INT DEFAULT 0,
    CreditBureauScore INT NULL,
    LastBureauPullDate DATETIME NULL,

    -- Metadata
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    CreatedBy BIGINT NULL,
    ModifiedDate DATETIME NULL,
    ModifiedBy BIGINT NULL,
    SyncedFromLMS BIT DEFAULT 0,
    LastSyncDate DATETIME NULL,

    CONSTRAINT CK_Gender CHECK (Gender IN ('Male', 'Female', 'Other', 'Not Specified')),
    CONSTRAINT CK_CustomerRiskScore CHECK (CustomerRiskScore BETWEEN 0 AND 1000)
);

CREATE INDEX IDX_Customer_Code ON Customers(CustomerCode);
CREATE INDEX IDX_Customer_Mobile ON Customers(PrimaryMobileNumber);
CREATE INDEX IDX_Customer_Email ON Customers(PrimaryEmail);
CREATE INDEX IDX_Customer_PAN ON Customers(PanNumber);
CREATE INDEX IDX_Customer_Active ON Customers(IsActive);
GO

-- =============================================
-- 2. LOAN ACCOUNTS TABLE
-- =============================================
CREATE TABLE LoanAccounts (
    LoanAccountID BIGINT IDENTITY(1,1) PRIMARY KEY,
    LoanAccountNumber NVARCHAR(50) NOT NULL UNIQUE,
    CustomerID BIGINT NOT NULL,

    -- Product Information
    ProductType NVARCHAR(100) NOT NULL, -- FPO, AVCF, Corporate, Agri-Corporate, etc.
    ProductCategory NVARCHAR(50) NOT NULL, -- Secured, Unsecured
    LineOfBusiness NVARCHAR(100) NOT NULL,

    -- Loan Details
    SanctionedAmount DECIMAL(18,2) NOT NULL,
    DisbursedAmount DECIMAL(18,2) NOT NULL,
    DisbursementDate DATE NOT NULL,

    -- EMI and Interest
    EMIAmount DECIMAL(18,2) NOT NULL,
    EMIFrequency NVARCHAR(20) NOT NULL, -- Monthly, Quarterly, etc.
    InterestRate DECIMAL(5,2) NOT NULL,
    TenureMonths INT NOT NULL,
    RemainingTenureMonths INT NULL,

    -- Outstanding Information
    CurrentPrincipalOutstanding DECIMAL(18,2) DEFAULT 0,
    CurrentInterestOutstanding DECIMAL(18,2) DEFAULT 0,
    CurrentPenalCharges DECIMAL(18,2) DEFAULT 0,
    CurrentLateFees DECIMAL(18,2) DEFAULT 0,
    CurrentOtherCharges DECIMAL(18,2) DEFAULT 0,
    TotalOutstanding AS (
        CurrentPrincipalOutstanding +
        CurrentInterestOutstanding +
        CurrentPenalCharges +
        CurrentLateFees +
        CurrentOtherCharges
    ) PERSISTED,

    -- Delinquency Information
    CurrentDPD INT DEFAULT 0, -- Days Past Due
    LastPaymentDate DATE NULL,
    LastPaymentAmount DECIMAL(18,2) NULL,
    NextEMIDueDate DATE NULL,

    -- Classification
    LoanStatus NVARCHAR(50) NOT NULL, -- Active, Closed, Written-Off, NPA, etc.
    NPAClassification NVARCHAR(50) NULL, -- Standard, Sub-Standard, Doubtful, Loss
    NPADate DATE NULL,

    -- Collateral Information (for secured loans)
    IsSecured BIT DEFAULT 0,
    CollateralType NVARCHAR(100) NULL,
    CollateralValue DECIMAL(18,2) NULL,

    -- Relationship Manager
    AssignedRMUserID BIGINT NULL,
    AssignedTeamID BIGINT NULL,

    -- Metadata
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    CreatedBy BIGINT NULL,
    ModifiedDate DATETIME NULL,
    ModifiedBy BIGINT NULL,
    SyncedFromLMS BIT DEFAULT 0,
    LastSyncDate DATETIME NULL,

    CONSTRAINT FK_Loan_Customer FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT CK_LoanStatus CHECK (LoanStatus IN ('Active', 'Closed', 'Written-Off', 'NPA', 'Restructured', 'Settled')),
    CONSTRAINT CK_ProductCategory CHECK (ProductCategory IN ('Secured', 'Unsecured'))
);

CREATE INDEX IDX_Loan_Customer ON LoanAccounts(CustomerID);
CREATE INDEX IDX_Loan_AccountNumber ON LoanAccounts(LoanAccountNumber);
CREATE INDEX IDX_Loan_DPD ON LoanAccounts(CurrentDPD);
CREATE INDEX IDX_Loan_Status ON LoanAccounts(LoanStatus);
CREATE INDEX IDX_Loan_RM ON LoanAccounts(AssignedRMUserID);
CREATE INDEX IDX_Loan_Product ON LoanAccounts(ProductType);
GO

-- =============================================
-- 3. COLLECTION CASES TABLE
-- =============================================
CREATE TABLE CollectionCases (
    CaseID BIGINT IDENTITY(1,1) PRIMARY KEY,
    CaseNumber NVARCHAR(50) NOT NULL UNIQUE,

    -- Link to Customer and Loan
    CustomerID BIGINT NOT NULL,
    LoanAccountID BIGINT NOT NULL,

    -- Case Classification
    CurrentDPD INT NOT NULL,
    DPDBucket NVARCHAR(20) NOT NULL, -- Bucket-1, Bucket-2, etc.
    CurrentOutstandingAmount DECIMAL(18,2) NOT NULL,
    OverdueAmount DECIMAL(18,2) NOT NULL,

    -- Case Status
    CaseStatus NVARCHAR(50) NOT NULL,
    -- Status: New, InProgress, Contacted, PTPActive, PartialRecovery,
    --         FullRecovery, PTPBroken, FieldVisit, LegalAction,
    --         Dispute, WrittenOff, Closed

    CaseSubStatus NVARCHAR(100) NULL,
    CasePriority NVARCHAR(20) NOT NULL, -- Critical, High, Medium, Low
    PriorityScore INT DEFAULT 0,

    -- Assignment
    AssignedToUserID BIGINT NULL,
    AssignedToTeamID BIGINT NULL,
    AssignedDate DATETIME NULL,
    LastReassignedDate DATETIME NULL,

    -- Strategy
    CurrentStrategyID BIGINT NULL,
    StrategyAssignedDate DATETIME NULL,

    -- Risk and Behavior Scoring
    BehavioralScore INT DEFAULT 0,
    ProbabilityOfPayment DECIMAL(5,2) DEFAULT 0, -- 0-100 percentage
    RiskCategory NVARCHAR(50) NULL, -- Low, Medium, High, Very High

    -- SLA and Escalation
    SLADueDate DATETIME NULL,
    IsSLABreached BIT DEFAULT 0,
    EscalationLevel INT DEFAULT 0, -- 0=None, 1=L1, 2=L2, etc.
    LastEscalationDate DATETIME NULL,

    -- Activity Tracking
    FirstContactAttemptDate DATETIME NULL,
    LastContactAttemptDate DATETIME NULL,
    TotalContactAttempts INT DEFAULT 0,
    SuccessfulContactCount INT DEFAULT 0,

    -- Payment Tracking
    TotalAmountCollected DECIMAL(18,2) DEFAULT 0,
    LastCollectionDate DATETIME NULL,
    LastCollectionAmount DECIMAL(18,2) NULL,

    -- PTP Tracking
    ActivePTPCount INT DEFAULT 0,
    TotalPTPsMade INT DEFAULT 0,
    PTPsKept INT DEFAULT 0,
    PTPsBroken INT DEFAULT 0,
    PTPSuccessRate AS (
        CASE
            WHEN TotalPTPsMade > 0 THEN
                CAST(PTPsKept AS DECIMAL(5,2)) / TotalPTPsMade * 100
            ELSE 0
        END
    ) PERSISTED,

    -- Field Visit
    FieldVisitRequired BIT DEFAULT 0,
    TotalFieldVisits INT DEFAULT 0,
    LastFieldVisitDate DATETIME NULL,

    -- Legal Status
    IsLegalActionInitiated BIT DEFAULT 0,
    LegalActionDate DATETIME NULL,
    LegalCaseNumber NVARCHAR(100) NULL,

    -- Closure Information
    ResolutionType NVARCHAR(50) NULL, -- FullPayment, Settlement, WrittenOff, Legal
    ClosureDate DATETIME NULL,
    ClosureRemarks NVARCHAR(MAX) NULL,

    -- Metadata
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    CreatedBy BIGINT NULL,
    ModifiedDate DATETIME NULL,
    ModifiedBy BIGINT NULL,

    CONSTRAINT FK_Case_Customer FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT FK_Case_Loan FOREIGN KEY (LoanAccountID) REFERENCES LoanAccounts(LoanAccountID),
    CONSTRAINT CK_CaseStatus CHECK (CaseStatus IN (
        'New', 'InProgress', 'Contacted', 'PTPActive', 'PartialRecovery',
        'FullRecovery', 'PTPBroken', 'NoContact', 'FieldVisit', 'FieldContacted',
        'FieldNoContact', 'LegalAction', 'Dispute', 'UnderReview', 'Resolved',
        'RefusedToPay', 'WrittenOff', 'Closed', 'Abandoned', 'TransferredLegal'
    )),
    CONSTRAINT CK_Priority CHECK (CasePriority IN ('Critical', 'High', 'Medium', 'Low')),
    CONSTRAINT CK_PriorityScore CHECK (PriorityScore BETWEEN 0 AND 100)
);

CREATE INDEX IDX_Case_Number ON CollectionCases(CaseNumber);
CREATE INDEX IDX_Case_Customer ON CollectionCases(CustomerID);
CREATE INDEX IDX_Case_Loan ON CollectionCases(LoanAccountID);
CREATE INDEX IDX_Case_Status ON CollectionCases(CaseStatus);
CREATE INDEX IDX_Case_AssignedUser ON CollectionCases(AssignedToUserID);
CREATE INDEX IDX_Case_DPDBucket ON CollectionCases(DPDBucket);
CREATE INDEX IDX_Case_Priority ON CollectionCases(CasePriority);
CREATE INDEX IDX_Case_SLA ON CollectionCases(SLADueDate, IsSLABreached);
GO

-- =============================================
-- 4. CASE STATUS HISTORY TABLE
-- =============================================
CREATE TABLE CaseStatusHistory (
    StatusHistoryID BIGINT IDENTITY(1,1) PRIMARY KEY,
    CaseID BIGINT NOT NULL,

    PreviousStatus NVARCHAR(50) NULL,
    NewStatus NVARCHAR(50) NOT NULL,
    StatusChangeReason NVARCHAR(500) NULL,

    PreviousDPDBucket NVARCHAR(20) NULL,
    NewDPDBucket NVARCHAR(20) NULL,

    ChangedByUserID BIGINT NULL,
    ChangedDate DATETIME DEFAULT GETDATE(),
    Remarks NVARCHAR(MAX) NULL,

    CONSTRAINT FK_StatusHistory_Case FOREIGN KEY (CaseID) REFERENCES CollectionCases(CaseID)
);

CREATE INDEX IDX_StatusHistory_Case ON CaseStatusHistory(CaseID);
CREATE INDEX IDX_StatusHistory_Date ON CaseStatusHistory(ChangedDate);
GO

-- =============================================
-- 5. DPD BUCKET CONFIGURATION TABLE
-- =============================================
CREATE TABLE DPDBucketConfiguration (
    BucketID INT IDENTITY(1,1) PRIMARY KEY,
    BucketName NVARCHAR(20) NOT NULL UNIQUE,
    BucketDisplayName NVARCHAR(100) NOT NULL,

    MinDPD INT NOT NULL,
    MaxDPD INT NOT NULL,

    ProductType NVARCHAR(100) NULL, -- NULL means applicable to all products
    LineOfBusiness NVARCHAR(100) NULL,

    DefaultStrategyID BIGINT NULL,
    SLAHours INT DEFAULT 24,

    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    CreatedBy BIGINT NULL,
    ModifiedDate DATETIME NULL,
    ModifiedBy BIGINT NULL,

    CONSTRAINT CK_Bucket_DPD CHECK (MinDPD >= 0 AND MaxDPD >= MinDPD)
);

CREATE INDEX IDX_Bucket_DPD_Range ON DPDBucketConfiguration(MinDPD, MaxDPD);
GO

-- Insert default bucket configurations
INSERT INTO DPDBucketConfiguration (BucketName, BucketDisplayName, MinDPD, MaxDPD, SLAHours)
VALUES
    ('Bucket-1', '0-30 DPD', 0, 30, 24),
    ('Bucket-2', '31-60 DPD', 31, 60, 12),
    ('Bucket-3', '61-90 DPD', 61, 90, 8),
    ('Bucket-4', '91-180 DPD', 91, 180, 6),
    ('Bucket-5', '181-365 DPD', 181, 365, 4),
    ('Bucket-6', '365+ DPD', 366, 9999, 2);
GO
