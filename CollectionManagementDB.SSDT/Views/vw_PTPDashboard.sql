-- =============================================
-- 2. VIEW: PTP Dashboard
-- =============================================
CREATE OR ALTER VIEW vw_PTPDashboard AS
SELECT
    ptp.PTPID,
    ptp.PTPNumber,
    ptp.PromisedAmount,
    ptp.PromisedDate,
    ptp.PTPStatus,
    ptp.ConfidenceLevel,

    -- Case Details
    cc.CaseNumber,
    cc.CurrentDPD,
    cc.DPDBucket,

    -- Customer Details
    c.CustomerCode,
    c.FullName AS CustomerName,
    c.PrimaryMobileNumber,

    -- Loan Details
    la.LoanAccountNumber,
    la.ProductType,

    -- Created By
    u.FullName AS CreatedBy,
    ptp.CreatedDate,

    -- Days Until Due
    DATEDIFF(DAY, GETDATE(), ptp.PromisedDate) AS DaysUntilDue,

    -- Status Indicators
    CASE
        WHEN ptp.PTPStatus = 'Active' AND ptp.PromisedDate < CAST(GETDATE() AS DATE) THEN 'Overdue'
        WHEN ptp.PTPStatus = 'Active' AND ptp.PromisedDate = CAST(GETDATE() AS DATE) THEN 'Due Today'
        WHEN ptp.PTPStatus = 'Active' AND DATEDIFF(DAY, GETDATE(), ptp.PromisedDate) <= 3 THEN 'Due Soon'
        ELSE ptp.PTPStatus
    END AS PTPStatusCategory

FROM PromiseToPay ptp
INNER JOIN CollectionCases cc ON ptp.CaseID = cc.CaseID
INNER JOIN Customers c ON ptp.CustomerID = c.CustomerID
INNER JOIN LoanAccounts la ON ptp.LoanAccountID = la.LoanAccountID
INNER JOIN Users u ON ptp.CreatedByUserID = u.UserID;
GO
