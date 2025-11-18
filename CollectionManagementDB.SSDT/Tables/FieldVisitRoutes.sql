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
