-- =============================================
-- Post-Deployment Script: System Configuration Seed Data
-- Description: Inserts default system configuration settings
-- Idempotent: Yes (uses MERGE statement)
-- =============================================

PRINT 'Seeding System Configuration data...';

MERGE INTO SystemConfiguration AS Target
USING (
    VALUES
        ('MaxLoginAttempts', '5', 'Integer', 'Security', 'Maximum failed login attempts before account lockout', '5', 0, 0, 1),
        ('SessionTimeoutMinutes', '30', 'Integer', 'Security', 'Session timeout in minutes', '30', 0, 0, 1),
        ('PasswordExpiryDays', '90', 'Integer', 'Security', 'Password expiry period in days', '90', 0, 0, 1),
        ('MaxCaseLoadPerRM', '100', 'Integer', 'Collection', 'Maximum case load per Relationship Manager', '100', 0, 0, 1),
        ('DefaultDPDBucketRefreshHours', '6', 'Integer', 'Collection', 'DPD bucket recalculation frequency', '6', 0, 0, 1),
        ('MaxDailyContactAttempts', '3', 'Integer', 'Collection', 'Maximum contact attempts per customer per day', '3', 0, 0, 1),
        ('PaymentLinkExpiryHours', '48', 'Integer', 'Payment', 'Payment link validity period', '48', 0, 0, 1),
        ('FieldVisitGeoFenceRadius', '50', 'Integer', 'FieldVisit', 'Geo-fence radius in meters for check-in', '50', 0, 0, 1),
        ('SMSGatewayURL', 'https://sms.gateway.example.com', 'String', 'Integration', 'SMS Gateway API URL', '', 0, 1, 1),
        ('EnableAutomatedWorkflows', 'true', 'Boolean', 'System', 'Enable/disable automated workflows', 'true', 0, 0, 1)
) AS Source (
    ConfigKey,
    ConfigValue,
    ConfigDataType,
    ConfigCategory,
    ConfigDescription,
    DefaultValue,
    IsEncrypted,
    IsSensitive,
    IsEditable
)
ON Target.ConfigKey = Source.ConfigKey

-- Update existing configurations only if they haven't been modified by users
-- (This respects user changes while ensuring new configs are added)
WHEN MATCHED AND Target.LastModifiedDate IS NULL THEN
    UPDATE SET
        Target.ConfigValue = Source.ConfigValue,
        Target.ConfigDataType = Source.ConfigDataType,
        Target.ConfigCategory = Source.ConfigCategory,
        Target.ConfigDescription = Source.ConfigDescription,
        Target.DefaultValue = Source.DefaultValue,
        Target.IsEncrypted = Source.IsEncrypted,
        Target.IsSensitive = Source.IsSensitive,
        Target.IsEditable = Source.IsEditable

-- Insert new configurations
WHEN NOT MATCHED BY TARGET THEN
    INSERT (
        ConfigKey,
        ConfigValue,
        ConfigDataType,
        ConfigCategory,
        ConfigDescription,
        DefaultValue,
        IsEncrypted,
        IsSensitive,
        IsEditable,
        IsActive,
        EffectiveFromDate
    )
    VALUES (
        Source.ConfigKey,
        Source.ConfigValue,
        Source.ConfigDataType,
        Source.ConfigCategory,
        Source.ConfigDescription,
        Source.DefaultValue,
        Source.IsEncrypted,
        Source.IsSensitive,
        Source.IsEditable,
        1,
        GETDATE()
    );

PRINT 'System Configuration seed data completed.';
GO
