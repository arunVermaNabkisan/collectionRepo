-- =============================================
-- 2. DOCUMENT ACCESS LOG TABLE
-- =============================================
CREATE TABLE DocumentAccessLog (
    AccessLogID BIGINT IDENTITY(1,1) PRIMARY KEY,
    DocumentID BIGINT NOT NULL,
    AccessedByUserID BIGINT NOT NULL,

    AccessType NVARCHAR(50) NOT NULL, -- View, Download, Print, Share, Delete
    AccessDateTime DATETIME DEFAULT GETDATE(),

    IPAddress NVARCHAR(50) NULL,
    DeviceType NVARCHAR(50) NULL,
    Browser NVARCHAR(100) NULL,
    Location NVARCHAR(200) NULL,

    AccessDuration INT DEFAULT 0, -- in seconds
    IsSuccessful BIT DEFAULT 1,
    FailureReason NVARCHAR(500) NULL,

    CONSTRAINT FK_DocAccess_Document FOREIGN KEY (DocumentID) REFERENCES Documents(DocumentID),
    CONSTRAINT FK_DocAccess_User FOREIGN KEY (AccessedByUserID) REFERENCES Users(UserID)
);

CREATE INDEX IDX_DocAccess_Document ON DocumentAccessLog(DocumentID);
CREATE INDEX IDX_DocAccess_User ON DocumentAccessLog(AccessedByUserID);
CREATE INDEX IDX_DocAccess_DateTime ON DocumentAccessLog(AccessDateTime);
GO
