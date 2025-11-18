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
