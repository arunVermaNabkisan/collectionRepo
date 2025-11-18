-- =============================================
-- Collection Management System - Strategy and Workflow Tables
-- Purpose: Collection Strategies, Rules, and Automation
-- =============================================

USE CollectionManagementDB;
GO

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

-- =============================================
-- 2. CASE STRATEGY ASSIGNMENT TABLE
-- =============================================
CREATE TABLE CaseStrategyAssignment (
    AssignmentID BIGINT IDENTITY(1,1) PRIMARY KEY,
    CaseID BIGINT NOT NULL,
    StrategyID BIGINT NOT NULL,

    AssignedDate DATETIME DEFAULT GETDATE(),
    AssignedByUserID BIGINT NULL,
    AssignmentReason NVARCHAR(500) NULL,

    IsActive BIT DEFAULT 1,
    DeactivatedDate DATETIME NULL,
    DeactivatedReason NVARCHAR(500) NULL,

    -- Strategy Performance for this case
    ContactAttempts INT DEFAULT 0,
    SuccessfulContacts INT DEFAULT 0,
    PTPsCreated INT DEFAULT 0,
    PaymentsReceived INT DEFAULT 0,
    AmountCollected DECIMAL(18,2) DEFAULT 0,

    StrategyEffectiveness AS (
        CASE
            WHEN ContactAttempts > 0 THEN
                CAST(SuccessfulContacts AS DECIMAL(5,2)) / ContactAttempts * 100
            ELSE 0
        END
    ) PERSISTED,

    CONSTRAINT FK_CaseStrategy_Case FOREIGN KEY (CaseID) REFERENCES CollectionCases(CaseID),
    CONSTRAINT FK_CaseStrategy_Strategy FOREIGN KEY (StrategyID) REFERENCES CollectionStrategies(StrategyID)
);

CREATE INDEX IDX_CaseStrategy_Case ON CaseStrategyAssignment(CaseID);
CREATE INDEX IDX_CaseStrategy_Strategy ON CaseStrategyAssignment(StrategyID);
CREATE INDEX IDX_CaseStrategy_Active ON CaseStrategyAssignment(IsActive);
GO

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

-- =============================================
-- 4. WORKFLOW EXECUTION LOG TABLE
-- =============================================
CREATE TABLE WorkflowExecutionLog (
    ExecutionLogID BIGINT IDENTITY(1,1) PRIMARY KEY,
    RuleID BIGINT NOT NULL,
    CaseID BIGINT NULL,
    CustomerID BIGINT NULL,

    ExecutionDateTime DATETIME DEFAULT GETDATE(),
    ExecutionStatus NVARCHAR(50) NOT NULL, -- Success, Failed, Skipped
    ExecutionDuration INT DEFAULT 0, -- in milliseconds

    TriggerEvent NVARCHAR(100) NOT NULL,
    TriggerData NVARCHAR(MAX) NULL, -- JSON format

    ActionsExecuted NVARCHAR(MAX) NULL, -- JSON array of actions
    ExecutionResult NVARCHAR(MAX) NULL, -- JSON format

    ErrorMessage NVARCHAR(MAX) NULL,
    ErrorStackTrace NVARCHAR(MAX) NULL,

    CONSTRAINT FK_WorkflowLog_Rule FOREIGN KEY (RuleID) REFERENCES WorkflowRules(RuleID)
);

CREATE INDEX IDX_WorkflowLog_Rule ON WorkflowExecutionLog(RuleID);
CREATE INDEX IDX_WorkflowLog_Case ON WorkflowExecutionLog(CaseID);
CREATE INDEX IDX_WorkflowLog_DateTime ON WorkflowExecutionLog(ExecutionDateTime);
CREATE INDEX IDX_WorkflowLog_Status ON WorkflowExecutionLog(ExecutionStatus);
GO

