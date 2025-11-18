-- =============================================
-- 3. COLLECTION CASES TABLE
-- =============================================
CREATE TABLE CollectionCases (
    CaseID BIGINT IDENTITY(1,1) PRIMARY KEY,
    CaseNumber NVARCHAR(50) NOT NULL UNIQUE,

    -- Link to Customer and Loan
    CustomerID BIGINT NOT NULL,
    LoanAccountID BIGINT NOT NULL,

    -- Case Classification
    CurrentDPD INT NOT NULL,
    DPDBucket NVARCHAR(20) NOT NULL, -- Bucket-1, Bucket-2, etc.
    CurrentOutstandingAmount DECIMAL(18,2) NOT NULL,
    OverdueAmount DECIMAL(18,2) NOT NULL,

    -- Case Status
    CaseStatus NVARCHAR(50) NOT NULL,
    -- Status: New, InProgress, Contacted, PTPActive, PartialRecovery,
    --         FullRecovery, PTPBroken, FieldVisit, LegalAction,
    --         Dispute, WrittenOff, Closed

    CaseSubStatus NVARCHAR(100) NULL,
    CasePriority NVARCHAR(20) NOT NULL, -- Critical, High, Medium, Low
    PriorityScore INT DEFAULT 0,

    -- Assignment
    AssignedToUserID BIGINT NULL,
    AssignedToTeamID BIGINT NULL,
    AssignedDate DATETIME NULL,
    LastReassignedDate DATETIME NULL,

    -- Strategy
    CurrentStrategyID BIGINT NULL,
    StrategyAssignedDate DATETIME NULL,

    -- Risk and Behavior Scoring
    BehavioralScore INT DEFAULT 0,
    ProbabilityOfPayment DECIMAL(5,2) DEFAULT 0, -- 0-100 percentage
    RiskCategory NVARCHAR(50) NULL, -- Low, Medium, High, Very High

    -- SLA and Escalation
    SLADueDate DATETIME NULL,
    IsSLABreached BIT DEFAULT 0,
    EscalationLevel INT DEFAULT 0, -- 0=None, 1=L1, 2=L2, etc.
    LastEscalationDate DATETIME NULL,

    -- Activity Tracking
    FirstContactAttemptDate DATETIME NULL,
    LastContactAttemptDate DATETIME NULL,
    TotalContactAttempts INT DEFAULT 0,
    SuccessfulContactCount INT DEFAULT 0,

    -- Payment Tracking
    TotalAmountCollected DECIMAL(18,2) DEFAULT 0,
    LastCollectionDate DATETIME NULL,
    LastCollectionAmount DECIMAL(18,2) NULL,

    -- PTP Tracking
    ActivePTPCount INT DEFAULT 0,
    TotalPTPsMade INT DEFAULT 0,
    PTPsKept INT DEFAULT 0,
    PTPsBroken INT DEFAULT 0,
    PTPSuccessRate AS (
        CASE
            WHEN TotalPTPsMade > 0 THEN
                CAST(PTPsKept AS DECIMAL(5,2)) / TotalPTPsMade * 100
            ELSE 0
        END
    ) PERSISTED,

    -- Field Visit
    FieldVisitRequired BIT DEFAULT 0,
    TotalFieldVisits INT DEFAULT 0,
    LastFieldVisitDate DATETIME NULL,

    -- Legal Status
    IsLegalActionInitiated BIT DEFAULT 0,
    LegalActionDate DATETIME NULL,
    LegalCaseNumber NVARCHAR(100) NULL,

    -- Closure Information
    ResolutionType NVARCHAR(50) NULL, -- FullPayment, Settlement, WrittenOff, Legal
    ClosureDate DATETIME NULL,
    ClosureRemarks NVARCHAR(MAX) NULL,

    -- Metadata
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    CreatedBy BIGINT NULL,
    ModifiedDate DATETIME NULL,
    ModifiedBy BIGINT NULL,

    CONSTRAINT FK_Case_Customer FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT FK_Case_Loan FOREIGN KEY (LoanAccountID) REFERENCES LoanAccounts(LoanAccountID),
    CONSTRAINT CK_CaseStatus CHECK (CaseStatus IN (
        'New', 'InProgress', 'Contacted', 'PTPActive', 'PartialRecovery',
        'FullRecovery', 'PTPBroken', 'NoContact', 'FieldVisit', 'FieldContacted',
        'FieldNoContact', 'LegalAction', 'Dispute', 'UnderReview', 'Resolved',
        'RefusedToPay', 'WrittenOff', 'Closed', 'Abandoned', 'TransferredLegal'
    )),
    CONSTRAINT CK_Priority CHECK (CasePriority IN ('Critical', 'High', 'Medium', 'Low')),
    CONSTRAINT CK_PriorityScore CHECK (PriorityScore BETWEEN 0 AND 100)
);

CREATE INDEX IDX_Case_Number ON CollectionCases(CaseNumber);
CREATE INDEX IDX_Case_Customer ON CollectionCases(CustomerID);
CREATE INDEX IDX_Case_Loan ON CollectionCases(LoanAccountID);
CREATE INDEX IDX_Case_Status ON CollectionCases(CaseStatus);
CREATE INDEX IDX_Case_AssignedUser ON CollectionCases(AssignedToUserID);
CREATE INDEX IDX_Case_DPDBucket ON CollectionCases(DPDBucket);
CREATE INDEX IDX_Case_Priority ON CollectionCases(CasePriority);
CREATE INDEX IDX_Case_SLA ON CollectionCases(SLADueDate, IsSLABreached);
GO
