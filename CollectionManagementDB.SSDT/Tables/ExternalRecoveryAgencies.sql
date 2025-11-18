-- =============================================
-- 4. EXTERNAL RECOVERY AGENCIES TABLE
-- =============================================
CREATE TABLE ExternalRecoveryAgencies (
    AgencyID BIGINT IDENTITY(1,1) PRIMARY KEY,
    AgencyCode NVARCHAR(50) NOT NULL UNIQUE,
    AgencyName NVARCHAR(200) NOT NULL,

    -- Contact Information
    ContactPersonName NVARCHAR(200) NOT NULL,
    ContactEmail NVARCHAR(255) NOT NULL,
    ContactMobile NVARCHAR(15) NOT NULL,
    OfficeAddress NVARCHAR(500) NULL,
    City NVARCHAR(100) NULL,
    State NVARCHAR(100) NULL,
    Pincode NVARCHAR(10) NULL,

    -- Business Details
    RegistrationNumber NVARCHAR(100) NULL,
    GSTNumber NVARCHAR(20) NULL,
    PANNumber NVARCHAR(20) NULL,

    -- Contract Information
    ContractStartDate DATE NULL,
    ContractEndDate DATE NULL,
    CommissionPercentage DECIMAL(5,2) DEFAULT 0,
    PerformanceBondAmount DECIMAL(18,2) DEFAULT 0,

    -- Service Areas
    GeographicCoverage NVARCHAR(500) NULL, -- Comma-separated states/regions
    ProductTypes NVARCHAR(500) NULL, -- Comma-separated product types
    MinDPD INT DEFAULT 90,
    MaxDPD INT DEFAULT 365,

    -- Performance Metrics
    TotalCasesAssigned INT DEFAULT 0,
    TotalAmountCollected DECIMAL(18,2) DEFAULT 0,
    CollectionEfficiency DECIMAL(5,2) DEFAULT 0,
    QualityScore DECIMAL(5,2) DEFAULT 0,

    -- Compliance
    LastAuditDate DATE NULL,
    NextAuditDate DATE NULL,
    ComplianceStatus NVARCHAR(50) DEFAULT 'Active',

    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    CreatedBy BIGINT NULL,
    ModifiedDate DATETIME NULL,
    ModifiedBy BIGINT NULL
);

CREATE INDEX IDX_Agency_Code ON ExternalRecoveryAgencies(AgencyCode);
CREATE INDEX IDX_Agency_Active ON ExternalRecoveryAgencies(IsActive);
GO
