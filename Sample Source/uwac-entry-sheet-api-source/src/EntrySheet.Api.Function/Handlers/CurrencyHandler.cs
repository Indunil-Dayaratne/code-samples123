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
using EntrySheet.Api.Function.Helpers;

namespace EntrySheet.Api.Function.Handlers
{
    public class CurrencyHandler
    {
        private readonly ILogger<CurrencyHandler> _logger;
        private readonly IHttpRequestHelper _httpRequestHelper;
        private readonly ICurrencyService _currencyService;

        public CurrencyHandler(ILogger<CurrencyHandler> logger,
            IHttpRequestHelper httpRequestHelper,
            ICurrencyService currencyService)
        {
            this._logger = logger;
            this._httpRequestHelper = httpRequestHelper;
            this._currencyService = currencyService;
        }

        /// <summary>
        /// Fetch currency values
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
        [FunctionName("GetCurrencies")]
        public async Task<IActionResult> GetCurrenciesAsync([HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "EntrySheet/currencies")] HttpRequest req)
        {
            var (authenticated, _) = await _httpRequestHelper.AuthenticateRequestAsync(req);

            if (!authenticated)
            {
                return new UnauthorizedResult();
            }
            try
            {
                var currencyList = await _currencyService.GetCurrencyAsync();
                if (!currencyList.Any())
                {
                    return new NoContentResult();
                }

                return new OkObjectResult(currencyList);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting e-Placing");
                return new ExceptionResult(ex, false);
            }
        }
    }
}
