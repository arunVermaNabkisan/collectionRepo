-- =============================================
-- 1. FIELD VISITS TABLE
-- =============================================
CREATE TABLE FieldVisits (
    FieldVisitID BIGINT IDENTITY(1,1) PRIMARY KEY,
    VisitNumber NVARCHAR(50) NOT NULL UNIQUE,

    -- Links
    CaseID BIGINT NOT NULL,
    CustomerID BIGINT NOT NULL,
    LoanAccountID BIGINT NOT NULL,
    InteractionID BIGINT NULL,

    -- Assignment
    AssignedToUserID BIGINT NOT NULL,
    AssignedDate DATETIME DEFAULT GETDATE(),
    AssignedByUserID BIGINT NULL,

    -- Visit Type
    VisitType NVARCHAR(50) NOT NULL,
    -- Collection, Verification, Investigation, Legal Notice, Asset Inspection
    VisitPriority NVARCHAR(20) NOT NULL, -- Critical, High, Medium, Low
    VisitPurpose NVARCHAR(500) NULL,

    -- Schedule
    ScheduledDate DATE NOT NULL,
    ScheduledTime TIME NULL,
    PreferredTimeSlot NVARCHAR(50) NULL, -- Morning, Afternoon, Evening

    -- Visit Address
    VisitAddressType NVARCHAR(50) NOT NULL, -- Current, Permanent, Office, Alternate
    VisitAddressLine1 NVARCHAR(500) NOT NULL,
    VisitAddressLine2 NVARCHAR(500) NULL,
    VisitCity NVARCHAR(100) NULL,
    VisitState NVARCHAR(100) NULL,
    VisitPincode NVARCHAR(10) NULL,
    VisitLocationLat DECIMAL(10,8) NULL,
    VisitLocationLong DECIMAL(11,8) NULL,

    -- Check-in Details
    CheckInDateTime DATETIME NULL,
    CheckInLocationLat DECIMAL(10,8) NULL,
    CheckInLocationLong DECIMAL(11,8) NULL,
    CheckInAddress NVARCHAR(500) NULL,
    DistanceFromScheduledLocation DECIMAL(10,2) NULL, -- in meters
    IsGeoVerified BIT DEFAULT 0,

    -- Check-out Details
    CheckOutDateTime DATETIME NULL,
    CheckOutLocationLat DECIMAL(10,8) NULL,
    CheckOutLocationLong DECIMAL(11,8) NULL,
    VisitDuration AS (DATEDIFF(MINUTE, CheckInDateTime, CheckOutDateTime)) PERSISTED,

    -- Visit Outcome
    VisitStatus NVARCHAR(50) NOT NULL,
    -- Scheduled, InProgress, Completed, Cancelled, CustomerNotFound, CustomerRefused
    VisitOutcome NVARCHAR(100) NULL,
    -- Met Customer, Payment Collected, PTP Taken, Customer Refused,
    -- Customer Not Available, Address Incorrect, Property Locked, etc.

    IsCustomerMet BIT DEFAULT 0,
    PersonMetName NVARCHAR(200) NULL,
    PersonMetRelation NVARCHAR(100) NULL, -- Self, Spouse, Parent, etc.

    -- Payment Collection
    IsPaymentCollected BIT DEFAULT 0,
    PaymentAmount DECIMAL(18,2) DEFAULT 0,
    PaymentMode NVARCHAR(50) NULL,
    PaymentTransactionID BIGINT NULL,

    -- PTP Creation
    IsPTPCreated BIT DEFAULT 0,
    PTPID BIGINT NULL,

    -- Evidence Collection
    PhotosCount INT DEFAULT 0,
    VoiceNotesCount INT DEFAULT 0,
    DocumentsCount INT DEFAULT 0,

    -- Customer Behavior
    CustomerBehavior NVARCHAR(100) NULL, -- Cooperative, Aggressive, Evasive, etc.
    CustomerSentiment NVARCHAR(50) NULL, -- Positive, Negative, Neutral
    WillingnessToPay NVARCHAR(50) NULL, -- High, Medium, Low, None

    -- Property/Asset Observation
    PropertyType NVARCHAR(100) NULL, -- Owned House, Rented, Commercial, etc.
    PropertyCondition NVARCHAR(100) NULL, -- Good, Average, Poor
    AssetsSeen NVARCHAR(500) NULL,
    EstimatedPropertyValue DECIMAL(18,2) NULL,

    -- Neighborhood Details
    NeighborhoodType NVARCHAR(100) NULL, -- Residential, Commercial, Rural, etc.
    AccessibilityRating NVARCHAR(20) NULL, -- Easy, Moderate, Difficult

    -- Follow-up Requirements
    RequiresFollowUp BIT DEFAULT 0,
    FollowUpDate DATE NULL,
    FollowUpRemarks NVARCHAR(MAX) NULL,

    -- Escalation
    IsEscalated BIT DEFAULT 0,
    EscalatedToUserID BIGINT NULL,
    EscalationReason NVARCHAR(500) NULL,

    -- Agent Notes
    VisitRemarks NVARCHAR(MAX) NULL,
    DetailedNotes NVARCHAR(MAX) NULL,
    InternalNotes NVARCHAR(MAX) NULL, -- Not visible to customer

    -- Quality and Compliance
    IsReviewed BIT DEFAULT 0,
    ReviewedByUserID BIGINT NULL,
    ReviewedDate DATETIME NULL,
    QualityScore DECIMAL(5,2) NULL,
    ComplianceIssues NVARCHAR(MAX) NULL,

    -- Metadata
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL,
    ModifiedBy BIGINT NULL,

    CONSTRAINT FK_Visit_Case FOREIGN KEY (CaseID) REFERENCES CollectionCases(CaseID),
    CONSTRAINT FK_Visit_Customer FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT FK_Visit_Loan FOREIGN KEY (LoanAccountID) REFERENCES LoanAccounts(LoanAccountID),
    CONSTRAINT FK_Visit_Interaction FOREIGN KEY (InteractionID) REFERENCES CustomerInteractions(InteractionID),
    CONSTRAINT FK_Visit_Agent FOREIGN KEY (AssignedToUserID) REFERENCES Users(UserID),
    CONSTRAINT FK_Visit_Payment FOREIGN KEY (PaymentTransactionID) REFERENCES PaymentTransactions(PaymentTransactionID),
    CONSTRAINT FK_Visit_PTP FOREIGN KEY (PTPID) REFERENCES PromiseToPay(PTPID),
    CONSTRAINT CK_Visit_Status CHECK (VisitStatus IN (
        'Scheduled', 'InProgress', 'Completed', 'Cancelled',
        'CustomerNotFound', 'CustomerRefused', 'Postponed'
    )),
    CONSTRAINT CK_Visit_Priority CHECK (VisitPriority IN ('Critical', 'High', 'Medium', 'Low'))
);

CREATE INDEX IDX_Visit_Number ON FieldVisits(VisitNumber);
CREATE INDEX IDX_Visit_Case ON FieldVisits(CaseID);
CREATE INDEX IDX_Visit_Agent ON FieldVisits(AssignedToUserID);
CREATE INDEX IDX_Visit_Date ON FieldVisits(ScheduledDate);
CREATE INDEX IDX_Visit_Status ON FieldVisits(VisitStatus);
CREATE INDEX IDX_Visit_CheckIn ON FieldVisits(CheckInDateTime);
GO
