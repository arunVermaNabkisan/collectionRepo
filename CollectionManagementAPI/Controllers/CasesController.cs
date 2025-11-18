using Microsoft.AspNetCore.Mvc;
using CollectionManagementAPI.DTOs;
using CollectionManagementAPI.Services;
using System;
using System.Threading.Tasks;

namespace CollectionManagementAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Produces("application/json")]
    public class CasesController : ControllerBase
    {
        private readonly ICaseService _caseService;
        private readonly ILogger<CasesController> _logger;

        public CasesController(ICaseService caseService, ILogger<CasesController> logger)
        {
            _caseService = caseService;
            _logger = logger;
        }

        /// <summary>
        /// Get case details by ID
        /// </summary>
        [HttpGet("{id}")]
        [ProducesResponseType(typeof(ApiResponse<CaseDetailDTO>), 200)]
        [ProducesResponseType(404)]
        public async Task<IActionResult> GetCaseById(long id)
        {
            try
            {
                var caseDetail = await _caseService.GetCaseByIdAsync(id);
                if (caseDetail == null)
                    return NotFound(ApiResponse<CaseDetailDTO>.ErrorResponse("Case not found"));

                return Ok(ApiResponse<CaseDetailDTO>.SuccessResponse(caseDetail));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting case by ID: {CaseId}", id);
                return StatusCode(500, ApiResponse<CaseDetailDTO>.ErrorResponse("Internal server error"));
            }
        }

        /// <summary>
        /// Get agent worklist for a specific user
        /// </summary>
        [HttpGet("worklist/{userId}")]
        [ProducesResponseType(typeof(ApiResponse<List<CaseSummaryDTO>>), 200)]
        public async Task<IActionResult> GetAgentWorklist(long userId, [FromQuery] DateTime? date = null)
        {
            try
            {
                var worklist = await _caseService.GetAgentWorklistAsync(userId, date);
                return Ok(ApiResponse<List<CaseSummaryDTO>>.SuccessResponse(worklist));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting worklist for user: {UserId}", userId);
                return StatusCode(500, ApiResponse<List<CaseSummaryDTO>>.ErrorResponse("Internal server error"));
            }
        }

        /// <summary>
        /// Get cases by status
        /// </summary>
        [HttpGet("status/{status}")]
        [ProducesResponseType(typeof(ApiResponse<List<CaseSummaryDTO>>), 200)]
        public async Task<IActionResult> GetCasesByStatus(string status, [FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 50)
        {
            try
            {
                var cases = await _caseService.GetCasesByStatusAsync(status, pageNumber, pageSize);
                return Ok(ApiResponse<List<CaseSummaryDTO>>.SuccessResponse(cases));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting cases by status: {Status}", status);
                return StatusCode(500, ApiResponse<List<CaseSummaryDTO>>.ErrorResponse("Internal server error"));
            }
        }

        /// <summary>
        /// Create a new collection case
        /// </summary>
        [HttpPost]
        [ProducesResponseType(typeof(ApiResponse<long>), 201)]
        [ProducesResponseType(400)]
        public async Task<IActionResult> CreateCase([FromBody] CreateCaseRequest request)
        {
            try
            {
                if (!ModelState.IsValid)
                    return BadRequest(ApiResponse<long>.ErrorResponse("Invalid request data"));

                var caseId = await _caseService.CreateCaseAsync(request);
                return CreatedAtAction(nameof(GetCaseById), new { id = caseId },
                    ApiResponse<long>.SuccessResponse(caseId, "Case created successfully"));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating case");
                return StatusCode(500, ApiResponse<long>.ErrorResponse("Internal server error"));
            }
        }

        /// <summary>
        /// Update case status
        /// </summary>
        [HttpPut("{id}/status")]
        [ProducesResponseType(typeof(ApiResponse<bool>), 200)]
        [ProducesResponseType(400)]
        [ProducesResponseType(404)]
        public async Task<IActionResult> UpdateCaseStatus(long id, [FromBody] UpdateCaseStatusRequest request)
        {
            try
            {
                if (!ModelState.IsValid)
                    return BadRequest(ApiResponse<bool>.ErrorResponse("Invalid request data"));

                var result = await _caseService.UpdateCaseStatusAsync(id, request);
                if (!result)
                    return NotFound(ApiResponse<bool>.ErrorResponse("Case not found or update failed"));

                return Ok(ApiResponse<bool>.SuccessResponse(true, "Case status updated successfully"));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating case status: {CaseId}", id);
                return StatusCode(500, ApiResponse<bool>.ErrorResponse("Internal server error"));
            }
        }

        /// <summary>
        /// Assign case to user
        /// </summary>
        [HttpPost("assign")]
        [ProducesResponseType(typeof(ApiResponse<bool>), 200)]
        [ProducesResponseType(400)]
        public async Task<IActionResult> AssignCase([FromBody] AssignCaseRequest request)
        {
            try
            {
                if (!ModelState.IsValid)
                    return BadRequest(ApiResponse<bool>.ErrorResponse("Invalid request data"));

                var result = await _caseService.AssignCaseAsync(request);
                if (!result)
                    return BadRequest(ApiResponse<bool>.ErrorResponse("Assignment failed"));

                return Ok(ApiResponse<bool>.SuccessResponse(true, "Case assigned successfully"));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error assigning case");
                return StatusCode(500, ApiResponse<bool>.ErrorResponse("Internal server error"));
            }
        }

        /// <summary>
        /// Get case statistics
        /// </summary>
        [HttpGet("statistics")]
        [ProducesResponseType(typeof(ApiResponse<CaseStatisticsDTO>), 200)]
        public async Task<IActionResult> GetStatistics([FromQuery] long? userId = null)
        {
            try
            {
                var statistics = await _caseService.GetCaseStatisticsAsync(userId);
                return Ok(ApiResponse<CaseStatisticsDTO>.SuccessResponse(statistics));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting case statistics");
                return StatusCode(500, ApiResponse<CaseStatisticsDTO>.ErrorResponse("Internal server error"));
            }
        }

        /// <summary>
        /// Get cases with overdue PTPs
        /// </summary>
        [HttpGet("overdue-ptp")]
        [ProducesResponseType(typeof(ApiResponse<List<CaseSummaryDTO>>), 200)]
        public async Task<IActionResult> GetOverduePTPCases()
        {
            try
            {
                var cases = await _caseService.GetOverduePTPCasesAsync();
                return Ok(ApiResponse<List<CaseSummaryDTO>>.SuccessResponse(cases));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting overdue PTP cases");
                return StatusCode(500, ApiResponse<List<CaseSummaryDTO>>.ErrorResponse("Internal server error"));
            }
        }
    }
}
