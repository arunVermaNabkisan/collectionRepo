-- =============================================
-- Collection Management System - PTP and Payment Tables
-- Purpose: Promise to Pay and Payment Management
-- =============================================

USE CollectionManagementDB;
GO

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

-- =============================================
-- 2. PTP STATUS HISTORY TABLE
-- =============================================
CREATE TABLE PTPStatusHistory (
    HistoryID BIGINT IDENTITY(1,1) PRIMARY KEY,
    PTPID BIGINT NOT NULL,

    PreviousStatus NVARCHAR(50) NULL,
    NewStatus NVARCHAR(50) NOT NULL,
    StatusChangeReason NVARCHAR(500) NULL,

    ChangedByUserID BIGINT NULL,
    ChangedDate DATETIME DEFAULT GETDATE(),
    Remarks NVARCHAR(MAX) NULL,

    CONSTRAINT FK_PTPHistory_PTP FOREIGN KEY (PTPID) REFERENCES PromiseToPay(PTPID),
    CONSTRAINT FK_PTPHistory_User FOREIGN KEY (ChangedByUserID) REFERENCES Users(UserID)
);

CREATE INDEX IDX_PTPHistory_PTP ON PTPStatusHistory(PTPID);
CREATE INDEX IDX_PTPHistory_Date ON PTPStatusHistory(ChangedDate);
GO

-- =============================================
-- 3. PAYMENT TRANSACTIONS TABLE
-- =============================================
CREATE TABLE PaymentTransactions (
    PaymentTransactionID BIGINT IDENTITY(1,1) PRIMARY KEY,
    TransactionNumber NVARCHAR(50) NOT NULL UNIQUE,

    -- Links
    CustomerID BIGINT NOT NULL,
    LoanAccountID BIGINT NOT NULL,
    CaseID BIGINT NULL,
    PTPID BIGINT NULL, -- If payment is against a PTP

    -- Payment Details
    PaymentDate DATETIME DEFAULT GETDATE(),
    PaymentAmount DECIMAL(18,2) NOT NULL,
    Currency NVARCHAR(10) DEFAULT 'INR',

    -- Payment Method
    PaymentMode NVARCHAR(50) NOT NULL,
    -- Cash, Cheque, DD, NEFT, RTGS, IMPS, UPI, Card, Wallet, etc.
    PaymentChannel NVARCHAR(50) NOT NULL,
    -- Branch, Online, Mobile, FieldAgent, PaymentGateway, etc.

    -- Payment Source
    PaymentSource NVARCHAR(50) NOT NULL,
    -- Customer, FieldCollection, Settlement, Legal, etc.

    -- Instrument Details (for cheque, DD, etc.)
    InstrumentNumber NVARCHAR(100) NULL,
    InstrumentDate DATE NULL,
    BankName NVARCHAR(200) NULL,
    BranchName NVARCHAR(200) NULL,
    IFSCCode NVARCHAR(20) NULL,

    -- Online Payment Details
    PaymentGateway NVARCHAR(100) NULL,
    GatewayTransactionID NVARCHAR(200) NULL,
    GatewayReferenceNumber NVARCHAR(200) NULL,
    UPITransactionID NVARCHAR(200) NULL,
    UPIReferenceNumber NVARCHAR(200) NULL,
    CardType NVARCHAR(50) NULL, -- Debit, Credit
    CardLast4Digits NVARCHAR(4) NULL,

    -- Payment Status
    PaymentStatus NVARCHAR(50) NOT NULL,
    -- Success, Pending, Failed, Bounced, Cancelled, Reversed
    StatusReason NVARCHAR(500) NULL,

    -- Processing Details
    ProcessedDate DATETIME NULL,
    ProcessedByUserID BIGINT NULL,
    SettlementDate DATE NULL,
    SettlementStatus NVARCHAR(50) DEFAULT 'Pending',

    -- Allocation
    AllocationStatus NVARCHAR(50) DEFAULT 'Pending',
    -- Pending, Allocated, PartiallyAllocated, Failed
    AllocatedAmount DECIMAL(18,2) DEFAULT 0,
    UnallocatedAmount AS (PaymentAmount - AllocatedAmount) PERSISTED,
    AllocationDate DATETIME NULL,

    -- Receipt
    ReceiptNumber NVARCHAR(50) NULL,
    ReceiptGeneratedDate DATETIME NULL,
    ReceiptURL NVARCHAR(500) NULL,
    IsReceiptSent BIT DEFAULT 0,

    -- Field Collection Details
    CollectedByUserID BIGINT NULL,
    CollectionLocationLat DECIMAL(10,8) NULL,
    CollectionLocationLong DECIMAL(11,8) NULL,
    CollectionAddress NVARCHAR(500) NULL,

    -- Reconciliation
    IsReconciled BIT DEFAULT 0,
    ReconciledDate DATETIME NULL,
    ReconciledByUserID BIGINT NULL,
    BankStatementReference NVARCHAR(200) NULL,

    -- For Bounced Payments
    IsBounced BIT DEFAULT 0,
    BouncedDate DATETIME NULL,
    BounceReason NVARCHAR(500) NULL,
    BounceCharges DECIMAL(18,2) DEFAULT 0,

    -- Reversal Details
    IsReversed BIT DEFAULT 0,
    ReversalDate DATETIME NULL,
    ReversalReason NVARCHAR(500) NULL,
    ReversalAmount DECIMAL(18,2) DEFAULT 0,

    -- Payment Link
    PaymentLinkID BIGINT NULL,
    IsPaymentLinkPayment BIT DEFAULT 0,

    -- Metadata
    CreatedDate DATETIME DEFAULT GETDATE(),
    CreatedBy BIGINT NULL,
    ModifiedDate DATETIME NULL,
    ModifiedBy BIGINT NULL,

    -- Synced to LMS
    SyncedToLMS BIT DEFAULT 0,
    LMSSyncDate DATETIME NULL,
    LMSTransactionID NVARCHAR(100) NULL,

    Remarks NVARCHAR(MAX) NULL,

    CONSTRAINT FK_Payment_Customer FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT FK_Payment_Loan FOREIGN KEY (LoanAccountID) REFERENCES LoanAccounts(LoanAccountID),
    CONSTRAINT FK_Payment_Case FOREIGN KEY (CaseID) REFERENCES CollectionCases(CaseID),
    CONSTRAINT FK_Payment_PTP FOREIGN KEY (PTPID) REFERENCES PromiseToPay(PTPID),
    CONSTRAINT FK_Payment_Collector FOREIGN KEY (CollectedByUserID) REFERENCES Users(UserID),
    CONSTRAINT CK_PaymentStatus CHECK (PaymentStatus IN ('Success', 'Pending', 'Failed', 'Bounced', 'Cancelled', 'Reversed'))
);

