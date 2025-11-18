# Process Flow Documentation
## NABKISAN Collection Management System

**Document Version:** 1.0  
**Date:** November 17, 2024  
**Purpose:** Detailed process flows for system implementation

---

## Table of Contents
1. [Core Collection Process Flows](#1-core-collection-process-flows)
2. [Case Management Workflows](#2-case-management-workflows)
3. [Communication Workflows](#3-communication-workflows)
4. [Payment Processing Flows](#4-payment-processing-flows)
5. [Field Collection Processes](#5-field-collection-processes)
6. [Escalation and Strategy Workflows](#6-escalation-workflows)
7. [Reporting and Analytics Flows](#7-reporting-analytics-flows)
8. [Integration Process Flows](#8-integration-flows)

---

## 1. Core Collection Process Flows

### 1.1 End-to-End Collection Process

```mermaid
flowchart TB
    Start([Loan Account in LMS]) --> EOD[EOD Batch Process]
    EOD --> Check{DPD > 0?}
    Check -->|No| End1([No Action Required])
    Check -->|Yes| CreateCase[Create Collection Case]
    
    CreateCase --> Bucket[Assign to DPD Bucket]
    Bucket --> Score[Calculate Risk Score]
    Score --> Strategy[Assign Collection Strategy]
    Strategy --> Allocate[Allocate to RM]
    
    Allocate --> Contact{Contact Attempt}
    Contact -->|Success| Negotiate[Negotiate Payment]
    Contact -->|Failed| Retry{Max Attempts?}
    
    Retry -->|No| NextAttempt[Schedule Next Attempt]
    NextAttempt --> Contact
    Retry -->|Yes| Escalate1[Escalate to Supervisor]
    
    Negotiate --> PTP{Promise to Pay?}
    PTP -->|Yes| RecordPTP[Record PTP Details]
    PTP -->|No| FieldVisit{Field Visit Required?}
    
    RecordPTP --> Monitor[Monitor PTP Date]
    Monitor --> PaymentCheck{Payment Received?}
    
    PaymentCheck -->|Yes| UpdateStatus[Update Case Status]
    PaymentCheck -->|No| BreakPTP[Mark PTP as Broken]
    BreakPTP --> Escalate2[Escalate Strategy]
    
    FieldVisit -->|Yes| ScheduleVisit[Schedule Field Visit]
    FieldVisit -->|No| LegalCheck{Legal Action Required?}
    
    ScheduleVisit --> FieldExecution[Execute Field Visit]
    FieldExecution --> FieldResult{Collection Success?}
    
    FieldResult -->|Yes| UpdateStatus
    FieldResult -->|No| LegalCheck
    
    LegalCheck -->|Yes| InitiateLegal[Transfer to Legal Team]
    LegalCheck -->|No| WriteOffCheck{Write-off Criteria Met?}
    
    WriteOffCheck -->|Yes| InitiateWriteOff[Initiate Write-off]
    WriteOffCheck -->|No| ContinueEfforts[Continue Collection Efforts]
    
    UpdateStatus --> CloseCase[Close Case]
    InitiateWriteOff --> CloseCase
    InitiateLegal --> LegalSystem[Transfer to Litigation System]
    
    CloseCase --> End2([Case Closed])
    LegalSystem --> End3([Legal Process])
    ContinueEfforts --> Contact
    
    Escalate1 --> SupervisorReview[Supervisor Review]
    SupervisorReview --> ReassignStrategy[Reassign/Change Strategy]
    ReassignStrategy --> Contact
    
    Escalate2 --> IncreaseIntensity[Increase Contact Intensity]
    IncreaseIntensity --> Contact
```

### 1.2 Daily Collection Cycle

```mermaid
flowchart LR
    subgraph Morning["Morning (6:00 AM - 9:00 AM)"]
        BOD[BOD Sync from LMS]
        BOD --> LoadCases[Load Updated Cases]
        LoadCases --> GenerateWorklists[Generate RM Worklists]
        GenerateWorklists --> PrioritySort[Sort by Priority Score]
    end
    
    subgraph WorkDay["Work Day (9:00 AM - 6:00 PM)"]
        PrioritySort --> AgentLogin[RM Login]
        AgentLogin --> ViewDashboard[View Dashboard & Targets]
        ViewDashboard --> StartCalling[Start Collection Activities]
        
        StartCalling --> ActivityLoop{More Cases?}
        ActivityLoop -->|Yes| SelectCase[Select Next Case]
        SelectCase --> AttemptContact[Attempt Contact]
        AttemptContact --> RecordOutcome[Record Outcome]
        RecordOutcome --> ActivityLoop
        
        ActivityLoop -->|No| EndOfDay[End of Day Activities]
    end
    
    subgraph Evening["Evening (6:00 PM - 10:00 PM)"]
        EndOfDay --> SubmitReports[Submit Daily Reports]
        SubmitReports --> EODSync[EOD Sync to LMS]
        EODSync --> GenerateMetrics[Generate Performance Metrics]
        GenerateMetrics --> PrepareNext[Prepare Next Day Lists]
    end
```

---

## 2. Case Management Workflows

### 2.1 Case Creation and Allocation

```mermaid
flowchart TB
    subgraph CaseCreation["Automated Case Creation"]
        LMSData[LMS Data Feed] --> DPDCalc[Calculate DPD]
        DPDCalc --> CheckExisting{Existing Case?}
        CheckExisting -->|Yes| UpdateCase[Update Existing Case]
        CheckExisting -->|No| NewCase[Create New Case]
        
        NewCase --> AssignID[Assign Unique Case ID]
        AssignID --> PopulateData[Populate Case Data]
        PopulateData --> SetPriority[Calculate Priority Score]
    end
    
    subgraph Allocation["Intelligent Allocation"]
        SetPriority --> AllocationEngine[Allocation Engine]
        AllocationEngine --> CheckRM{Check RM Availability}
        
        CheckRM --> LoadBalance[Check RM Workload]
        LoadBalance --> SkillMatch[Match Skills to Case]
        SkillMatch --> GeoMatch[Geographic Matching]
        GeoMatch --> ProductMatch[Product Expertise Match]
        
        ProductMatch --> AssignRM[Assign to Best RM]
        AssignRM --> NotifyRM[Send Notification]
        NotifyRM --> AddToWorklist[Add to RM Worklist]
    end
    
    subgraph Monitoring["Case Monitoring"]
        AddToWorklist --> TrackSLA[Track SLA Timer]
        TrackSLA --> CheckActivity{Activity Within SLA?}
        CheckActivity -->|No| AutoReassign[Auto-Reassign Case]
        CheckActivity -->|Yes| ContinueMonitor[Continue Monitoring]
        
        AutoReassign --> Allocation
        ContinueMonitor --> TrackProgress[Track Progress]
    end
```

### 2.2 Case Status Management

```mermaid
stateDiagram-v2
    [*] --> New: Case Created
    
    New --> InProgress: RM Assigned
    New --> Abandoned: No Activity >48hrs
    
    InProgress --> Contacted: Customer Reached
    InProgress --> NoContact: Multiple Failed Attempts
    InProgress --> FieldVisit: Escalated to Field
    
    Contacted --> PTPActive: Promise Recorded
    Contacted --> Dispute: Customer Disputes
    Contacted --> RefusedToPay: Payment Refused
    
    PTPActive --> PartialRecovery: Partial Payment
    PTPActive --> FullRecovery: Full Payment
    PTPActive --> PTPBroken: Promise Not Kept
    
    PTPBroken --> InProgress: Retry Collection
    PTPBroken --> FieldVisit: Escalate to Field
    
    NoContact --> FieldVisit: Desk Efforts Exhausted
    NoContact --> SkipTrace: Customer Not Found
    
    FieldVisit --> FieldContacted: Customer Met
    FieldVisit --> FieldNoContact: Not Available
    
    FieldContacted --> PartialRecovery: Payment Collected
    FieldContacted --> FullRecovery: Full Payment
    FieldContacted --> LegalAction: Transfer to Legal
    
    RefusedToPay --> LegalAction: Initiate Legal
    
    PartialRecovery --> InProgress: Continue Collection
    
    FullRecovery --> Closed: Case Success
    LegalAction --> TransferredLegal: Sent to Litigation
    
    Dispute --> UnderReview: Investigation
    UnderReview --> Resolved: Dispute Cleared
    UnderReview --> WrittenOff: Valid Dispute
    
    Resolved --> InProgress: Resume Collection
    
    WrittenOff --> Closed: Case Closed
    TransferredLegal --> Closed: Out of Scope
    Abandoned --> Closed: Auto-Closed
    
    Closed --> [*]
```

### 2.3 Promise to Pay (PTP) Workflow

```mermaid
flowchart TB
    Start([Customer Agrees to Pay]) --> PTPType{Payment Type?}
    
    PTPType -->|Single| SinglePTP[Record Single Payment]
    PTPType -->|Split| SplitPTP[Record Multiple Payments]
    
    SinglePTP --> ValidateAmount1{Amount >= Minimum?}
    SplitPTP --> SplitDetails[Enter Split Details]
    
    SplitDetails --> ValidateSum{Sum >= Minimum %?}
    ValidateSum -->|No| RejectSplit[Reject - Insufficient]
    ValidateSum -->|Yes| RecordSplits[Record Each Split]
    
    ValidateAmount1 -->|No| Reject1[Reject PTP]
    ValidateAmount1 -->|Yes| ValidateDate1{Date Within Limit?}
    
    ValidateDate1 -->|No| Reject2[Reject - Too Far]
    ValidateDate1 -->|Yes| ConfidenceScore[Assign Confidence Score]
    
    RecordSplits --> ConfidenceScore
    
    ConfidenceScore --> SavePTP[Save PTP Record]
    SavePTP --> SetReminders[Set Auto Reminders]
    
    SetReminders --> SendConfirmation[Send PTP Confirmation]
    SendConfirmation --> UpdateStrategy[Update Collection Strategy]
    
    UpdateStrategy --> MonitoringLoop[Start Monitoring]
    
    subgraph Monitoring["PTP Monitoring"]
        MonitoringLoop --> DayBefore[T-1 Day Reminder]
        DayBefore --> PTPDay[PTP Due Date]
        PTPDay --> CheckPayment{Payment Received?}
        
        CheckPayment -->|Full| MarkKept[Mark PTP Kept]
        CheckPayment -->|Partial| MarkPartial[Mark Partially Kept]
        CheckPayment -->|None| MarkBroken[Mark PTP Broken]
        
        MarkKept --> UpdateScore1[Improve Behavior Score]
        MarkPartial --> FollowUp[Follow-up for Balance]
        MarkBroken --> UpdateScore2[Reduce Behavior Score]
        
        UpdateScore2 --> EscalateStrategy[Escalate Strategy]
        EscalateStrategy --> HigherIntensity[Increase Contact Intensity]
    end
    
    Reject1 --> RequestHigher[Request Higher Amount]
    Reject2 --> RequestSooner[Request Earlier Date]
    RejectSplit --> RequestHigher
```

---

## 3. Communication Workflows

### 3.1 Omnichannel Communication Flow

```mermaid
flowchart TB
    CaseSelected([Case Selected]) --> GetProfile[Retrieve Customer Profile]
    GetProfile --> CheckPreference{Communication Preference?}
    
    CheckPreference -->|Voice| InitiateCall[Initiate Voice Call]
    CheckPreference -->|SMS| SendSMS[Send SMS]
    CheckPreference -->|Email| SendEmail[Send Email]
    CheckPreference -->|WhatsApp| SendWhatsApp[Send WhatsApp]
    CheckPreference -->|None| DefaultStrategy[Use Default Strategy]
    
    DefaultStrategy --> TimeCheck{Current Time?}
    TimeCheck -->|Morning| SMS1[Start with SMS]
    TimeCheck -->|Afternoon| Call1[Start with Call]
    TimeCheck -->|Evening| WhatsApp1[Start with WhatsApp]
    
    InitiateCall --> CallResult{Call Outcome?}
    CallResult -->|Connected| RecordCall[Record Conversation]
    CallResult -->|No Answer| LogAttempt1[Log Attempt]
    CallResult -->|Busy| ScheduleRetry1[Retry in 30 min]
    CallResult -->|Invalid Number| UpdateNumber[Flag for Update]
    
    SendSMS --> SMSResult{Delivery Status?}
    SMSResult -->|Delivered| WaitResponse1[Wait for Response]
    SMSResult -->|Failed| TryAlternate1[Try Alternate Channel]
    
    SendEmail --> EmailResult{Email Status?}
    EmailResult -->|Sent| TrackOpen[Track Opens/Clicks]
    EmailResult -->|Bounced| UpdateEmail[Flag Email Invalid]
    
    SendWhatsApp --> WAResult{WhatsApp Status?}
    WAResult -->|Delivered| WaitResponse2[Wait for Response]
    WAResult -->|Failed| CheckReason{Failure Reason?}
    
    CheckReason -->|Not on WA| TryOther[Try Other Channel]
    CheckReason -->|Template Issue| UseBackup[Use Backup Template]
    
    RecordCall --> Disposition[Record Disposition]
    WaitResponse1 --> CheckReply1{Customer Replied?}
    WaitResponse2 --> CheckReply2{Customer Replied?}
    TrackOpen --> CheckEngagement{Engaged?}
    
    CheckReply1 -->|Yes| HandleResponse[Handle Response]
    CheckReply2 -->|Yes| HandleResponse
    CheckEngagement -->|Yes| FollowUpCall[Schedule Call]
    
    Disposition --> UpdateHistory[Update Interaction History]
    HandleResponse --> UpdateHistory
    
    UpdateHistory --> NextAction{Next Action?}
    NextAction -->|PTP| CreatePTP[Create Promise]
    NextAction -->|Callback| ScheduleCallback[Schedule Callback]
    NextAction -->|Escalate| EscalateCase[Escalate to Supervisor]
    NextAction -->|Close| CloseInteraction[Close Interaction]
```

### 3.2 Automated Communication Campaign

```mermaid
flowchart LR
    subgraph Day0_5["DPD 0-5: Soft Reminder"]
        D1[Day 1: SMS Reminder]
        D3[Day 3: WhatsApp with Payment Link]
        D5[Day 5: Email Statement]
    end
    
    subgraph Day6_15["DPD 6-15: Increased Frequency"]
        D7[Day 7: First Call Attempt]
        D10[Day 10: Voice AI Call]
        D12[Day 12: Multiple Channel Outreach]
        D15[Day 15: Supervisor Call]
    end
    
    subgraph Day16_30["DPD 16-30: Intensive Follow-up"]
        D16[Daily Call Attempts]
        D20[Day 20: Formal Notice Email]
        D25[Day 25: Field Visit Warning]
        D30[Day 30: Final Desk Attempt]
    end
    
    subgraph Day31_60["DPD 31-60: Field Integration"]
        D31[Field Visit Scheduled]
        D35[Legal Notice Preparation]
        D45[Day 45: Demand Letter]
        D60[Day 60: Pre-Legal Warning]
    end
    
    subgraph Day61Plus["DPD 61+: Legal Track"]
        D61[Legal Team Handover]
        D75[Arbitration Notice]
        D90[Day 90: NPA Classification]
    end
    
    D1 --> D3
    D3 --> D5
    D5 --> D7
    D7 --> D10
    D10 --> D12
    D12 --> D15
    D15 --> D16
    D16 --> D20
    D20 --> D25
    D25 --> D30
    D30 --> D31
    D31 --> D35
    D35 --> D45
    D45 --> D60
    D60 --> D61
    D61 --> D75
    D75 --> D90
```

---

## 4. Payment Processing Flows

### 4.1 Payment Collection and Processing

```mermaid
flowchart TB
    Start([Payment Initiated]) --> Source{Payment Source?}
    
    Source -->|Field Collection| FieldPayment[Field Agent Collection]
    Source -->|Customer Initiative| DirectPayment[Direct Payment]
    Source -->|Payment Link| LinkPayment[Link-based Payment]
    Source -->|Bank Transfer| BankPayment[Bank Transfer]
    
    FieldPayment --> Mode1{Payment Mode?}
    Mode1 -->|Cash| RecordCash[Record Cash Details]
    Mode1 -->|Cheque| RecordCheque[Capture Cheque Image]
    Mode1 -->|UPI| GenerateQR[Generate QR Code]
    
    RecordCash --> GenerateReceipt[Generate Receipt]
    RecordCheque --> ValidateMICR[Validate MICR]
    GenerateQR --> WaitConfirmation[Wait for Confirmation]
    
    DirectPayment --> Gateway[Payment Gateway]
    LinkPayment --> Gateway
    BankPayment --> VirtualAccount[Virtual Account]
    
    Gateway --> Process{Processing Result?}
    VirtualAccount --> BankRecon[Bank Reconciliation]
    
    Process -->|Success| UpdateLedger[Update Payment Ledger]
    Process -->|Failed| HandleFailure[Handle Failure]
    Process -->|Pending| WaitStatus[Wait for Status]
    
    HandleFailure --> FailureReason{Reason?}
    FailureReason -->|Insufficient Funds| NotifyRetry[Notify for Retry]
    FailureReason -->|Technical| AutoRetry[Auto Retry]
    FailureReason -->|Invalid Details| RequestUpdate[Request Correct Details]
    
    UpdateLedger --> ApplyPayment[Apply to Outstanding]
    BankRecon --> MatchPayment[Match with Account]
    MatchPayment --> ApplyPayment
    
    ApplyPayment --> Hierarchy{Application Hierarchy}
    Hierarchy --> Step1[1. Clear Penal Charges]
    Step1 --> Step2[2. Clear Late Fees]
    Step2 --> Step3[3. Clear Interest]
    Step3 --> Step4[4. Clear Principal]
    
    Step4 --> CheckFull{Full Payment?}
    CheckFull -->|Yes| CloseLoan[Close Loan Account]
    CheckFull -->|No| UpdateBalance[Update Balance]
    
    CloseLoan --> NotifySuccess[Notify Success]
    UpdateBalance --> NotifyPartial[Notify Partial Payment]
    
    NotifySuccess --> UpdateCase[Update Case Status]
    NotifyPartial --> UpdateCase
    
    UpdateCase --> SyncLMS[Sync with LMS]
    SyncLMS --> End([Payment Processed])
```

### 4.2 Payment Reconciliation Flow

```mermaid
flowchart TB
    Start([Reconciliation Start]) --> Sources[Gather Payment Sources]
    
    Sources --> Gateway1[Payment Gateway Files]
    Sources --> Bank1[Bank Statements]
    Sources --> Virtual1[Virtual Account Reports]
    Sources --> Field1[Field Collection Reports]
    
    Gateway1 --> Consolidate[Consolidate All Payments]
    Bank1 --> Consolidate
    Virtual1 --> Consolidate
    Field1 --> Consolidate
    
    Consolidate --> Match{Match with CMS Records?}
    
    Match -->|Matched| Validate[Validate Amounts]
    Match -->|Unmatched| Investigate[Investigate Discrepancy]
    
    Validate --> Check{Amount Correct?}
    Check -->|Yes| MarkReconciled[Mark as Reconciled]
    Check -->|No| AmountIssue[Flag Amount Mismatch]
    
    Investigate --> FindReason{Identify Reason}
    FindReason -->|Payment Not Recorded| CreateEntry[Create Payment Entry]
    FindReason -->|Duplicate| RemoveDuplicate[Remove Duplicate]
    FindReason -->|Wrong Account| Reallocation[Reallocate Payment]
    FindReason -->|Unknown| ManualReview[Queue for Manual Review]
    
    CreateEntry --> UpdateRecords[Update CMS Records]
    RemoveDuplicate --> UpdateRecords
    Reallocation --> UpdateRecords
    
    MarkReconciled --> GenerateReport[Generate Reconciliation Report]
    AmountIssue --> ManualReview
    ManualReview --> ResolveManual[Manual Resolution]
    ResolveManual --> UpdateRecords
    
    UpdateRecords --> SyncSystems[Sync with LMS]
    GenerateReport --> SyncSystems
    
    SyncSystems --> End([Reconciliation Complete])
```

---

## 5. Field Collection Processes

### 5.1 Field Visit Planning and Execution

```mermaid
flowchart TB
    Start([Field Visit Triggered]) --> Criteria{Trigger Reason?}
    
    Criteria -->|No Contact| NCVisit[No Contact Visit]
    Criteria -->|High Value| HVVisit[High Value Case]
    Criteria -->|Broken PTP| BPVisit[Broken Promise Visit]
    Criteria -->|Verification| VerifyVisit[Address Verification]
    
    NCVisit --> PlanVisit[Plan Field Visit]
    HVVisit --> PlanVisit
    BPVisit --> PlanVisit
    VerifyVisit --> PlanVisit
    
    PlanVisit --> CheckLocation[Check Customer Location]
    CheckLocation --> AssignAgent{Available Field Agent?}
    
    AssignAgent -->|Yes| AssignToAgent[Assign to RM/Agent]
    AssignAgent -->|No| CheckAgency{Agency Available?}
    CheckAgency -->|Yes| AssignToAgency[Assign to Agency]
    CheckAgency -->|No| WaitAvailability[Queue for Assignment]
    
    AssignToAgent --> CreateRoute[Create Route Plan]
    AssignToAgency --> CreateRoute
    
    CreateRoute --> OptimizeRoute[Optimize Travel Route]
    OptimizeRoute --> NotifyAgent[Notify Agent via App]
    
    subgraph FieldExecution["Field Visit Execution"]
        NotifyAgent --> AgentDeparts[Agent Starts Route]
        AgentDeparts --> EnableTracking[Enable GPS Tracking]
        
        EnableTracking --> ArriveLoc[Arrive at Location]
        ArriveLoc --> CheckIn[Check-in GPS Verified]
        
        CheckIn --> AttemptMeet{Customer Available?}
        AttemptMeet -->|Yes| MeetCustomer[Meet Customer]
        AttemptMeet -->|No| LeaveNotice[Leave Notice/Card]
        
        MeetCustomer --> Discussion[Discuss Payment]
        Discussion --> Outcome{Visit Outcome?}
        
        Outcome -->|Payment| CollectPayment[Collect Payment]
        Outcome -->|Promise| RecordNewPTP[Record New PTP]
        Outcome -->|Refusal| DocumentRefusal[Document Refusal]
        Outcome -->|Dispute| RecordDispute[Record Dispute]
        
        CollectPayment --> IssueReceipt[Issue Receipt]
        RecordNewPTP --> CaptureProof[Capture Evidence]
        DocumentRefusal --> CaptureProof
        RecordDispute --> CaptureProof
        LeaveNotice --> CaptureProof
        
        CaptureProof --> Photos[Take Photos]
        Photos --> VoiceNote[Record Voice Note]
        VoiceNote --> CheckOut[Check-out from Location]
    end
    
    CheckOut --> UploadData[Upload Visit Data]
    UploadData --> SyncServer[Sync with Server]
    SyncServer --> UpdateCase[Update Case Status]
    UpdateCase --> NextVisit{More Visits?}
    
    NextVisit -->|Yes| NextLocation[Go to Next Location]
    NextVisit -->|No| EndDay[End Field Day]
    
    NextLocation --> ArriveLoc
    EndDay --> GenerateSummary[Generate Day Summary]
    GenerateSummary --> End([Field Visit Complete])
```

### 5.2 Mobile App Workflow for Field Agents

```mermaid
flowchart LR
    subgraph AppStart["App Initialization"]
        Login[Agent Login]
        Login --> Biometric[Biometric Auth]
        Biometric --> LoadData[Download Cases]
        LoadData --> CheckOffline{Offline Mode?}
        CheckOffline -->|Yes| LoadCache[Load Cached Data]
        CheckOffline -->|No| SyncFresh[Sync Fresh Data]
    end
    
    subgraph DayPlanning["Day Planning"]
        LoadCache --> ViewRoute[View Route Map]
        SyncFresh --> ViewRoute
        ViewRoute --> ReviewCases[Review Case Details]
        ReviewCases --> StartRoute[Start Route]
    end
    
    subgraph VisitExecution["Visit Execution"]
        StartRoute --> Navigate[Navigation to Location]
        Navigate --> Arrival[Arrival at Location]
        Arrival --> CheckInProcess[Check-in Process]
        CheckInProcess --> ExecuteVisit[Execute Visit]
        ExecuteVisit --> RecordOutcome[Record Outcome]
        RecordOutcome --> CheckOutProcess[Check-out Process]
    end
    
    subgraph DataSync["Data Management"]
        CheckOutProcess --> QueueSync{Network Available?}
        QueueSync -->|Yes| ImmediateSync[Sync Immediately]
        QueueSync -->|No| QueueData[Queue for Sync]
        QueueData --> RetrySync[Retry When Online]
        ImmediateSync --> NextVisit[Next Visit]
        RetrySync --> NextVisit
    end
```

---

## 6. Escalation and Strategy Workflows

### 6.1 Horizontal and Vertical Escalation

```mermaid
flowchart TB
    CaseReview([Case Under Review]) --> CheckPerformance{Performance Check}
    
    CheckPerformance --> Metrics[Evaluate Metrics]
    Metrics --> ContactRate{Contact Rate Low?}
    Metrics --> RecoveryRate{Recovery Rate Low?}
    Metrics --> PTPRate{PTP Success Low?}
    
    ContactRate -->|Yes| HorizontalEsc[Horizontal Escalation]
    RecoveryRate -->|Yes| AnalyzeReason[Analyze Reason]
    PTPRate -->|Yes| AnalyzeReason
    
    HorizontalEsc --> FindBetterRM[Find Better Skilled RM]
    FindBetterRM --> CheckAvailable{RM Available?}
    CheckAvailable -->|Yes| ReassignCase[Reassign to New RM]
    CheckAvailable -->|No| VerticalEsc[Vertical Escalation]
    
    AnalyzeReason --> ReasonType{Root Cause?}
    ReasonType -->|Skill Gap| HorizontalEsc
    ReasonType -->|Difficult Case| VerticalEsc
    ReasonType -->|System Issue| TechEscalation[Technical Escalation]
    
    VerticalEsc --> Level{Escalation Level}
    Level -->|L1| TeamLead[Escalate to Team Lead]
    Level -->|L2| Supervisor[Escalate to Supervisor]
    Level -->|L3| Manager[Escalate to Manager]
    Level -->|L4| Head[Escalate to Vertical Head]
    
    TeamLead --> Review1[Review & Guide]
    Supervisor --> Review2[Strategic Intervention]
    Manager --> Review3[Special Handling]
    Head --> Review4[Executive Decision]
    
    Review1 --> Action{Action Required?}
    Review2 --> Action
    Review3 --> Action
    Review4 --> Action
    
    Action -->|Change Strategy| NewStrategy[Implement New Strategy]
    Action -->|Special Team| SpecialTeam[Assign to Special Team]
    Action -->|External Agency| AgencyAssign[Assign to Agency]
    Action -->|Legal| LegalTransfer[Transfer to Legal]
    
    ReassignCase --> NotifyParties[Notify All Parties]
    NewStrategy --> NotifyParties
    SpecialTeam --> NotifyParties
    AgencyAssign --> NotifyParties
    LegalTransfer --> NotifyParties
    
    NotifyParties --> UpdateSystem[Update CMS Records]
    UpdateSystem --> MonitorNew[Monitor New Approach]
```

### 6.2 Dynamic Strategy Assignment

```mermaid
flowchart TB
    Start([Customer Profile]) --> DataCollection[Collect Multi-Source Data]
    
    DataCollection --> Internal[Internal Data]
    DataCollection --> External[External Data]
    DataCollection --> Behavioral[Behavioral Data]
    
    Internal --> LoanHistory[Loan History]
    Internal --> PaymentPattern[Payment Patterns]
    Internal --> PrevStrategy[Previous Strategies]
    
    External --> BureauScore[Credit Bureau Score]
    External --> MacroFactors[Economic Factors]
    
    Behavioral --> ResponseRate[Channel Response]
    Behavioral --> PTPHistory[PTP Performance]
    Behavioral --> InteractionQuality[Interaction Quality]
    
    LoanHistory --> Scoring[Combined Scoring Engine]
    PaymentPattern --> Scoring
    PrevStrategy --> Scoring
    BureauScore --> Scoring
    MacroFactors --> Scoring
    ResponseRate --> Scoring
    PTPHistory --> Scoring
    InteractionQuality --> Scoring
    
    Scoring --> RiskCategory{Risk Classification}
    
    RiskCategory -->|Low Risk| Supportive[Supportive Strategy]
    RiskCategory -->|Medium Risk| Balanced[Balanced Strategy]
    RiskCategory -->|High Risk| Intensive[Intensive Strategy]
    RiskCategory -->|Very High Risk| Aggressive[Aggressive Strategy]
    
    Supportive --> S1[Self-Service Options]
    Supportive --> S2[Flexible Payment Plans]
    Supportive --> S3[Minimal Contact]
    
    Balanced --> B1[Regular Reminders]
    Balanced --> B2[Standard PTP Terms]
    Balanced --> B3[Graduated Intensity]
    
    Intensive --> I1[Daily Contact Attempts]
    Intensive --> I2[Multiple Channels]
    Intensive --> I3[Field Visit Ready]
    
    Aggressive --> A1[Immediate Field Visit]
    Aggressive --> A2[Legal Notice Prep]
    Aggressive --> A3[Settlement Offers]
    
    S1 --> Implementation[Implement Strategy]
    S2 --> Implementation
    S3 --> Implementation
    B1 --> Implementation
    B2 --> Implementation
    B3 --> Implementation
    I1 --> Implementation
    I2 --> Implementation
    I3 --> Implementation
    A1 --> Implementation
    A2 --> Implementation
    A3 --> Implementation
    
    Implementation --> Monitor[Monitor Effectiveness]
    Monitor --> Adjust{Strategy Working?}
    
    Adjust -->|Yes| Continue[Continue Strategy]
    Adjust -->|No| Reevaluate[Re-evaluate Profile]
    
    Reevaluate --> DataCollection
    Continue --> TrackResults[Track Results]
```

---

## 7. Reporting and Analytics Flows

### 7.1 Real-time Dashboard Update Flow

```mermaid
flowchart TB
    Events([System Events]) --> EventTypes{Event Type}
    
    EventTypes -->|Payment| PaymentEvent[Payment Received]
    EventTypes -->|Call| CallEvent[Call Completed]
    EventTypes -->|PTP| PTPEvent[PTP Created]
    EventTypes -->|Status| StatusEvent[Status Changed]
    
    PaymentEvent --> ProcessPayment[Process Payment Data]
    CallEvent --> ProcessCall[Process Call Data]
    PTPEvent --> ProcessPTP[Process PTP Data]
    StatusEvent --> ProcessStatus[Process Status Data]
    
    ProcessPayment --> UpdateMetrics[Update Metrics Cache]
    ProcessCall --> UpdateMetrics
    ProcessPTP --> UpdateMetrics
    ProcessStatus --> UpdateMetrics
    
    UpdateMetrics --> Calculate[Calculate KPIs]
    
    Calculate --> CollectionMetrics[Collection Metrics]
    Calculate --> AgentMetrics[Agent Performance]
    Calculate --> PortfolioMetrics[Portfolio Health]
    
    CollectionMetrics --> CEI[CEI Calculation]
    CollectionMetrics --> DSO[DSO Calculation]
    CollectionMetrics --> Recovery[Recovery Rate]
    
    AgentMetrics --> Productivity[Calls/Visits Made]
    AgentMetrics --> Success[Success Rate]
    AgentMetrics --> Efficiency[Time Efficiency]
    
    PortfolioMetrics --> PAR[PAR Analysis]
    PortfolioMetrics --> RollRate[Roll Rate]
    PortfolioMetrics --> Vintage[Vintage Analysis]
    
    CEI --> Broadcast[Broadcast Updates]
    DSO --> Broadcast
    Recovery --> Broadcast
    Productivity --> Broadcast
    Success --> Broadcast
    Efficiency --> Broadcast
    PAR --> Broadcast
    RollRate --> Broadcast
    Vintage --> Broadcast
    
    Broadcast --> WebSocket[WebSocket Push]
    WebSocket --> Dashboard{User Dashboard}
    
    Dashboard -->|RM| RMDash[RM Dashboard]
    Dashboard -->|Supervisor| SuperDash[Supervisor Dashboard]
    Dashboard -->|Manager| ManagerDash[Manager Dashboard]
    Dashboard -->|Executive| ExecDash[Executive Dashboard]
```

### 7.2 Report Generation Workflow

```mermaid
flowchart LR
    subgraph Scheduling["Report Scheduling"]
        Trigger{Trigger Type}
        Trigger -->|Scheduled| CronJob[Cron Job]
        Trigger -->|On-Demand| UserRequest[User Request]
        Trigger -->|Event| EventTrigger[Event-based]
        
        CronJob --> Queue[Report Queue]
        UserRequest --> Queue
        EventTrigger --> Queue
    end
    
    subgraph Processing["Report Processing"]
        Queue --> Generator[Report Generator]
        Generator --> DataQuery[Query Data Sources]
        
        DataQuery --> CMS[CMS Database]
        DataQuery --> LMS[LMS Data]
        DataQuery --> DW[Data Warehouse]
        
        CMS --> Aggregate[Aggregate Data]
        LMS --> Aggregate
        DW --> Aggregate
        
        Aggregate --> Transform[Transform & Calculate]
        Transform --> Format{Output Format}
        
        Format -->|PDF| PDFGen[PDF Generation]
        Format -->|Excel| ExcelGen[Excel Generation]
        Format -->|CSV| CSVGen[CSV Generation]
        Format -->|Dashboard| JSONGen[JSON Generation]
    end
    
    subgraph Distribution["Report Distribution"]
        PDFGen --> Deliver[Delivery Engine]
        ExcelGen --> Deliver
        CSVGen --> Deliver
        JSONGen --> Deliver
        
        Deliver --> Channel{Distribution Channel}
        Channel -->|Email| EmailSend[Email Report]
        Channel -->|Portal| UploadPortal[Upload to Portal]
        Channel -->|API| APISend[API Response]
        Channel -->|Archive| StoreArchive[Archive Storage]
    end
```

---

## 8. Integration Process Flows

### 8.1 LMS Integration Flow

```mermaid
flowchart TB
    subgraph EODBatch["EOD Batch Process (11 PM Daily)"]
        StartEOD([EOD Trigger]) --> ExtractData[Extract from LMS]
        ExtractData --> Validate[Validate Data]
        Validate --> Transform[Transform Format]
        Transform --> Load[Load to CMS]
        Load --> Reconcile[Reconciliation Check]
        Reconcile --> Report[Generate Sync Report]
    end
    
    subgraph RealTimeAPI["Real-time API Calls"]
        UserAction([Agent Action]) --> APICall{API Type}
        
        APICall -->|SOA| GetSOA[Get Statement]
        APICall -->|Payment| PostPayment[Post Payment]
        APICall -->|Contact| UpdateContact[Update Contact]
        
        GetSOA --> LMSQuery[Query LMS]
        PostPayment --> LMSUpdate[Update LMS]
        UpdateContact --> LMSUpdate
        
        LMSQuery --> Response[Process Response]
        LMSUpdate --> Confirm[Await Confirmation]
        
        Response --> Display[Display to Agent]
        Confirm --> UpdateCMS[Update CMS Records]
    end
    
    subgraph ErrorHandling["Error Management"]
        Validate --> Error1{Validation Error?}
        Error1 -->|Yes| LogError[Log Error]
        Error1 -->|No| Continue1[Continue Process]
        
        LMSQuery --> Error2{API Error?}
        Error2 -->|Yes| Retry{Retry Count?}
        Retry -->|<3| RetryCall[Retry API Call]
        Retry -->|>=3| Fallback[Use Cached Data]
        Error2 -->|No| Continue2[Process Success]
        
        LogError --> Alert[Alert Support]
        Fallback --> Alert
    end
```

### 8.2 Payment Gateway Integration

```mermaid
flowchart TB
    PaymentInit([Payment Initiated]) --> Method{Payment Method}
    
    Method -->|Card| CardFlow[Card Payment Flow]
    Method -->|NetBanking| NetBankFlow[NetBanking Flow]
    Method -->|UPI| UPIFlow[UPI Flow]
    Method -->|Wallet| WalletFlow[Wallet Flow]
    
    CardFlow --> CreateSession[Create PG Session]
    NetBankFlow --> CreateSession
    UPIFlow --> CreateSession
    WalletFlow --> CreateSession
    
    CreateSession --> Redirect[Redirect to PG]
    Redirect --> CustomerAuth[Customer Authentication]
    
    CustomerAuth --> PGProcess[PG Processing]
    PGProcess --> Result{Transaction Result}
    
    Result -->|Success| Success[Success Response]
    Result -->|Failed| Failed[Failure Response]
    Result -->|Pending| Pending[Pending Status]
    
    Success --> Callback[Webhook Callback]
    Failed --> Callback
    Pending --> StatusCheck[Status Check API]
    
    Callback --> Verify[Verify Signature]
    StatusCheck --> PollStatus[Poll Status]
    
    Verify --> Valid{Valid Signature?}
    Valid -->|Yes| UpdatePayment[Update Payment Status]
    Valid -->|No| SecurityAlert[Security Alert]
    
    PollStatus --> StatusResult{Final Status}
    StatusResult -->|Success| UpdatePayment
    StatusResult -->|Failed| UpdateFailed[Mark Failed]
    StatusResult -->|Timeout| ManualCheck[Manual Verification]
    
    UpdatePayment --> Reconciliation[Payment Reconciliation]
    UpdateFailed --> NotifyCustomer[Notify Customer]
    ManualCheck --> SupportQueue[Support Queue]
    
    Reconciliation --> Settlement[Settlement Process]
    Settlement --> BankCredit[Bank Credit Confirmation]
```

### 8.3 Communication Channel Integration

```mermaid
flowchart TB
    Message([Message to Send]) --> Channel{Select Channel}
    
    Channel -->|SMS| SMSProvider
    Channel -->|Email| EmailProvider
    Channel -->|WhatsApp| WAProvider
    Channel -->|Voice| VoiceProvider
    
    subgraph SMSProvider["SMS Gateway"]
        SMSTemplate[Select Template]
        SMSTemplate --> SMSPersonalize[Personalize Content]
        SMSPersonalize --> SMSSend[Send via API]
        SMSSend --> SMSDLR[Track DLR]
    end
    
    subgraph EmailProvider["Email Service"]
        EmailTemplate[Select Template]
        EmailTemplate --> EmailPersonalize[Add Dynamic Content]
        EmailPersonalize --> EmailSend[Send via SMTP/API]
        EmailSend --> EmailTrack[Track Opens/Clicks]
    end
    
    subgraph WAProvider["WhatsApp Business"]
        WATemplate[Select Approved Template]
        WATemplate --> WAPersonalize[Add Variables]
        WAPersonalize --> WACheck{Session Active?}
        WACheck -->|Yes| WASession[Send Session Message]
        WACheck -->|No| WATemplate2[Send Template Message]
        WASession --> WATrack[Track Delivery]
        WATemplate2 --> WATrack
    end
    
    subgraph VoiceProvider["Voice/IVR System"]
        VoiceScript[Load Call Script]
        VoiceScript --> InitCall[Initiate Call]
        InitCall --> CallStatus{Call Status}
        CallStatus -->|Answered| PlayIVR[Play IVR/Connect Agent]
        CallStatus -->|No Answer| LogMissed[Log Missed Call]
        CallStatus -->|Busy| ScheduleRetry[Schedule Retry]
        PlayIVR --> RecordCall[Record Interaction]
    end
    
    SMSDLR --> UpdateLog[Update Communication Log]
    EmailTrack --> UpdateLog
    WATrack --> UpdateLog
    RecordCall --> UpdateLog
    LogMissed --> UpdateLog
    
    UpdateLog --> Analytics[Communication Analytics]
    Analytics --> OptimizeStrategy[Optimize Channel Strategy]
```

---

## Process Flow Legend

```mermaid
flowchart LR
    Start([Start/End Node])
    Process[Process/Action]
    Decision{Decision Point}
    Data[(Database)]
    Document[/Document/]
    Manual[/Manual Process/]
    System[System/Integration]
    
    Start --> Process
    Process --> Decision
    Decision -->|Yes| Data
    Decision -->|No| Document
    Document --> Manual
    Manual --> System
```

### Symbol Definitions:
- **Oval**: Start/End points
- **Rectangle**: Process or action steps
- **Diamond**: Decision points requiring branching logic
- **Cylinder**: Database operations
- **Parallelogram**: Documents or reports
- **Slanted Rectangle**: Manual interventions
- **Rectangle with double sides**: External system integration

---

## Implementation Notes

### Critical Path Processes
1. **EOD/BOD Synchronization**: Must complete within 2-hour window
2. **Real-time Payment Processing**: Maximum 30-second response time
3. **PTP Monitoring**: Automated checks every 30 minutes
4. **Field Visit Check-in**: GPS validation within 50-meter radius

### Performance Requirements
- API response time: < 2 seconds
- Batch processing: < 2 hours for 1M records
- Dashboard refresh: Real-time (< 1 second)
- Report generation: < 30 seconds for standard reports

### Error Handling Principles
1. All processes must have fallback mechanisms
2. Failed transactions must be queued for retry
3. Manual intervention queues for unresolved issues
4. Comprehensive audit logging for all operations

### Security Checkpoints
- Authentication required at all entry points
- Encryption for all data in transit
- Role-based access control for all processes
- Audit trails for all data modifications

---

*End of Process Flow Documentation*