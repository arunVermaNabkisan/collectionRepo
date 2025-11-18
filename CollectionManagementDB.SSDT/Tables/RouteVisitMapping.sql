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
