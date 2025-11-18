using System;
using System.ComponentModel.DataAnnotations;

namespace CollectionManagementAPI.DTOs
{
    /// <summary>
    /// DTO for Case details response
    /// </summary>
    public class CaseDetailDTO
    {
        public long CaseID { get; set; }
        public string CaseNumber { get; set; }
        public string CaseStatus { get; set; }
        public string CaseSubStatus { get; set; }
        public int CurrentDPD { get; set; }
        public string DPDBucket { get; set; }
        public decimal CurrentOutstandingAmount { get; set; }
        public decimal OverdueAmount { get; set; }
        public string CasePriority { get; set; }
        public int PriorityScore { get; set; }

        // Customer Info
        public long CustomerID { get; set; }
        public string CustomerCode { get; set; }
        public string CustomerName { get; set; }
        public string PrimaryMobileNumber { get; set; }
        public string PrimaryEmail { get; set; }

        // Loan Info
        public long LoanAccountID { get; set; }
        public string LoanAccountNumber { get; set; }
        public string ProductType { get; set; }
        public decimal TotalOutstanding { get; set; }

        // Assignment Info
        public long? AssignedToUserID { get; set; }
        public string AssignedToUserName { get; set; }
        public long? AssignedToTeamID { get; set; }
        public DateTime? AssignedDate { get; set; }

        // Activity Summary
        public int TotalContactAttempts { get; set; }
        public int SuccessfulContactCount { get; set; }
        public DateTime? LastContactAttemptDate { get; set; }
        public decimal TotalAmountCollected { get; set; }
        public DateTime? LastCollectionDate { get; set; }

        // PTP Summary
        public int ActivePTPCount { get; set; }
        public int TotalPTPsMade { get; set; }
        public int PTPsKept { get; set; }
        public int PTPsBroken { get; set; }
        public decimal? PTPSuccessRate { get; set; }
    }

    /// <summary>
    /// DTO for creating a new case
    /// </summary>
    public class CreateCaseRequest
    {
        [Required]
        public long CustomerID { get; set; }

        [Required]
        public long LoanAccountID { get; set; }

        [Required]
        public int CurrentDPD { get; set; }

        [Required]
        [StringLength(50)]
        public string DPDBucket { get; set; }

        [Required]
        public decimal CurrentOutstandingAmount { get; set; }

        [Required]
        public decimal OverdueAmount { get; set; }

        public long? AssignedToUserID { get; set; }

        public long? AssignedToTeamID { get; set; }

        public long CreatedBy { get; set; }
    }

    /// <summary>
    /// DTO for updating case status
    /// </summary>
    public class UpdateCaseStatusRequest
    {
        [Required]
        [StringLength(50)]
        public string NewStatus { get; set; }

        [StringLength(100)]
        public string SubStatus { get; set; }

        [StringLength(500)]
        public string Remarks { get; set; }

        [Required]
        public long ModifiedBy { get; set; }
    }

    /// <summary>
    /// DTO for case assignment
    /// </summary>
    public class AssignCaseRequest
    {
        [Required]
        public long CaseID { get; set; }

        [Required]
        public long AssignToUserID { get; set; }

        [Required]
        public long AssignedBy { get; set; }

        [StringLength(500)]
        public string AssignmentReason { get; set; }
    }

    /// <summary>
    /// DTO for case summary in list views
    /// </summary>
    public class CaseSummaryDTO
    {
        public long CaseID { get; set; }
        public string CaseNumber { get; set; }
        public string CustomerName { get; set; }
        public string LoanAccountNumber { get; set; }
        public int CurrentDPD { get; set; }
        public string DPDBucket { get; set; }
        public decimal OverdueAmount { get; set; }
        public string CaseStatus { get; set; }
        public string AssignedToUserName { get; set; }
        public DateTime? LastContactDate { get; set; }
        public int PriorityScore { get; set; }
    }

    /// <summary>
    /// DTO for case statistics
    /// </summary>
    public class CaseStatisticsDTO
    {
        public int TotalCases { get; set; }
        public int ActiveCases { get; set; }
        public int ResolvedCases { get; set; }
        public int ClosedCases { get; set; }
        public decimal TotalOutstanding { get; set; }
        public decimal TotalOverdue { get; set; }
        public Dictionary<string, int> CasesByStatus { get; set; }
        public Dictionary<string, decimal> OutstandingByBucket { get; set; }
    }
}
