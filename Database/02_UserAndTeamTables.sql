-- =============================================
-- Collection Management System - User and Team Tables
-- Purpose: User Management, Teams, Roles, and Hierarchy
-- =============================================

USE CollectionManagementDB;
GO

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

-- Insert default roles
INSERT INTO Roles (RoleName, RoleDescription, RoleLevel, CanViewAllCases, CanReassignCases, CanAccessReports)
VALUES
    ('System Admin', 'System Administrator with full access', 1, 1, 1, 1),
    ('CXO', 'Chief Executive Officer / Senior Management', 2, 1, 1, 1),
    ('Vertical Head', 'Business Line Vertical Head', 3, 1, 1, 1),
    ('Team Leader', 'First-line manager / Supervisor', 4, 1, 1, 1),
    ('Relationship Manager', 'Collection Agent / RM', 5, 0, 0, 0),
    ('External Recovery Executive', 'External Agency Executive', 5, 0, 0, 0),
    ('Quality Analyst', 'Quality Assurance Analyst', 4, 1, 0, 1),
    ('MIS Analyst', 'Reporting and Analytics', 4, 1, 0, 1);
GO

-- =============================================
-- 2. TEAMS TABLE
-- =============================================
CREATE TABLE Teams (
    TeamID BIGINT IDENTITY(1,1) PRIMARY KEY,
    TeamCode NVARCHAR(50) NOT NULL UNIQUE,
    TeamName NVARCHAR(200) NOT NULL,
    TeamDescription NVARCHAR(500) NULL,

    -- Hierarchy
    TeamLeadUserID BIGINT NULL,
    SupervisorUserID BIGINT NULL,
    VerticalHeadUserID BIGINT NULL,
    ParentTeamID BIGINT NULL,

    -- Team Classification
    TeamType NVARCHAR(50) NOT NULL, -- Internal, External, Special
    LineOfBusiness NVARCHAR(100) NULL,
    GeographicRegion NVARCHAR(100) NULL,
    ProductFocus NVARCHAR(100) NULL,

    -- Team Capacity
    MaxTeamSize INT DEFAULT 10,
    CurrentTeamSize INT DEFAULT 0,
    MaxCaseLoad INT DEFAULT 1000,
    CurrentCaseLoad INT DEFAULT 0,

    -- Performance Targets
    MonthlyCollectionTarget DECIMAL(18,2) DEFAULT 0,
    QuarterlyCollectionTarget DECIMAL(18,2) DEFAULT 0,

    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    CreatedBy BIGINT NULL,
    ModifiedDate DATETIME NULL,
    ModifiedBy BIGINT NULL,

    CONSTRAINT FK_Team_Parent FOREIGN KEY (ParentTeamID) REFERENCES Teams(TeamID),
    CONSTRAINT CK_TeamType CHECK (TeamType IN ('Internal', 'External', 'Special'))
);

CREATE INDEX IDX_Team_Code ON Teams(TeamCode);
CREATE INDEX IDX_Team_Leader ON Teams(TeamLeadUserID);
CREATE INDEX IDX_Team_Type ON Teams(TeamType);
GO

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

