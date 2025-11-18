-- Create sequence for payment numbering
IF NOT EXISTS (SELECT * FROM sys.sequences WHERE name = 'seq_PaymentNumber')
BEGIN
    CREATE SEQUENCE seq_PaymentNumber
        START WITH 1
        INCREMENT BY 1;
END;
GO
