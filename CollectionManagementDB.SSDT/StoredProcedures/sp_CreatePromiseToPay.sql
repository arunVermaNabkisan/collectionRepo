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
