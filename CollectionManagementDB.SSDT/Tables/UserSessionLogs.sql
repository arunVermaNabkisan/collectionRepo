-- =============================================
-- 5. USER SESSION LOGS TABLE
-- =============================================
CREATE TABLE UserSessionLogs (
    SessionLogID BIGINT IDENTITY(1,1) PRIMARY KEY,
    UserID BIGINT NOT NULL,

    LoginTime DATETIME DEFAULT GETDATE(),
    LogoutTime DATETIME NULL,
    SessionDuration AS (DATEDIFF(MINUTE, LoginTime, LogoutTime)) PERSISTED,

    LoginIP NVARCHAR(50) NULL,
    DeviceType NVARCHAR(50) NULL, -- Desktop, Mobile, Tablet
    Browser NVARCHAR(100) NULL,
    OperatingSystem NVARCHAR(100) NULL,

    LoginStatus NVARCHAR(50) DEFAULT 'Success',
    LogoutReason NVARCHAR(100) NULL,

    CONSTRAINT FK_SessionLog_User FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

CREATE INDEX IDX_SessionLog_User ON UserSessionLogs(UserID);
CREATE INDEX IDX_SessionLog_LoginTime ON UserSessionLogs(LoginTime);
GO
