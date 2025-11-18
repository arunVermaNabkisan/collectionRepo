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
