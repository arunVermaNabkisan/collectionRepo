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
