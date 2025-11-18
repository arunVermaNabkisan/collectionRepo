-- =============================================
-- 3. VIEW: Field Visit Summary
-- =============================================
CREATE OR ALTER VIEW vw_FieldVisitSummary AS
SELECT
    fv.FieldVisitID,
    fv.VisitNumber,
    fv.ScheduledDate,
    fv.VisitStatus,
    fv.VisitOutcome,

    -- Assignment
    u.FullName AS AssignedAgent,
    u.MobileNumber AS AgentMobile,

    -- Case Details
    cc.CaseNumber,
    c.FullName AS CustomerName,
    la.LoanAccountNumber,

    -- Visit Details
    fv.CheckInDateTime,
    fv.CheckOutDateTime,
    fv.VisitDuration,
    fv.IsPaymentCollected,
    fv.PaymentAmount,
    fv.IsPTPCreated,

    -- Evidence Count
    fv.PhotosCount,
    fv.VoiceNotesCount,
    fv.DocumentsCount,

    -- Location
    fv.VisitCity,
    fv.VisitState

FROM FieldVisits fv
INNER JOIN Users u ON fv.AssignedToUserID = u.UserID
INNER JOIN CollectionCases cc ON fv.CaseID = cc.CaseID
INNER JOIN Customers c ON fv.CustomerID = c.CustomerID
INNER JOIN LoanAccounts la ON fv.LoanAccountID = la.LoanAccountID;
GO
