-- =============================================
-- Post-Deployment Script: Roles Seed Data
-- Description: Inserts default system roles
-- Idempotent: Yes (uses MERGE statement)
-- =============================================

PRINT 'Seeding Roles data...';

MERGE INTO Roles AS Target
USING (
    VALUES
        ('System Admin', 'System Administrator with full access', 1, 1, 1, 0, 0, 1, 1),
        ('CXO', 'Chief Executive Officer / Senior Management', 2, 1, 1, 0, 0, 1, 0),
        ('Vertical Head', 'Business Line Vertical Head', 3, 1, 1, 0, 0, 1, 0),
        ('Team Leader', 'First-line manager / Supervisor', 4, 1, 1, 0, 0, 1, 0),
        ('Relationship Manager', 'Collection Agent / RM', 5, 0, 0, 0, 0, 0, 0),
        ('External Recovery Executive', 'External Agency Executive', 5, 0, 0, 0, 0, 0, 0),
        ('Quality Analyst', 'Quality Assurance Analyst', 4, 1, 0, 0, 0, 1, 0),
        ('MIS Analyst', 'Reporting and Analytics', 4, 1, 0, 0, 0, 1, 0)
) AS Source (
    RoleName,
    RoleDescription,
    RoleLevel,
    CanViewAllCases,
    CanReassignCases,
    CanModifyStrategies,
    CanApproveSettlements,
    CanAccessReports,
    CanManageUsers
)
ON Target.RoleName = Source.RoleName

-- Update existing roles if permissions have changed
WHEN MATCHED THEN
    UPDATE SET
        Target.RoleDescription = Source.RoleDescription,
        Target.RoleLevel = Source.RoleLevel,
        Target.CanViewAllCases = Source.CanViewAllCases,
        Target.CanReassignCases = Source.CanReassignCases,
        Target.CanModifyStrategies = Source.CanModifyStrategies,
        Target.CanApproveSettlements = Source.CanApproveSettlements,
        Target.CanAccessReports = Source.CanAccessReports,
        Target.CanManageUsers = Source.CanManageUsers,
        Target.ModifiedDate = GETDATE()

-- Insert new roles
WHEN NOT MATCHED BY TARGET THEN
    INSERT (
        RoleName,
        RoleDescription,
        RoleLevel,
        CanViewAllCases,
        CanReassignCases,
        CanModifyStrategies,
        CanApproveSettlements,
        CanAccessReports,
        CanManageUsers,
        IsActive,
        CreatedDate
    )
    VALUES (
        Source.RoleName,
        Source.RoleDescription,
        Source.RoleLevel,
        Source.CanViewAllCases,
        Source.CanReassignCases,
        Source.CanModifyStrategies,
        Source.CanApproveSettlements,
        Source.CanAccessReports,
        Source.CanManageUsers,
        1,
        GETDATE()
    );

PRINT 'Roles seed data completed.';
GO
