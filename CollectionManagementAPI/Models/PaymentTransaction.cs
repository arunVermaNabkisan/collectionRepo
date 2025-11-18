using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CollectionManagementSystem.Models
{
    /// <summary>
    /// Payment Transaction entity - mapped to PaymentTransactions table
    /// </summary>
    [Table("PaymentTransactions")]
    public class PaymentTransaction
    {
        [Key]
        public long PaymentID { get; set; }

        [Required]
        [StringLength(50)]
        public string PaymentReferenceNumber { get; set; }

        public long CaseID { get; set; }

        public long CustomerID { get; set; }

        public long LoanAccountID { get; set; }

        public long? PTPID { get; set; }

        // Payment Details
        [Column(TypeName = "decimal(18,2)")]
        public decimal PaymentAmount { get; set; }

        public DateTime PaymentDate { get; set; }

        public DateTime? ValueDate { get; set; }

        [Required]
        [StringLength(50)]
        public string PaymentMode { get; set; }

        [StringLength(50)]
        public string PaymentStatus { get; set; }

        // Payment Instrument Details
        [StringLength(100)]
        public string TransactionReferenceNumber { get; set; }

        [StringLength(100)]
        public string UTRNumber { get; set; }

        [StringLength(100)]
        public string ChequeNumber { get; set; }

        [StringLength(200)]
        public string BankName { get; set; }

        [StringLength(100)]
        public string BranchName { get; set; }

        public DateTime? ChequeDate { get; set; }

        [StringLength(50)]
        public string ChequeStatus { get; set; }

        // Gateway Details (for online payments)
        [StringLength(100)]
        public string PaymentGateway { get; set; }

        [StringLength(100)]
        public string GatewayTransactionID { get; set; }

        [StringLength(50)]
        public string GatewayResponseCode { get; set; }

        [StringLength(500)]
        public string GatewayResponseMessage { get; set; }

        // Payment Link
        public long? PaymentLinkID { get; set; }

        // Receipt Details
        [StringLength(50)]
        public string ReceiptNumber { get; set; }

        public DateTime? ReceiptGeneratedDate { get; set; }

        public bool IsReceiptSent { get; set; }

        // Reconciliation
        public bool IsReconciled { get; set; }

        public DateTime? ReconciliationDate { get; set; }

        public long? ReconciledBy { get; set; }

        [StringLength(500)]
        public string ReconciliationRemarks { get; set; }

        // Reversal Information
        public bool IsReversed { get; set; }

        public DateTime? ReversalDate { get; set; }

        [StringLength(500)]
        public string ReversalReason { get; set; }

        public long? ReversedBy { get; set; }

        // Collection Details
        public long? CollectedByUserID { get; set; }

        public DateTime? CollectionDate { get; set; }

        [StringLength(100)]
        public string CollectionLocation { get; set; }

        // LMS Sync
        public bool SyncedToLMS { get; set; } = false;

        public DateTime? LMSSyncDate { get; set; }

        [StringLength(100)]
        public string LMSReceiptNumber { get; set; }

        // Metadata
        [StringLength(1000)]
        public string Remarks { get; set; }

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
        public LoanAccount LoanAccount { get; set; }
    }

    /// <summary>
    /// Payment Allocation entity - how payment is allocated across components
    /// </summary>
    [Table("PaymentAllocation")]
    public class PaymentAllocation
    {
        [Key]
        public long AllocationID { get; set; }

        public long PaymentID { get; set; }

        public long LoanAccountID { get; set; }

        [StringLength(50)]
        public string AllocationComponent { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal AllocatedAmount { get; set; }

        public int AllocationSequence { get; set; }

        public DateTime CreatedDate { get; set; } = DateTime.Now;
    }
}
