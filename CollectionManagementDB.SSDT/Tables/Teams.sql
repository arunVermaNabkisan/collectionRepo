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
