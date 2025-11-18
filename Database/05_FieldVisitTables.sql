-- =============================================
-- Collection Management System - Field Visit Tables
-- Purpose: Field Collection and Visit Management
-- =============================================

USE CollectionManagementDB;
GO

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

-- =============================================
-- 2. FIELD VISIT EVIDENCE TABLE
-- =============================================
CREATE TABLE FieldVisitEvidence (
    EvidenceID BIGINT IDENTITY(1,1) PRIMARY KEY,
    FieldVisitID BIGINT NOT NULL,

    -- Evidence Type
    EvidenceType NVARCHAR(50) NOT NULL, -- Photo, VoiceNote, Document, Video
    EvidenceCategory NVARCHAR(100) NULL,
    -- Property, Customer, Document, Asset, Signature, etc.

    -- File Details
    FileName NVARCHAR(500) NOT NULL,
    FilePath NVARCHAR(1000) NOT NULL,
    FileSize BIGINT DEFAULT 0, -- in bytes
    FileType NVARCHAR(50) NULL, -- jpg, png, pdf, mp3, mp4, etc.
    MimeType NVARCHAR(100) NULL,

    -- Capture Details
    CapturedDateTime DATETIME DEFAULT GETDATE(),
    CapturedByUserID BIGINT NOT NULL,

    -- Location Details
    CaptureLocationLat DECIMAL(10,8) NULL,
    CaptureLocationLong DECIMAL(11,8) NULL,
    CaptureAddress NVARCHAR(500) NULL,

    -- Device Information
    DeviceID NVARCHAR(200) NULL,
    DeviceModel NVARCHAR(200) NULL,
    DeviceOS NVARCHAR(100) NULL,

    -- Photo/Video Metadata
    ImageResolution NVARCHAR(50) NULL,
    VideoDuration INT DEFAULT 0, -- in seconds
    AudioDuration INT DEFAULT 0, -- in seconds

    -- Transcription (for voice notes)
    IsTranscribed BIT DEFAULT 0,
    TranscriptionText NVARCHAR(MAX) NULL,
    TranscriptionConfidence DECIMAL(5,2) NULL,

    -- Security
    FileHash NVARCHAR(500) NULL, -- SHA-256 hash for integrity
    IsEncrypted BIT DEFAULT 0,
    DigitalSignature NVARCHAR(MAX) NULL,

    -- Processing Status
    ProcessingStatus NVARCHAR(50) DEFAULT 'Uploaded',
    -- Uploaded, Processing, Processed, Failed, Verified

    Description NVARCHAR(1000) NULL,
    Tags NVARCHAR(500) NULL, -- Comma-separated tags

    CreatedDate DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_Evidence_Visit FOREIGN KEY (FieldVisitID) REFERENCES FieldVisits(FieldVisitID),
    CONSTRAINT FK_Evidence_User FOREIGN KEY (CapturedByUserID) REFERENCES Users(UserID),
    CONSTRAINT CK_Evidence_Type CHECK (EvidenceType IN ('Photo', 'VoiceNote', 'Document', 'Video', 'Signature'))
);

CREATE INDEX IDX_Evidence_Visit ON FieldVisitEvidence(FieldVisitID);
CREATE INDEX IDX_Evidence_Type ON FieldVisitEvidence(EvidenceType);
CREATE INDEX IDX_Evidence_Date ON FieldVisitEvidence(CapturedDateTime);
GO

