-- =============================================
-- 7. USER PERFORMANCE METRICS TABLE
-- =============================================
CREATE TABLE UserPerformanceMetrics (
    MetricID BIGINT IDENTITY(1,1) PRIMARY KEY,
    UserID BIGINT NOT NULL,

    -- Time Period
    MetricDate DATE NOT NULL,
    MetricPeriod NVARCHAR(20) NOT NULL, -- Daily, Weekly, Monthly, Quarterly

    -- Activity Metrics
    TotalCasesWorked INT DEFAULT 0,
    TotalCallAttempts INT DEFAULT 0,
    SuccessfulCalls INT DEFAULT 0,
    RightPartyContactRate DECIMAL(5,2) DEFAULT 0,

    -- Collection Metrics
    TotalAmountCollected DECIMAL(18,2) DEFAULT 0,
    NumberOfRecoveries INT DEFAULT 0,
    AverageRecoveryAmount DECIMAL(18,2) DEFAULT 0,

    -- PTP Metrics
    PTPsCreated INT DEFAULT 0,
    PTPsKept INT DEFAULT 0,
    PTPSuccessRate DECIMAL(5,2) DEFAULT 0,

    -- Field Visit Metrics
    FieldVisitsConducted INT DEFAULT 0,
    SuccessfulFieldVisits INT DEFAULT 0,

    -- Quality Metrics
    QualityScore DECIMAL(5,2) DEFAULT 0,
    ComplianceScore DECIMAL(5,2) DEFAULT 0,
    CustomerSatisfactionScore DECIMAL(5,2) DEFAULT 0,

    -- Time Metrics
    TotalWorkingHours DECIMAL(10,2) DEFAULT 0,
    AverageTalkTime INT DEFAULT 0, -- in seconds
    AverageHandlingTime INT DEFAULT 0, -- in seconds

    -- Target Achievement
    CollectionTarget DECIMAL(18,2) DEFAULT 0,
    TargetAchievementPercentage DECIMAL(5,2) DEFAULT 0,

    CreatedDate DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_Performance_User FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT CK_MetricPeriod CHECK (MetricPeriod IN ('Daily', 'Weekly', 'Monthly', 'Quarterly', 'Yearly'))
);

CREATE INDEX IDX_Performance_User ON UserPerformanceMetrics(UserID);
CREATE INDEX IDX_Performance_Date ON UserPerformanceMetrics(MetricDate);
CREATE INDEX IDX_Performance_Period ON UserPerformanceMetrics(MetricPeriod);
CREATE UNIQUE INDEX UX_Performance_User_Date_Period ON UserPerformanceMetrics(UserID, MetricDate, MetricPeriod);
GO
