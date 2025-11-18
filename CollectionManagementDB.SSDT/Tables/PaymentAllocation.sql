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
