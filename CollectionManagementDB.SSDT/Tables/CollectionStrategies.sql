-- =============================================
-- 1. COLLECTION STRATEGIES TABLE
-- =============================================
CREATE TABLE CollectionStrategies (
    StrategyID BIGINT IDENTITY(1,1) PRIMARY KEY,
    StrategyCode NVARCHAR(50) NOT NULL UNIQUE,
    StrategyName NVARCHAR(200) NOT NULL,
    StrategyDescription NVARCHAR(1000) NULL,

    -- Strategy Classification
    StrategyType NVARCHAR(50) NOT NULL,
    -- Supportive, Balanced, Intensive, Aggressive, Legal
    StrategyApproach NVARCHAR(50) NOT NULL,
    -- Soft, Standard, Firm, Legal

    -- Applicability Criteria
    MinDPD INT DEFAULT 0,
    MaxDPD INT DEFAULT 365,
    MinOutstanding DECIMAL(18,2) DEFAULT 0,
    MaxOutstanding DECIMAL(18,2) DEFAULT 999999999,

    ProductTypes NVARCHAR(500) NULL, -- Comma-separated
    LineOfBusiness NVARCHAR(500) NULL,

    RiskCategories NVARCHAR(200) NULL, -- Low, Medium, High, Very High
    CustomerSegments NVARCHAR(200) NULL,

    -- Contact Parameters
    MaxContactAttemptsPerDay INT DEFAULT 3,
    MaxContactAttemptsTotal INT DEFAULT 30,
    PreferredContactChannels NVARCHAR(200) NULL, -- Voice, SMS, Email, WhatsApp
    ContactTimeWindows NVARCHAR(500) NULL, -- JSON format

    -- PTP Parameters
    AllowPTP BIT DEFAULT 1,
    MinPTPAmount DECIMAL(18,2) DEFAULT 0,
    MaxPTPDays INT DEFAULT 7,
    AllowSplitPTP BIT DEFAULT 1,
    MaxSplitParts INT DEFAULT 3,

    -- Field Visit Parameters
    TriggerFieldVisit BIT DEFAULT 0,
    FieldVisitTriggerDays INT DEFAULT 30,
    FieldVisitPriority NVARCHAR(20) DEFAULT 'Medium',

    -- Escalation Rules
    EscalationEnabled BIT DEFAULT 1,
    EscalationDays INT DEFAULT 7,
    EscalationLevel INT DEFAULT 1,

    -- Settlement Parameters
    AllowSettlement BIT DEFAULT 0,
    MinSettlementPercentage DECIMAL(5,2) DEFAULT 80,
    MaxDiscountPercentage DECIMAL(5,2) DEFAULT 20,
    SettlementApprovalRequired BIT DEFAULT 1,

    -- Legal Action
    TriggerLegalAction BIT DEFAULT 0,
    LegalActionTriggerDPD INT DEFAULT 90,

    -- SLA
    ResponseSLAHours INT DEFAULT 24,
    ResolutionSLADays INT DEFAULT 7,

    -- Priority Settings
    DefaultPriority NVARCHAR(20) DEFAULT 'Medium',
    PriorityBoostFactor DECIMAL(5,2) DEFAULT 1.0,

    -- Performance Metrics
    TargetContactRate DECIMAL(5,2) DEFAULT 70,
    TargetResolutionRate DECIMAL(5,2) DEFAULT 50,
    TargetPTPConversion DECIMAL(5,2) DEFAULT 30,

    -- Workflow Automation
    AutomationEnabled BIT DEFAULT 1,
    AutomationRulesJSON NVARCHAR(MAX) NULL, -- JSON configuration

    IsActive BIT DEFAULT 1,
    EffectiveFromDate DATE DEFAULT GETDATE(),
    EffectiveToDate DATE NULL,

    CreatedDate DATETIME DEFAULT GETDATE(),
    CreatedBy BIGINT NULL,
    ModifiedDate DATETIME NULL,
    ModifiedBy BIGINT NULL,

    CONSTRAINT CK_Strategy_Type CHECK (StrategyType IN ('Supportive', 'Balanced', 'Intensive', 'Aggressive', 'Legal'))
);

CREATE INDEX IDX_Strategy_Code ON CollectionStrategies(StrategyCode);
CREATE INDEX IDX_Strategy_Type ON CollectionStrategies(StrategyType);
CREATE INDEX IDX_Strategy_DPD ON CollectionStrategies(MinDPD, MaxDPD);
GO
