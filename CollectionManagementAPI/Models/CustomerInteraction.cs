using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CollectionManagementSystem.Models
{
    /// <summary>
    /// Customer Interaction entity - unified interaction history across all channels
    /// </summary>
    [Table("CustomerInteractions")]
    public class CustomerInteraction
    {
        [Key]
        public long InteractionID { get; set; }

        [Required]
        [StringLength(50)]
        public string InteractionNumber { get; set; }

        public long CaseID { get; set; }

        public long CustomerID { get; set; }

        public long LoanAccountID { get; set; }

        // Channel and Type
        [Required]
        [StringLength(50)]
        public string InteractionChannel { get; set; }

        [Required]
        [StringLength(50)]
        public string InteractionType { get; set; }

        [StringLength(50)]
        public string InteractionDirection { get; set; }

        // Timing
        public DateTime InteractionDateTime { get; set; }

        public int? DurationSeconds { get; set; }

        [NotMapped]
        public string DurationDisplay
        {
            get
            {
                if (!DurationSeconds.HasValue) return "N/A";
                var ts = TimeSpan.FromSeconds(DurationSeconds.Value);
                return $"{ts.Hours:D2}:{ts.Minutes:D2}:{ts.Seconds:D2}";
            }
        }

        // Initiator
        public long InitiatedByUserID { get; set; }

        [StringLength(100)]
        public string InitiatedByUserName { get; set; }

        // Contact Details
        [StringLength(15)]
        public string ContactNumber { get; set; }

        [StringLength(255)]
        public string ContactEmail { get; set; }

        // Status and Outcome
        [StringLength(50)]
        public string ContactStatus { get; set; }

        [StringLength(50)]
        public string Disposition { get; set; }

        [StringLength(50)]
        public string SubDisposition { get; set; }

        // Customer Response
        [StringLength(100)]
        public string CustomerResponse { get; set; }

        [StringLength(100)]
        public string PaymentCommitment { get; set; }

        public DateTime? CommittedPaymentDate { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal? CommittedAmount { get; set; }

        // Content
        [StringLength(4000)]
        public string InteractionSummary { get; set; }

        public string InteractionTranscript { get; set; }

        [StringLength(2000)]
        public string AgentNotes { get; set; }

        // Call/Recording Details
        [StringLength(100)]
        public string CallSID { get; set; }

        [StringLength(500)]
        public string RecordingURL { get; set; }

        public int? RecordingDuration { get; set; }

        // Email Details
        [StringLength(500)]
        public string EmailSubject { get; set; }

        public bool? EmailOpened { get; set; }

        public DateTime? EmailOpenedDateTime { get; set; }

        public bool? EmailLinkClicked { get; set; }

        // SMS/WhatsApp Details
        [StringLength(50)]
        public string MessageStatus { get; set; }

        public DateTime? MessageDeliveredDateTime { get; set; }

        public DateTime? MessageReadDateTime { get; set; }

        // Campaign
        public long? CampaignID { get; set; }

        public long? TemplateID { get; set; }

        // Follow-up
        public bool RequiresFollowUp { get; set; }

        public DateTime? FollowUpDate { get; set; }

        [StringLength(500)]
        public string FollowUpReason { get; set; }

        // PTP Creation
        public long? PTPCreatedID { get; set; }

        // Compliance
        public bool IsRecordingConsent { get; set; }

        public bool IsComplaint { get; set; }

        [StringLength(50)]
        public string ComplaintCategory { get; set; }

        // Sentiment Analysis
        [StringLength(50)]
        public string SentimentScore { get; set; }

        [Column(TypeName = "decimal(5,2)")]
        public decimal? SentimentConfidence { get; set; }

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
        public User InitiatedByUser { get; set; }
    }
}
