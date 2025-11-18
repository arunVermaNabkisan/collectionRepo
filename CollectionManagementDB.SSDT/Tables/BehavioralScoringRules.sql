-- =============================================
-- 7. BEHAVIORAL SCORING RULES TABLE
-- =============================================
CREATE TABLE BehavioralScoringRules (
    ScoringRuleID BIGINT IDENTITY(1,1) PRIMARY KEY,
    RuleCode NVARCHAR(50) NOT NULL UNIQUE,
    RuleName NVARCHAR(200) NOT NULL,
    RuleDescription NVARCHAR(1000) NULL,

    -- Parameter Details
    ParameterName NVARCHAR(100) NOT NULL,
    ParameterCategory NVARCHAR(100) NOT NULL,
    -- PaymentBehavior, Communication, PTP, Demographic, Bureau

    -- Scoring Logic
    ScoreCalculationMethod NVARCHAR(50) NOT NULL,
    -- Direct, Range, Lookup, Formula

    MinValue DECIMAL(18,2) NULL,
    MaxValue DECIMAL(18,2) NULL,
    MinScore INT DEFAULT 0,
    MaxScore INT DEFAULT 100,

    ScoreFormula NVARCHAR(500) NULL,
    LookupValuesJSON NVARCHAR(MAX) NULL, -- JSON for lookup tables

    -- Weighting
    WeightPercentage DECIMAL(5,2) NOT NULL, -- Contribution to total score
    IsMandatory BIT DEFAULT 0,

    -- Impact
    ImpactDirection NVARCHAR(20) NOT NULL, -- Positive, Negative
    -- Positive: Higher value = Better score
    -- Negative: Higher value = Worse score

    IsActive BIT DEFAULT 1,
    EffectiveFromDate DATE DEFAULT GETDATE(),
    EffectiveToDate DATE NULL,

    CreatedDate DATETIME DEFAULT GETDATE(),
    CreatedBy BIGINT NULL,
    ModifiedDate DATETIME NULL,
    ModifiedBy BIGINT NULL
);

CREATE INDEX IDX_Scoring_Code ON BehavioralScoringRules(RuleCode);
CREATE INDEX IDX_Scoring_Category ON BehavioralScoringRules(ParameterCategory);
CREATE INDEX IDX_Scoring_Active ON BehavioralScoringRules(IsActive);
GO
