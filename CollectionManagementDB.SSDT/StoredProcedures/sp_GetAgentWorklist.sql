-- =============================================
-- 2. SP: Get Agent Worklist
-- =============================================
CREATE OR ALTER PROCEDURE sp_GetAgentWorklist
    @UserID BIGINT,
    @Date DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Date IS NULL SET @Date = CAST(GETDATE() AS DATE);

    SELECT
        cc.CaseID,
        cc.CaseNumber,
        cc.CasePriority,
        cc.CurrentDPD,
        cc.DPDBucket,
        cc.CurrentOutstandingAmount,

        c.FullName AS CustomerName,
        c.PrimaryMobileNumber,
        c.PreferredContactTime,

        la.LoanAccountNumber,
        la.ProductType,

        cc.TotalContactAttempts,
        cc.LastContactAttemptDate,

        -- Today's PTPs
        (SELECT COUNT(*) FROM PromiseToPay
         WHERE CaseID = cc.CaseID
         AND PTPStatus = 'Active'
         AND PromisedDate = @Date) AS PTPlDueToday,

        -- Priority Score
        cc.PriorityScore,
        cc.BehavioralScore

    FROM CollectionCases cc
    INNER JOIN Customers c ON cc.CustomerID = c.CustomerID
    INNER JOIN LoanAccounts la ON cc.LoanAccountID = la.LoanAccountID
    WHERE cc.AssignedToUserID = @UserID
        AND cc.IsActive = 1
        AND cc.CaseStatus NOT IN ('Closed', 'WrittenOff')
    ORDER BY
        cc.CasePriority DESC,
        cc.PriorityScore DESC,
        cc.CurrentDPD DESC;
END;
GO