-- =============================================
-- 3. FIELD VISIT ROUTES TABLE
-- =============================================
CREATE TABLE FieldVisitRoutes (
    RouteID BIGINT IDENTITY(1,1) PRIMARY KEY,
    RouteNumber NVARCHAR(50) NOT NULL UNIQUE,

    -- Assignment
    AssignedToUserID BIGINT NOT NULL,
    RouteDate DATE NOT NULL,

    -- Route Details
    TotalVisits INT DEFAULT 0,
    CompletedVisits INT DEFAULT 0,
    PendingVisits INT DEFAULT 0,
    CancelledVisits INT DEFAULT 0,

    -- Route Optimization
    EstimatedDistance DECIMAL(10,2) DEFAULT 0, -- in kilometers
    ActualDistance DECIMAL(10,2) DEFAULT 0,
    EstimatedDuration INT DEFAULT 0, -- in minutes
    ActualDuration INT DEFAULT 0,

    -- Route Status
    RouteStatus NVARCHAR(50) NOT NULL,
    -- Planned, InProgress, Completed, Cancelled
    StartDateTime DATETIME NULL,
    EndDateTime DATETIME NULL,

    -- Performance
    PaymentCollectionTarget DECIMAL(18,2) DEFAULT 0,
    PaymentCollectionActual DECIMAL(18,2) DEFAULT 0,
    CollectionEfficiency AS (
        CASE
            WHEN PaymentCollectionTarget > 0 THEN
                (PaymentCollectionActual / PaymentCollectionTarget) * 100
            ELSE 0
        END
    ) PERSISTED,

    -- Start and End Locations
    StartLocationLat DECIMAL(10,8) NULL,
    StartLocationLong DECIMAL(11,8) NULL,
    EndLocationLat DECIMAL(10,8) NULL,
    EndLocationLong DECIMAL(11,8) NULL,

    Notes NVARCHAR(MAX) NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),
    CreatedBy BIGINT NULL,

    CONSTRAINT FK_Route_User FOREIGN KEY (AssignedToUserID) REFERENCES Users(UserID),
    CONSTRAINT CK_Route_Status CHECK (RouteStatus IN ('Planned', 'InProgress', 'Completed', 'Cancelled'))
);

CREATE INDEX IDX_Route_Number ON FieldVisitRoutes(RouteNumber);
CREATE INDEX IDX_Route_User ON FieldVisitRoutes(AssignedToUserID);
CREATE INDEX IDX_Route_Date ON FieldVisitRoutes(RouteDate);
GO

-- =============================================
-- 4. ROUTE VISIT MAPPING TABLE
-- =============================================
CREATE TABLE RouteVisitMapping (
    MappingID BIGINT IDENTITY(1,1) PRIMARY KEY,
    RouteID BIGINT NOT NULL,
    FieldVisitID BIGINT NOT NULL,

    SequenceNumber INT NOT NULL, -- Visit sequence in route
    EstimatedArrivalTime DATETIME NULL,
    ActualArrivalTime DATETIME NULL,

    DistanceFromPrevious DECIMAL(10,2) DEFAULT 0, -- in kilometers
    TravelTimeFro mPrevious INT DEFAULT 0, -- in minutes

    IsCompleted BIT DEFAULT 0,
    CompletionDateTime DATETIME NULL,

    CONSTRAINT FK_RouteMap_Route FOREIGN KEY (RouteID) REFERENCES FieldVisitRoutes(RouteID),
    CONSTRAINT FK_RouteMap_Visit FOREIGN KEY (FieldVisitID) REFERENCES FieldVisits(FieldVisitID)
);

CREATE INDEX IDX_RouteMap_Route ON RouteVisitMapping(RouteID);
CREATE INDEX IDX_RouteMap_Visit ON RouteVisitMapping(FieldVisitID);
CREATE INDEX IDX_RouteMap_Sequence ON RouteVisitMapping(RouteID, SequenceNumber);
GO

