-- =============================================
-- Collection Management System - Communication Tables
-- Purpose: Multi-channel Communication Management
-- =============================================

USE CollectionManagementDB;
GO

-- =============================================
-- 1. CUSTOMER INTERACTIONS TABLE
-- =============================================
CREATE TABLE CustomerInteractions (
    InteractionID BIGINT IDENTITY(1,1) PRIMARY KEY,
    InteractionReference NVARCHAR(100) NOT NULL UNIQUE,

    -- Links
    CaseID BIGINT NOT NULL,
    CustomerID BIGINT NOT NULL,
    LoanAccountID BIGINT NOT NULL,
    InitiatedByUserID BIGINT NULL,

    -- Interaction Details
    InteractionChannel NVARCHAR(50) NOT NULL, -- Voice, SMS, Email, WhatsApp, FieldVisit
    InteractionDirection NVARCHAR(20) NOT NULL, -- Outbound, Inbound
    InteractionType NVARCHAR(100) NOT NULL, -- Reminder, Follow-up, PTP, Payment, Dispute, etc.

    InteractionDateTime DATETIME DEFAULT GETDATE(),
    InteractionDuration INT DEFAULT 0, -- in seconds

    -- Contact Result
    ContactStatus NVARCHAR(50) NOT NULL,
    -- ContactSuccess, NoAnswer, Busy, InvalidNumber, Disconnected,
    -- CustomerNotAvailable, Callback, etc.

    DispositionCode NVARCHAR(100) NULL,
    SubDispositionCode NVARCHAR(100) NULL,

    -- Customer Response
    CustomerResponse NVARCHAR(MAX) NULL,
    CustomerSentiment NVARCHAR(50) NULL, -- Positive, Negative, Neutral, Angry, Cooperative
    IsRightPartyContact BIT DEFAULT 0,

    -- Outcome
    InteractionOutcome NVARCHAR(100) NULL,
    -- PTPCreated, PaymentPromised, PaymentMade, Dispute, Refusal,
    -- CallbackRequested, InformationUpdated, NoResponse, etc.

    PTPCreated BIT DEFAULT 0,
    PaymentMade BIT DEFAULT 0,
    DisputeRaised BIT DEFAULT 0,
    CallbackRequested BIT DEFAULT 0,
    CallbackDateTime DATETIME NULL,

    -- Notes and Remarks
    AgentNotes NVARCHAR(MAX) NULL,
    SystemNotes NVARCHAR(MAX) NULL,

    -- Quality and Compliance
    IsRecorded BIT DEFAULT 0,
    RecordingURL NVARCHAR(500) NULL,
    RecordingDuration INT DEFAULT 0,
    QualityScore DECIMAL(5,2) NULL,
    ComplianceScore DECIMAL(5,2) NULL,
    IsReviewed BIT DEFAULT 0,
    ReviewedByUserID BIGINT NULL,
    ReviewedDate DATETIME NULL,

    -- Follow-up
    RequiresFollowUp BIT DEFAULT 0,
    FollowUpDate DATETIME NULL,
    FollowUpAssignedTo BIGINT NULL,

    CreatedDate DATETIME DEFAULT GETDATE(),
    CreatedBy BIGINT NULL,

    CONSTRAINT FK_Interaction_Case FOREIGN KEY (CaseID) REFERENCES CollectionCases(CaseID),
    CONSTRAINT FK_Interaction_Customer FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT FK_Interaction_Loan FOREIGN KEY (LoanAccountID) REFERENCES LoanAccounts(LoanAccountID),
    CONSTRAINT FK_Interaction_User FOREIGN KEY (InitiatedByUserID) REFERENCES Users(UserID),
    CONSTRAINT CK_InteractionChannel CHECK (InteractionChannel IN ('Voice', 'SMS', 'Email', 'WhatsApp', 'FieldVisit', 'WebChat', 'IVR')),
    CONSTRAINT CK_InteractionDirection CHECK (InteractionDirection IN ('Outbound', 'Inbound'))
);

