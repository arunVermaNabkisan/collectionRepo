-- =============================================
-- 1. CUSTOMER INTERACTIONS TABLE
-- =============================================
CREATE TABLE CustomerInteractions (
    InteractionID BIGINT IDENTITY(1,1) PRIMARY KEY,
    InteractionReference NVARCHAR(100) NOT NULL UNIQUE,

    -- Links
    CaseID BIGINT NOT NULL,
    CustomerID BIGINT NOT NULL,
    LoanAccountID BIGINT NOT NULL,
    InitiatedByUserID BIGINT NULL,

    -- Interaction Details
    InteractionChannel NVARCHAR(50) NOT NULL, -- Voice, SMS, Email, WhatsApp, FieldVisit
    InteractionDirection NVARCHAR(20) NOT NULL, -- Outbound, Inbound
    InteractionType NVARCHAR(100) NOT NULL, -- Reminder, Follow-up, PTP, Payment, Dispute, etc.

    InteractionDateTime DATETIME DEFAULT GETDATE(),
    InteractionDuration INT DEFAULT 0, -- in seconds

    -- Contact Result
    ContactStatus NVARCHAR(50) NOT NULL,
    -- ContactSuccess, NoAnswer, Busy, InvalidNumber, Disconnected,
    -- CustomerNotAvailable, Callback, etc.

    DispositionCode NVARCHAR(100) NULL,
    SubDispositionCode NVARCHAR(100) NULL,

    -- Customer Response
    CustomerResponse NVARCHAR(MAX) NULL,
    CustomerSentiment NVARCHAR(50) NULL, -- Positive, Negative, Neutral, Angry, Cooperative
    IsRightPartyContact BIT DEFAULT 0,

    -- Outcome
    InteractionOutcome NVARCHAR(100) NULL,
    -- PTPCreated, PaymentPromised, PaymentMade, Dispute, Refusal,
    -- CallbackRequested, InformationUpdated, NoResponse, etc.

    PTPCreated BIT DEFAULT 0,
    PaymentMade BIT DEFAULT 0,
    DisputeRaised BIT DEFAULT 0,
    CallbackRequested BIT DEFAULT 0,
    CallbackDateTime DATETIME NULL,

    -- Notes and Remarks
    AgentNotes NVARCHAR(MAX) NULL,
    SystemNotes NVARCHAR(MAX) NULL,

    -- Quality and Compliance
    IsRecorded BIT DEFAULT 0,
    RecordingURL NVARCHAR(500) NULL,
    RecordingDuration INT DEFAULT 0,
    QualityScore DECIMAL(5,2) NULL,
    ComplianceScore DECIMAL(5,2) NULL,
    IsReviewed BIT DEFAULT 0,
    ReviewedByUserID BIGINT NULL,
    ReviewedDate DATETIME NULL,

    -- Follow-up
    RequiresFollowUp BIT DEFAULT 0,
    FollowUpDate DATETIME NULL,
    FollowUpAssignedTo BIGINT NULL,

    CreatedDate DATETIME DEFAULT GETDATE(),
    CreatedBy BIGINT NULL,

    CONSTRAINT FK_Interaction_Case FOREIGN KEY (CaseID) REFERENCES CollectionCases(CaseID),
    CONSTRAINT FK_Interaction_Customer FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT FK_Interaction_Loan FOREIGN KEY (LoanAccountID) REFERENCES LoanAccounts(LoanAccountID),
    CONSTRAINT FK_Interaction_User FOREIGN KEY (InitiatedByUserID) REFERENCES Users(UserID),
    CONSTRAINT CK_InteractionChannel CHECK (InteractionChannel IN ('Voice', 'SMS', 'Email', 'WhatsApp', 'FieldVisit', 'WebChat', 'IVR')),
    CONSTRAINT CK_InteractionDirection CHECK (InteractionDirection IN ('Outbound', 'Inbound'))
);

CREATE INDEX IDX_Interaction_Case ON CustomerInteractions(CaseID);
CREATE INDEX IDX_Interaction_Customer ON CustomerInteractions(CustomerID);
CREATE INDEX IDX_Interaction_Date ON CustomerInteractions(InteractionDateTime);
CREATE INDEX IDX_Interaction_Channel ON CustomerInteractions(InteractionChannel);
CREATE INDEX IDX_Interaction_User ON CustomerInteractions(InitiatedByUserID);
CREATE INDEX IDX_Interaction_Outcome ON CustomerInteractions(InteractionOutcome);
GO
