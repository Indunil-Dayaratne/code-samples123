using EntrySheet.Api.Function.Helpers;
using EntrySheet.Api.Function.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using System;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Http;


namespace EntrySheet.Api.Function.Handlers
{
    public class IndustryCodeHandler
    {
        private readonly ILogger<IndustryCodeHandler> _logger;
        private readonly IHttpRequestHelper _httpRequestHelper;
        private readonly IIndustryCodeService _industryCodeService;

        public IndustryCodeHandler(ILogger<IndustryCodeHandler> logger,
            IHttpRequestHelper httpRequestHelper,
            IIndustryCodeService industryCodeService)
        {
            _logger = logger;
            _httpRequestHelper = httpRequestHelper;
            _industryCodeService = industryCodeService;
        }

        /// <summary>
        /// Fetch Industry Code values
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
        [FunctionName("GetIndustryCodes")]
        public async Task<IActionResult> GetIndustryCodesAsync([HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "EntrySheet/industryCodes")] HttpRequest req)
        {
            var (authenticated, _) = await _httpRequestHelper.AuthenticateRequestAsync(req);

            if (!authenticated)
            {
                return new UnauthorizedResult();
            }
            try
            {
                var insdustryCodes = await _industryCodeService.GetIndustryCodesAsync();
                if (!insdustryCodes.Any())
                {
                    return new NoContentResult();
                }

                return new OkObjectResult(insdustryCodes);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting industry codes");
                return new ExceptionResult(ex, false);
            }
        }
    }
}