-- =============================================
-- 5. FIELD AGENT LOCATION TRACKING TABLE
-- =============================================
CREATE TABLE FieldAgentLocationTracking (
    LocationID BIGINT IDENTITY(1,1) PRIMARY KEY,
    UserID BIGINT NOT NULL,
    RouteID BIGINT NULL,

    -- Location Details
    Latitude DECIMAL(10,8) NOT NULL,
    Longitude DECIMAL(11,8) NOT NULL,
    Accuracy DECIMAL(10,2) NULL, -- in meters
    Altitude DECIMAL(10,2) NULL,

    -- Tracking Time
    TrackedDateTime DATETIME DEFAULT GETDATE(),

    -- Speed and Movement
    Speed DECIMAL(10,2) NULL, -- in km/h
    Heading DECIMAL(5,2) NULL, -- in degrees
    IsMoving BIT DEFAULT 0,

    -- Battery and Device Status
    BatteryLevel INT NULL, -- 0-100
    IsCharging BIT DEFAULT 0,
    NetworkType NVARCHAR(50) NULL, -- WiFi, 4G, 3G, etc.

    -- Activity Recognition
    ActivityType NVARCHAR(50) NULL, -- Still, Walking, Driving, etc.
    ActivityConfidence DECIMAL(5,2) NULL,

    -- Address (reverse geocoded)
    Address NVARCHAR(500) NULL,
    City NVARCHAR(100) NULL,
    State NVARCHAR(100) NULL,

    CreatedDate DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_Location_User FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT FK_Location_Route FOREIGN KEY (RouteID) REFERENCES FieldVisitRoutes(RouteID)
);

CREATE INDEX IDX_Location_User ON FieldAgentLocationTracking(UserID);
CREATE INDEX IDX_Location_DateTime ON FieldAgentLocationTracking(TrackedDateTime);
CREATE INDEX IDX_Location_Route ON FieldAgentLocationTracking(RouteID);
CREATE INDEX IDX_Location_User_DateTime ON FieldAgentLocationTracking(UserID, TrackedDateTime);
GO

-- =============================================
-- 6. FIELD VISIT EXPENSES TABLE
-- =============================================
CREATE TABLE FieldVisitExpenses (
    ExpenseID BIGINT IDENTITY(1,1) PRIMARY KEY,
    FieldVisitID BIGINT NULL,
    RouteID BIGINT NULL,
    UserID BIGINT NOT NULL,

    -- Expense Details
    ExpenseDate DATE NOT NULL,
    ExpenseType NVARCHAR(100) NOT NULL,
    -- Travel, Food, Parking, Toll, Vehicle, Accommodation, etc.

    ExpenseAmount DECIMAL(18,2) NOT NULL,
    Currency NVARCHAR(10) DEFAULT 'INR',

    -- Billing Details
    BillNumber NVARCHAR(100) NULL,
    VendorName NVARCHAR(200) NULL,

    -- Approval
    ApprovalStatus NVARCHAR(50) DEFAULT 'Pending',
    -- Pending, Approved, Rejected, Paid
    ApprovedByUserID BIGINT NULL,
    ApprovedDate DATETIME NULL,
    RejectionReason NVARCHAR(500) NULL,

    -- Reimbursement
    ReimbursementAmount DECIMAL(18,2) DEFAULT 0,
    ReimbursementDate DATE NULL,
    PaymentReference NVARCHAR(100) NULL,

    -- Supporting Documents
    ReceiptPath NVARCHAR(500) NULL,
    HasReceipt BIT DEFAULT 0,

    Description NVARCHAR(1000) NULL,
    Remarks NVARCHAR(MAX) NULL,

    CreatedDate DATETIME DEFAULT GETDATE(),
    CreatedBy BIGINT NULL,

    CONSTRAINT FK_Expense_Visit FOREIGN KEY (FieldVisitID) REFERENCES FieldVisits(FieldVisitID),
    CONSTRAINT FK_Expense_Route FOREIGN KEY (RouteID) REFERENCES FieldVisitRoutes(RouteID),
    CONSTRAINT FK_Expense_User FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT CK_Expense_Status CHECK (ApprovalStatus IN ('Pending', 'Approved', 'Rejected', 'Paid'))
);

CREATE INDEX IDX_Expense_Visit ON FieldVisitExpenses(FieldVisitID);
CREATE INDEX IDX_Expense_Route ON FieldVisitExpenses(RouteID);
CREATE INDEX IDX_Expense_User ON FieldVisitExpenses(UserID);
CREATE INDEX IDX_Expense_Status ON FieldVisitExpenses(ApprovalStatus);
GO
