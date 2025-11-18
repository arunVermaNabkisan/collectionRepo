-- =============================================
-- 4. CASE STATUS HISTORY TABLE
-- =============================================
CREATE TABLE CaseStatusHistory (
    StatusHistoryID BIGINT IDENTITY(1,1) PRIMARY KEY,
    CaseID BIGINT NOT NULL,

    PreviousStatus NVARCHAR(50) NULL,
    NewStatus NVARCHAR(50) NOT NULL,
    StatusChangeReason NVARCHAR(500) NULL,

    PreviousDPDBucket NVARCHAR(20) NULL,
    NewDPDBucket NVARCHAR(20) NULL,

    ChangedByUserID BIGINT NULL,
    ChangedDate DATETIME DEFAULT GETDATE(),
    Remarks NVARCHAR(MAX) NULL,

    CONSTRAINT FK_StatusHistory_Case FOREIGN KEY (CaseID) REFERENCES CollectionCases(CaseID)
);

CREATE INDEX IDX_StatusHistory_Case ON CaseStatusHistory(CaseID);
CREATE INDEX IDX_StatusHistory_Date ON CaseStatusHistory(ChangedDate);
GO
