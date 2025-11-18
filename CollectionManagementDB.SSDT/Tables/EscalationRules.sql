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
