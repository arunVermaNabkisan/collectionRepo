using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using CollectionManagementSystem.Models;

namespace CollectionManagementAPI.Repositories
{
    public interface IPTPRepository : IGenericRepository<PromiseToPay>
    {
        Task<IEnumerable<PromiseToPay>> GetPTPsByCaseIdAsync(long caseId);
        Task<IEnumerable<PromiseToPay>> GetActivePTPsAsync();
        Task<IEnumerable<PromiseToPay>> GetPTPsDueOnDateAsync(DateTime date);
        Task<IEnumerable<PromiseToPay>> GetOverduePTPsAsync();
        Task<bool> UpdatePTPStatusAsync(long ptpId, string status, long modifiedBy);
        Task<bool> MarkPTPAsKeptAsync(long ptpId, long paymentId, long modifiedBy);
        Task<bool> MarkPTPAsBrokenAsync(long ptpId, string reason, long modifiedBy);
        Task<Dictionary<string, int>> GetPTPStatisticsAsync(long? userId = null);
    }
}
