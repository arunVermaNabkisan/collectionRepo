using System;
using System.ComponentModel.DataAnnotations;

namespace CollectionManagementAPI.DTOs
{
    /// <summary>
    /// DTO for creating a new Promise to Pay
    /// </summary>
    public class CreatePTPRequest
    {
        [Required]
        public long CaseID { get; set; }

        [Required]
        public long CustomerID { get; set; }

        [Required]
        public long LoanAccountID { get; set; }

        public long? InteractionID { get; set; }

        [Required]
        [StringLength(50)]
        public string PTPType { get; set; }

        [Required]
        public decimal PromisedAmount { get; set; }

        [Required]
        public DateTime PromisedDate { get; set; }

        [Required]
        [StringLength(50)]
        public string PromisedPaymentMode { get; set; }

        [StringLength(50)]
        public string ConfidenceLevel { get; set; }

        public int? ConfidenceScore { get; set; }

        [StringLength(1000)]
        public string CustomerStatement { get; set; }

        [StringLength(500)]
        public string ReasonForDelay { get; set; }

        [Required]
        public long CreatedByUserID { get; set; }

        [StringLength(1000)]
        public string Remarks { get; set; }
    }

    /// <summary>
    /// DTO for PTP details response
    /// </summary>
    public class PTPDetailDTO
    {
        public long PTPID { get; set; }
        public string PTPNumber { get; set; }
        public long CaseID { get; set; }
        public string CaseNumber { get; set; }
        public string CustomerName { get; set; }
        public string LoanAccountNumber { get; set; }

        public string PTPType { get; set; }
        public decimal PromisedAmount { get; set; }
        public DateTime PromisedDate { get; set; }
        public string PromisedPaymentMode { get; set; }

        public string PTPStatus { get; set; }
        public string ConfidenceLevel { get; set; }
        public int? ConfidenceScore { get; set; }

        public DateTime? ActualPaymentDate { get; set; }
        public decimal? ActualPaymentAmount { get; set; }
        public decimal? VarianceAmount { get; set; }
        public decimal? VariancePercentage { get; set; }

        public string CustomerStatement { get; set; }
        public string ReasonForDelay { get; set; }

        public bool IsOverdue { get; set; }
        public bool IsDueToday { get; set; }
        public int? DaysUntilDue { get; set; }

        public int FollowUpCount { get; set; }
        public DateTime? LastFollowUpDate { get; set; }

        public string CreatedByUserName { get; set; }
        public DateTime CreatedDate { get; set; }
        public string Remarks { get; set; }
    }

    /// <summary>
    /// DTO for updating PTP status
    /// </summary>
    public class UpdatePTPStatusRequest
    {
        [Required]
        [StringLength(50)]
        public string Status { get; set; }

        [StringLength(500)]
        public string Remarks { get; set; }

        [Required]
        public long ModifiedBy { get; set; }
    }

    /// <summary>
    /// DTO for marking PTP as kept
    /// </summary>
    public class MarkPTPAsKeptRequest
    {
        [Required]
        public long PTPID { get; set; }

        [Required]
        public long PaymentID { get; set; }

        public DateTime ActualPaymentDate { get; set; }

        public decimal ActualPaymentAmount { get; set; }

        [Required]
        public long ModifiedBy { get; set; }
    }

    /// <summary>
    /// DTO for PTP statistics
    /// </summary>
    public class PTPStatisticsDTO
    {
        public int TotalPTPs { get; set; }
        public int ActivePTPs { get; set; }
        public int PTPs Kept { get; set; }
        public int PTPsBroken { get; set; }
        public int OverduePTPs { get; set; }
        public decimal PTPSuccessRate { get; set; }
        public decimal TotalPromisedAmount { get; set; }
        public decimal TotalCollectedAgainstPTP { get; set; }
    }
}
