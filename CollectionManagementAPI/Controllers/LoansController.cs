using Microsoft.AspNetCore.Mvc;
using Dapper;
using Microsoft.Data.SqlClient;
using System.Data;

namespace CollectionManagementAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Produces("application/json")]
    public class LoansController : ControllerBase
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<LoansController> _logger;

        public LoansController(IConfiguration configuration, ILogger<LoansController> logger)
        {
            _configuration = configuration;
            _logger = logger;
        }

        private IDbConnection GetConnection()
        {
            return new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
        }

        /// <summary>
        /// Get all loan accounts
        /// </summary>
        [HttpGet]
        [ProducesResponseType(typeof(ApiResponse<List<LoanDTO>>), 200)]
        public async Task<IActionResult> GetAllLoans()
        {
            try
            {
                using var connection = GetConnection();
                var query = @"
                    SELECT
                        LoanAccountID AS Id,
                        LoanAccountNumber AS AccountNumber,
                        CustomerName AS BorrowerName,
                        ProductType,
                        DisbursedAmount,
                        TotalOutstanding AS OutstandingAmount,
                        CurrentDPD AS DPD,
                        LoanStatus AS Status,
                        NextEMIDueDate AS NextDueDate
                    FROM vw_LoanAccountsList
                    WHERE IsActive = 1
                    ORDER BY LoanAccountID";

                var loans = await connection.QueryAsync<LoanDTO>(query);
                return Ok(ApiResponse<List<LoanDTO>>.SuccessResponse(loans.ToList()));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching loans");
                return StatusCode(500, ApiResponse<List<LoanDTO>>.ErrorResponse("Internal server error"));
            }
        }

        /// <summary>
        /// Get loan by ID
        /// </summary>
        [HttpGet("{id}")]
        [ProducesResponseType(typeof(ApiResponse<LoanDTO>), 200)]
        [ProducesResponseType(404)]
        public async Task<IActionResult> GetLoanById(long id)
        {
            try
            {
                using var connection = GetConnection();
                var query = @"
                    SELECT
                        LoanAccountID AS Id,
                        LoanAccountNumber AS AccountNumber,
                        CustomerName AS BorrowerName,
                        ProductType,
                        DisbursedAmount,
                        TotalOutstanding AS OutstandingAmount,
                        CurrentDPD AS DPD,
                        LoanStatus AS Status,
                        NextEMIDueDate AS NextDueDate
                    FROM vw_LoanAccountsList
                    WHERE LoanAccountID = @Id";

                var loan = await connection.QueryFirstOrDefaultAsync<LoanDTO>(query, new { Id = id });

                if (loan == null)
                    return NotFound(ApiResponse<LoanDTO>.ErrorResponse("Loan not found"));

                return Ok(ApiResponse<LoanDTO>.SuccessResponse(loan));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching loan by ID: {Id}", id);
                return StatusCode(500, ApiResponse<LoanDTO>.ErrorResponse("Internal server error"));
            }
        }
    }

    public class LoanDTO
    {
        public long Id { get; set; }
        public string AccountNumber { get; set; } = string.Empty;
        public string BorrowerName { get; set; } = string.Empty;
        public string ProductType { get; set; } = string.Empty;
        public decimal DisbursedAmount { get; set; }
        public decimal OutstandingAmount { get; set; }
        public int DPD { get; set; }
        public string Status { get; set; } = string.Empty;
        public DateTime? NextDueDate { get; set; }
    }
}
