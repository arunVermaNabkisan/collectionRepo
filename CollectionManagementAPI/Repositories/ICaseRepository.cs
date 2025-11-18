using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using CollectionManagementSystem.Models;

namespace CollectionManagementAPI.Repositories
{
    /// <summary>
    /// Interface for Case Repository with specific case-related operations
    /// </summary>
    public interface ICaseRepository : IGenericRepository<CollectionCase>
    {
        Task<CollectionCase> GetCaseDetailsByIdAsync(long caseId);
        Task<IEnumerable<CollectionCase>> GetActiveCasesByUserIdAsync(long userId);
        Task<IEnumerable<CollectionCase>> GetCasesByStatusAsync(string status);
        Task<IEnumerable<CollectionCase>> GetCasesByDPDBucketAsync(string dpdbucket);
        Task<IEnumerable<CollectionCase>> GetAgentWorklistAsync(long userId, DateTime? date);
        Task<bool> UpdateCaseStatusAsync(long caseId, string newStatus, string subStatus, long modifiedBy);
        Task<bool> AssignCaseToUserAsync(long caseId, long userId, long assignedBy);
        Task<bool> ReassignCaseAsync(long caseId, long fromUserId, long toUserId, string reason, long modifiedBy);
        Task<IEnumerable<CollectionCase>> GetOverduePTPCasesAsync();
        Task<IEnumerable<CollectionCase>> GetCasesNeedingFieldVisitAsync();
        Task<Dictionary<string, int>> GetCaseCountByStatusAsync(long? userId = null);
        Task<Dictionary<string, decimal>> GetOutstandingByDPDBucketAsync(long? userId = null);
    }
}