CREATE INDEX IDX_Interaction_Case ON CustomerInteractions(CaseID);
CREATE INDEX IDX_Interaction_Customer ON CustomerInteractions(CustomerID);
CREATE INDEX IDX_Interaction_Date ON CustomerInteractions(InteractionDateTime);
CREATE INDEX IDX_Interaction_Channel ON CustomerInteractions(InteractionChannel);
CREATE INDEX IDX_Interaction_User ON CustomerInteractions(InitiatedByUserID);
CREATE INDEX IDX_Interaction_Outcome ON CustomerInteractions(InteractionOutcome);
GO

-- =============================================
-- 2. VOICE CALL LOGS TABLE
-- =============================================
CREATE TABLE VoiceCallLogs (
    CallLogID BIGINT IDENTITY(1,1) PRIMARY KEY,
    InteractionID BIGINT NOT NULL,

    -- Call Identification
    CallID NVARCHAR(100) NULL, -- From telephony system
    SessionID NVARCHAR(100) NULL,

    -- Call Details
    CallerNumber NVARCHAR(15) NOT NULL,
    RecipientNumber NVARCHAR(15) NOT NULL,
    CallDirection NVARCHAR(20) NOT NULL, -- Outbound, Inbound

    CallStartTime DATETIME NOT NULL,
    CallEndTime DATETIME NULL,
    CallDuration INT DEFAULT 0, -- in seconds
    TalkTime INT DEFAULT 0, -- actual conversation time
    HoldTime INT DEFAULT 0,

    -- Call Status
    CallStatus NVARCHAR(50) NOT NULL,
    -- Answered, NotAnswered, Busy, Failed, Rejected, VoiceMail, etc.

    HangupReason NVARCHAR(100) NULL,
    HangupParty NVARCHAR(50) NULL, -- Customer, Agent, System

    -- Agent Details
    AgentUserID BIGINT NULL,
    AgentExtension NVARCHAR(20) NULL,

    -- Recording
    IsRecorded BIT DEFAULT 0,
    RecordingPath NVARCHAR(500) NULL,
    RecordingFileSize BIGINT DEFAULT 0,

    -- VOIP Details
    VoIPProvider NVARCHAR(100) NULL,
    CallQuality DECIMAL(5,2) NULL, -- MOS Score
    Latency INT DEFAULT 0, -- in milliseconds
    PacketLoss DECIMAL(5,2) DEFAULT 0,

    -- Cost
    CallCost DECIMAL(10,4) DEFAULT 0,
    Currency NVARCHAR(10) DEFAULT 'INR',

    CreatedDate DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_CallLog_Interaction FOREIGN KEY (InteractionID) REFERENCES CustomerInteractions(InteractionID),
    CONSTRAINT FK_CallLog_Agent FOREIGN KEY (AgentUserID) REFERENCES Users(UserID)
);

CREATE INDEX IDX_CallLog_Interaction ON VoiceCallLogs(InteractionID);
CREATE INDEX IDX_CallLog_CallID ON VoiceCallLogs(CallID);
CREATE INDEX IDX_CallLog_StartTime ON VoiceCallLogs(CallStartTime);
CREATE INDEX IDX_CallLog_Agent ON VoiceCallLogs(AgentUserID);
GO

