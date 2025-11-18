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
