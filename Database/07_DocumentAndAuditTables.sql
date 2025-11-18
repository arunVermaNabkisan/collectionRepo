-- =============================================
-- Collection Management System - Document and Audit Tables
-- Purpose: Document Management, Audit Trails, and Compliance
-- =============================================

USE CollectionManagementDB;
GO

-- =============================================
-- 1. DOCUMENTS TABLE
-- =============================================
CREATE TABLE Documents (
    DocumentID BIGINT IDENTITY(1,1) PRIMARY KEY,
    DocumentNumber NVARCHAR(50) NOT NULL UNIQUE,

    -- Document Classification
    DocumentType NVARCHAR(100) NOT NULL,
    -- LegalNotice, DemandLetter, SettlementAgreement, PaymentReceipt,
    -- FieldVisitReport, CustomerCorrespondence, KYCDocument, etc.

    DocumentCategory NVARCHAR(100) NOT NULL,
    -- Legal, Payment, Collection, Compliance, Customer, Internal

    DocumentSubType NVARCHAR(100) NULL,

    -- Links
    CustomerID BIGINT NULL,
    LoanAccountID BIGINT NULL,
    CaseID BIGINT NULL,
    InteractionID BIGINT NULL,
    FieldVisitID BIGINT NULL,
    PaymentTransactionID BIGINT NULL,
    SettlementID BIGINT NULL,

    -- Document Details
    DocumentName NVARCHAR(500) NOT NULL,
    DocumentDescription NVARCHAR(1000) NULL,

    -- File Details
    FileName NVARCHAR(500) NOT NULL,
    FilePath NVARCHAR(1000) NOT NULL,
    FileSize BIGINT DEFAULT 0, -- in bytes
    FileType NVARCHAR(50) NOT NULL, -- pdf, docx, jpg, png, etc.
    MimeType NVARCHAR(100) NOT NULL,

    -- Version Control
    DocumentVersion NVARCHAR(20) DEFAULT '1.0',
    ParentDocumentID BIGINT NULL, -- For versioning
    IsLatestVersion BIT DEFAULT 1,

    -- Storage Details
    StorageLocation NVARCHAR(100) NOT NULL, -- Local, Cloud, DMS
    StorageProvider NVARCHAR(100) NULL, -- AWS S3, Azure Blob, etc.
    StoragePath NVARCHAR(1000) NULL,
    CloudURL NVARCHAR(1000) NULL,

    -- Security
    IsEncrypted BIT DEFAULT 0,
    EncryptionMethod NVARCHAR(100) NULL,
    FileHash NVARCHAR(500) NULL, -- SHA-256
    AccessLevel NVARCHAR(50) DEFAULT 'Internal',
    -- Public, Internal, Confidential, Restricted

    -- Digital Signature
    IsDigitallySigned BIT DEFAULT 0,
    SignedByUserID BIGINT NULL,
    SignedDate DATETIME NULL,
    DigitalSignature NVARCHAR(MAX) NULL,
    CertificateDetails NVARCHAR(MAX) NULL,

    -- Metadata
    Tags NVARCHAR(500) NULL, -- Comma-separated tags
    MetadataJSON NVARCHAR(MAX) NULL, -- Additional metadata in JSON format

    -- Approval Workflow
    RequiresApproval BIT DEFAULT 0,
    ApprovalStatus NVARCHAR(50) DEFAULT 'Draft',
    -- Draft, PendingApproval, Approved, Rejected
    ApprovedByUserID BIGINT NULL,
    ApprovedDate DATETIME NULL,
    RejectionReason NVARCHAR(500) NULL,

    -- Lifecycle
    DocumentStatus NVARCHAR(50) DEFAULT 'Active',
    -- Draft, Active, Archived, Deleted, Expired
    ExpiryDate DATETIME NULL,
    ArchiveDate DATETIME NULL,
    DeletionDate DATETIME NULL,
    RetentionPeriodYears INT DEFAULT 7,

    -- Access Tracking
    ViewCount INT DEFAULT 0,
    DownloadCount INT DEFAULT 0,
    LastAccessedDate DATETIME NULL,
    LastAccessedByUserID BIGINT NULL,

    -- Compliance
    IsRegulatoryDocument BIT DEFAULT 0,
    RegulatoryReference NVARCHAR(200) NULL,
    ComplianceNotes NVARCHAR(MAX) NULL,

    -- Upload Details
    UploadedByUserID BIGINT NOT NULL,
    UploadedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL,
    ModifiedBy BIGINT NULL,

    Remarks NVARCHAR(MAX) NULL,

    CONSTRAINT FK_Document_Customer FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT FK_Document_Loan FOREIGN KEY (LoanAccountID) REFERENCES LoanAccounts(LoanAccountID),
    CONSTRAINT FK_Document_Case FOREIGN KEY (CaseID) REFERENCES CollectionCases(CaseID),
    CONSTRAINT FK_Document_Parent FOREIGN KEY (ParentDocumentID) REFERENCES Documents(DocumentID),
    CONSTRAINT FK_Document_Uploader FOREIGN KEY (UploadedByUserID) REFERENCES Users(UserID),
    CONSTRAINT CK_Document_Status CHECK (DocumentStatus IN ('Draft', 'Active', 'Archived', 'Deleted', 'Expired')),
    CONSTRAINT CK_Document_ApprovalStatus CHECK (ApprovalStatus IN ('Draft', 'PendingApproval', 'Approved', 'Rejected'))
);

