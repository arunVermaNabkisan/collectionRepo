using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CollectionManagementAPI.DTOs;
using CollectionManagementAPI.Repositories;
using CollectionManagementSystem.Models;

namespace CollectionManagementAPI.Services
{
    public class CaseService : ICaseService
    {
        private readonly ICaseRepository _caseRepository;

        public CaseService(ICaseRepository caseRepository)
        {
            _caseRepository = caseRepository;
        }

        public async Task<CaseDetailDTO> GetCaseByIdAsync(long caseId)
        {
            var caseEntity = await _caseRepository.GetCaseDetailsByIdAsync(caseId);
            if (caseEntity == null)
                return null;

            return MapToCaseDetailDTO(caseEntity);
        }

        public async Task<List<CaseSummaryDTO>> GetAgentWorklistAsync(long userId, DateTime? date = null)
        {
            var cases = await _caseRepository.GetAgentWorklistAsync(userId, date);
            return cases.Select(MapToCaseSummaryDTO).ToList();
        }

        public async Task<List<CaseSummaryDTO>> GetCasesByStatusAsync(string status, int pageNumber = 1, int pageSize = 50)
        {
            var cases = await _caseRepository.GetCasesByStatusAsync(status);
            return cases.Select(MapToCaseSummaryDTO).ToList();
        }

        public async Task<long> CreateCaseAsync(CreateCaseRequest request)
        {
            var caseEntity = new CollectionCase
            {
                CaseNumber = GenerateCaseNumber(),
                CustomerID = request.CustomerID,
                LoanAccountID = request.LoanAccountID,
                CurrentDPD = request.CurrentDPD,
                DPDBucket = request.DPDBucket,
                CurrentOutstandingAmount = request.CurrentOutstandingAmount,
                OverdueAmount = request.OverdueAmount,
                CaseStatus = "Active",
                CaseSubStatus = "Pending Contact",
                CasePriority = DeterminePriority(request.CurrentDPD, request.OverdueAmount),
                PriorityScore = CalculatePriorityScore(request.CurrentDPD, request.OverdueAmount),
                AssignedToUserID = request.AssignedToUserID,
                AssignedToTeamID = request.AssignedToTeamID,
                AssignedDate = request.AssignedToUserID.HasValue ? DateTime.Now : (DateTime?)null,
                CreatedDate = DateTime.Now,
                CreatedBy = request.CreatedBy,
                IsActive = true
            };

            return await _caseRepository.AddAsync(caseEntity);
        }

        public async Task<bool> UpdateCaseStatusAsync(long caseId, UpdateCaseStatusRequest request)
        {
            return await _caseRepository.UpdateCaseStatusAsync(
                caseId,
                request.NewStatus,
                request.SubStatus,
                request.ModifiedBy
            );
        }

        public async Task<bool> AssignCaseAsync(AssignCaseRequest request)
        {
            return await _caseRepository.AssignCaseToUserAsync(
                request.CaseID,
                request.AssignToUserID,
                request.AssignedBy
            );
        }

        public async Task<CaseStatisticsDTO> GetCaseStatisticsAsync(long? userId = null)
        {
            var casesByStatus = await _caseRepository.GetCaseCountByStatusAsync(userId);
            var outstandingByBucket = await _caseRepository.GetOutstandingByDPDBucketAsync(userId);

            return new CaseStatisticsDTO
            {
                TotalCases = casesByStatus.Values.Sum(),
                ActiveCases = casesByStatus.ContainsKey("Active") ? casesByStatus["Active"] : 0,
                ResolvedCases = casesByStatus.ContainsKey("Resolved") ? casesByStatus["Resolved"] : 0,
                ClosedCases = casesByStatus.ContainsKey("Closed") ? casesByStatus["Closed"] : 0,
                TotalOutstanding = outstandingByBucket.Values.Sum(),
                TotalOverdue = outstandingByBucket.Values.Sum(),
                CasesByStatus = casesByStatus,
                OutstandingByBucket = outstandingByBucket
            };
        }

        public async Task<List<CaseSummaryDTO>> GetOverduePTPCasesAsync()
        {
            var cases = await _caseRepository.GetOverduePTPCasesAsync();
            return cases.Select(MapToCaseSummaryDTO).ToList();
        }

