using System;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Http;
using EntrySheet.Api.Function.Helpers;
using EntrySheet.Api.Function.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;

namespace EntrySheet.Api.Function.Handlers
{
    public class RiskRatingHandler
    {
        private readonly ILogger<RiskRatingHandler> _logger;
        private readonly IHttpRequestHelper _httpRequestHelper;
        private readonly IRiskRatingService _riskRatingService;

        public RiskRatingHandler(ILogger<RiskRatingHandler> logger, IHttpRequestHelper httpRequestHelper, IRiskRatingService riskRatingService)
        {
            _logger = logger;
            _httpRequestHelper = httpRequestHelper;
            _riskRatingService = riskRatingService;
        }

        /// <summary>
        /// Fetch Risk Rating values
        /// </summary>  
        /// <response code="200">Request processed successfully.</response>
        /// <response code="400">Invalid parameters supplied. </response>         
        /// <response code="403">The request is not authenticated with AAD or does not have the BEAS authorisation.</response>         
        /// <response code="500">Internal service error.</response>
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        [FunctionName("GetRiskRatings")]
        public async Task<IActionResult> GetRiskRatingsAsync([HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "EntrySheet/riskratings")] HttpRequest req)
        {
            var (authenticated, _) = await _httpRequestHelper.AuthenticateRequestAsync(req);

            if (!authenticated)
            {
                return new UnauthorizedResult();
            }
            try
            {
                var riskRatings = _riskRatingService.GetRiskRatings();
                if (!riskRatings.Any())
                {
                    return new NoContentResult();
                }

                return new OkObjectResult(riskRatings);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting risk ratings");
                return new ExceptionResult(ex, false);
            }
        }
    }
}