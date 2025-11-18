using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Dapper;
using CollectionManagementSystem.Models;
using Microsoft.Data.SqlClient;

namespace CollectionManagementAPI.Repositories
{
    /// <summary>
    /// Repository for Collection Case operations
    /// </summary>
    public class CaseRepository : ICaseRepository
    {
        private readonly DapperContext _context;

        public CaseRepository(DapperContext context)
        {
            _context = context;
        }

        public async Task<CollectionCase> GetByIdAsync(long id)
        {
            using var connection = _context.CreateConnection();
            var sql = "SELECT * FROM CollectionCases WHERE CaseID = @CaseID AND IsActive = 1";
            return await connection.QueryFirstOrDefaultAsync<CollectionCase>(sql, new { CaseID = id });
        }

        public async Task<CollectionCase> GetCaseDetailsByIdAsync(long caseId)
        {
            using var connection = _context.CreateConnection();
            var sql = @"
                SELECT
                    c.*,
                    cust.*,
                    loan.*,
                    u.*
                FROM CollectionCases c
                LEFT JOIN Customers cust ON c.CustomerID = cust.CustomerID
                LEFT JOIN LoanAccounts loan ON c.LoanAccountID = loan.LoanAccountID
                LEFT JOIN Users u ON c.AssignedToUserID = u.UserID
                WHERE c.CaseID = @CaseID";

            var caseDictionary = new Dictionary<long, CollectionCase>();

            var result = await connection.QueryAsync<CollectionCase, Customer, LoanAccount, User, CollectionCase>(
                sql,
                (collectionCase, customer, loanAccount, user) =>
                {
                    if (!caseDictionary.TryGetValue(collectionCase.CaseID, out var caseEntry))
                    {
                        caseEntry = collectionCase;
                        caseEntry.Customer = customer;
                        caseEntry.LoanAccount = loanAccount;
                        caseEntry.AssignedUser = user;
                        caseDictionary.Add(caseEntry.CaseID, caseEntry);
                    }
                    return caseEntry;
                },
                new { CaseID = caseId },
                splitOn: "CustomerID,LoanAccountID,UserID"
            );

            return caseDictionary.Values.FirstOrDefault();
        }

        public async Task<IEnumerable<CollectionCase>> GetAllAsync()
        {
            using var connection = _context.CreateConnection();
            var sql = "SELECT TOP 1000 * FROM CollectionCases WHERE IsActive = 1 ORDER BY CreatedDate DESC";
            return await connection.QueryAsync<CollectionCase>(sql);
        }

        public async Task<IEnumerable<CollectionCase>> GetPagedAsync(int pageNumber, int pageSize)
        {
            using var connection = _context.CreateConnection();
            var offset = (pageNumber - 1) * pageSize;
            var sql = @"
                SELECT * FROM CollectionCases
                WHERE IsActive = 1
                ORDER BY CreatedDate DESC
                OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY";

            return await connection.QueryAsync<CollectionCase>(sql, new { Offset = offset, PageSize = pageSize });
        }

        public async Task<IEnumerable<CollectionCase>> GetActiveCasesByUserIdAsync(long userId)
        {
            using var connection = _context.CreateConnection();
            var sql = @"
                SELECT * FROM vw_ActiveCasesDetail
                WHERE AssignedToUserID = @UserID
                ORDER BY PriorityScore DESC, CurrentDPD DESC";

            return await connection.QueryAsync<CollectionCase>(sql, new { UserID = userId });
        }

        public async Task<IEnumerable<CollectionCase>> GetCasesByStatusAsync(string status)
        {
            using var connection = _context.CreateConnection();
            var sql = "SELECT * FROM CollectionCases WHERE CaseStatus = @Status AND IsActive = 1";
            return await connection.QueryAsync<CollectionCase>(sql, new { Status = status });
        }

        public async Task<IEnumerable<CollectionCase>> GetCasesByDPDBucketAsync(string dpdbucket)
        {
            using var connection = _context.CreateConnection();
            var sql = "SELECT * FROM CollectionCases WHERE DPDBucket = @DPDBucket AND IsActive = 1";
            return await connection.QueryAsync<CollectionCase>(sql, new { DPDBucket = dpdbucket });
        }

