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
