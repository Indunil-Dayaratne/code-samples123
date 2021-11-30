using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using System;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Http;
using EntrySheet.Api.Function.Helpers;
using EntrySheet.Api.Function.Services;

namespace EntrySheet.Api.Function.Handlers
{
    public class EPlacingHandler
    {
        private readonly ILogger<EPlacingHandler> _logger;
        private readonly IHttpRequestHelper _httpRequestHelper;
        private readonly IEPlacingService _ePlacingService;

        public EPlacingHandler(ILogger<EPlacingHandler> logger,
            IHttpRequestHelper httpRequestHelper,
            IEPlacingService ePlacingService)
        {
            _logger = logger;
            _httpRequestHelper = httpRequestHelper;
            _ePlacingService = ePlacingService;
        }

        /// <summary>
        /// Fetch E Placing values 
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
        [FunctionName("GetEPlacing")]
        public async Task<IActionResult> GetEPlacingAsync([HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "EntrySheet/ePlacing")] HttpRequest req)
        {
            var (authenticated, _) = await _httpRequestHelper.AuthenticateRequestAsync(req);

            if (!authenticated)
            {
                return new UnauthorizedResult();
            }
            try
            {
                var eplacings = await _ePlacingService.GetEPlacingValuesAsync();
                if (!eplacings.Any())
                {
                    return new NoContentResult();
                }

                return new OkObjectResult(eplacings);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting e-Placing");
                return new ExceptionResult(ex, false);
            }
        }
    }
}
