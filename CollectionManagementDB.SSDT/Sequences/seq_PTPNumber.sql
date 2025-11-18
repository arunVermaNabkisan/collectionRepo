-- Create sequence for PTP numbering
IF NOT EXISTS (SELECT * FROM sys.sequences WHERE name = 'seq_PTPNumber')
BEGIN
    CREATE SEQUENCE seq_PTPNumber
        START WITH 1
        INCREMENT BY 1;
END;
GO