        // Helper methods
        private CaseDetailDTO MapToCaseDetailDTO(CollectionCase caseEntity)
        {
            return new CaseDetailDTO
            {
                CaseID = caseEntity.CaseID,
                CaseNumber = caseEntity.CaseNumber,
                CaseStatus = caseEntity.CaseStatus,
                CaseSubStatus = caseEntity.CaseSubStatus,
                CurrentDPD = caseEntity.CurrentDPD,
                DPDBucket = caseEntity.DPDBucket,
                CurrentOutstandingAmount = caseEntity.CurrentOutstandingAmount,
                OverdueAmount = caseEntity.OverdueAmount,
                CasePriority = caseEntity.CasePriority,
                PriorityScore = caseEntity.PriorityScore,

                CustomerID = caseEntity.CustomerID,
                CustomerCode = caseEntity.Customer?.CustomerCode,
                CustomerName = caseEntity.Customer?.FullName,
                PrimaryMobileNumber = caseEntity.Customer?.PrimaryMobileNumber,
                PrimaryEmail = caseEntity.Customer?.PrimaryEmail,

                LoanAccountID = caseEntity.LoanAccountID,
                LoanAccountNumber = caseEntity.LoanAccount?.LoanAccountNumber,
                ProductType = caseEntity.LoanAccount?.ProductType,
                TotalOutstanding = caseEntity.LoanAccount?.TotalOutstanding ?? 0,

                AssignedToUserID = caseEntity.AssignedToUserID,
                AssignedToUserName = caseEntity.AssignedUser?.FullName,
                AssignedToTeamID = caseEntity.AssignedToTeamID,
                AssignedDate = caseEntity.AssignedDate,

                TotalContactAttempts = caseEntity.TotalContactAttempts,
                SuccessfulContactCount = caseEntity.SuccessfulContactCount,
                LastContactAttemptDate = caseEntity.LastContactAttemptDate,
                TotalAmountCollected = caseEntity.TotalAmountCollected,
                LastCollectionDate = caseEntity.LastCollectionDate,

                ActivePTPCount = caseEntity.ActivePTPCount,
                TotalPTPsMade = caseEntity.TotalPTPsMade,
                PTPsKept = caseEntity.PTPsKept,
                PTPsBroken = caseEntity.PTPsBroken,
                PTPSuccessRate = caseEntity.PTPSuccessRate
            };
        }

        private CaseSummaryDTO MapToCaseSummaryDTO(CollectionCase caseEntity)
        {
            return new CaseSummaryDTO
            {
                CaseID = caseEntity.CaseID,
                CaseNumber = caseEntity.CaseNumber,
                CustomerName = caseEntity.Customer?.FullName ?? "N/A",
                LoanAccountNumber = caseEntity.LoanAccount?.LoanAccountNumber ?? "N/A",
                CurrentDPD = caseEntity.CurrentDPD,
                DPDBucket = caseEntity.DPDBucket,
                OverdueAmount = caseEntity.OverdueAmount,
                CaseStatus = caseEntity.CaseStatus,
                AssignedToUserName = caseEntity.AssignedUser?.FullName ?? "Unassigned",
                LastContactDate = caseEntity.LastContactAttemptDate,
                PriorityScore = caseEntity.PriorityScore
            };
        }

        private string GenerateCaseNumber()
        {
            return $"CASE{DateTime.Now:yyyyMMdd}{Guid.NewGuid().ToString("N").Substring(0, 8).ToUpper()}";
        }

        private string DeterminePriority(int dpd, decimal overdueAmount)
        {
            if (dpd >= 90 || overdueAmount >= 500000)
                return "Critical";
            if (dpd >= 30 || overdueAmount >= 100000)
                return "High";
            if (dpd >= 10)
                return "Medium";
            return "Low";
        }

        private int CalculatePriorityScore(int dpd, decimal overdueAmount)
        {
            int dpdScore = dpd * 2;
            int amountScore = (int)(overdueAmount / 10000);
            return Math.Min(dpdScore + amountScore, 100);
        }
    }
}
