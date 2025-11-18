using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using CollectionManagementSystem.Models;

namespace CollectionManagementAPI.Repositories
{
    public interface IInteractionRepository : IGenericRepository<CustomerInteraction>
    {
        Task<IEnumerable<CustomerInteraction>> GetInteractionsByCaseIdAsync(long caseId);
        Task<IEnumerable<CustomerInteraction>> GetInteractionsByCustomerIdAsync(long customerId);
        Task<IEnumerable<CustomerInteraction>> GetInteractionsByUserIdAsync(long userId, DateTime? fromDate = null);
        Task<CustomerInteraction> GetLatestInteractionByCaseIdAsync(long caseId);
        Task<int> GetInteractionCountAsync(long caseId, string channel = null);
        Task<Dictionary<string, int>> GetDispositionSummaryAsync(long? userId = null, DateTime? fromDate = null);
    }
}
