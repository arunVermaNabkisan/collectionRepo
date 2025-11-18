using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CollectionManagementSystem.Models
{
    /// <summary>
    /// Field Visit entity - mapped to FieldVisits table
    /// </summary>
    [Table("FieldVisits")]
    public class FieldVisit
    {
        [Key]
        public long VisitID { get; set; }

        [Required]
        [StringLength(50)]
        public string VisitNumber { get; set; }

        public long CaseID { get; set; }

        public long CustomerID { get; set; }

        public long LoanAccountID { get; set; }

        public long AssignedToUserID { get; set; }

        // Visit Planning
        public DateTime ScheduledDate { get; set; }

        [StringLength(50)]
        public string ScheduledTimeSlot { get; set; }

        [StringLength(50)]
        public string VisitPurpose { get; set; }

        [StringLength(50)]
        public string VisitPriority { get; set; }

        // Visit Address
        [Required]
        [StringLength(500)]
        public string VisitAddressLine1 { get; set; }

        [StringLength(500)]
        public string VisitAddressLine2 { get; set; }

        [StringLength(100)]
        public string VisitCity { get; set; }

        [StringLength(100)]
        public string VisitState { get; set; }

        [StringLength(10)]
        public string VisitPincode { get; set; }

        [Column(TypeName = "decimal(10,8)")]
        public decimal? VisitLatitude { get; set; }

        [Column(TypeName = "decimal(11,8)")]
        public decimal? VisitLongitude { get; set; }

        // Visit Execution
        [StringLength(50)]
        public string VisitStatus { get; set; }

        public DateTime? ActualVisitDate { get; set; }

        public DateTime? CheckInTime { get; set; }

        [Column(TypeName = "decimal(10,8)")]
        public decimal? CheckInLatitude { get; set; }

        [Column(TypeName = "decimal(11,8)")]
        public decimal? CheckInLongitude { get; set; }

        [StringLength(500)]
        public string CheckInAddress { get; set; }

        public DateTime? CheckOutTime { get; set; }

        [Column(TypeName = "decimal(10,8)")]
        public decimal? CheckOutLatitude { get; set; }

        [Column(TypeName = "decimal(11,8)")]
        public decimal? CheckOutLongitude { get; set; }

        [NotMapped]
        public int? VisitDurationMinutes
        {
            get
            {
                if (CheckInTime.HasValue && CheckOutTime.HasValue)
                {
                    return (int)(CheckOutTime.Value - CheckInTime.Value).TotalMinutes;
                }
                return null;
            }
        }

        // Visit Outcome
        [StringLength(50)]
        public string VisitOutcome { get; set; }

        [StringLength(50)]
        public string CustomerMet { get; set; }

        [StringLength(200)]
        public string PersonMetName { get; set; }

        [StringLength(100)]
        public string PersonMetRelation { get; set; }

        [StringLength(15)]
        public string PersonMetContact { get; set; }

        // Customer Feedback
        [StringLength(100)]
        public string CustomerDisposition { get; set; }

        [StringLength(100)]
        public string PaymentCommitment { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal? CommittedAmount { get; set; }

        public DateTime? CommittedDate { get; set; }

        // Observations
        [StringLength(100)]
        public string ResidenceStatus { get; set; }

        [StringLength(100)]
        public string LivingStandard { get; set; }

        [StringLength(100)]
        public string NeighborhoodFeedback { get; set; }

        public bool IsAddressVerified { get; set; }

        [StringLength(2000)]
        public string VisitNotes { get; set; }

        [StringLength(2000)]
        public string AgentRemarks { get; set; }

        // PTP Created
        public long? PTPCreatedID { get; set; }

        // Evidence Collection
        public int PhotosCollected { get; set; }

        public int DocumentsCollected { get; set; }

        public bool VoiceNoteRecorded { get; set; }

        // Route Information
        public long? RouteID { get; set; }

        public int? SequenceInRoute { get; set; }

        // Distance Tracking
        [Column(TypeName = "decimal(10,2)")]
        public decimal? DistanceTravelledKM { get; set; }

        // Expense Tracking
        public bool ExpenseIncurred { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal? ExpenseAmount { get; set; }

        // Metadata
        public DateTime CreatedDate { get; set; } = DateTime.Now;

        public long? CreatedBy { get; set; }

        public DateTime? ModifiedDate { get; set; }

        public long? ModifiedBy { get; set; }

        // Navigation Properties
        [NotMapped]
        public CollectionCase Case { get; set; }

        [NotMapped]
        public Customer Customer { get; set; }

        [NotMapped]
        public User AssignedUser { get; set; }
    }

    /// <summary>
    /// Field Visit Evidence - photos, documents, voice notes
    /// </summary>
    [Table("FieldVisitEvidence")]
    public class FieldVisitEvidence
    {
        [Key]
        public long EvidenceID { get; set; }

        public long VisitID { get; set; }

        [Required]
        [StringLength(50)]
        public string EvidenceType { get; set; }

        [Required]
        [StringLength(500)]
        public string FileName { get; set; }

        [Required]
        public string FilePath { get; set; }

        [StringLength(100)]
        public string FileType { get; set; }

        public long? FileSizeBytes { get; set; }

        [Column(TypeName = "decimal(10,8)")]
        public decimal? CaptureLatitude { get; set; }

        [Column(TypeName = "decimal(11,8)")]
        public decimal? CaptureLongitude { get; set; }

        public DateTime CaptureDateTime { get; set; }

        [StringLength(500)]
        public string Description { get; set; }

        public DateTime CreatedDate { get; set; } = DateTime.Now;

        public long? CreatedBy { get; set; }
    }
}
