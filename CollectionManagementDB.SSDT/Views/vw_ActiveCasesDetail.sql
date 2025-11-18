-- =============================================
-- 1. VIEW: Active Cases with Customer and Loan Details
-- =============================================
CREATE OR ALTER VIEW vw_ActiveCasesDetail AS
SELECT
    cc.CaseID,
    cc.CaseNumber,
    cc.CaseStatus,
    cc.CasePriority,
    cc.CurrentDPD,
    cc.DPDBucket,
    cc.CurrentOutstandingAmount,
    cc.AssignedToUserID,

    -- Customer Details
    c.CustomerID,
    c.CustomerCode,
    c.FullName AS CustomerName,
    c.PrimaryMobileNumber,
    c.PrimaryEmail,
    c.CurrentCity,
    c.CurrentState,

    -- Loan Details
    la.LoanAccountID,
    la.LoanAccountNumber,
    la.ProductType,
    la.TotalOutstanding,
    la.LastPaymentDate,
    la.LastPaymentAmount,

    -- RM Details
    u.UserID AS RMUserID,
    u.FullName AS RMName,
    u.Email AS RMEmail,
    u.MobileNumber AS RMMobile,

    -- Team Details
    t.TeamID,
    t.TeamName,

    cc.CreatedDate,
    cc.ModifiedDate
FROM CollectionCases cc
INNER JOIN Customers c ON cc.CustomerID = c.CustomerID
INNER JOIN LoanAccounts la ON cc.LoanAccountID = la.LoanAccountID
LEFT JOIN Users u ON cc.AssignedToUserID = u.UserID
LEFT JOIN Teams t ON cc.AssignedToTeamID = t.TeamID
WHERE cc.IsActive = 1
    AND cc.CaseStatus NOT IN ('Closed', 'WrittenOff');
GO
