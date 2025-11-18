-- =============================================
-- 1. PROMISE TO PAY (PTP) TABLE
-- =============================================
CREATE TABLE PromiseToPay (
    PTPID BIGINT IDENTITY(1,1) PRIMARY KEY,
    PTPNumber NVARCHAR(50) NOT NULL UNIQUE,

    -- Links
    CaseID BIGINT NOT NULL,
    CustomerID BIGINT NOT NULL,
    LoanAccountID BIGINT NOT NULL,
    InteractionID BIGINT NULL, -- Link to the interaction where PTP was created

    -- PTP Type
    PTPType NVARCHAR(50) NOT NULL, -- Single, Split
    ParentPTPID BIGINT NULL, -- For split PTPs, reference to parent

    -- PTP Details
    PromisedAmount DECIMAL(18,2) NOT NULL,
    PromisedDate DATE NOT NULL,
    PromisedPaymentMode NVARCHAR(50) NULL, -- Cash, Cheque, UPI, NEFT, etc.

    -- Outstanding at PTP Creation
    OutstandingAtPTPCreation DECIMAL(18,2) NOT NULL,

    -- Confidence and Priority
    ConfidenceLevel NVARCHAR(20) NOT NULL, -- High, Medium, Low
    ConfidenceScore DECIMAL(5,2) DEFAULT 0, -- 0-100
    Priority INT DEFAULT 1, -- 1=Highest

    -- Customer Commitment Details
    CustomerStatement NVARCHAR(MAX) NULL,
    ReasonForDelay NVARCHAR(500) NULL,
    CommitmentQuality NVARCHAR(50) NULL, -- Strong, Moderate, Weak

    -- PTP Status
    PTPStatus NVARCHAR(50) NOT NULL,
    -- Active, Kept, PartiallyKept, Broken, Expired, Cancelled
    StatusChangeDate DATETIME NULL,

    -- Actual Payment Details
    ActualPaymentDate DATE NULL,
    ActualPaymentAmount DECIMAL(18,2) DEFAULT 0,
    PaymentTransactionID BIGINT NULL,
    VarianceAmount AS (PromisedAmount - ActualPaymentAmount) PERSISTED,
    VariancePercentage AS (
        CASE
            WHEN PromisedAmount > 0 THEN
                ((PromisedAmount - ActualPaymentAmount) / PromisedAmount) * 100
            ELSE 0
        END
    ) PERSISTED,

    -- Monitoring
    ReminderSent BIT DEFAULT 0,
    ReminderSentDateTime DATETIME NULL,
    FollowUpCount INT DEFAULT 0,
    LastFollowUpDate DATETIME NULL,

    -- Escalation
    IsEscalated BIT DEFAULT 0,
    EscalatedToUserID BIGINT NULL,
    EscalationDate DATETIME NULL,
    EscalationReason NVARCHAR(500) NULL,

    -- Split PTP Details
    IsSplitPTP BIT DEFAULT 0,
    SplitSequence INT DEFAULT 1, -- 1, 2, 3, etc.
    TotalSplits INT DEFAULT 1,

    -- Created By
    CreatedByUserID BIGINT NOT NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL,
    ModifiedBy BIGINT NULL,

    -- Notes
    Remarks NVARCHAR(MAX) NULL,

    CONSTRAINT FK_PTP_Case FOREIGN KEY (CaseID) REFERENCES CollectionCases(CaseID),
    CONSTRAINT FK_PTP_Customer FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT FK_PTP_Loan FOREIGN KEY (LoanAccountID) REFERENCES LoanAccounts(LoanAccountID),
    CONSTRAINT FK_PTP_Interaction FOREIGN KEY (InteractionID) REFERENCES CustomerInteractions(InteractionID),
    CONSTRAINT FK_PTP_Parent FOREIGN KEY (ParentPTPID) REFERENCES PromiseToPay(PTPID),
    CONSTRAINT FK_PTP_CreatedBy FOREIGN KEY (CreatedByUserID) REFERENCES Users(UserID),
    CONSTRAINT CK_PTPType CHECK (PTPType IN ('Single', 'Split')),
    CONSTRAINT CK_PTPStatus CHECK (PTPStatus IN ('Active', 'Kept', 'PartiallyKept', 'Broken', 'Expired', 'Cancelled')),
    CONSTRAINT CK_ConfidenceLevel CHECK (ConfidenceLevel IN ('High', 'Medium', 'Low'))
);

CREATE INDEX IDX_PTP_Number ON PromiseToPay(PTPNumber);
CREATE INDEX IDX_PTP_Case ON PromiseToPay(CaseID);
CREATE INDEX IDX_PTP_Customer ON PromiseToPay(CustomerID);
CREATE INDEX IDX_PTP_Date ON PromiseToPay(PromisedDate);
CREATE INDEX IDX_PTP_Status ON PromiseToPay(PTPStatus);
CREATE INDEX IDX_PTP_Parent ON PromiseToPay(ParentPTPID);
GO