-- =============================================
-- 5. USER SESSION LOGS TABLE
-- =============================================
CREATE TABLE UserSessionLogs (
    SessionLogID BIGINT IDENTITY(1,1) PRIMARY KEY,
    UserID BIGINT NOT NULL,

    LoginTime DATETIME DEFAULT GETDATE(),
    LogoutTime DATETIME NULL,
    SessionDuration AS (DATEDIFF(MINUTE, LoginTime, LogoutTime)) PERSISTED,

    LoginIP NVARCHAR(50) NULL,
    DeviceType NVARCHAR(50) NULL, -- Desktop, Mobile, Tablet
    Browser NVARCHAR(100) NULL,
    OperatingSystem NVARCHAR(100) NULL,

    LoginStatus NVARCHAR(50) DEFAULT 'Success',
    LogoutReason NVARCHAR(100) NULL,

    CONSTRAINT FK_SessionLog_User FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

CREATE INDEX IDX_SessionLog_User ON UserSessionLogs(UserID);
CREATE INDEX IDX_SessionLog_LoginTime ON UserSessionLogs(LoginTime);
GO

-- =============================================
-- 6. TEAM MEMBER HISTORY TABLE
-- =============================================
CREATE TABLE TeamMemberHistory (
    HistoryID BIGINT IDENTITY(1,1) PRIMARY KEY,
    UserID BIGINT NOT NULL,
    TeamID BIGINT NOT NULL,

    AssignmentDate DATETIME NOT NULL,
    RemovalDate DATETIME NULL,
    RemovalReason NVARCHAR(500) NULL,

    AssignedByUserID BIGINT NULL,
    RemovedByUserID BIGINT NULL,

    CONSTRAINT FK_TeamHistory_User FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT FK_TeamHistory_Team FOREIGN KEY (TeamID) REFERENCES Teams(TeamID)
);

CREATE INDEX IDX_TeamHistory_User ON TeamMemberHistory(UserID);
CREATE INDEX IDX_TeamHistory_Team ON TeamMemberHistory(TeamID);
GO

-- =============================================
-- 7. USER PERFORMANCE METRICS TABLE
-- =============================================
CREATE TABLE UserPerformanceMetrics (
    MetricID BIGINT IDENTITY(1,1) PRIMARY KEY,
    UserID BIGINT NOT NULL,

    -- Time Period
    MetricDate DATE NOT NULL,
    MetricPeriod NVARCHAR(20) NOT NULL, -- Daily, Weekly, Monthly, Quarterly

    -- Activity Metrics
    TotalCasesWorked INT DEFAULT 0,
    TotalCallAttempts INT DEFAULT 0,
    SuccessfulCalls INT DEFAULT 0,
    RightPartyContactRate DECIMAL(5,2) DEFAULT 0,

    -- Collection Metrics
    TotalAmountCollected DECIMAL(18,2) DEFAULT 0,
    NumberOfRecoveries INT DEFAULT 0,
    AverageRecoveryAmount DECIMAL(18,2) DEFAULT 0,

    -- PTP Metrics
    PTPsCreated INT DEFAULT 0,
    PTPsKept INT DEFAULT 0,
    PTPSuccessRate DECIMAL(5,2) DEFAULT 0,

    -- Field Visit Metrics
    FieldVisitsConducted INT DEFAULT 0,
    SuccessfulFieldVisits INT DEFAULT 0,

    -- Quality Metrics
    QualityScore DECIMAL(5,2) DEFAULT 0,
    ComplianceScore DECIMAL(5,2) DEFAULT 0,
    CustomerSatisfactionScore DECIMAL(5,2) DEFAULT 0,

    -- Time Metrics
    TotalWorkingHours DECIMAL(10,2) DEFAULT 0,
    AverageTalkTime INT DEFAULT 0, -- in seconds
    AverageHandlingTime INT DEFAULT 0, -- in seconds

    -- Target Achievement
    CollectionTarget DECIMAL(18,2) DEFAULT 0,
    TargetAchievementPercentage DECIMAL(5,2) DEFAULT 0,

    CreatedDate DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_Performance_User FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT CK_MetricPeriod CHECK (MetricPeriod IN ('Daily', 'Weekly', 'Monthly', 'Quarterly', 'Yearly'))
);

CREATE INDEX IDX_Performance_User ON UserPerformanceMetrics(UserID);
CREATE INDEX IDX_Performance_Date ON UserPerformanceMetrics(MetricDate);
CREATE INDEX IDX_Performance_Period ON UserPerformanceMetrics(MetricPeriod);
CREATE UNIQUE INDEX UX_Performance_User_Date_Period ON UserPerformanceMetrics(UserID, MetricDate, MetricPeriod);
GO