        public async Task<IEnumerable<CollectionCase>> GetAgentWorklistAsync(long userId, DateTime? date)
        {
            using var connection = _context.CreateConnection();
            var parameters = new DynamicParameters();
            parameters.Add("@UserID", userId);
            parameters.Add("@WorklistDate", date ?? DateTime.Today);

            return await connection.QueryAsync<CollectionCase>(
                "sp_GetAgentWorklist",
                parameters,
                commandType: CommandType.StoredProcedure
            );
        }

        public async Task<long> AddAsync(CollectionCase entity)
        {
            using var connection = _context.CreateConnection();
            var sql = @"
                INSERT INTO CollectionCases (
                    CaseNumber, CustomerID, LoanAccountID, CurrentDPD, DPDBucket,
                    CurrentOutstandingAmount, OverdueAmount, CaseStatus, CaseSubStatus,
                    CasePriority, PriorityScore, AssignedToUserID, AssignedToTeamID,
                    CreatedDate, CreatedBy, IsActive
                )
                VALUES (
                    @CaseNumber, @CustomerID, @LoanAccountID, @CurrentDPD, @DPDBucket,
                    @CurrentOutstandingAmount, @OverdueAmount, @CaseStatus, @CaseSubStatus,
                    @CasePriority, @PriorityScore, @AssignedToUserID, @AssignedToTeamID,
                    @CreatedDate, @CreatedBy, @IsActive
                );
                SELECT CAST(SCOPE_IDENTITY() as bigint)";

            return await connection.ExecuteScalarAsync<long>(sql, entity);
        }

        public async Task<bool> UpdateAsync(CollectionCase entity)
        {
            using var connection = _context.CreateConnection();
            var sql = @"
                UPDATE CollectionCases SET
                    CurrentDPD = @CurrentDPD,
                    DPDBucket = @DPDBucket,
                    CurrentOutstandingAmount = @CurrentOutstandingAmount,
                    OverdueAmount = @OverdueAmount,
                    CaseStatus = @CaseStatus,
                    CaseSubStatus = @CaseSubStatus,
                    CasePriority = @CasePriority,
                    PriorityScore = @PriorityScore,
                    ModifiedDate = @ModifiedDate,
                    ModifiedBy = @ModifiedBy
                WHERE CaseID = @CaseID";

            var rowsAffected = await connection.ExecuteAsync(sql, entity);
            return rowsAffected > 0;
        }

        public async Task<bool> UpdateCaseStatusAsync(long caseId, string newStatus, string subStatus, long modifiedBy)
        {
            using var connection = _context.CreateConnection();

            using var transaction = connection.BeginTransaction();
            try
            {
                // Update case status
                var updateSql = @"
                    UPDATE CollectionCases
                    SET CaseStatus = @NewStatus,
                        CaseSubStatus = @SubStatus,
                        ModifiedDate = @ModifiedDate,
                        ModifiedBy = @ModifiedBy
                    WHERE CaseID = @CaseID";

                await connection.ExecuteAsync(updateSql, new
                {
                    CaseID = caseId,
                    NewStatus = newStatus,
                    SubStatus = subStatus,
                    ModifiedDate = DateTime.Now,
                    ModifiedBy = modifiedBy
                }, transaction);

                // Insert status history
                var historySql = @"
                    INSERT INTO CaseStatusHistory (CaseID, OldStatus, NewStatus, StatusChangeReason, ChangedBy, ChangedDate)
                    SELECT @CaseID, CaseStatus, @NewStatus, 'Status Update', @ModifiedBy, @ChangedDate
                    FROM CollectionCases WHERE CaseID = @CaseID";

                await connection.ExecuteAsync(historySql, new
                {
                    CaseID = caseId,
                    NewStatus = newStatus,
                    ModifiedBy = modifiedBy,
                    ChangedDate = DateTime.Now
                }, transaction);

                transaction.Commit();
                return true;
            }
            catch
            {
                transaction.Rollback();
                throw;
            }
        }

        public async Task<bool> AssignCaseToUserAsync(long caseId, long userId, long assignedBy)
        {
            using var connection = _context.CreateConnection();
            var sql = @"
                UPDATE CollectionCases
                SET AssignedToUserID = @UserID,
                    AssignedDate = @AssignedDate,
                    ModifiedDate = @ModifiedDate,
                    ModifiedBy = @AssignedBy
                WHERE CaseID = @CaseID";

            var rowsAffected = await connection.ExecuteAsync(sql, new
            {
                CaseID = caseId,
                UserID = userId,
                AssignedDate = DateTime.Now,
                ModifiedDate = DateTime.Now,
                AssignedBy = assignedBy
            });

            return rowsAffected > 0;
        }

