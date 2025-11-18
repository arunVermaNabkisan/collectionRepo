using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using CollectionManagementAPI.DTOs;

namespace CollectionManagementAPI.Services
{
    public interface ICaseService
    {
        Task<CaseDetailDTO> GetCaseByIdAsync(long caseId);
        Task<List<CaseSummaryDTO>> GetAgentWorklistAsync(long userId, DateTime? date = null);
        Task<List<CaseSummaryDTO>> GetCasesByStatusAsync(string status, int pageNumber = 1, int pageSize = 50);
        Task<long> CreateCaseAsync(CreateCaseRequest request);
        Task<bool> UpdateCaseStatusAsync(long caseId, UpdateCaseStatusRequest request);
        Task<bool> AssignCaseAsync(AssignCaseRequest request);
        Task<CaseStatisticsDTO> GetCaseStatisticsAsync(long? userId = null);
        Task<List<CaseSummaryDTO>> GetOverduePTPCasesAsync();
    }
}
