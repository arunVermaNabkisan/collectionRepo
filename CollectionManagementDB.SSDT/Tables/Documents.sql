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
