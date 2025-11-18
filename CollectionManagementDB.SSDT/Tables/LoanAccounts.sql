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
