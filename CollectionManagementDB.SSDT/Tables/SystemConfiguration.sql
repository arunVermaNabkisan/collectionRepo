-- =============================================
-- 4. SYSTEM CONFIGURATION TABLE
-- =============================================
CREATE TABLE SystemConfiguration (
    ConfigID INT IDENTITY(1,1) PRIMARY KEY,
    ConfigKey NVARCHAR(100) NOT NULL UNIQUE,
    ConfigValue NVARCHAR(MAX) NOT NULL,
    ConfigDataType NVARCHAR(50) NOT NULL, -- String, Integer, Decimal, Boolean, JSON
    ConfigCategory NVARCHAR(100) NOT NULL,
    -- System, Integration, Communication, Collection, Security

    ConfigDescription NVARCHAR(1000) NULL,
    DefaultValue NVARCHAR(MAX) NULL,

    IsEncrypted BIT DEFAULT 0,
    IsSensitive BIT DEFAULT 0,
    IsEditable BIT DEFAULT 1,

    LastModifiedDate DATETIME NULL,
    LastModifiedBy BIGINT NULL,

    EffectiveFromDate DATETIME DEFAULT GETDATE(),
    EffectiveToDate DATETIME NULL,

    IsActive BIT DEFAULT 1
);

CREATE INDEX IDX_Config_Key ON SystemConfiguration(ConfigKey);
CREATE INDEX IDX_Config_Category ON SystemConfiguration(ConfigCategory);
GO
