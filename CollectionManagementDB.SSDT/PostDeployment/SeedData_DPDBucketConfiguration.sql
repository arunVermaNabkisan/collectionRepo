-- =============================================
-- Post-Deployment Script: DPD Bucket Configuration Seed Data
-- Description: Inserts default DPD bucket configurations
-- Idempotent: Yes (uses MERGE statement)
-- =============================================

PRINT 'Seeding DPD Bucket Configuration data...';

MERGE INTO DPDBucketConfiguration AS Target
USING (
    VALUES
        ('Bucket-1', '0-30 DPD', 0, 30, 24),
        ('Bucket-2', '31-60 DPD', 31, 60, 12),
        ('Bucket-3', '61-90 DPD', 61, 90, 8),
        ('Bucket-4', '91-180 DPD', 91, 180, 6),
        ('Bucket-5', '181-365 DPD', 181, 365, 4),
        ('Bucket-6', '365+ DPD', 366, 9999, 2)
) AS Source (BucketName, BucketDisplayName, MinDPD, MaxDPD, SLAHours)
ON Target.BucketName = Source.BucketName

-- Update existing buckets if DPD ranges or SLA hours have changed
WHEN MATCHED THEN
    UPDATE SET
        Target.BucketDisplayName = Source.BucketDisplayName,
        Target.MinDPD = Source.MinDPD,
        Target.MaxDPD = Source.MaxDPD,
        Target.SLAHours = Source.SLAHours,
        Target.ModifiedDate = GETDATE()

-- Insert new buckets
WHEN NOT MATCHED BY TARGET THEN
    INSERT (BucketName, BucketDisplayName, MinDPD, MaxDPD, SLAHours, IsActive, CreatedDate)
    VALUES (Source.BucketName, Source.BucketDisplayName, Source.MinDPD, Source.MaxDPD, Source.SLAHours, 1, GETDATE());

PRINT 'DPD Bucket Configuration seed data completed.';
GO
