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
