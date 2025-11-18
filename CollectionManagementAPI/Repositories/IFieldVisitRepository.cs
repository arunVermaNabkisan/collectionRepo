using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using CollectionManagementSystem.Models;

namespace CollectionManagementAPI.Repositories
{
    public interface IFieldVisitRepository : IGenericRepository<FieldVisit>
    {
        Task<IEnumerable<FieldVisit>> GetVisitsByUserIdAsync(long userId, DateTime? date = null);
        Task<IEnumerable<FieldVisit>> GetVisitsByCaseIdAsync(long caseId);
        Task<IEnumerable<FieldVisit>> GetScheduledVisitsAsync(DateTime date);
        Task<bool> CheckInVisitAsync(long visitId, decimal latitude, decimal longitude, string address);
        Task<bool> CheckOutVisitAsync(long visitId, decimal latitude, decimal longitude);
        Task<bool> UpdateVisitOutcomeAsync(long visitId, string outcome, string notes, long modifiedBy);
        Task<int> GetVisitCountByUserAsync(long userId, DateTime fromDate, DateTime toDate);
    }
}
