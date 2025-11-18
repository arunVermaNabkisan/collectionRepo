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
