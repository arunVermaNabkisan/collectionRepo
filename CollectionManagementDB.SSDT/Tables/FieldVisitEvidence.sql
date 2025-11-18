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
