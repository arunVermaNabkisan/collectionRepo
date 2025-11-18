using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using Dapper;
using CollectionManagementSystem.Models;

namespace CollectionManagementSystem.Data.Repositories
{
    /// <summary>
    /// Repository for Collection Case operations using Dapper
    /// </summary>
    public class CaseRepository : ICaseRepository
    {
        private readonly DapperContext _context;

        public CaseRepository(DapperContext context)
        {
            _context = context ?? throw new ArgumentNullException(nameof(context));
        }

        /// <summary>
        /// Get case details by Case ID with related entities
        /// </summary>
        public async Task<CollectionCase> GetCaseDetailsByIdAsync(long caseId)
        {
            using var connection = _context.CreateConnection();

            var sql = @"
                SELECT
                    cc.*,
                    c.*,
                    la.*,
                    u.*
                FROM CollectionCases cc
                INNER JOIN Customers c ON cc.CustomerID = c.CustomerID
                INNER JOIN LoanAccounts la ON cc.LoanAccountID = la.LoanAccountID
                LEFT JOIN Users u ON cc.AssignedToUserID = u.UserID
                WHERE cc.CaseID = @CaseId";

            var cases = await connection.QueryAsync<CollectionCase, Customer, LoanAccount, User, CollectionCase>(
                sql,
                (collectionCase, customer, loanAccount, user) =>
                {
                    collectionCase.Customer = customer;
                    collectionCase.LoanAccount = loanAccount;
                    collectionCase.AssignedUser = user;
                    return collectionCase;
                },
                new { CaseId = caseId },
                splitOn: "CustomerID,LoanAccountID,UserID"
            );

            return cases.FirstOrDefault();
        }

        /// <summary>
        /// Get active cases for a specific user (RM)
        /// </summary>
        public async Task<IEnumerable<CollectionCase>> GetActiveCasesByUserIdAsync(long userId)
        {
            using var connection = _context.CreateConnection();

            var sql = @"
                SELECT * FROM vw_ActiveCasesDetail
                WHERE RMUserID = @UserId
                ORDER BY CasePriority DESC, PriorityScore DESC, CurrentDPD DESC";

            return await connection.QueryAsync<CollectionCase>(sql, new { UserId = userId });
        }

        /// <summary>
        /// Get agent worklist using stored procedure
        /// </summary>
        public async Task<IEnumerable<dynamic>> GetAgentWorklistAsync(long userId, DateTime? date = null)
        {
            using var connection = _context.CreateConnection();

            return await connection.QueryAsync(
                "sp_GetAgentWorklist",
                new { UserID = userId, Date = date ?? DateTime.Today },
                commandType: CommandType.StoredProcedure
            );
        }

        /// <summary>
        /// Update case status
        /// </summary>
        public async Task<bool> UpdateCaseStatusAsync(long caseId, string newStatus, long modifiedBy, string remarks = null)
        {
            using var connection = _context.CreateConnection();
            connection.Open();
            using var transaction = connection.BeginTransaction();

            try
            {
                // Get current status
                var currentStatus = await connection.QueryFirstOrDefaultAsync<string>(
                    "SELECT CaseStatus FROM CollectionCases WHERE CaseID = @CaseId",
                    new { CaseId = caseId },
                    transaction
                );

                // Update case status
                var updateSql = @"
                    UPDATE CollectionCases
                    SET CaseStatus = @NewStatus,
                        ModifiedDate = GETDATE(),
                        ModifiedBy = @ModifiedBy
                    WHERE CaseID = @CaseId";

                await connection.ExecuteAsync(
                    updateSql,
                    new { CaseId = caseId, NewStatus = newStatus, ModifiedBy = modifiedBy },
                    transaction
                );

                // Insert status history
                var historySql = @"
                    INSERT INTO CaseStatusHistory (CaseID, PreviousStatus, NewStatus, ChangedByUserID, Remarks)
                    VALUES (@CaseId, @PreviousStatus, @NewStatus, @ChangedBy, @Remarks)";

                await connection.ExecuteAsync(
                    historySql,
                    new { CaseId = caseId, PreviousStatus = currentStatus, NewStatus = newStatus, ChangedBy = modifiedBy, Remarks = remarks },
                    transaction
                );

                transaction.Commit();
                return true;
            }
            catch
            {
                transaction.Rollback();
                throw;
            }
        }

        /// <summary>
        /// Get cases by DPD bucket
        /// </summary>
        public async Task<IEnumerable<CollectionCase>> GetCasesByDPDBucketAsync(string dpdBucket)
        {
            using var connection = _context.CreateConnection();

            var sql = @"
                SELECT * FROM CollectionCases
                WHERE DPDBucket = @DPDBucket
                    AND IsActive = 1
                    AND CaseStatus NOT IN ('Closed', 'WrittenOff')
                ORDER BY PriorityScore DESC, CurrentDPD DESC";

            return await connection.QueryAsync<CollectionCase>(sql, new { DPDBucket = dpdBucket });
        }

