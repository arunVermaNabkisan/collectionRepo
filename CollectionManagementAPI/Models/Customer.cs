using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CollectionManagementSystem.Models
{
    /// <summary>
    /// Customer Master entity - mapped to Customers table
    /// </summary>
    [Table("Customers")]
    public class Customer
    {
        [Key]
        public long CustomerID { get; set; }

        [Required]
        [StringLength(50)]
        public string CustomerCode { get; set; }

        // Personal Information
        [Required]
        [StringLength(100)]
        public string FirstName { get; set; }

        [StringLength(100)]
        public string MiddleName { get; set; }

        [Required]
        [StringLength(100)]
        public string LastName { get; set; }

        [NotMapped]
        public string FullName => $"{FirstName} {(!string.IsNullOrEmpty(MiddleName) ? MiddleName + " " : "")}{LastName}";

        public DateTime? DateOfBirth { get; set; }

        [NotMapped]
        public int? Age
        {
            get
            {
                if (!DateOfBirth.HasValue) return null;
                var today = DateTime.Today;
                var age = today.Year - DateOfBirth.Value.Year;
                if (DateOfBirth.Value.Date > today.AddYears(-age)) age--;
                return age;
            }
        }

        [StringLength(10)]
        public string Gender { get; set; }

        // Contact Information
        [Required]
        [StringLength(15)]
        [Phone]
        public string PrimaryMobileNumber { get; set; }

        public bool IsPrimaryMobileVerified { get; set; }

        [StringLength(15)]
        [Phone]
        public string AlternateMobileNumber { get; set; }

        public bool IsAlternateMobileVerified { get; set; }

        [StringLength(255)]
        [EmailAddress]
        public string PrimaryEmail { get; set; }

        public bool IsPrimaryEmailVerified { get; set; }

        [StringLength(255)]
        [EmailAddress]
        public string AlternateEmail { get; set; }

        // Current Address
        [StringLength(500)]
        public string CurrentAddressLine1 { get; set; }

        [StringLength(500)]
        public string CurrentAddressLine2 { get; set; }

        [StringLength(100)]
        public string CurrentCity { get; set; }

        [StringLength(100)]
        public string CurrentState { get; set; }

        [StringLength(10)]
        public string CurrentPincode { get; set; }

        [StringLength(100)]
        public string CurrentCountry { get; set; } = "India";

        // Permanent Address
        [StringLength(500)]
        public string PermanentAddressLine1 { get; set; }

        [StringLength(500)]
        public string PermanentAddressLine2 { get; set; }

        [StringLength(100)]
        public string PermanentCity { get; set; }

        [StringLength(100)]
        public string PermanentState { get; set; }

        [StringLength(10)]
        public string PermanentPincode { get; set; }

        [StringLength(100)]
        public string PermanentCountry { get; set; } = "India";

        // Professional Information
        [StringLength(100)]
        public string Occupation { get; set; }

        [StringLength(50)]
        public string EmploymentType { get; set; }

        [StringLength(200)]
        public string EmployerName { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal? MonthlyIncome { get; set; }

        // Preferences
        [StringLength(50)]
        public string PreferredLanguage { get; set; } = "English";

        [StringLength(50)]
        public string PreferredContactTime { get; set; }

        [StringLength(50)]
        public string PreferredContactMode { get; set; }

        // KYC Information
        [StringLength(20)]
        public string PanNumber { get; set; }

        [StringLength(20)]
        public string AadharNumber { get; set; }

        public bool IsKYCVerified { get; set; }

        public DateTime? KYCVerificationDate { get; set; }

        // Risk and Scoring
        public int CustomerRiskScore { get; set; } = 0;

        public int? CreditBureauScore { get; set; }

        public DateTime? LastBureauPullDate { get; set; }

        // Metadata
        public bool IsActive { get; set; } = true;

        public DateTime CreatedDate { get; set; } = DateTime.Now;

        public long? CreatedBy { get; set; }

        public DateTime? ModifiedDate { get; set; }

        public long? ModifiedBy { get; set; }

        public bool SyncedFromLMS { get; set; } = false;

        public DateTime? LastSyncDate { get; set; }
    }
}
