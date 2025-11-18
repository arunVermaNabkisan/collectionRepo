-- =============================================
-- 4. VIEW: Payment Summary
-- =============================================
CREATE OR ALTER VIEW vw_PaymentSummary AS
SELECT
    pt.PaymentTransactionID,
    pt.TransactionNumber,
    pt.PaymentDate,
    pt.PaymentAmount,
    pt.PaymentMode,
    pt.PaymentStatus,

    -- Customer and Loan
    c.CustomerCode,
    c.FullName AS CustomerName,
    la.LoanAccountNumber,
    la.ProductType,

    -- Case
    cc.CaseNumber,
    cc.CurrentDPD,

    -- Allocation Status
    pt.AllocationStatus,
    pt.AllocatedAmount,
    pt.UnallocatedAmount,

    -- Receipt
    pt.ReceiptNumber,
    pt.IsReceiptSent,

    -- Collection Details
    CASE
        WHEN pt.CollectedByUserID IS NOT NULL THEN u.FullName
        ELSE 'Online'
    END AS CollectedBy,

    pt.CreatedDate

FROM PaymentTransactions pt
INNER JOIN Customers c ON pt.CustomerID = c.CustomerID
INNER JOIN LoanAccounts la ON pt.LoanAccountID = la.LoanAccountID
LEFT JOIN CollectionCases cc ON pt.CaseID = cc.CaseID
LEFT JOIN Users u ON pt.CollectedByUserID = u.UserID;
GO
