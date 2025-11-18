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