-- =============================================
-- 3. SMS LOGS TABLE
-- =============================================
CREATE TABLE SMSLogs (
    SMSLogID BIGINT IDENTITY(1,1) PRIMARY KEY,
    InteractionID BIGINT NULL,
    CaseID BIGINT NULL,
    CustomerID BIGINT NULL,

    -- SMS Details
    MessageID NVARCHAR(100) NULL, -- From SMS gateway
    SenderID NVARCHAR(20) NOT NULL, -- Sender name/number
    RecipientNumber NVARCHAR(15) NOT NULL,

    MessageContent NVARCHAR(1000) NOT NULL,
    MessageType NVARCHAR(50) NOT NULL, -- Transactional, Promotional, OTP
    TemplateID NVARCHAR(100) NULL,

    -- Sending Details
    SentDateTime DATETIME DEFAULT GETDATE(),
    ScheduledDateTime DATETIME NULL,
    SentByUserID BIGINT NULL,

    -- Delivery Status
    DeliveryStatus NVARCHAR(50) NOT NULL,
    -- Sent, Delivered, Failed, Expired, Rejected
    DeliveryDateTime DATETIME NULL,
    FailureReason NVARCHAR(500) NULL,

    -- Gateway Details
    SMSGateway NVARCHAR(100) NULL,
    MessageParts INT DEFAULT 1, -- Number of SMS parts
    DLRStatus NVARCHAR(100) NULL, -- Delivery Report Status
    DLRReceivedDateTime DATETIME NULL,

    -- Cost
    SMSCost DECIMAL(10,4) DEFAULT 0,
    Currency NVARCHAR(10) DEFAULT 'INR',

    -- Campaign
    CampaignID BIGINT NULL,
    CampaignName NVARCHAR(200) NULL,

    CreatedDate DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_SMSLog_Interaction FOREIGN KEY (InteractionID) REFERENCES CustomerInteractions(InteractionID),
    CONSTRAINT FK_SMSLog_Case FOREIGN KEY (CaseID) REFERENCES CollectionCases(CaseID),
    CONSTRAINT FK_SMSLog_Customer FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE INDEX IDX_SMSLog_Interaction ON SMSLogs(InteractionID);
CREATE INDEX IDX_SMSLog_MessageID ON SMSLogs(MessageID);
CREATE INDEX IDX_SMSLog_Recipient ON SMSLogs(RecipientNumber);
CREATE INDEX IDX_SMSLog_Status ON SMSLogs(DeliveryStatus);
CREATE INDEX IDX_SMSLog_Date ON SMSLogs(SentDateTime);
GO

-- =============================================
-- 4. EMAIL LOGS TABLE
-- =============================================
CREATE TABLE EmailLogs (
    EmailLogID BIGINT IDENTITY(1,1) PRIMARY KEY,
    InteractionID BIGINT NULL,
    CaseID BIGINT NULL,
    CustomerID BIGINT NULL,

    -- Email Details
    MessageID NVARCHAR(200) NULL, -- Email message ID
    FromEmail NVARCHAR(255) NOT NULL,
    ToEmail NVARCHAR(255) NOT NULL,
    CCEmail NVARCHAR(1000) NULL,
    BCCEmail NVARCHAR(1000) NULL,

    Subject NVARCHAR(500) NOT NULL,
    EmailBody NVARCHAR(MAX) NOT NULL,
    IsHTML BIT DEFAULT 1,

    TemplateID NVARCHAR(100) NULL,
    TemplateName NVARCHAR(200) NULL,

    -- Attachments
    HasAttachments BIT DEFAULT 0,
    AttachmentCount INT DEFAULT 0,
    AttachmentPaths NVARCHAR(MAX) NULL,
    TotalAttachmentSize BIGINT DEFAULT 0,

    -- Sending Details
    SentDateTime DATETIME DEFAULT GETDATE(),
    ScheduledDateTime DATETIME NULL,
    SentByUserID BIGINT NULL,

    -- Delivery and Engagement Status
    DeliveryStatus NVARCHAR(50) NOT NULL,
    -- Sent, Delivered, Bounced, Deferred, Failed
    BounceType NVARCHAR(50) NULL, -- Hard, Soft
    BounceReason NVARCHAR(500) NULL,

    IsOpened BIT DEFAULT 0,
    OpenedDateTime DATETIME NULL,
    OpenCount INT DEFAULT 0,

    IsClicked BIT DEFAULT 0,
    ClickedDateTime DATETIME NULL,
    ClickCount INT DEFAULT 0,
    ClickedLinks NVARCHAR(MAX) NULL,

    IsUnsubscribed BIT DEFAULT 0,
    UnsubscribedDateTime DATETIME NULL,

    IsSpamReported BIT DEFAULT 0,
    SpamReportedDateTime DATETIME NULL,

    -- Email Service Details
    EmailServiceProvider NVARCHAR(100) NULL,
    EmailPriority NVARCHAR(20) DEFAULT 'Normal',

    -- Campaign
    CampaignID BIGINT NULL,
    CampaignName NVARCHAR(200) NULL,

    CreatedDate DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_EmailLog_Interaction FOREIGN KEY (InteractionID) REFERENCES CustomerInteractions(InteractionID),
    CONSTRAINT FK_EmailLog_Case FOREIGN KEY (CaseID) REFERENCES CollectionCases(CaseID),
    CONSTRAINT FK_EmailLog_Customer FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE INDEX IDX_EmailLog_Interaction ON EmailLogs(InteractionID);
CREATE INDEX IDX_EmailLog_MessageID ON EmailLogs(MessageID);
CREATE INDEX IDX_EmailLog_To ON EmailLogs(ToEmail);
CREATE INDEX IDX_EmailLog_Status ON EmailLogs(DeliveryStatus);
CREATE INDEX IDX_EmailLog_Date ON EmailLogs(SentDateTime);
GO

-- =============================================
-- 5. WHATSAPP LOGS TABLE
-- =============================================
CREATE TABLE WhatsAppLogs (
    WhatsAppLogID BIGINT IDENTITY(1,1) PRIMARY KEY,
    InteractionID BIGINT NULL,
    CaseID BIGINT NULL,
    CustomerID BIGINT NULL,

    -- WhatsApp Details
    MessageID NVARCHAR(200) NULL, -- WhatsApp message ID
    ConversationID NVARCHAR(200) NULL,
    SenderNumber NVARCHAR(15) NOT NULL,
    RecipientNumber NVARCHAR(15) NOT NULL,

    MessageType NVARCHAR(50) NOT NULL, -- Text, Image, Document, Template, Interactive
    MessageContent NVARCHAR(4000) NULL,
    MediaURL NVARCHAR(500) NULL,
    MediaType NVARCHAR(50) NULL, -- image, video, document, audio

    -- Template Details (for template messages)
    TemplateID NVARCHAR(100) NULL,
    TemplateName NVARCHAR(200) NULL,
    TemplateLanguage NVARCHAR(20) DEFAULT 'en',
    TemplateParameters NVARCHAR(MAX) NULL, -- JSON format

    -- Message Direction
    MessageDirection NVARCHAR(20) NOT NULL, -- Outbound, Inbound

    -- Sending Details
    SentDateTime DATETIME DEFAULT GETDATE(),
    SentByUserID BIGINT NULL,

    -- Delivery Status
    DeliveryStatus NVARCHAR(50) NOT NULL,
    -- Sent, Delivered, Read, Failed, Deleted
    DeliveredDateTime DATETIME NULL,
    ReadDateTime DATETIME NULL,
    FailureReason NVARCHAR(500) NULL,

    -- Session Details
    IsSessionMessage BIT DEFAULT 0, -- Within 24-hour window
    SessionExpiryDateTime DATETIME NULL,

    -- Interactive Message Details
    HasButtons BIT DEFAULT 0,
    ButtonsClicked NVARCHAR(500) NULL,
    HasList BIT DEFAULT 0,
    ListItemSelected NVARCHAR(200) NULL,

    -- WhatsApp Business API Details
    WABANumber NVARCHAR(15) NULL,
    APIProvider NVARCHAR(100) NULL,

    -- Cost
    MessageCost DECIMAL(10,4) DEFAULT 0,
    Currency NVARCHAR(10) DEFAULT 'INR',
    ConversationCategory NVARCHAR(50) NULL, -- Marketing, Utility, Authentication, Service

    -- Campaign
    CampaignID BIGINT NULL,
    CampaignName NVARCHAR(200) NULL,

    CreatedDate DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_WhatsAppLog_Interaction FOREIGN KEY (InteractionID) REFERENCES CustomerInteractions(InteractionID),
    CONSTRAINT FK_WhatsAppLog_Case FOREIGN KEY (CaseID) REFERENCES CollectionCases(CaseID),
    CONSTRAINT FK_WhatsAppLog_Customer FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE INDEX IDX_WhatsAppLog_Interaction ON WhatsAppLogs(InteractionID);
CREATE INDEX IDX_WhatsAppLog_MessageID ON WhatsAppLogs(MessageID);
CREATE INDEX IDX_WhatsAppLog_Recipient ON WhatsAppLogs(RecipientNumber);
CREATE INDEX IDX_WhatsAppLog_Status ON WhatsAppLogs(DeliveryStatus);
CREATE INDEX IDX_WhatsAppLog_Date ON WhatsAppLogs(SentDateTime);
GO

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

-- =============================================
-- 7. COMMUNICATION CAMPAIGNS TABLE
-- =============================================
CREATE TABLE CommunicationCampaigns (
    CampaignID BIGINT IDENTITY(1,1) PRIMARY KEY,
    CampaignCode NVARCHAR(50) NOT NULL UNIQUE,
    CampaignName NVARCHAR(200) NOT NULL,
    CampaignDescription NVARCHAR(1000) NULL,

    -- Campaign Type
    CampaignType NVARCHAR(50) NOT NULL, -- Automated, Manual, Triggered
    Channel NVARCHAR(50) NOT NULL, -- SMS, Email, WhatsApp, Voice

    -- Template
    TemplateID BIGINT NULL,

    -- Target Criteria
    TargetDPDBuckets NVARCHAR(200) NULL,
    TargetProductTypes NVARCHAR(200) NULL,
    MinOutstanding DECIMAL(18,2) NULL,
    MaxOutstanding DECIMAL(18,2) NULL,
    TargetCustomerCount INT DEFAULT 0,

    -- Schedule
    ScheduleType NVARCHAR(50) NOT NULL, -- OneTime, Daily, Weekly, Monthly, Event-based
    StartDateTime DATETIME NULL,
    EndDateTime DATETIME NULL,
    ExecutionTime TIME NULL, -- For scheduled campaigns

    -- Execution Details
    ExecutionStatus NVARCHAR(50) DEFAULT 'Pending',
    -- Pending, InProgress, Completed, Failed, Cancelled
    LastExecutionDateTime DATETIME NULL,
    NextExecutionDateTime DATETIME NULL,

    -- Results
    TotalMessagesSent INT DEFAULT 0,
    TotalMessagesDelivered INT DEFAULT 0,
    TotalMessagesFailed INT DEFAULT 0,
    TotalOpened INT DEFAULT 0,
    TotalClicked INT DEFAULT 0,
    TotalResponses INT DEFAULT 0,

    -- Cost
    TotalCost DECIMAL(18,2) DEFAULT 0,
    BudgetAllocated DECIMAL(18,2) DEFAULT 0,

    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    CreatedBy BIGINT NULL,
    ModifiedDate DATETIME NULL,
    ModifiedBy BIGINT NULL,

    CONSTRAINT FK_Campaign_Template FOREIGN KEY (TemplateID) REFERENCES CommunicationTemplates(TemplateID)
);

CREATE INDEX IDX_Campaign_Code ON CommunicationCampaigns(CampaignCode);
CREATE INDEX IDX_Campaign_Status ON CommunicationCampaigns(ExecutionStatus);
CREATE INDEX IDX_Campaign_Next ON CommunicationCampaigns(NextExecutionDateTime);
GO
