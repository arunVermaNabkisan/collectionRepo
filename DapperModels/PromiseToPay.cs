using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CollectionManagementSystem.Models
{
    /// <summary>
    /// Promise to Pay entity - mapped to PromiseToPay table
    /// </summary>
    [Table("PromiseToPay")]
    public class PromiseToPay
    {
        [Key]
        public long PTPID { get; set; }

        [Required]
        [StringLength(50)]
        public string PTPNumber { get; set; }

        // Links
        public long CaseID { get; set; }
        public long CustomerID { get; set; }
        public long LoanAccountID { get; set; }
        public long? InteractionID { get; set; }

        // PTP Type
        [Required]
        [StringLength(50)]
        public string PTPType { get; set; }

        public long? ParentPTPID { get; set; }

        // PTP Details
        [Column(TypeName = "decimal(18,2)")]
        [Required]
        public decimal PromisedAmount { get; set; }

        [Required]
        public DateTime PromisedDate { get; set; }

        [StringLength(50)]
        public string PromisedPaymentMode { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal OutstandingAtPTPCreation { get; set; }

        // Confidence and Priority
        [Required]
        [StringLength(20)]
        public string ConfidenceLevel { get; set; }

        [Column(TypeName = "decimal(5,2)")]
        public decimal ConfidenceScore { get; set; } = 0;

        public int Priority { get; set; } = 1;

        // Customer Commitment Details
        public string CustomerStatement { get; set; }

        [StringLength(500)]
        public string ReasonForDelay { get; set; }

        [StringLength(50)]
        public string CommitmentQuality { get; set; }

        // PTP Status
        [Required]
        [StringLength(50)]
        public string PTPStatus { get; set; }

        public DateTime? StatusChangeDate { get; set; }

        // Actual Payment Details
        public DateTime? ActualPaymentDate { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal ActualPaymentAmount { get; set; } = 0;

        public long? PaymentTransactionID { get; set; }

        [NotMapped]
        public decimal VarianceAmount => PromisedAmount - ActualPaymentAmount;

        [NotMapped]
        public decimal VariancePercentage
        {
            get
            {
                if (PromisedAmount == 0) return 0;
                return ((PromisedAmount - ActualPaymentAmount) / PromisedAmount) * 100;
            }
        }

        // Monitoring
        public bool ReminderSent { get; set; } = false;
        public DateTime? ReminderSentDateTime { get; set; }
        public int FollowUpCount { get; set; } = 0;
        public DateTime? LastFollowUpDate { get; set; }

        // Escalation
        public bool IsEscalated { get; set; } = false;
        public long? EscalatedToUserID { get; set; }
        public DateTime? EscalationDate { get; set; }

        [StringLength(500)]
        public string EscalationReason { get; set; }

        // Split PTP Details
        public bool IsSplitPTP { get; set; } = false;
        public int SplitSequence { get; set; } = 1;
        public int TotalSplits { get; set; } = 1;

        // Created By
        public long CreatedByUserID { get; set; }
        public DateTime CreatedDate { get; set; } = DateTime.Now;
        public DateTime? ModifiedDate { get; set; }
        public long? ModifiedBy { get; set; }

        // Notes
        public string Remarks { get; set; }

        // Helper Properties
        [NotMapped]
        public int DaysUntilDue
        {
            get
            {
                return (PromisedDate.Date - DateTime.Today).Days;
            }
        }

        [NotMapped]
        public bool IsOverdue
        {
            get
            {
                return PTPStatus == "Active" && PromisedDate < DateTime.Today;
            }
        }

        [NotMapped]
        public bool IsDueToday
        {
            get
            {
                return PTPStatus == "Active" && PromisedDate.Date == DateTime.Today;
            }
        }

        [NotMapped]
        public string StatusDisplay
        {
            get
            {
                if (IsOverdue) return "Overdue";
                if (IsDueToday) return "Due Today";
                if (DaysUntilDue <= 3 && DaysUntilDue > 0) return "Due Soon";
                return PTPStatus;
            }
        }
    }
}
