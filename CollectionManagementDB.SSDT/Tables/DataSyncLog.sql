-- =============================================
-- 6. DATA SYNC LOG TABLE
-- =============================================
CREATE TABLE DataSyncLog (
    SyncLogID BIGINT IDENTITY(1,1) PRIMARY KEY,
    SyncType NVARCHAR(50) NOT NULL, -- EOD, BOD, RealTime, Manual
    SyncSource NVARCHAR(100) NOT NULL, -- LMS, PaymentGateway, Bureau, etc.
    SyncDirection NVARCHAR(20) NOT NULL, -- Import, Export, BiDirectional

    -- Sync Details
    SyncStartTime DATETIME NOT NULL,
    SyncEndTime DATETIME NULL,
    SyncDuration AS (DATEDIFF(SECOND, SyncStartTime, SyncEndTime)) PERSISTED,

    -- Status
    SyncStatus NVARCHAR(50) NOT NULL,
    -- InProgress, Completed, Failed, PartialSuccess

    -- Statistics
    TotalRecordsProcessed INT DEFAULT 0,
    SuccessfulRecords INT DEFAULT 0,
    FailedRecords INT DEFAULT 0,
    SkippedRecords INT DEFAULT 0,

    -- File Details (if file-based sync)
    SourceFileName NVARCHAR(500) NULL,
    SourceFilePath NVARCHAR(1000) NULL,
    FileSize BIGINT DEFAULT 0,

    -- Error Details
    ErrorCount INT DEFAULT 0,
    ErrorSummary NVARCHAR(MAX) NULL,
    ErrorDetailsJSON NVARCHAR(MAX) NULL,

    -- Batch Details
    BatchID NVARCHAR(100) NULL,
    BatchSequence INT DEFAULT 1,

    InitiatedBy BIGINT NULL,
    Remarks NVARCHAR(MAX) NULL,

    CONSTRAINT CK_Sync_Status CHECK (SyncStatus IN ('InProgress', 'Completed', 'Failed', 'PartialSuccess')),
    CONSTRAINT CK_Sync_Type CHECK (SyncType IN ('EOD', 'BOD', 'RealTime', 'Manual', 'Scheduled'))
);

CREATE INDEX IDX_SyncLog_Type ON DataSyncLog(SyncType);
CREATE INDEX IDX_SyncLog_Source ON DataSyncLog(SyncSource);
CREATE INDEX IDX_SyncLog_Status ON DataSyncLog(SyncStatus);
CREATE INDEX IDX_SyncLog_StartTime ON DataSyncLog(SyncStartTime);
GO
