-- =============================================
-- 5. COMPLIANCE CHECKLIST TABLE
-- =============================================
CREATE TABLE ComplianceChecklist (
    ChecklistID BIGINT IDENTITY(1,1) PRIMARY KEY,
    CaseID BIGINT NOT NULL,

    -- Checklist Details
    ComplianceCategory NVARCHAR(100) NOT NULL,
    -- FairPractices, RBIGuidelines, DataProtection, Documentation

    CheckpointName NVARCHAR(200) NOT NULL,
    CheckpointDescription NVARCHAR(1000) NULL,
    MandatoryFlag BIT DEFAULT 1,

    -- Status
    ComplianceStatus NVARCHAR(50) NOT NULL,
    -- Compliant, NonCompliant, PartiallyCompliant, NotApplicable, Pending

    VerifiedByUserID BIGINT NULL,
    VerifiedDate DATETIME NULL,

    -- Evidence
    EvidenceDocumentID BIGINT NULL,
    EvidenceNotes NVARCHAR(MAX) NULL,

    -- Remediation
    RequiresRemediation BIT DEFAULT 0,
    RemediationPlan NVARCHAR(MAX) NULL,
    RemediationDeadline DATETIME NULL,
    RemediationStatus NVARCHAR(50) NULL,

    Remarks NVARCHAR(MAX) NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_Compliance_Case FOREIGN KEY (CaseID) REFERENCES CollectionCases(CaseID),
    CONSTRAINT FK_Compliance_Evidence FOREIGN KEY (EvidenceDocumentID) REFERENCES Documents(DocumentID),
    CONSTRAINT CK_Compliance_Status CHECK (ComplianceStatus IN (
        'Compliant', 'NonCompliant', 'PartiallyCompliant', 'NotApplicable', 'Pending'
    ))
);

CREATE INDEX IDX_Compliance_Case ON ComplianceChecklist(CaseID);
CREATE INDEX IDX_Compliance_Category ON ComplianceChecklist(ComplianceCategory);
CREATE INDEX IDX_Compliance_Status ON ComplianceChecklist(ComplianceStatus);
GO
