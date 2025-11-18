using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CollectionManagementSystem.Models
{
    /// <summary>
    /// Collection Case entity - mapped to CollectionCases table
    /// </summary>
    [Table("CollectionCases")]
    public class CollectionCase
    {
        [Key]
        public long CaseID { get; set; }

        [Required]
        [StringLength(50)]
        public string CaseNumber { get; set; }

        // Links
        public long CustomerID { get; set; }
        public long LoanAccountID { get; set; }

        // Case Classification
        public int CurrentDPD { get; set; }

        [Required]
        [StringLength(20)]
        public string DPDBucket { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal CurrentOutstandingAmount { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal OverdueAmount { get; set; }

        // Case Status
        [Required]
        [StringLength(50)]
        public string CaseStatus { get; set; }

        [StringLength(100)]
        public string CaseSubStatus { get; set; }

        [Required]
        [StringLength(20)]
        public string CasePriority { get; set; }

        public int PriorityScore { get; set; } = 0;

        // Assignment
        public long? AssignedToUserID { get; set; }
        public long? AssignedToTeamID { get; set; }
        public DateTime? AssignedDate { get; set; }
        public DateTime? LastReassignedDate { get; set; }

        // Strategy
        public long? CurrentStrategyID { get; set; }
        public DateTime? StrategyAssignedDate { get; set; }

        // Risk and Behavior Scoring
        public int BehavioralScore { get; set; } = 0;

        [Column(TypeName = "decimal(5,2)")]
        public decimal ProbabilityOfPayment { get; set; } = 0;

        [StringLength(50)]
        public string RiskCategory { get; set; }

        // SLA and Escalation
        public DateTime? SLADueDate { get; set; }
        public bool IsSLABreached { get; set; } = false;
        public int EscalationLevel { get; set; } = 0;
        public DateTime? LastEscalationDate { get; set; }

        // Activity Tracking
        public DateTime? FirstContactAttemptDate { get; set; }
        public DateTime? LastContactAttemptDate { get; set; }
        public int TotalContactAttempts { get; set; } = 0;
        public int SuccessfulContactCount { get; set; } = 0;

        // Payment Tracking
        [Column(TypeName = "decimal(18,2)")]
        public decimal TotalAmountCollected { get; set; } = 0;

        public DateTime? LastCollectionDate { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal? LastCollectionAmount { get; set; }

        // PTP Tracking
        public int ActivePTPCount { get; set; } = 0;
        public int TotalPTPsMade { get; set; } = 0;
        public int PTPsKept { get; set; } = 0;
        public int PTPsBroken { get; set; } = 0;

        [NotMapped]
        public decimal PTPSuccessRate
        {
            get
            {
                if (TotalPTPsMade == 0) return 0;
                return ((decimal)PTPsKept / TotalPTPsMade) * 100;
            }
        }

        // Field Visit
        public bool FieldVisitRequired { get; set; } = false;
        public int TotalFieldVisits { get; set; } = 0;
        public DateTime? LastFieldVisitDate { get; set; }

        // Legal Status
        public bool IsLegalActionInitiated { get; set; } = false;
        public DateTime? LegalActionDate { get; set; }

        [StringLength(100)]
        public string LegalCaseNumber { get; set; }

        // Closure Information
        [StringLength(50)]
        public string ResolutionType { get; set; }

        public DateTime? ClosureDate { get; set; }
        public string ClosureRemarks { get; set; }

        // Metadata
        public bool IsActive { get; set; } = true;
        public DateTime CreatedDate { get; set; } = DateTime.Now;
        public long? CreatedBy { get; set; }
        public DateTime? ModifiedDate { get; set; }
        public long? ModifiedBy { get; set; }

        // Navigation Properties (not mapped to DB, populated via Dapper)
        [NotMapped]
        public Customer Customer { get; set; }

        [NotMapped]
        public LoanAccount LoanAccount { get; set; }

        [NotMapped]
        public User AssignedUser { get; set; }
    }
}