CREATE INDEX IDX_Payment_Transaction ON PaymentTransactions(TransactionNumber);
CREATE INDEX IDX_Payment_Customer ON PaymentTransactions(CustomerID);
CREATE INDEX IDX_Payment_Loan ON PaymentTransactions(LoanAccountID);
CREATE INDEX IDX_Payment_Date ON PaymentTransactions(PaymentDate);
CREATE INDEX IDX_Payment_Status ON PaymentTransactions(PaymentStatus);
CREATE INDEX IDX_Payment_Mode ON PaymentTransactions(PaymentMode);
CREATE INDEX IDX_Payment_Gateway ON PaymentTransactions(GatewayTransactionID);
GO

-- =============================================
-- 4. PAYMENT ALLOCATION TABLE
-- =============================================
CREATE TABLE PaymentAllocation (
    AllocationID BIGINT IDENTITY(1,1) PRIMARY KEY,
    PaymentTransactionID BIGINT NOT NULL,
    LoanAccountID BIGINT NOT NULL,

    -- Allocation Hierarchy (as per RBI norms)
    PenalChargesAllocated DECIMAL(18,2) DEFAULT 0,
    LateFeesAllocated DECIMAL(18,2) DEFAULT 0,
    InterestAllocated DECIMAL(18,2) DEFAULT 0,
    PrincipalAllocated DECIMAL(18,2) DEFAULT 0,
    OtherChargesAllocated DECIMAL(18,2) DEFAULT 0,

    TotalAllocated AS (
        PenalChargesAllocated +
        LateFeesAllocated +
        InterestAllocated +
        PrincipalAllocated +
        OtherChargesAllocated
    ) PERSISTED,

    AllocationDate DATETIME DEFAULT GETDATE(),
    AllocatedByUserID BIGINT NULL,

    -- Outstanding before and after
    OutstandingBeforePayment DECIMAL(18,2) NOT NULL,
    OutstandingAfterPayment DECIMAL(18,2) NOT NULL,

    -- DPD Impact
    DPDBeforePayment INT NOT NULL,
    DPDAfterPayment INT NOT NULL,

    Remarks NVARCHAR(MAX) NULL,

    CONSTRAINT FK_Allocation_Payment FOREIGN KEY (PaymentTransactionID) REFERENCES PaymentTransactions(PaymentTransactionID),
    CONSTRAINT FK_Allocation_Loan FOREIGN KEY (LoanAccountID) REFERENCES LoanAccounts(LoanAccountID)
);