CREATE INDEX IDX_Document_Number ON Documents(DocumentNumber);
CREATE INDEX IDX_Document_Type ON Documents(DocumentType);
CREATE INDEX IDX_Document_Customer ON Documents(CustomerID);
CREATE INDEX IDX_Document_Loan ON Documents(LoanAccountID);
CREATE INDEX IDX_Document_Case ON Documents(CaseID);
CREATE INDEX IDX_Document_Status ON Documents(DocumentStatus);
CREATE INDEX IDX_Document_Upload ON Documents(UploadedDate);
GO

-- =============================================
-- 2. DOCUMENT ACCESS LOG TABLE
-- =============================================
CREATE TABLE DocumentAccessLog (
    AccessLogID BIGINT IDENTITY(1,1) PRIMARY KEY,
    DocumentID BIGINT NOT NULL,
    AccessedByUserID BIGINT NOT NULL,

    AccessType NVARCHAR(50) NOT NULL, -- View, Download, Print, Share, Delete
    AccessDateTime DATETIME DEFAULT GETDATE(),

    IPAddress NVARCHAR(50) NULL,
    DeviceType NVARCHAR(50) NULL,
    Browser NVARCHAR(100) NULL,
    Location NVARCHAR(200) NULL,

    AccessDuration INT DEFAULT 0, -- in seconds
    IsSuccessful BIT DEFAULT 1,
    FailureReason NVARCHAR(500) NULL,

    CONSTRAINT FK_DocAccess_Document FOREIGN KEY (DocumentID) REFERENCES Documents(DocumentID),
    CONSTRAINT FK_DocAccess_User FOREIGN KEY (AccessedByUserID) REFERENCES Users(UserID)
);

CREATE INDEX IDX_DocAccess_Document ON DocumentAccessLog(DocumentID);
CREATE INDEX IDX_DocAccess_User ON DocumentAccessLog(AccessedByUserID);
CREATE INDEX IDX_DocAccess_DateTime ON DocumentAccessLog(AccessDateTime);
GO

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

-- =============================================
-- 4. SYSTEM CONFIGURATION TABLE
-- =============================================
CREATE TABLE SystemConfiguration (
    ConfigID INT IDENTITY(1,1) PRIMARY KEY,
    ConfigKey NVARCHAR(100) NOT NULL UNIQUE,
    ConfigValue NVARCHAR(MAX) NOT NULL,
    ConfigDataType NVARCHAR(50) NOT NULL, -- String, Integer, Decimal, Boolean, JSON
    ConfigCategory NVARCHAR(100) NOT NULL,
    -- System, Integration, Communication, Collection, Security

    ConfigDescription NVARCHAR(1000) NULL,
    DefaultValue NVARCHAR(MAX) NULL,

    IsEncrypted BIT DEFAULT 0,
    IsSensitive BIT DEFAULT 0,
    IsEditable BIT DEFAULT 1,

    LastModifiedDate DATETIME NULL,
    LastModifiedBy BIGINT NULL,

    EffectiveFromDate DATETIME DEFAULT GETDATE(),
    EffectiveToDate DATETIME NULL,

    IsActive BIT DEFAULT 1
);

CREATE INDEX IDX_Config_Key ON SystemConfiguration(ConfigKey);
CREATE INDEX IDX_Config_Category ON SystemConfiguration(ConfigCategory);
GO

-- Insert default system configurations
INSERT INTO SystemConfiguration (ConfigKey, ConfigValue, ConfigDataType, ConfigCategory, ConfigDescription)
VALUES
    ('MaxLoginAttempts', '5', 'Integer', 'Security', 'Maximum failed login attempts before account lockout'),
    ('SessionTimeoutMinutes', '30', 'Integer', 'Security', 'Session timeout in minutes'),
    ('PasswordExpiryDays', '90', 'Integer', 'Security', 'Password expiry period in days'),
    ('MaxCaseLoadPerRM', '100', 'Integer', 'Collection', 'Maximum case load per Relationship Manager'),
    ('DefaultDPDBucketRefreshHours', '6', 'Integer', 'Collection', 'DPD bucket recalculation frequency'),
    ('MaxDailyContactAttempts', '3', 'Integer', 'Collection', 'Maximum contact attempts per customer per day'),
    ('PaymentLinkExpiryHours', '48', 'Integer', 'Payment', 'Payment link validity period'),
    ('FieldVisitGeoFenceRadius', '50', 'Integer', 'FieldVisit', 'Geo-fence radius in meters for check-in'),
    ('SMSGatewayURL', 'https://sms.gateway.example.com', 'String', 'Integration', 'SMS Gateway API URL'),
    ('EnableAutomatedWorkflows', 'true', 'Boolean', 'System', 'Enable/disable automated workflows');
