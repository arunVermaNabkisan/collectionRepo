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
