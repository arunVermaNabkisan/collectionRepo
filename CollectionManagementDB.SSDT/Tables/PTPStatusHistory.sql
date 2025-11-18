-- =============================================
-- 2. PTP STATUS HISTORY TABLE
-- =============================================
CREATE TABLE PTPStatusHistory (
    HistoryID BIGINT IDENTITY(1,1) PRIMARY KEY,
    PTPID BIGINT NOT NULL,

    PreviousStatus NVARCHAR(50) NULL,
    NewStatus NVARCHAR(50) NOT NULL,
    StatusChangeReason NVARCHAR(500) NULL,

    ChangedByUserID BIGINT NULL,
    ChangedDate DATETIME DEFAULT GETDATE(),
    Remarks NVARCHAR(MAX) NULL,

    CONSTRAINT FK_PTPHistory_PTP FOREIGN KEY (PTPID) REFERENCES PromiseToPay(PTPID),
    CONSTRAINT FK_PTPHistory_User FOREIGN KEY (ChangedByUserID) REFERENCES Users(UserID)
);

CREATE INDEX IDX_PTPHistory_PTP ON PTPStatusHistory(PTPID);
CREATE INDEX IDX_PTPHistory_Date ON PTPStatusHistory(ChangedDate);
GO
