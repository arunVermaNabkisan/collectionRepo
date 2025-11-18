-- =============================================
-- 6. SETTLEMENT PROPOSALS TABLE
-- =============================================
CREATE TABLE SettlementProposals (
    SettlementID BIGINT IDENTITY(1,1) PRIMARY KEY,
    SettlementNumber NVARCHAR(50) NOT NULL UNIQUE,

    -- Links
    CaseID BIGINT NOT NULL,
    CustomerID BIGINT NOT NULL,
    LoanAccountID BIGINT NOT NULL,

    -- Settlement Details
    TotalOutstanding DECIMAL(18,2) NOT NULL,
    ProposedSettlementAmount DECIMAL(18,2) NOT NULL,
    DiscountAmount AS (TotalOutstanding - ProposedSettlementAmount) PERSISTED,
    DiscountPercentage AS (
        CASE
            WHEN TotalOutstanding > 0 THEN
                ((TotalOutstanding - ProposedSettlementAmount) / TotalOutstanding) * 100
            ELSE 0
        END
    ) PERSISTED,

    -- Payment Terms
    PaymentType NVARCHAR(50) NOT NULL, -- Lumpsum, Installment
    NumberOfInstallments INT DEFAULT 1,
    InstallmentAmount DECIMAL(18,2) NULL,
    FirstInstallmentDate DATE NULL,
    InstallmentFrequency NVARCHAR(20) NULL, -- Monthly, Weekly

    -- Settlement Status
    SettlementStatus NVARCHAR(50) NOT NULL,
    -- Proposed, Pending Approval, Approved, Rejected, Accepted, Completed, Cancelled
    ProposedDate DATETIME DEFAULT GETDATE(),
    ApprovalDate DATETIME NULL,
    CompletionDate DATETIME NULL,

    -- Approval Workflow
    ProposedByUserID BIGINT NOT NULL,
    ApproverLevel1UserID BIGINT NULL,
    ApproverLevel2UserID BIGINT NULL,
    ApproverLevel3UserID BIGINT NULL,
    ApprovedByUserID BIGINT NULL,
    RejectedByUserID BIGINT NULL,
    RejectionReason NVARCHAR(500) NULL,

    -- Customer Acceptance
    IsCustomerAccepted BIT DEFAULT 0,
    CustomerAcceptanceDate DATETIME NULL,
    AcceptanceMode NVARCHAR(50) NULL, -- Email, Physical, Verbal

    -- Documentation
    SettlementAgreementPath NVARCHAR(500) NULL,
    DigitalSignature NVARCHAR(MAX) NULL,

    ValidityDate DATETIME NULL,
    ExpiryDate DATETIME NULL,

    Remarks NVARCHAR(MAX) NULL,

    CONSTRAINT FK_Settlement_Case FOREIGN KEY (CaseID) REFERENCES CollectionCases(CaseID),
    CONSTRAINT FK_Settlement_Customer FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT FK_Settlement_Loan FOREIGN KEY (LoanAccountID) REFERENCES LoanAccounts(LoanAccountID),
    CONSTRAINT FK_Settlement_Proposer FOREIGN KEY (ProposedByUserID) REFERENCES Users(UserID),
    CONSTRAINT CK_Settlement_Status CHECK (SettlementStatus IN (
        'Proposed', 'PendingApproval', 'Approved', 'Rejected', 'Accepted', 'Completed', 'Cancelled'
    )),
    CONSTRAINT CK_Settlement_PaymentType CHECK (PaymentType IN ('Lumpsum', 'Installment'))
);

CREATE INDEX IDX_Settlement_Number ON SettlementProposals(SettlementNumber);
CREATE INDEX IDX_Settlement_Case ON SettlementProposals(CaseID);
CREATE INDEX IDX_Settlement_Status ON SettlementProposals(SettlementStatus);
GO
