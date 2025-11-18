-- =============================================
-- 3. USERS TABLE
-- =============================================
CREATE TABLE Users (
    UserID BIGINT IDENTITY(1,1) PRIMARY KEY,
    EmployeeCode NVARCHAR(50) NOT NULL UNIQUE,
    Username NVARCHAR(100) NOT NULL UNIQUE,

    -- Personal Information
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    FullName AS (FirstName + ' ' + LastName) PERSISTED,
    Email NVARCHAR(255) NOT NULL UNIQUE,
    MobileNumber NVARCHAR(15) NOT NULL,

    -- Role and Team
    RoleID INT NOT NULL,
    TeamID BIGINT NULL,
    ReportsToUserID BIGINT NULL,

    -- User Type
    UserType NVARCHAR(50) NOT NULL, -- Internal, External, Agency
    AgencyID BIGINT NULL, -- If external user

    -- Skills and Attributes
    PrimaryLanguage NVARCHAR(50) DEFAULT 'English',
    SecondaryLanguages NVARCHAR(200) NULL,
    GeographicZone NVARCHAR(100) NULL,
    ProductExpertise NVARCHAR(200) NULL,
    ExperienceYears DECIMAL(4,2) DEFAULT 0,

    -- Capacity and Workload
    MaxCaseCapacity INT DEFAULT 100,
    CurrentCaseLoad INT DEFAULT 0,
    IsAvailableForAllocation BIT DEFAULT 1,

    -- Performance Metrics
    MonthlyCollectionTarget DECIMAL(18,2) DEFAULT 0,
    CurrentMonthCollection DECIMAL(18,2) DEFAULT 0,
    AverageCallDuration INT DEFAULT 0, -- in seconds
    AverageResolutionTime INT DEFAULT 0, -- in hours
    QualityScore DECIMAL(5,2) DEFAULT 0, -- 0-100

    -- Authentication
    PasswordHash NVARCHAR(500) NULL,
    PasswordSalt NVARCHAR(500) NULL,
    LastPasswordChangeDate DATETIME NULL,
    MustChangePassword BIT DEFAULT 1,

    -- Security
    IsTwoFactorEnabled BIT DEFAULT 0,
    FailedLoginAttempts INT DEFAULT 0,
    IsLocked BIT DEFAULT 0,
    LockoutEndDate DATETIME NULL,
    LastLoginDate DATETIME NULL,
    LastLoginIP NVARCHAR(50) NULL,

    -- Account Status
    IsActive BIT DEFAULT 1,
    ActivationDate DATETIME NULL,
    DeactivationDate DATETIME NULL,
    DeactivationReason NVARCHAR(500) NULL,

    -- Metadata
    CreatedDate DATETIME DEFAULT GETDATE(),
    CreatedBy BIGINT NULL,
    ModifiedDate DATETIME NULL,
    ModifiedBy BIGINT NULL,

    CONSTRAINT FK_User_Role FOREIGN KEY (RoleID) REFERENCES Roles(RoleID),
    CONSTRAINT FK_User_Team FOREIGN KEY (TeamID) REFERENCES Teams(TeamID),
    CONSTRAINT FK_User_ReportsTo FOREIGN KEY (ReportsToUserID) REFERENCES Users(UserID),
    CONSTRAINT CK_UserType CHECK (UserType IN ('Internal', 'External', 'Agency', 'System'))
);

CREATE INDEX IDX_User_EmployeeCode ON Users(EmployeeCode);
CREATE INDEX IDX_User_Username ON Users(Username);
CREATE INDEX IDX_User_Email ON Users(Email);
CREATE INDEX IDX_User_Team ON Users(TeamID);
CREATE INDEX IDX_User_Role ON Users(RoleID);
CREATE INDEX IDX_User_Active ON Users(IsActive);
GO
