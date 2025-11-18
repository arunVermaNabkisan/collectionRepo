using System.Collections.Generic;
using System.Threading.Tasks;
using CollectionManagementSystem.Models;

namespace CollectionManagementAPI.Repositories
{
    public interface ICustomerRepository : IGenericRepository<Customer>
    {
        Task<Customer> GetByCustomerCodeAsync(string customerCode);
        Task<IEnumerable<Customer>> SearchCustomersAsync(string searchTerm);
        Task<Customer> GetCustomerWithLoansAsync(long customerId);
        Task<bool> UpdateContactInfoAsync(long customerId, string mobile, string email, long modifiedBy);
    }
}
