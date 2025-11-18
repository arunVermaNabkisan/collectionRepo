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
