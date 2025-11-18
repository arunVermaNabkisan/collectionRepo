# Collection Management System - Database Documentation

## Overview
This document provides comprehensive information about the database schema for the **NABKISAN Collection Management System**, designed based on the Functional Requirements Document (FRD) and Process Flows.

## Database Name
**CollectionManagementDB**

## Technology Stack
- **Database**: Microsoft SQL Server 2019 or higher / Azure SQL Database
- **ORM**: Dapper (Micro-ORM for .NET)
- **Language**: C# (.NET 6.0 or higher)

## Database Schema Overview

The database consists of **50+ tables** organized into the following categories:

### 1. Core Entities (01_CoreTables.sql)
- **Customers** - Customer master data with demographics, contact info, and KYC details
- **LoanAccounts** - Loan account information including outstanding amounts and EMI details
- **CollectionCases** - Collection case management with status tracking and assignment
- **CaseStatusHistory** - Audit trail for case status changes
- **DPDBucketConfiguration** - Configurable DPD (Days Past Due) bucket definitions

### 2. Users and Teams (02_UserAndTeamTables.sql)
- **Roles** - Role-based access control definitions
- **Teams** - Team structure and hierarchy
- **Users** - User accounts for RMs, supervisors, and external agents
- **ExternalRecoveryAgencies** - External collection agency management
- **UserSessionLogs** - User login/logout tracking
- **TeamMemberHistory** - Team assignment history
- **UserPerformanceMetrics** - Agent performance tracking (daily, weekly, monthly)

### 3. Communications (03_CommunicationTables.sql)
- **CustomerInteractions** - Unified interaction history across all channels
- **VoiceCallLogs** - Detailed voice call records with recording info
- **SMSLogs** - SMS communication tracking with delivery status
- **EmailLogs** - Email communication with engagement tracking
- **WhatsAppLogs** - WhatsApp Business API message tracking
- **CommunicationTemplates** - Template library for all channels
- **CommunicationCampaigns** - Automated campaign management

### 4. Promise to Pay & Payments (04_PTPAndPaymentTables.sql)
- **PromiseToPay** - PTP tracking with single and split payment support
- **PTPStatusHistory** - PTP status change audit trail
- **PaymentTransactions** - Payment processing across all modes
- **PaymentAllocation** - Payment allocation to principal, interest, charges
- **PaymentLinks** - Dynamic payment link generation and tracking
- **SettlementProposals** - Settlement negotiation and approval workflow

### 5. Field Visits (05_FieldVisitTables.sql)
- **FieldVisits** - Field visit scheduling and execution
- **FieldVisitEvidence** - Photos, voice notes, documents from field visits
- **FieldVisitRoutes** - Route planning and optimization
- **RouteVisitMapping** - Visit sequencing within routes
- **FieldAgentLocationTracking** - Real-time GPS tracking
- **FieldVisitExpenses** - Expense management for field operations

### 6. Strategies & Workflows (06_StrategyAndWorkflowTables.sql)
- **CollectionStrategies** - Collection strategy definitions
- **CaseStrategyAssignment** - Strategy allocation to cases
- **WorkflowRules** - Automation rules engine
- **WorkflowExecutionLog** - Workflow execution history
- **EscalationRules** - Horizontal and vertical escalation logic
- **CaseEscalationHistory** - Escalation tracking
- **BehavioralScoringRules** - Customer behavior scoring framework
- **CustomerBehavioralScores** - Calculated behavioral scores

### 7. Documents & Audit (07_DocumentAndAuditTables.sql)
- **Documents** - Document management with versioning
- **DocumentAccessLog** - Document access audit trail
- **AuditTrail** - Comprehensive audit logging for all operations
- **SystemConfiguration** - System-wide configuration parameters
- **ComplianceChecklist** - RBI and regulatory compliance tracking
- **DataSyncLog** - LMS synchronization logs
- **ErrorLog** - Application error tracking
- **NotificationQueue** - Notification management and delivery

## Execution Order

Execute the SQL scripts in the following order:

