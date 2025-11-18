using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CollectionManagementSystem.Models
{
    /// <summary>
    /// User entity - mapped to Users table
    /// </summary>
    [Table("Users")]
    public class User
    {
        [Key]
        public long UserID { get; set; }

        [Required]
        [StringLength(50)]
        public string UserCode { get; set; }

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

        [Required]
        [StringLength(255)]
        [EmailAddress]
        public string Email { get; set; }

        [Required]
        [StringLength(15)]
        [Phone]
        public string MobileNumber { get; set; }

        [Required]
        [StringLength(100)]
        public string Username { get; set; }

        [Required]
        public string PasswordHash { get; set; }

        public long RoleID { get; set; }

        public long? TeamID { get; set; }

        public long? ReportsToUserID { get; set; }

        [StringLength(100)]
        public string EmployeeCode { get; set; }

        [StringLength(100)]
        public string Designation { get; set; }

        public DateTime? JoiningDate { get; set; }

        [StringLength(100)]
        public string Department { get; set; }

        [StringLength(100)]
        public string Location { get; set; }

        // Capacity and Limits
        public int MaxConcurrentCases { get; set; } = 50;

        public int DailyCaseAllocationLimit { get; set; } = 100;

        [Column(TypeName = "decimal(18,2)")]
        public decimal? MonthlyCollectionTarget { get; set; }

        public bool CanHandleFieldVisits { get; set; } = false;

        public bool CanHandleLegalCases { get; set; } = false;

        // Login and Session
        public DateTime? LastLoginDate { get; set; }

        public DateTime? LastLogoutDate { get; set; }

        [StringLength(50)]
        public string LastLoginIP { get; set; }

        public bool IsOnline { get; set; } = false;

        public int FailedLoginAttempts { get; set; } = 0;

        public DateTime? AccountLockedUntil { get; set; }

        // Status
        public bool IsActive { get; set; } = true;

        public bool IsDeleted { get; set; } = false;

        public DateTime CreatedDate { get; set; } = DateTime.Now;

        public long? CreatedBy { get; set; }

        public DateTime? ModifiedDate { get; set; }

        public long? ModifiedBy { get; set; }

        // Navigation Properties
        [NotMapped]
        public Role Role { get; set; }

        [NotMapped]
        public Team Team { get; set; }
    }

    [Table("Roles")]
    public class Role
    {
        [Key]
        public long RoleID { get; set; }

        [Required]
        [StringLength(100)]
        public string RoleName { get; set; }

        [StringLength(500)]
        public string Description { get; set; }

        public bool IsActive { get; set; } = true;
    }

    [Table("Teams")]
    public class Team
    {
        [Key]
        public long TeamID { get; set; }

        [Required]
        [StringLength(100)]
        public string TeamName { get; set; }

        [StringLength(500)]
        public string Description { get; set; }

        public long? TeamLeadUserID { get; set; }

        public long? ParentTeamID { get; set; }

        [StringLength(100)]
        public string TeamType { get; set; }

        public bool IsActive { get; set; } = true;

        public DateTime CreatedDate { get; set; } = DateTime.Now;
    }
}
