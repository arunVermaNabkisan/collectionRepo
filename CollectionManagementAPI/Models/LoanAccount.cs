using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CollectionManagementSystem.Models
{
    /// <summary>
    /// Loan Account entity - mapped to LoanAccounts table
    /// </summary>
    [Table("LoanAccounts")]
    public class LoanAccount
    {
        [Key]
        public long LoanAccountID { get; set; }

        [Required]
        [StringLength(50)]
        public string LoanAccountNumber { get; set; }

        public long CustomerID { get; set; }

        // Product Information
        [Required]
        [StringLength(100)]
        public string ProductType { get; set; }

        [StringLength(200)]
        public string ProductName { get; set; }

        [StringLength(100)]
        public string LoanPurpose { get; set; }

        // Loan Terms
        [Column(TypeName = "decimal(18,2)")]
        public decimal SanctionedAmount { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal DisbursedAmount { get; set; }

        public DateTime DisbursementDate { get; set; }

        [Column(TypeName = "decimal(8,4)")]
        public decimal InterestRate { get; set; }

        public int TenureInMonths { get; set; }

        [StringLength(50)]
        public string RepaymentFrequency { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal EMIAmount { get; set; }

        // Outstanding Details
        [Column(TypeName = "decimal(18,2)")]
        public decimal PrincipalOutstanding { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal InterestOutstanding { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal PenalInterestOutstanding { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal LegalChargesOutstanding { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal OtherChargesOutstanding { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal TotalOutstanding { get; set; }

        // Payment Details
        public DateTime? LastPaymentDate { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal? LastPaymentAmount { get; set; }

        public DateTime? NextDueDate { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal? NextDueAmount { get; set; }

        public int TotalEMIsPaid { get; set; }

        public int EMIsOverdue { get; set; }

        // Delinquency Information
        public int CurrentDPD { get; set; }

        public int MaxDPDEver { get; set; }

        [StringLength(50)]
        public string DPDBucket { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal TotalOverdueAmount { get; set; }

        // Account Status
        [StringLength(50)]
        public string LoanStatus { get; set; }

        [StringLength(100)]
        public string LoanSubStatus { get; set; }

        public DateTime? ClosureDate { get; set; }

        [StringLength(500)]
        public string ClosureReason { get; set; }

        // Collateral Information
        public bool IsSecuredLoan { get; set; }

        [StringLength(200)]
        public string CollateralType { get; set; }

        [StringLength(500)]
        public string CollateralDetails { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal? CollateralValue { get; set; }

        // Agreement Details
        [StringLength(100)]
        public string AgreementNumber { get; set; }

        public DateTime? AgreementDate { get; set; }

        // Branch and Territory
        [StringLength(50)]
        public string BranchCode { get; set; }

        [StringLength(200)]
        public string BranchName { get; set; }

        [StringLength(100)]
        public string RegionCode { get; set; }

        [StringLength(200)]
        public string RegionName { get; set; }

        [StringLength(100)]
        public string ZoneCode { get; set; }

        [StringLength(200)]
        public string ZoneName { get; set; }

        // NPA Classification
        public bool IsNPA { get; set; }

        public DateTime? NPADate { get; set; }

        [StringLength(50)]
        public string NPAClassification { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal? ProvisionAmount { get; set; }

        // Write-off Information
        public bool IsWrittenOff { get; set; }

        public DateTime? WriteOffDate { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal? WriteOffAmount { get; set; }

        // Co-borrower Information
        public bool HasCoBorrower { get; set; }

        [StringLength(200)]
        public string CoBorrowerName { get; set; }

        [StringLength(15)]
        public string CoBorrowerMobile { get; set; }

        // Guarantor Information
        public bool HasGuarantor { get; set; }

        [StringLength(200)]
        public string GuarantorName { get; set; }

        [StringLength(15)]
        public string GuarantorMobile { get; set; }

        // Metadata
        public bool IsActive { get; set; } = true;

        public DateTime CreatedDate { get; set; } = DateTime.Now;

        public long? CreatedBy { get; set; }

        public DateTime? ModifiedDate { get; set; }

        public long? ModifiedBy { get; set; }

        public bool SyncedFromLMS { get; set; } = false;

        public DateTime? LastSyncDate { get; set; }

        // Navigation Property
        [NotMapped]
        public Customer Customer { get; set; }
    }
}
