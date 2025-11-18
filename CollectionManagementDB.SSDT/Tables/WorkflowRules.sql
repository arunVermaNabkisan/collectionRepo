-- =============================================
-- 3. WORKFLOW RULES TABLE
-- =============================================
CREATE TABLE WorkflowRules (
    RuleID BIGINT IDENTITY(1,1) PRIMARY KEY,
    RuleCode NVARCHAR(50) NOT NULL UNIQUE,
    RuleName NVARCHAR(200) NOT NULL,
    RuleDescription NVARCHAR(1000) NULL,

    -- Rule Type
    RuleType NVARCHAR(50) NOT NULL,
    -- CaseAssignment, Communication, Escalation, PTP, Payment, FieldVisit

    -- Trigger Conditions
    TriggerEvent NVARCHAR(100) NOT NULL,
    -- CaseCreated, StatusChanged, PaymentReceived, PTPBroken, DPDThreshold, etc.

    TriggerConditionsJSON NVARCHAR(MAX) NOT NULL, -- JSON format for complex conditions

    -- Actions
    ActionsJSON NVARCHAR(MAX) NOT NULL, -- JSON format for actions to execute

    -- Execution Settings
    ExecutionOrder INT DEFAULT 1, -- Order of execution when multiple rules apply
    ExecutionFrequency NVARCHAR(50) DEFAULT 'Once',
    -- Once, Daily, Weekly, OnEvent

    -- Filters
    ApplicableProductTypes NVARCHAR(500) NULL,
    ApplicableBuckets NVARCHAR(200) NULL,
    ApplicableTeams NVARCHAR(500) NULL,

    -- Status
    IsActive BIT DEFAULT 1,
    EffectiveFromDate DATETIME DEFAULT GETDATE(),
    EffectiveToDate DATETIME NULL,

    -- Performance Tracking
    TotalExecutions BIGINT DEFAULT 0,
    SuccessfulExecutions BIGINT DEFAULT 0,
    FailedExecutions BIGINT DEFAULT 0,
    LastExecutionDateTime DATETIME NULL,

    CreatedDate DATETIME DEFAULT GETDATE(),
    CreatedBy BIGINT NULL,
    ModifiedDate DATETIME NULL,
    ModifiedBy BIGINT NULL
);

CREATE INDEX IDX_Rule_Code ON WorkflowRules(RuleCode);
CREATE INDEX IDX_Rule_Type ON WorkflowRules(RuleType);
CREATE INDEX IDX_Rule_Active ON WorkflowRules(IsActive);
GO