GO

-- =============================================
-- 5. COMPLIANCE CHECKLIST TABLE
-- =============================================
CREATE TABLE ComplianceChecklist (
    ChecklistID BIGINT IDENTITY(1,1) PRIMARY KEY,
    CaseID BIGINT NOT NULL,

    -- Checklist Details
    ComplianceCategory NVARCHAR(100) NOT NULL,
    -- FairPractices, RBIGuidelines, DataProtection, Documentation

    CheckpointName NVARCHAR(200) NOT NULL,
    CheckpointDescription NVARCHAR(1000) NULL,
    MandatoryFlag BIT DEFAULT 1,

    -- Status
    ComplianceStatus NVARCHAR(50) NOT NULL,
    -- Compliant, NonCompliant, PartiallyCompliant, NotApplicable, Pending

    VerifiedByUserID BIGINT NULL,
    VerifiedDate DATETIME NULL,

    -- Evidence
    EvidenceDocumentID BIGINT NULL,
    EvidenceNotes NVARCHAR(MAX) NULL,

    -- Remediation
    RequiresRemediation BIT DEFAULT 0,
    RemediationPlan NVARCHAR(MAX) NULL,
    RemediationDeadline DATETIME NULL,
    RemediationStatus NVARCHAR(50) NULL,

    Remarks NVARCHAR(MAX) NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_Compliance_Case FOREIGN KEY (CaseID) REFERENCES CollectionCases(CaseID),
    CONSTRAINT FK_Compliance_Evidence FOREIGN KEY (EvidenceDocumentID) REFERENCES Documents(DocumentID),
    CONSTRAINT CK_Compliance_Status CHECK (ComplianceStatus IN (
        'Compliant', 'NonCompliant', 'PartiallyCompliant', 'NotApplicable', 'Pending'
    ))
);

CREATE INDEX IDX_Compliance_Case ON ComplianceChecklist(CaseID);
CREATE INDEX IDX_Compliance_Category ON ComplianceChecklist(ComplianceCategory);
CREATE INDEX IDX_Compliance_Status ON ComplianceChecklist(ComplianceStatus);
GO

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

-- =============================================
-- 8. NOTIFICATION QUEUE TABLE
-- =============================================
CREATE TABLE NotificationQueue (
    NotificationID BIGINT IDENTITY(1,1) PRIMARY KEY,
    NotificationReference NVARCHAR(100) NOT NULL UNIQUE,

    -- Recipient
    UserID BIGINT NULL,
    RecipientEmail NVARCHAR(255) NULL,
    RecipientMobile NVARCHAR(15) NULL,

    -- Notification Details
    NotificationType NVARCHAR(50) NOT NULL,
    -- Email, SMS, Push, InApp, System
    NotificationCategory NVARCHAR(100) NOT NULL,
    -- Alert, Reminder, Approval, Information, Error

    Subject NVARCHAR(500) NULL,
    MessageBody NVARCHAR(MAX) NOT NULL,
    Priority NVARCHAR(20) DEFAULT 'Normal',
    -- Low, Normal, High, Critical

    -- Related Entities
    CaseID BIGINT NULL,
    CustomerID BIGINT NULL,
    PaymentTransactionID BIGINT NULL,

    -- Schedule
    ScheduledDateTime DATETIME DEFAULT GETDATE(),
    ExpiryDateTime DATETIME NULL,

    -- Status
    NotificationStatus NVARCHAR(50) NOT NULL,
    -- Queued, Sent, Delivered, Failed, Expired, Cancelled
    SentDateTime DATETIME NULL,
    DeliveredDateTime DATETIME NULL,
    FailureReason NVARCHAR(500) NULL,

    -- Retry Management
    RetryCount INT DEFAULT 0,
    MaxRetries INT DEFAULT 3,
    NextRetryDateTime DATETIME NULL,

    -- Tracking
    IsRead BIT DEFAULT 0,
    ReadDateTime DATETIME NULL,
    IsActioned BIT DEFAULT 0,
    ActionDateTime DATETIME NULL,
    ActionType NVARCHAR(100) NULL,

    -- Template
    TemplateID BIGINT NULL,
    TemplateData NVARCHAR(MAX) NULL, -- JSON format

    CreatedDate DATETIME DEFAULT GETDATE(),
    CreatedBy BIGINT NULL,

    CONSTRAINT FK_Notification_User FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT CK_Notification_Status CHECK (NotificationStatus IN (
        'Queued', 'Sent', 'Delivered', 'Failed', 'Expired', 'Cancelled'
    ))
);

CREATE INDEX IDX_Notification_Reference ON NotificationQueue(NotificationReference);
CREATE INDEX IDX_Notification_User ON NotificationQueue(UserID);
CREATE INDEX IDX_Notification_Status ON NotificationQueue(NotificationStatus);
CREATE INDEX IDX_Notification_Scheduled ON NotificationQueue(ScheduledDateTime);
CREATE INDEX IDX_Notification_Retry ON NotificationQueue(NextRetryDateTime);
GO