        public async Task<bool> ReassignCaseAsync(long caseId, long fromUserId, long toUserId, string reason, long modifiedBy)
        {
            using var connection = _context.CreateConnection();

            using var transaction = connection.BeginTransaction();
            try
            {
                // Update case assignment
                var updateSql = @"
                    UPDATE CollectionCases
                    SET AssignedToUserID = @ToUserID,
                        LastReassignedDate = @ReassignedDate,
                        ModifiedDate = @ModifiedDate,
                        ModifiedBy = @ModifiedBy
                    WHERE CaseID = @CaseID AND AssignedToUserID = @FromUserID";

                await connection.ExecuteAsync(updateSql, new
                {
                    CaseID = caseId,
                    FromUserID = fromUserId,
                    ToUserID = toUserId,
                    ReassignedDate = DateTime.Now,
                    ModifiedDate = DateTime.Now,
                    ModifiedBy = modifiedBy
                }, transaction);

                transaction.Commit();
                return true;
            }
            catch
            {
                transaction.Rollback();
                throw;
            }
        }

        public async Task<bool> DeleteAsync(long id)
        {
            using var connection = _context.CreateConnection();
            var sql = "UPDATE CollectionCases SET IsActive = 0 WHERE CaseID = @CaseID";
            var rowsAffected = await connection.ExecuteAsync(sql, new { CaseID = id });
            return rowsAffected > 0;
        }

        public async Task<int> CountAsync()
        {
            using var connection = _context.CreateConnection();
            var sql = "SELECT COUNT(*) FROM CollectionCases WHERE IsActive = 1";
            return await connection.ExecuteScalarAsync<int>(sql);
        }

        public async Task<IEnumerable<CollectionCase>> GetOverduePTPCasesAsync()
        {
            using var connection = _context.CreateConnection();
            var sql = @"
                SELECT DISTINCT c.*
                FROM CollectionCases c
                INNER JOIN PromiseToPay ptp ON c.CaseID = ptp.CaseID
                WHERE ptp.PTPStatus = 'Active'
                AND ptp.PromisedDate < @Today
                AND c.IsActive = 1";

            return await connection.QueryAsync<CollectionCase>(sql, new { Today = DateTime.Today });
        }

        public async Task<IEnumerable<CollectionCase>> GetCasesNeedingFieldVisitAsync()
        {
            using var connection = _context.CreateConnection();
            var sql = @"
                SELECT * FROM CollectionCases
                WHERE FieldVisitRequired = 1
                AND IsActive = 1
                AND CaseStatus IN ('Active', 'Follow-Up')
                ORDER BY PriorityScore DESC";

            return await connection.QueryAsync<CollectionCase>(sql);
        }

        public async Task<Dictionary<string, int>> GetCaseCountByStatusAsync(long? userId = null)
        {
            using var connection = _context.CreateConnection();
            var sql = @"
                SELECT CaseStatus, COUNT(*) as Count
                FROM CollectionCases
                WHERE IsActive = 1";

            if (userId.HasValue)
            {
                sql += " AND AssignedToUserID = @UserID";
            }

            sql += " GROUP BY CaseStatus";

            var results = await connection.QueryAsync<(string Status, int Count)>(sql, new { UserID = userId });
            return results.ToDictionary(x => x.Status, x => x.Count);
        }

        public async Task<Dictionary<string, decimal>> GetOutstandingByDPDBucketAsync(long? userId = null)
        {
            using var connection = _context.CreateConnection();
            var sql = @"
                SELECT DPDBucket, SUM(CurrentOutstandingAmount) as TotalOutstanding
                FROM CollectionCases
                WHERE IsActive = 1";

            if (userId.HasValue)
            {
                sql += " AND AssignedToUserID = @UserID";
            }

            sql += " GROUP BY DPDBucket";

            var results = await connection.QueryAsync<(string Bucket, decimal Outstanding)>(sql, new { UserID = userId });
            return results.ToDictionary(x => x.Bucket ?? "Unknown", x => x.Outstanding);
        }
    }
}
