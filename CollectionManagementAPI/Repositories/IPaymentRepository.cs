using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using CollectionManagementSystem.Models;

namespace CollectionManagementAPI.Repositories
{
    public interface IPaymentRepository : IGenericRepository<PaymentTransaction>
    {
        Task<IEnumerable<PaymentTransaction>> GetPaymentsByCaseIdAsync(long caseId);
        Task<IEnumerable<PaymentTransaction>> GetPaymentsByDateRangeAsync(DateTime fromDate, DateTime toDate);
        Task<PaymentTransaction> GetPaymentByReferenceNumberAsync(string referenceNumber);
        Task<bool> ReconcilePaymentAsync(long paymentId, long reconciledBy);
        Task<bool> ReversePaymentAsync(long paymentId, string reason, long reversedBy);
        Task<decimal> GetTotalCollectionByUserAsync(long userId, DateTime fromDate, DateTime toDate);
        Task<Dictionary<string, decimal>> GetCollectionSummaryAsync(DateTime fromDate, DateTime toDate);
    }
}
