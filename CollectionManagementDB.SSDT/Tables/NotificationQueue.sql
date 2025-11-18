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