CREATE INDEX IDX_Allocation_Payment ON PaymentAllocation(PaymentTransactionID);
CREATE INDEX IDX_Allocation_Loan ON PaymentAllocation(LoanAccountID);
GO

-- =============================================
-- 5. PAYMENT LINKS TABLE
-- =============================================
CREATE TABLE PaymentLinks (
    PaymentLinkID BIGINT IDENTITY(1,1) PRIMARY KEY,
    LinkReference NVARCHAR(100) NOT NULL UNIQUE,
    ShortURL NVARCHAR(500) NOT NULL,
    LongURL NVARCHAR(1000) NOT NULL,

    -- Links
    CaseID BIGINT NOT NULL,
    CustomerID BIGINT NOT NULL,
    LoanAccountID BIGINT NOT NULL,

    -- Link Details
    LinkAmount DECIMAL(18,2) NOT NULL,
    MinimumAmount DECIMAL(18,2) NULL,
    MaximumAmount DECIMAL(18,2) NULL,
    AllowPartialPayment BIT DEFAULT 1,

    -- Link Status
    LinkStatus NVARCHAR(50) NOT NULL,
    -- Active, Used, Expired, Cancelled
    CreatedDate DATETIME DEFAULT GETDATE(),
    ExpiryDate DATETIME NOT NULL,
    ActivatedDate DATETIME NULL,

    -- Usage Tracking
    IsClicked BIT DEFAULT 0,
    FirstClickedDateTime DATETIME NULL,
    TotalClicks INT DEFAULT 0,
    UniqueIPCount INT DEFAULT 0,

    IsPaymentCompleted BIT DEFAULT 0,
    PaymentCompletedDateTime DATETIME NULL,
    PaymentTransactionID BIGINT NULL,
    AmountPaid DECIMAL(18,2) DEFAULT 0,

    -- Delivery
    DeliveryChannel NVARCHAR(50) NULL, -- SMS, Email, WhatsApp
    SentDateTime DATETIME NULL,
    SentByUserID BIGINT NULL,

    -- Security
    AccessToken NVARCHAR(500) NULL,
    IsPasswordProtected BIT DEFAULT 0,

    CreatedByUserID BIGINT NOT NULL,
    Remarks NVARCHAR(MAX) NULL,

    CONSTRAINT FK_PayLink_Case FOREIGN KEY (CaseID) REFERENCES CollectionCases(CaseID),
    CONSTRAINT FK_PayLink_Customer FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT FK_PayLink_Loan FOREIGN KEY (LoanAccountID) REFERENCES LoanAccounts(LoanAccountID),
    CONSTRAINT FK_PayLink_Transaction FOREIGN KEY (PaymentTransactionID) REFERENCES PaymentTransactions(PaymentTransactionID),
    CONSTRAINT FK_PayLink_Creator FOREIGN KEY (CreatedByUserID) REFERENCES Users(UserID),
    CONSTRAINT CK_PayLink_Status CHECK (LinkStatus IN ('Active', 'Used', 'Expired', 'Cancelled'))
);

CREATE INDEX IDX_PayLink_Reference ON PaymentLinks(LinkReference);
CREATE INDEX IDX_PayLink_Case ON PaymentLinks(CaseID);
CREATE INDEX IDX_PayLink_Status ON PaymentLinks(LinkStatus);
CREATE INDEX IDX_PayLink_Expiry ON PaymentLinks(ExpiryDate);
GO

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
