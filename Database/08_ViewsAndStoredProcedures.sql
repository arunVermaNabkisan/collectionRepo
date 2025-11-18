-- =============================================
-- Collection Management System - Views and Stored Procedures
-- Purpose: Optimized views and stored procedures for Dapper usage
-- =============================================

USE CollectionManagementDB;
GO

-- =============================================
-- VIEWS
-- =============================================

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

-- =============================================
-- STORED PROCEDURES FOR DAPPER
-- =============================================

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

-- =============================================
-- 3. SP: Create Promise to Pay
-- =============================================
CREATE OR ALTER PROCEDURE sp_CreatePromiseToPay
    @CaseID BIGINT,
    @CustomerID BIGINT,
    @LoanAccountID BIGINT,
    @PromisedAmount DECIMAL(18,2),
    @PromisedDate DATE,
    @ConfidenceLevel NVARCHAR(20),
    @CreatedByUserID BIGINT,
    @Remarks NVARCHAR(MAX) = NULL,
    @InteractionID BIGINT = NULL,
    @NewPTPID BIGINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Get current outstanding
        DECLARE @Outstanding DECIMAL(18,2);
        SELECT @Outstanding = CurrentOutstandingAmount
        FROM CollectionCases WHERE CaseID = @CaseID;

        -- Generate PTP Number
        DECLARE @PTPNumber NVARCHAR(50);
        SET @PTPNumber = 'PTP' + FORMAT(GETDATE(), 'yyyyMMdd') +
                         RIGHT('000000' + CAST(NEXT VALUE FOR seq_PTPNumber AS NVARCHAR), 6);

        -- Insert PTP
        INSERT INTO PromiseToPay (
            PTPNumber, CaseID, CustomerID, LoanAccountID,
            PTPType, PromisedAmount, PromisedDate,
            OutstandingAtPTPCreation, ConfidenceLevel,
            ConfidenceScore, PTPStatus, CreatedByUserID,
            Remarks, InteractionID
        )
        VALUES (
            @PTPNumber, @CaseID, @CustomerID, @LoanAccountID,
            'Single', @PromisedAmount, @PromisedDate,
            @Outstanding, @ConfidenceLevel,
            CASE @ConfidenceLevel
                WHEN 'High' THEN 80
                WHEN 'Medium' THEN 50
                ELSE 30
            END,
            'Active', @CreatedByUserID,
            @Remarks, @InteractionID
        );

        SET @NewPTPID = SCOPE_IDENTITY();

        -- Update Case
        UPDATE CollectionCases
        SET ActivePTPCount = ActivePTPCount + 1,
            TotalPTPsMade = TotalPTPsMade + 1,
            CaseStatus = 'PTPActive',
            ModifiedDate = GETDATE(),
            ModifiedBy = @CreatedByUserID
        WHERE CaseID = @CaseID;

        COMMIT TRANSACTION;

        SELECT @NewPTPID AS PTPID, @PTPNumber AS PTPNumber;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- Create sequence for PTP numbering
IF NOT EXISTS (SELECT * FROM sys.sequences WHERE name = 'seq_PTPNumber')
BEGIN
    CREATE SEQUENCE seq_PTPNumber
        START WITH 1
        INCREMENT BY 1;
END;
GO

-- =============================================
-- 4. SP: Record Payment
-- =============================================
CREATE OR ALTER PROCEDURE sp_RecordPayment
    @CustomerID BIGINT,
    @LoanAccountID BIGINT,
    @CaseID BIGINT = NULL,
    @PaymentAmount DECIMAL(18,2),
    @PaymentMode NVARCHAR(50),
    @PaymentChannel NVARCHAR(50),
    @PaymentSource NVARCHAR(50),
    @CollectedByUserID BIGINT = NULL,
    @Remarks NVARCHAR(MAX) = NULL,
    @NewPaymentID BIGINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Generate Transaction Number
        DECLARE @TransactionNumber NVARCHAR(50);
        SET @TransactionNumber = 'PMT' + FORMAT(GETDATE(), 'yyyyMMddHHmmss') +
                                RIGHT('0000' + CAST(NEXT VALUE FOR seq_PaymentNumber AS NVARCHAR), 4);

        -- Insert Payment
        INSERT INTO PaymentTransactions (
            TransactionNumber, CustomerID, LoanAccountID, CaseID,
            PaymentAmount, PaymentMode, PaymentChannel, PaymentSource,
            PaymentStatus, CollectedByUserID, Remarks
        )
        VALUES (
            @TransactionNumber, @CustomerID, @LoanAccountID, @CaseID,
            @PaymentAmount, @PaymentMode, @PaymentChannel, @PaymentSource,
            'Success', @CollectedByUserID, @Remarks
        );

        SET @NewPaymentID = SCOPE_IDENTITY();

        -- Update Case if provided
        IF @CaseID IS NOT NULL
        BEGIN
            UPDATE CollectionCases
            SET TotalAmountCollected = TotalAmountCollected + @PaymentAmount,
                LastCollectionDate = GETDATE(),
                LastCollectionAmount = @PaymentAmount,
                ModifiedDate = GETDATE()
            WHERE CaseID = @CaseID;
        END;

        COMMIT TRANSACTION;

        SELECT @NewPaymentID AS PaymentTransactionID, @TransactionNumber AS TransactionNumber;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- Create sequence for payment numbering
IF NOT EXISTS (SELECT * FROM sys.sequences WHERE name = 'seq_PaymentNumber')
BEGIN
    CREATE SEQUENCE seq_PaymentNumber
        START WITH 1
        INCREMENT BY 1;
END;
GO

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

PRINT 'Views and Stored Procedures created successfully.';
GO