```
1. 00_DatabaseInitialization.sql       - Create database and configure settings
2. 01_CoreTables.sql                    - Customer, Loan, Case tables
3. 02_UserAndTeamTables.sql             - Users, Teams, Roles
4. 03_CommunicationTables.sql           - Multi-channel communication
5. 04_PTPAndPaymentTables.sql           - PTP and Payment management
6. 05_FieldVisitTables.sql              - Field visit operations
7. 06_StrategyAndWorkflowTables.sql     - Strategies and automation
8. 07_DocumentAndAuditTables.sql        - Documents and audit trails
9. 08_ViewsAndStoredProcedures.sql      - Database views and stored procedures
```

## Key Features

### 1. DPD Bucket Management
- Configurable bucket definitions (0-30, 31-60, 61-90, 91-180, 180+)
- Product-specific bucket configurations
- Automatic bucket classification
- Roll-forward and roll-backward analysis

### 2. Multi-Channel Communication
- Voice (VOIP integration)
- SMS (Gateway integration)
- Email (ESP integration)
- WhatsApp Business API
- Unified interaction history

### 3. Promise to Pay (PTP)
- Single and split PTP support
- Confidence level tracking
- Automated reminders
- PTP performance analytics
- Broken PTP tracking and escalation

### 4. Payment Management
- Multi-mode payment support (UPI, NEFT, Cash, Cheque, etc.)
- Payment gateway integration
- Payment link generation
- Automated reconciliation
- Payment allocation hierarchy (Charges → Interest → Principal)

### 5. Field Visit Management
- GPS-based check-in/check-out
- Evidence capture (Photos, Voice notes, Documents)
- Route optimization
- Real-time agent tracking
- Visit outcome tracking

### 6. Collection Strategies
- Risk-based strategy assignment
- Automated workflow execution
- Escalation management (Horizontal & Vertical)
- Behavioral scoring
- Predictive analytics support

### 7. Audit & Compliance
- Comprehensive audit trails
- RBI compliance tracking
- Document management with versioning
- Fair Practices Code adherence
- Data privacy compliance

## Database Views

### vw_ActiveCasesDetail
Complete case information with customer, loan, RM, and team details

### vw_PTPDashboard
PTP tracking with due date analysis and status categorization

### vw_FieldVisitSummary
Field visit execution summary with evidence counts

### vw_PaymentSummary
Payment tracking with allocation status

## Stored Procedures

### sp_GetCaseDetailsByCaseID
Retrieves complete case information with related entities

### sp_GetAgentWorklist
Generates prioritized worklist for collection agents

### sp_CreatePromiseToPay
Creates PTP with validation and case updates

### sp_RecordPayment
Records payment transaction with case updates

### sp_GetDashboardMetrics
Returns dashboard KPIs for users/teams

## Indexes and Performance

- **Primary Keys**: All tables have identity-based primary keys
- **Foreign Keys**: Referential integrity enforced
- **Indexes**: Strategic indexing on frequently queried columns
  - Search columns (Customer Code, Loan Number, Case Number)
  - Status columns (Case Status, Payment Status, PTP Status)
  - Date columns (Created Date, Payment Date, PTP Date)
  - Assignment columns (User ID, Team ID)

## Data Relationships

```
Customer (1) → (M) LoanAccounts
LoanAccount (1) → (M) CollectionCases
CollectionCase (1) → (M) CustomerInteractions
CollectionCase (1) → (M) PromiseToPay
CollectionCase (1) → (M) PaymentTransactions
CollectionCase (1) → (M) FieldVisits
User (1) → (M) CollectionCases (Assignment)
Team (1) → (M) CollectionCases (Assignment)
```

## Computed Columns

Several tables use computed columns for real-time calculations:
- **Customer.FullName**: Concatenated first, middle, last name
- **Customer.Age**: Calculated from DateOfBirth
- **LoanAccount.TotalOutstanding**: Sum of all outstanding components
- **CollectionCase.PTPSuccessRate**: PTPsKept / TotalPTPsMade * 100
- **PaymentTransaction.UnallocatedAmount**: PaymentAmount - AllocatedAmount

