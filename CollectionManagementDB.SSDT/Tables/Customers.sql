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
