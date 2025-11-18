-- =============================================
-- 3. AUDIT TRAIL TABLE
-- =============================================
CREATE TABLE AuditTrail (
    AuditID BIGINT IDENTITY(1,1) PRIMARY KEY,
    AuditDateTime DATETIME DEFAULT GETDATE(),

    -- User and Session
    UserID BIGINT NULL,
    SessionID NVARCHAR(200) NULL,
    Username NVARCHAR(100) NULL,

    -- Action Details
    ActionType NVARCHAR(100) NOT NULL,
    -- Create, Update, Delete, View, Login, Logout, Approve, Reject, etc.

    EntityType NVARCHAR(100) NOT NULL,
    -- Customer, LoanAccount, Case, Payment, User, etc.

    EntityID BIGINT NULL,
    EntityReference NVARCHAR(200) NULL,

    -- Change Details
    TableName NVARCHAR(100) NULL,
    PrimaryKeyValue NVARCHAR(100) NULL,
    FieldChanged NVARCHAR(100) NULL,
    OldValue NVARCHAR(MAX) NULL,
    NewValue NVARCHAR(MAX) NULL,

    -- Complete Change Set (JSON)
    ChangeSetJSON NVARCHAR(MAX) NULL,

    -- Request Details
    IPAddress NVARCHAR(50) NULL,
    UserAgent NVARCHAR(500) NULL,
    RequestURL NVARCHAR(1000) NULL,
    RequestMethod NVARCHAR(20) NULL,

    -- Application Context
    ApplicationModule NVARCHAR(100) NULL,
    ApplicationVersion NVARCHAR(50) NULL,

    -- Result
    ActionStatus NVARCHAR(50) DEFAULT 'Success',
    -- Success, Failed, PartialSuccess
    ErrorMessage NVARCHAR(MAX) NULL,

    -- Additional Context
    Remarks NVARCHAR(MAX) NULL,
    AdditionalDataJSON NVARCHAR(MAX) NULL,

    -- Compliance
    IsRegulatoryAudit BIT DEFAULT 0,
    ComplianceCategory NVARCHAR(100) NULL
);

CREATE INDEX IDX_Audit_DateTime ON AuditTrail(AuditDateTime);
CREATE INDEX IDX_Audit_User ON AuditTrail(UserID);
CREATE INDEX IDX_Audit_Entity ON AuditTrail(EntityType, EntityID);
CREATE INDEX IDX_Audit_Action ON AuditTrail(ActionType);
CREATE INDEX IDX_Audit_Table ON AuditTrail(TableName);
GO