## Check Constraints

Data integrity enforced through check constraints:
- Gender values (Male, Female, Other)
- Status fields (predefined valid values)
- Score ranges (0-100, 0-1000)
- DPD bucket ranges

## Dapper Integration

### Required NuGet Packages
```
Dapper (2.1.24 or higher)
Microsoft.Data.SqlClient (5.1.5 or higher)
```

### Sample Models Provided
- `Customer.cs`
- `CollectionCase.cs`
- `PromiseToPay.cs`
- `DapperContext.cs`
- `CaseRepository.cs`

## Configuration

### Connection String Format

**On-Premise SQL Server:**
```json
"Server=YOUR_SERVER;Database=CollectionManagementDB;User Id=YOUR_USER;Password=YOUR_PASSWORD;TrustServerCertificate=True;"
```

**Azure SQL Database:**
```json
"Server=tcp:yourserver.database.windows.net,1433;Initial Catalog=CollectionManagementDB;User ID=your_username;Password=your_password;Encrypt=True;TrustServerCertificate=False;"
```

## Security Considerations

1. **Encryption**: Sensitive fields (Aadhar, PAN) should be encrypted at application level
2. **Access Control**: Implement row-level security for multi-tenant scenarios
3. **Audit Logs**: All operations logged in AuditTrail table
4. **Role-Based Access**: Enforced through Roles and Users tables
5. **Password Security**: Store only hashed passwords with salt

## Backup Strategy

Recommended backup approach:
- **Full Backup**: Daily at 2 AM
- **Differential Backup**: Every 6 hours
- **Transaction Log Backup**: Every 15 minutes
- **Retention**: 30 days for compliance

## Maintenance Tasks

### Daily
- DPD bucket recalculation (BOD/EOD)
- PTP reminder generation
- Payment reconciliation
- Data synchronization with LMS

### Weekly
- Index maintenance (rebuild/reorganize)
- Statistics update
- Archive old audit logs

### Monthly
- Performance metrics aggregation
- Compliance report generation
- Data archival (closed cases > 1 year)

## Monitoring & Health Checks

Monitor these key metrics:
- Database size growth
- Index fragmentation
- Long-running queries
- Deadlocks
- Failed sync operations
- API integration errors

## Scalability Considerations

1. **Partitioning**: Consider table partitioning for large tables (Interactions, Audit Trail)
2. **Archival**: Move historical data to archive tables
3. **Read Replicas**: Use for reporting and analytics
4. **Caching**: Implement Redis for frequently accessed data
5. **Connection Pooling**: Configure appropriate pool sizes

## Compliance & Regulatory

### RBI Guidelines
- Fair Practices Code implementation
- Customer grievance tracking
- Communication frequency limits
- Legal notice requirements

### Data Protection
- PII data encryption
- Consent management
- Right to information
- Data retention policies

## Support & Documentation

For detailed information:
- **FRD**: `NABKISAN_Collections_FRD_FInal 1.md`
- **Process Flows**: `NABKISAN_Process_Flows (2).md`
- **Dapper Setup**: `DapperModels/README_DapperSetup.md`

## Database Statistics

- **Total Tables**: 50+
- **Total Views**: 4
- **Total Stored Procedures**: 5
- **Total Indexes**: 150+
- **Estimated Row Counts** (at scale):
  - Customers: 100,000+
  - Loan Accounts: 150,000+
  - Collection Cases: 50,000+ (active)
  - Interactions: 1,000,000+
  - Payments: 500,000+

## Version History

- **v1.0** (Nov 2024): Initial database schema based on FRD
  - Core entity tables
  - Communication management
  - PTP and payment tracking
  - Field visit management
  - Strategy and workflow automation
  - Document and audit management

---

**Document Prepared By**: Claude AI Assistant
**Date**: November 18, 2024
**Based On**: NABKISAN Collection Management System FRD v1.0
