-- =============================================
-- 6. COMMUNICATION TEMPLATES TABLE
-- =============================================
CREATE TABLE CommunicationTemplates (
    TemplateID BIGINT IDENTITY(1,1) PRIMARY KEY,
    TemplateCode NVARCHAR(50) NOT NULL UNIQUE,
    TemplateName NVARCHAR(200) NOT NULL,

    -- Template Details
    TemplateType NVARCHAR(50) NOT NULL, -- SMS, Email, WhatsApp, Voice
    TemplateCategory NVARCHAR(100) NOT NULL, -- Reminder, PTP, Legal, Thank You, etc.

    TemplateContent NVARCHAR(MAX) NOT NULL,
    TemplateSubject NVARCHAR(500) NULL, -- For emails

    -- Template Variables
    VariablesList NVARCHAR(MAX) NULL, -- JSON array of variables
    SampleContent NVARCHAR(MAX) NULL,

    -- Language
    Language NVARCHAR(50) DEFAULT 'English',

    -- DPD Bucket Association
    ApplicableBuckets NVARCHAR(200) NULL, -- Comma-separated bucket names

    -- Approval and Compliance
    ApprovalStatus NVARCHAR(50) DEFAULT 'Draft',
    -- Draft, Pending, Approved, Rejected, Expired
    ApprovedByUserID BIGINT NULL,
    ApprovedDate DATETIME NULL,
    ExpiryDate DATETIME NULL,

    -- WhatsApp Specific
    WhatsAppTemplateID NVARCHAR(200) NULL, -- Template ID from WhatsApp
    WhatsAppStatus NVARCHAR(50) NULL, -- APPROVED, REJECTED, PENDING

    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    CreatedBy BIGINT NULL,
    ModifiedDate DATETIME NULL,
    ModifiedBy BIGINT NULL
);

CREATE INDEX IDX_Template_Code ON CommunicationTemplates(TemplateCode);
CREATE INDEX IDX_Template_Type ON CommunicationTemplates(TemplateType);
CREATE INDEX IDX_Template_Status ON CommunicationTemplates(ApprovalStatus);
GO
