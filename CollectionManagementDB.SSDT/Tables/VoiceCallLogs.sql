-- =============================================
-- 2. VOICE CALL LOGS TABLE
-- =============================================
CREATE TABLE VoiceCallLogs (
    CallLogID BIGINT IDENTITY(1,1) PRIMARY KEY,
    InteractionID BIGINT NOT NULL,

    -- Call Identification
    CallID NVARCHAR(100) NULL, -- From telephony system
    SessionID NVARCHAR(100) NULL,

    -- Call Details
    CallerNumber NVARCHAR(15) NOT NULL,
    RecipientNumber NVARCHAR(15) NOT NULL,
    CallDirection NVARCHAR(20) NOT NULL, -- Outbound, Inbound

    CallStartTime DATETIME NOT NULL,
    CallEndTime DATETIME NULL,
    CallDuration INT DEFAULT 0, -- in seconds
    TalkTime INT DEFAULT 0, -- actual conversation time
    HoldTime INT DEFAULT 0,

    -- Call Status
    CallStatus NVARCHAR(50) NOT NULL,
    -- Answered, NotAnswered, Busy, Failed, Rejected, VoiceMail, etc.

    HangupReason NVARCHAR(100) NULL,
    HangupParty NVARCHAR(50) NULL, -- Customer, Agent, System

    -- Agent Details
    AgentUserID BIGINT NULL,
    AgentExtension NVARCHAR(20) NULL,

    -- Recording
    IsRecorded BIT DEFAULT 0,
    RecordingPath NVARCHAR(500) NULL,
    RecordingFileSize BIGINT DEFAULT 0,

    -- VOIP Details
    VoIPProvider NVARCHAR(100) NULL,
    CallQuality DECIMAL(5,2) NULL, -- MOS Score
    Latency INT DEFAULT 0, -- in milliseconds
    PacketLoss DECIMAL(5,2) DEFAULT 0,

    -- Cost
    CallCost DECIMAL(10,4) DEFAULT 0,
    Currency NVARCHAR(10) DEFAULT 'INR',

    CreatedDate DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_CallLog_Interaction FOREIGN KEY (InteractionID) REFERENCES CustomerInteractions(InteractionID),
    CONSTRAINT FK_CallLog_Agent FOREIGN KEY (AgentUserID) REFERENCES Users(UserID)
);

CREATE INDEX IDX_CallLog_Interaction ON VoiceCallLogs(InteractionID);
CREATE INDEX IDX_CallLog_CallID ON VoiceCallLogs(CallID);
CREATE INDEX IDX_CallLog_StartTime ON VoiceCallLogs(CallStartTime);
CREATE INDEX IDX_CallLog_Agent ON VoiceCallLogs(AgentUserID);
GO
