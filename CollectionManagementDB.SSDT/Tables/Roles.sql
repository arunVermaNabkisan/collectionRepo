-- =============================================
-- 1. ROLES TABLE
-- =============================================
CREATE TABLE Roles (
    RoleID INT IDENTITY(1,1) PRIMARY KEY,
    RoleName NVARCHAR(100) NOT NULL UNIQUE,
    RoleDescription NVARCHAR(500) NULL,
    RoleLevel INT NOT NULL, -- Hierarchy level (1=Highest, 5=Lowest)

    -- Permissions (can be expanded)
    CanViewAllCases BIT DEFAULT 0,
    CanReassignCases BIT DEFAULT 0,
    CanModifyStrategies BIT DEFAULT 0,
    CanApproveSettlements BIT DEFAULT 0,
    CanAccessReports BIT DEFAULT 0,
    CanManageUsers BIT DEFAULT 0,

    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    CreatedBy BIGINT NULL,
    ModifiedDate DATETIME NULL,
    ModifiedBy BIGINT NULL
);
GO
