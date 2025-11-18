using System;
using System.Collections.Generic;

namespace CollectionManagementAPI.DTOs
{
    /// <summary>
    /// Generic API response wrapper
    /// </summary>
    /// <typeparam name="T">Type of data being returned</typeparam>
    public class ApiResponse<T>
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public T Data { get; set; }
        public List<string> Errors { get; set; }
        public DateTime Timestamp { get; set; } = DateTime.UtcNow;

        public static ApiResponse<T> SuccessResponse(T data, string message = "Success")
        {
            return new ApiResponse<T>
            {
                Success = true,
                Message = message,
                Data = data,
                Errors = null
            };
        }

        public static ApiResponse<T> ErrorResponse(string message, List<string> errors = null)
        {
            return new ApiResponse<T>
            {
                Success = false,
                Message = message,
                Data = default,
                Errors = errors ?? new List<string> { message }
            };
        }
    }

    /// <summary>
    /// Paginated response wrapper
    /// </summary>
    /// <typeparam name="T">Type of items in the list</typeparam>
    public class PagedResponse<T>
    {
        public List<T> Items { get; set; }
        public int PageNumber { get; set; }
        public int PageSize { get; set; }
        public int TotalCount { get; set; }
        public int TotalPages => (int)Math.Ceiling((double)TotalCount / PageSize);
        public bool HasPreviousPage => PageNumber > 1;
        public bool HasNextPage => PageNumber < TotalPages;
    }

    /// <summary>
    /// Pagination request parameters
    /// </summary>
    public class PaginationParams
    {
        private int _pageSize = 10;
        private const int MaxPageSize = 100;

        public int PageNumber { get; set; } = 1;

        public int PageSize
        {
            get => _pageSize;
            set => _pageSize = value > MaxPageSize ? MaxPageSize : value;
        }
    }

    /// <summary>
    /// Date range filter
    /// </summary>
    public class DateRangeFilter
    {
        public DateTime? FromDate { get; set; }
        public DateTime? ToDate { get; set; }
    }

    /// <summary>
    /// Dashboard metrics DTO
    /// </summary>
    public class DashboardMetricsDTO
    {
        public CaseMetrics CaseMetrics { get; set; }
        public CollectionMetrics CollectionMetrics { get; set; }
        public PTPMetrics PTPMetrics { get; set; }
        public ActivityMetrics ActivityMetrics { get; set; }
    }

    public class CaseMetrics
    {
        public int TotalCases { get; set; }
        public int ActiveCases { get; set; }
        public int CasesResolved Today { get; set; }
        public Dictionary<string, int> CasesByBucket { get; set; }
        public Dictionary<string, int> CasesByStatus { get; set; }
    }

    public class CollectionMetrics
    {
        public decimal TodayCollection { get; set; }
        public decimal MTDCollection { get; set; }
        public decimal YTDCollection { get; set; }
        public decimal TargetAchievement { get; set; }
        public int PaymentsToday { get; set; }
    }

    public class PTPMetrics
    {
        public int ActivePTPs { get; set; }
        public int PTPsDueToday { get; set; }
        public int OverduePTPs { get; set; }
        public decimal PTPSuccessRate { get; set; }
        public decimal ExpectedCollectionToday { get; set; }
    }

    public class ActivityMetrics
    {
        public int CallsMade { get; set; }
        public int SuccessfulCalls { get; set; }
        public int FieldVisitsCompleted { get; set; }
        public int EmailsSent { get; set; }
        public int SMSSent { get; set; }
    }

    /// <summary>
    /// Login request DTO
    /// </summary>
    public class LoginRequest
    {
        public string Username { get; set; }
        public string Password { get; set; }
    }

    /// <summary>
    /// Login response DTO
    /// </summary>
    public class LoginResponse
    {
        public long UserID { get; set; }
        public string Username { get; set; }
        public string FullName { get; set; }
        public string Email { get; set; }
        public string Role { get; set; }
        public string Token { get; set; }
        public DateTime TokenExpiry { get; set; }
    }
}