-- =============================================
-- 5. ESCALATION RULES TABLE
-- =============================================
CREATE TABLE EscalationRules (
    EscalationRuleID BIGINT IDENTITY(1,1) PRIMARY KEY,
    RuleCode NVARCHAR(50) NOT NULL UNIQUE,
    RuleName NVARCHAR(200) NOT NULL,
    RuleDescription NVARCHAR(1000) NULL,

    -- Escalation Type
    EscalationType NVARCHAR(50) NOT NULL,
    -- Horizontal, Vertical, Functional
    EscalationLevel INT NOT NULL, -- L1, L2, L3, L4

    -- Trigger Conditions
    TriggerType NVARCHAR(100) NOT NULL,
    -- SLABreach, NoContact, MultiplePTPBreaches, HighValue, LegalThreshold

    DPDThreshold INT NULL,
    OutstandingThreshold DECIMAL(18,2) NULL,
    NoContactDays INT NULL,
    BrokenPTPCount INT NULL,
    NoPaymentDays INT NULL,

    -- Source and Target
    SourceRoleID INT NULL,
    TargetRoleID INT NOT NULL,
    TargetTeamID BIGINT NULL,
    TargetUserID BIGINT NULL, -- Specific user or NULL for role-based

    -- Actions
    NotifyTarget BIT DEFAULT 1,
    NotifySource BIT DEFAULT 1,
    NotifyManagement BIT DEFAULT 0,
    ChangeStrategy BIT DEFAULT 0,
    NewStrategyID BIGINT NULL,

    -- Communication
    NotificationTemplateID BIGINT NULL,
    NotificationChannels NVARCHAR(200) NULL, -- Email, SMS, System

    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    CreatedBy BIGINT NULL,
    ModifiedDate DATETIME NULL,
    ModifiedBy BIGINT NULL,

    CONSTRAINT FK_Escalation_SourceRole FOREIGN KEY (SourceRoleID) REFERENCES Roles(RoleID),
    CONSTRAINT FK_Escalation_TargetRole FOREIGN KEY (TargetRoleID) REFERENCES Roles(RoleID),
    CONSTRAINT FK_Escalation_TargetTeam FOREIGN KEY (TargetTeamID) REFERENCES Teams(TeamID),
    CONSTRAINT FK_Escalation_Strategy FOREIGN KEY (NewStrategyID) REFERENCES CollectionStrategies(StrategyID)
);

CREATE INDEX IDX_Escalation_Code ON EscalationRules(RuleCode);
CREATE INDEX IDX_Escalation_Level ON EscalationRules(EscalationLevel);
CREATE INDEX IDX_Escalation_Active ON EscalationRules(IsActive);
GO

-- =============================================
-- 6. CASE ESCALATION HISTORY TABLE
-- =============================================
CREATE TABLE CaseEscalationHistory (
    EscalationHistoryID BIGINT IDENTITY(1,1) PRIMARY KEY,
    CaseID BIGINT NOT NULL,
    EscalationRuleID BIGINT NULL,

    EscalationType NVARCHAR(50) NOT NULL,
    EscalationLevel INT NOT NULL,

    EscalatedFromUserID BIGINT NULL,
    EscalatedToUserID BIGINT NULL,
    EscalatedFromTeamID BIGINT NULL,
    EscalatedToTeamID BIGINT NULL,

    EscalationDate DATETIME DEFAULT GETDATE(),
    EscalationReason NVARCHAR(1000) NULL,

    ResolutionStatus NVARCHAR(50) DEFAULT 'Open',
    -- Open, InProgress, Resolved, Rejected
    ResolutionDate DATETIME NULL,
    ResolutionRemarks NVARCHAR(MAX) NULL,

    ActionTaken NVARCHAR(MAX) NULL,
    Outcome NVARCHAR(MAX) NULL,

    CONSTRAINT FK_CaseEscalation_Case FOREIGN KEY (CaseID) REFERENCES CollectionCases(CaseID),
    CONSTRAINT FK_CaseEscalation_Rule FOREIGN KEY (EscalationRuleID) REFERENCES EscalationRules(EscalationRuleID)
);

CREATE INDEX IDX_CaseEscalation_Case ON CaseEscalationHistory(CaseID);
CREATE INDEX IDX_CaseEscalation_Date ON CaseEscalationHistory(EscalationDate);
CREATE INDEX IDX_CaseEscalation_Status ON CaseEscalationHistory(ResolutionStatus);
GO

