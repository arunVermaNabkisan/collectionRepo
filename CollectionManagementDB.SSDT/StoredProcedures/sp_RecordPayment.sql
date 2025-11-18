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
