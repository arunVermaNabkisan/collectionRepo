using Microsoft.AspNetCore.Mvc;
using Dapper;
using Microsoft.Data.SqlClient;
using System.Data;

namespace CollectionManagementAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Produces("application/json")]
    public class CustomersController : ControllerBase
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<CustomersController> _logger;

        public CustomersController(IConfiguration configuration, ILogger<CustomersController> logger)
        {
            _configuration = configuration;
            _logger = logger;
        }

        private IDbConnection GetConnection()
        {
            return new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
        }

        /// <summary>
        /// Get all borrowers
        /// </summary>
        [HttpGet]
        [ProducesResponseType(typeof(ApiResponse<List<BorrowerDTO>>), 200)]
        public async Task<IActionResult> GetAllBorrowers()
        {
            try
            {
                using var connection = GetConnection();
                var query = @"
                    SELECT
                        CustomerID AS Id,
                        FullName AS Name,
                        PrimaryEmail AS Email,
                        PrimaryMobileNumber AS Phone,
                        IsActive
                    FROM vw_BorrowerList
                    WHERE IsActive = 1
                    ORDER BY CustomerID";

                var borrowers = await connection.QueryAsync<BorrowerDTO>(query);
                return Ok(ApiResponse<List<BorrowerDTO>>.SuccessResponse(borrowers.ToList()));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching borrowers");
                return StatusCode(500, ApiResponse<List<BorrowerDTO>>.ErrorResponse("Internal server error"));
            }
        }

        /// <summary>
        /// Get borrower by ID
        /// </summary>
        [HttpGet("{id}")]
        [ProducesResponseType(typeof(ApiResponse<BorrowerDetailDTO>), 200)]
        [ProducesResponseType(404)]
        public async Task<IActionResult> GetBorrowerById(long id)
        {
            try
            {
                using var connection = GetConnection();
                var query = @"
                    SELECT
                        CustomerID AS Id,
                        CustomerCode,
                        FullName AS Name,
                        FirstName,
                        LastName,
                        PrimaryEmail AS Email,
                        PrimaryMobileNumber AS Phone,
                        CurrentCity AS City,
                        CurrentState AS State,
                        TotalLoans,
                        TotalOutstanding,
                        MaxDPD
                    FROM vw_BorrowerList
                    WHERE CustomerID = @Id";

                var borrower = await connection.QueryFirstOrDefaultAsync<BorrowerDetailDTO>(query, new { Id = id });

                if (borrower == null)
                    return NotFound(ApiResponse<BorrowerDetailDTO>.ErrorResponse("Borrower not found"));

                return Ok(ApiResponse<BorrowerDetailDTO>.SuccessResponse(borrower));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching borrower by ID: {Id}", id);
                return StatusCode(500, ApiResponse<BorrowerDetailDTO>.ErrorResponse("Internal server error"));
            }
        }
    }

    public class BorrowerDTO
    {
        public long Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Phone { get; set; } = string.Empty;
        public bool IsActive { get; set; }
    }

    public class BorrowerDetailDTO : BorrowerDTO
    {
        public string CustomerCode { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string City { get; set; } = string.Empty;
        public string State { get; set; } = string.Empty;
        public int TotalLoans { get; set; }
        public decimal TotalOutstanding { get; set; }
        public int MaxDPD { get; set; }
    }

    public class ApiResponse<T>
    {
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;
        public T? Data { get; set; }

        public static ApiResponse<T> SuccessResponse(T data, string message = "Success")
        {
            return new ApiResponse<T>
            {
                Success = true,
                Message = message,
                Data = data
            };
        }

        public static ApiResponse<T> ErrorResponse(string message)
        {
            return new ApiResponse<T>
            {
                Success = false,
                Message = message,
                Data = default
            };
        }
    }
}