-- =============================================
-- 7. BEHAVIORAL SCORING RULES TABLE
-- =============================================
CREATE TABLE BehavioralScoringRules (
    ScoringRuleID BIGINT IDENTITY(1,1) PRIMARY KEY,
    RuleCode NVARCHAR(50) NOT NULL UNIQUE,
    RuleName NVARCHAR(200) NOT NULL,
    RuleDescription NVARCHAR(1000) NULL,

    -- Parameter Details
    ParameterName NVARCHAR(100) NOT NULL,
    ParameterCategory NVARCHAR(100) NOT NULL,
    -- PaymentBehavior, Communication, PTP, Demographic, Bureau

    -- Scoring Logic
    ScoreCalculationMethod NVARCHAR(50) NOT NULL,
    -- Direct, Range, Lookup, Formula

    MinValue DECIMAL(18,2) NULL,
    MaxValue DECIMAL(18,2) NULL,
    MinScore INT DEFAULT 0,
    MaxScore INT DEFAULT 100,

    ScoreFormula NVARCHAR(500) NULL,
    LookupValuesJSON NVARCHAR(MAX) NULL, -- JSON for lookup tables

    -- Weighting
    WeightPercentage DECIMAL(5,2) NOT NULL, -- Contribution to total score
    IsMandatory BIT DEFAULT 0,

    -- Impact
    ImpactDirection NVARCHAR(20) NOT NULL, -- Positive, Negative
    -- Positive: Higher value = Better score
    -- Negative: Higher value = Worse score

    IsActive BIT DEFAULT 1,
    EffectiveFromDate DATE DEFAULT GETDATE(),
    EffectiveToDate DATE NULL,

    CreatedDate DATETIME DEFAULT GETDATE(),
    CreatedBy BIGINT NULL,
    ModifiedDate DATETIME NULL,
    ModifiedBy BIGINT NULL
);

CREATE INDEX IDX_Scoring_Code ON BehavioralScoringRules(RuleCode);
CREATE INDEX IDX_Scoring_Category ON BehavioralScoringRules(ParameterCategory);
CREATE INDEX IDX_Scoring_Active ON BehavioralScoringRules(IsActive);
GO

-- =============================================
-- 8. CUSTOMER BEHAVIORAL SCORES TABLE
-- =============================================
CREATE TABLE CustomerBehavioralScores (
    ScoreID BIGINT IDENTITY(1,1) PRIMARY KEY,
    CustomerID BIGINT NOT NULL,
    LoanAccountID BIGINT NULL,
    CaseID BIGINT NULL,

    -- Score Details
    ScoreDate DATE DEFAULT GETDATE(),
    TotalScore INT NOT NULL,
    ScoreGrade NVARCHAR(10) NULL, -- A, B, C, D, E
    RiskCategory NVARCHAR(50) NOT NULL, -- Low, Medium, High, Very High

    -- Component Scores
    PaymentBehaviorScore INT DEFAULT 0,
    CommunicationScore INT DEFAULT 0,
    PTPPerformanceScore INT DEFAULT 0,
    DemographicScore INT DEFAULT 0,
    BureauScore INT DEFAULT 0,
    HistoricalScore INT DEFAULT 0,

    -- Score Breakdown JSON
    DetailedScoreBreakdown NVARCHAR(MAX) NULL, -- JSON format

    -- Probability Metrics
    ProbabilityOfPayment DECIMAL(5,2) DEFAULT 0,
    ProbabilityOfDefault DECIMAL(5,2) DEFAULT 0,
    ExpectedRecoveryRate DECIMAL(5,2) DEFAULT 0,

    -- Comparison
    PreviousScore INT NULL,
    ScoreChange AS (TotalScore - ISNULL(PreviousScore, TotalScore)) PERSISTED,
    ScoreTrend NVARCHAR(20) NULL, -- Improving, Stable, Declining

    -- Model Information
    ScoringModelVersion NVARCHAR(50) DEFAULT '1.0',
    CalculationMethod NVARCHAR(50) DEFAULT 'RuleBased',
    -- RuleBased, MLModel, Hybrid

    CalculatedDate DATETIME DEFAULT GETDATE(),
    NextRecalculationDate DATETIME NULL,

    CONSTRAINT FK_BehavioralScore_Customer FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT FK_BehavioralScore_Loan FOREIGN KEY (LoanAccountID) REFERENCES LoanAccounts(LoanAccountID),
    CONSTRAINT FK_BehavioralScore_Case FOREIGN KEY (CaseID) REFERENCES CollectionCases(CaseID),
    CONSTRAINT CK_TotalScore CHECK (TotalScore BETWEEN 0 AND 1000),
    CONSTRAINT CK_RiskCategory CHECK (RiskCategory IN ('Low', 'Medium', 'High', 'Very High'))
);

CREATE INDEX IDX_BehavScore_Customer ON CustomerBehavioralScores(CustomerID);
CREATE INDEX IDX_BehavScore_Loan ON CustomerBehavioralScores(LoanAccountID);
CREATE INDEX IDX_BehavScore_Case ON CustomerBehavioralScores(CaseID);
CREATE INDEX IDX_BehavScore_Date ON CustomerBehavioralScores(ScoreDate);
CREATE INDEX IDX_BehavScore_Risk ON CustomerBehavioralScores(RiskCategory);
GO
