using System;
using System.ComponentModel.DataAnnotations;

namespace CollectionManagementAPI.DTOs
{
    /// <summary>
    /// DTO for recording a new payment
    /// </summary>
    public class RecordPaymentRequest
    {
        [Required]
        public long CaseID { get; set; }

        [Required]
        public long CustomerID { get; set; }

        [Required]
        public long LoanAccountID { get; set; }

        public long? PTPID { get; set; }

        [Required]
        [Range(0.01, double.MaxValue, ErrorMessage = "Payment amount must be greater than 0")]
        public decimal PaymentAmount { get; set; }

        [Required]
        public DateTime PaymentDate { get; set; }

        [Required]
        [StringLength(50)]
        public string PaymentMode { get; set; }

        [StringLength(100)]
        public string TransactionReferenceNumber { get; set; }

        [StringLength(100)]
        public string UTRNumber { get; set; }

        [StringLength(100)]
        public string ChequeNumber { get; set; }

        [StringLength(200)]
        public string BankName { get; set; }

        public DateTime? ChequeDate { get; set; }

        public long? CollectedByUserID { get; set; }

        [StringLength(1000)]
        public string Remarks { get; set; }

        [Required]
        public long CreatedBy { get; set; }
    }

    /// <summary>
    /// DTO for payment details response
    /// </summary>
    public class PaymentDetailDTO
    {
        public long PaymentID { get; set; }
        public string PaymentReferenceNumber { get; set; }
        public string CaseNumber { get; set; }
        public string CustomerName { get; set; }
        public string LoanAccountNumber { get; set; }

        public decimal PaymentAmount { get; set; }
        public DateTime PaymentDate { get; set; }
        public DateTime? ValueDate { get; set; }
        public string PaymentMode { get; set; }
        public string PaymentStatus { get; set; }

        public string TransactionReferenceNumber { get; set; }
        public string UTRNumber { get; set; }
        public string ChequeNumber { get; set; }
        public string BankName { get; set; }
        public DateTime? ChequeDate { get; set; }
        public string ChequeStatus { get; set; }

        public string ReceiptNumber { get; set; }
        public DateTime? ReceiptGeneratedDate { get; set; }

        public bool IsReconciled { get; set; }
        public DateTime? ReconciliationDate { get; set; }

        public bool IsReversed { get; set; }
        public DateTime? ReversalDate { get; set; }
        public string ReversalReason { get; set; }

        public string CollectedByUserName { get; set; }
        public DateTime CreatedDate { get; set; }
        public string Remarks { get; set; }
    }

    /// <summary>
    /// DTO for payment reconciliation
    /// </summary>
    public class ReconcilePaymentRequest
    {
        [Required]
        public long PaymentID { get; set; }

        [StringLength(500)]
        public string ReconciliationRemarks { get; set; }

        [Required]
        public long ReconciledBy { get; set; }
    }

    /// <summary>
    /// DTO for payment reversal
    /// </summary>
    public class ReversePaymentRequest
    {
        [Required]
        public long PaymentID { get; set; }

        [Required]
        [StringLength(500)]
        public string ReversalReason { get; set; }

        [Required]
        public long ReversedBy { get; set; }
    }

    /// <summary>
    /// DTO for collection summary
    /// </summary>
    public class CollectionSummaryDTO
    {
        public DateTime FromDate { get; set; }
        public DateTime ToDate { get; set; }
        public int TotalPayments { get; set; }
        public decimal TotalAmount { get; set; }
        public decimal CashCollection { get; set; }
        public decimal OnlineCollection { get; set; }
        public decimal ChequeCollection { get; set; }
        public Dictionary<string, decimal> CollectionByMode { get; set; }
        public Dictionary<string, int> PaymentsByStatus { get; set; }
    }
}
