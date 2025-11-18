-- =============================================
-- 7. ERROR LOG TABLE
-- =============================================
CREATE TABLE ErrorLog (
    ErrorLogID BIGINT IDENTITY(1,1) PRIMARY KEY,
    ErrorDateTime DATETIME DEFAULT GETDATE(),

    -- Error Classification
    ErrorLevel NVARCHAR(20) NOT NULL, -- Info, Warning, Error, Critical
    ErrorCategory NVARCHAR(100) NOT NULL,
    -- Application, Database, Integration, Payment, Communication

    ErrorCode NVARCHAR(50) NULL,
    ErrorMessage NVARCHAR(MAX) NOT NULL,
    ErrorStackTrace NVARCHAR(MAX) NULL,

    -- Context
    ApplicationModule NVARCHAR(100) NULL,
    FunctionName NVARCHAR(200) NULL,
    UserID BIGINT NULL,
    SessionID NVARCHAR(200) NULL,

    -- Entity Context
    EntityType NVARCHAR(100) NULL,
    EntityID BIGINT NULL,
    RelatedCaseID BIGINT NULL,

    -- Request Details
    RequestURL NVARCHAR(1000) NULL,
    RequestMethod NVARCHAR(20) NULL,
    RequestPayload NVARCHAR(MAX) NULL,
    ResponseCode INT NULL,

    -- Environment
    ServerName NVARCHAR(200) NULL,
    IPAddress NVARCHAR(50) NULL,
    Environment NVARCHAR(50) DEFAULT 'Production',
    -- Development, Testing, Staging, Production

    -- Resolution
    IsResolved BIT DEFAULT 0,
    ResolvedDate DATETIME NULL,
    ResolvedByUserID BIGINT NULL,
    ResolutionNotes NVARCHAR(MAX) NULL,

    -- Notification
    IsNotificationSent BIT DEFAULT 0,
    NotificationSentTo NVARCHAR(500) NULL,

    AdditionalDataJSON NVARCHAR(MAX) NULL,

    CONSTRAINT CK_Error_Level CHECK (ErrorLevel IN ('Info', 'Warning', 'Error', 'Critical'))
);

CREATE INDEX IDX_ErrorLog_DateTime ON ErrorLog(ErrorDateTime);
CREATE INDEX IDX_ErrorLog_Level ON ErrorLog(ErrorLevel);
CREATE INDEX IDX_ErrorLog_Category ON ErrorLog(ErrorCategory);
CREATE INDEX IDX_ErrorLog_Resolved ON ErrorLog(IsResolved);
GO
