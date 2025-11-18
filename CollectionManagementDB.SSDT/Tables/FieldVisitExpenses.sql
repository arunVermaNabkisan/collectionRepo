-- =============================================
-- 6. FIELD VISIT EXPENSES TABLE
-- =============================================
CREATE TABLE FieldVisitExpenses (
    ExpenseID BIGINT IDENTITY(1,1) PRIMARY KEY,
    FieldVisitID BIGINT NULL,
    RouteID BIGINT NULL,
    UserID BIGINT NOT NULL,

    -- Expense Details
    ExpenseDate DATE NOT NULL,
    ExpenseType NVARCHAR(100) NOT NULL,
    -- Travel, Food, Parking, Toll, Vehicle, Accommodation, etc.

    ExpenseAmount DECIMAL(18,2) NOT NULL,
    Currency NVARCHAR(10) DEFAULT 'INR',

    -- Billing Details
    BillNumber NVARCHAR(100) NULL,
    VendorName NVARCHAR(200) NULL,

    -- Approval
    ApprovalStatus NVARCHAR(50) DEFAULT 'Pending',
    -- Pending, Approved, Rejected, Paid
    ApprovedByUserID BIGINT NULL,
    ApprovedDate DATETIME NULL,
    RejectionReason NVARCHAR(500) NULL,

    -- Reimbursement
    ReimbursementAmount DECIMAL(18,2) DEFAULT 0,
    ReimbursementDate DATE NULL,
    PaymentReference NVARCHAR(100) NULL,

    -- Supporting Documents
    ReceiptPath NVARCHAR(500) NULL,
    HasReceipt BIT DEFAULT 0,

    Description NVARCHAR(1000) NULL,
    Remarks NVARCHAR(MAX) NULL,

    CreatedDate DATETIME DEFAULT GETDATE(),
    CreatedBy BIGINT NULL,

    CONSTRAINT FK_Expense_Visit FOREIGN KEY (FieldVisitID) REFERENCES FieldVisits(FieldVisitID),
    CONSTRAINT FK_Expense_Route FOREIGN KEY (RouteID) REFERENCES FieldVisitRoutes(RouteID),
    CONSTRAINT FK_Expense_User FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT CK_Expense_Status CHECK (ApprovalStatus IN ('Pending', 'Approved', 'Rejected', 'Paid'))
);

CREATE INDEX IDX_Expense_Visit ON FieldVisitExpenses(FieldVisitID);
CREATE INDEX IDX_Expense_Route ON FieldVisitExpenses(RouteID);
CREATE INDEX IDX_Expense_User ON FieldVisitExpenses(UserID);
CREATE INDEX IDX_Expense_Status ON FieldVisitExpenses(ApprovalStatus);
GO
