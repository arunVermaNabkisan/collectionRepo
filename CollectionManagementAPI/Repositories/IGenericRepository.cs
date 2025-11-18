using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CollectionManagementAPI.Repositories
{
    /// <summary>
    /// Generic repository interface with common CRUD operations
    /// </summary>
    /// <typeparam name="T">Entity type</typeparam>
    public interface IGenericRepository<T> where T : class
    {
        Task<T> GetByIdAsync(long id);
        Task<IEnumerable<T>> GetAllAsync();
        Task<IEnumerable<T>> GetPagedAsync(int pageNumber, int pageSize);
        Task<long> AddAsync(T entity);
        Task<bool> UpdateAsync(T entity);
        Task<bool> DeleteAsync(long id);
        Task<int> CountAsync();
    }
}
