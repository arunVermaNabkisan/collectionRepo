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