        /// <summary>
        /// Search cases with filters
        /// </summary>
        public async Task<IEnumerable<CollectionCase>> SearchCasesAsync(CaseSearchFilter filter)
        {
            using var connection = _context.CreateConnection();

            var sql = @"
                SELECT cc.*, c.FullName AS CustomerName, la.LoanAccountNumber
                FROM CollectionCases cc
                INNER JOIN Customers c ON cc.CustomerID = c.CustomerID
                INNER JOIN LoanAccounts la ON cc.LoanAccountID = la.LoanAccountID
                WHERE cc.IsActive = 1";

            var parameters = new DynamicParameters();

            if (!string.IsNullOrEmpty(filter.CaseNumber))
            {
                sql += " AND cc.CaseNumber LIKE @CaseNumber";
                parameters.Add("CaseNumber", $"%{filter.CaseNumber}%");
            }

            if (!string.IsNullOrEmpty(filter.CustomerName))
            {
                sql += " AND c.FullName LIKE @CustomerName";
                parameters.Add("CustomerName", $"%{filter.CustomerName}%");
            }

            if (!string.IsNullOrEmpty(filter.LoanAccountNumber))
            {
                sql += " AND la.LoanAccountNumber LIKE @LoanAccountNumber";
                parameters.Add("LoanAccountNumber", $"%{filter.LoanAccountNumber}%");
            }

            if (!string.IsNullOrEmpty(filter.DPDBucket))
            {
                sql += " AND cc.DPDBucket = @DPDBucket";
                parameters.Add("DPDBucket", filter.DPDBucket);
            }

            if (!string.IsNullOrEmpty(filter.CaseStatus))
            {
                sql += " AND cc.CaseStatus = @CaseStatus";
                parameters.Add("CaseStatus", filter.CaseStatus);
            }

            if (filter.AssignedToUserID.HasValue)
            {
                sql += " AND cc.AssignedToUserID = @AssignedToUserID";
                parameters.Add("AssignedToUserID", filter.AssignedToUserID.Value);
            }

            sql += " ORDER BY cc.PriorityScore DESC, cc.CurrentDPD DESC";

            return await connection.QueryAsync<CollectionCase>(sql, parameters);
        }

        /// <summary>
        /// Get dashboard metrics using stored procedure
        /// </summary>
        public async Task<DashboardMetrics> GetDashboardMetricsAsync(long? userId = null, long? teamId = null, DateTime? date = null)
        {
            using var connection = _context.CreateConnection();

            using var multi = await connection.QueryMultipleAsync(
                "sp_GetDashboardMetrics",
                new { UserID = userId, TeamID = teamId, Date = date ?? DateTime.Today },
                commandType: CommandType.StoredProcedure
            );

            var metrics = new DashboardMetrics();

            // Total cases summary
            var summary = await multi.ReadFirstOrDefaultAsync<dynamic>();
            metrics.TotalCases = summary.TotalCases;
            metrics.TotalOutstanding = summary.TotalOutstanding;
            metrics.CriticalCases = summary.CriticalCases;
            metrics.HighPriorityCases = summary.HighPriorityCases;

            // DPD bucket distribution
            metrics.BucketDistribution = (await multi.ReadAsync<BucketDistribution>()).ToList();

            // PTP summary
            var ptpSummary = await multi.ReadFirstOrDefaultAsync<dynamic>();
            metrics.PTPlDueToday = ptpSummary?.PTPlDueToday ?? 0;
            metrics.TotalPromisedAmount = ptpSummary?.TotalPromisedAmount ?? 0;

            // Collection summary
            var collectionSummary = await multi.ReadFirstOrDefaultAsync<dynamic>();
            metrics.TodayPaymentCount = collectionSummary?.PaymentCount ?? 0;
            metrics.TodayTotalCollected = collectionSummary?.TotalCollected ?? 0;

            return metrics;
        }
    }

    // Supporting classes
    public class CaseSearchFilter
    {
        public string CaseNumber { get; set; }
        public string CustomerName { get; set; }
        public string LoanAccountNumber { get; set; }
        public string DPDBucket { get; set; }
        public string CaseStatus { get; set; }
        public long? AssignedToUserID { get; set; }
    }

    public class DashboardMetrics
    {
        public int TotalCases { get; set; }
        public decimal TotalOutstanding { get; set; }
        public int CriticalCases { get; set; }
        public int HighPriorityCases { get; set; }
        public List<BucketDistribution> BucketDistribution { get; set; }
        public int PTPlDueToday { get; set; }
        public decimal TotalPromisedAmount { get; set; }
        public int TodayPaymentCount { get; set; }
        public decimal TodayTotalCollected { get; set; }
    }

    public class BucketDistribution
    {
        public string DPDBucket { get; set; }
        public int CaseCount { get; set; }
        public decimal OutstandingAmount { get; set; }
    }

    public interface ICaseRepository
    {
        Task<CollectionCase> GetCaseDetailsByIdAsync(long caseId);
        Task<IEnumerable<CollectionCase>> GetActiveCasesByUserIdAsync(long userId);
        Task<IEnumerable<dynamic>> GetAgentWorklistAsync(long userId, DateTime? date = null);
        Task<bool> UpdateCaseStatusAsync(long caseId, string newStatus, long modifiedBy, string remarks = null);
        Task<IEnumerable<CollectionCase>> GetCasesByDPDBucketAsync(string dpdBucket);
        Task<IEnumerable<CollectionCase>> SearchCasesAsync(CaseSearchFilter filter);
        Task<DashboardMetrics> GetDashboardMetricsAsync(long? userId = null, long? teamId = null, DateTime? date = null);
    }
}
