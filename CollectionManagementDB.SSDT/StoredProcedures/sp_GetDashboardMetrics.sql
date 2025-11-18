-- =============================================
-- 5. SP: Get Dashboard Metrics
-- =============================================
CREATE OR ALTER PROCEDURE sp_GetDashboardMetrics
    @UserID BIGINT = NULL,
    @TeamID BIGINT = NULL,
    @Date DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Date IS NULL SET @Date = CAST(GETDATE() AS DATE);

    -- Total Cases
    SELECT
        COUNT(*) AS TotalCases,
        SUM(CurrentOutstandingAmount) AS TotalOutstanding,
        SUM(CASE WHEN CasePriority = 'Critical' THEN 1 ELSE 0 END) AS CriticalCases,
        SUM(CASE WHEN CasePriority = 'High' THEN 1 ELSE 0 END) AS HighPriorityCases
    FROM CollectionCases
    WHERE IsActive = 1
        AND (@UserID IS NULL OR AssignedToUserID = @UserID)
        AND (@TeamID IS NULL OR AssignedToTeamID = @TeamID);

    -- DPD Bucket Distribution
    SELECT
        DPDBucket,
        COUNT(*) AS CaseCount,
        SUM(CurrentOutstandingAmount) AS OutstandingAmount
    FROM CollectionCases
    WHERE IsActive = 1
        AND (@UserID IS NULL OR AssignedToUserID = @UserID)
        AND (@TeamID IS NULL OR AssignedToTeamID = @TeamID)
    GROUP BY DPDBucket
    ORDER BY DPDBucket;

    -- Today's PTPs
    SELECT
        COUNT(*) AS PTPlDueToday,
        SUM(PromisedAmount) AS TotalPromisedAmount
    FROM PromiseToPay
    WHERE PTPStatus = 'Active'
        AND PromisedDate = @Date
        AND (@UserID IS NULL OR CreatedByUserID = @UserID);

    -- Today's Collection
    SELECT
        COUNT(*) AS PaymentCount,
        SUM(PaymentAmount) AS TotalCollected
    FROM PaymentTransactions
    WHERE CAST(PaymentDate AS DATE) = @Date
        AND PaymentStatus = 'Success'
        AND (@UserID IS NULL OR CollectedByUserID = @UserID);
END;
GO
