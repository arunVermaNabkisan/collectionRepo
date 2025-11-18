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
