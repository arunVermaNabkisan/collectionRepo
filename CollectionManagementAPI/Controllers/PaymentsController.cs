using Microsoft.AspNetCore.Mvc;
using Dapper;
using Microsoft.Data.SqlClient;
using System.Data;

namespace CollectionManagementAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Produces("application/json")]
    public class PaymentsController : ControllerBase
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<PaymentsController> _logger;

        public PaymentsController(IConfiguration configuration, ILogger<PaymentsController> logger)
        {
            _configuration = configuration;
            _logger = logger;
        }

        private IDbConnection GetConnection()
        {
            return new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
        }

        /// <summary>
        /// Get all payment transactions
        /// </summary>
        [HttpGet]
        [ProducesResponseType(typeof(ApiResponse<List<PaymentDTO>>), 200)]
        public async Task<IActionResult> GetAllPayments()
        {
            try
            {
                using var connection = GetConnection();
                var query = @"
                    SELECT
                        PaymentTransactionID AS Id,
                        TransactionNumber AS TransactionId,
                        PaymentDate,
                        PaymentAmount AS Amount,
                        PaymentMode AS PaymentMethod,
                        PaymentStatus AS Status,
                        BorrowerName,
                        LoanAccountNumber AS AccountNumber,
                        ReceiptNumber
                    FROM vw_PaymentTransactionsList
                    ORDER BY PaymentDate DESC";

                var payments = await connection.QueryAsync<PaymentDTO>(query);
                return Ok(ApiResponse<List<PaymentDTO>>.SuccessResponse(payments.ToList()));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching payments");
                return StatusCode(500, ApiResponse<List<PaymentDTO>>.ErrorResponse("Internal server error"));
            }
        }

        /// <summary>
        /// Get payment by ID
        /// </summary>
        [HttpGet("{id}")]
        [ProducesResponseType(typeof(ApiResponse<PaymentDTO>), 200)]
        [ProducesResponseType(404)]
        public async Task<IActionResult> GetPaymentById(long id)
        {
            try
            {
                using var connection = GetConnection();
                var query = @"
                    SELECT
                        PaymentTransactionID AS Id,
                        TransactionNumber AS TransactionId,
                        PaymentDate,
                        PaymentAmount AS Amount,
                        PaymentMode AS PaymentMethod,
                        PaymentStatus AS Status,
                        BorrowerName,
                        LoanAccountNumber AS AccountNumber,
                        ReceiptNumber
                    FROM vw_PaymentTransactionsList
                    WHERE PaymentTransactionID = @Id";

                var payment = await connection.QueryFirstOrDefaultAsync<PaymentDTO>(query, new { Id = id });

                if (payment == null)
                    return NotFound(ApiResponse<PaymentDTO>.ErrorResponse("Payment not found"));

                return Ok(ApiResponse<PaymentDTO>.SuccessResponse(payment));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching payment by ID: {Id}", id);
                return StatusCode(500, ApiResponse<PaymentDTO>.ErrorResponse("Internal server error"));
            }
        }
    }

    public class PaymentDTO
    {
        public long Id { get; set; }
        public string TransactionId { get; set; } = string.Empty;
        public DateTime PaymentDate { get; set; }
        public decimal Amount { get; set; }
        public string PaymentMethod { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
        public string BorrowerName { get; set; } = string.Empty;
        public string AccountNumber { get; set; } = string.Empty;
        public string? ReceiptNumber { get; set; }
    }
}
