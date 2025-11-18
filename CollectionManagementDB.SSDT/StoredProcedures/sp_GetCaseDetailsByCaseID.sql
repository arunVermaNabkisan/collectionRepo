-- =============================================
-- 1. SP: Get Case Details by Case ID
-- =============================================
CREATE OR ALTER PROCEDURE sp_GetCaseDetailsByCaseID
    @CaseID BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    -- Main Case Details
    SELECT * FROM vw_ActiveCasesDetail WHERE CaseID = @CaseID;

    -- Recent Interactions
    SELECT TOP 10 * FROM CustomerInteractions
    WHERE CaseID = @CaseID
    ORDER BY InteractionDateTime DESC;

    -- Active PTPs
    SELECT * FROM PromiseToPay
    WHERE CaseID = @CaseID AND PTPStatus = 'Active';

    -- Recent Payments
    SELECT TOP 5 * FROM vw_PaymentSummary
    WHERE CaseNumber = (SELECT CaseNumber FROM CollectionCases WHERE CaseID = @CaseID)
    ORDER BY PaymentDate DESC;

    -- Case Status History
    SELECT TOP 10 * FROM CaseStatusHistory
    WHERE CaseID = @CaseID
    ORDER BY ChangedDate DESC;
END;
GO
