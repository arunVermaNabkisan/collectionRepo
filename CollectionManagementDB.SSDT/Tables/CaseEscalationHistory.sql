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
