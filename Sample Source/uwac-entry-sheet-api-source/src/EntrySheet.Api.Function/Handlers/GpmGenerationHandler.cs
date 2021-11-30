using System;
using System.IO;
using System.Threading.Tasks;
using System.Web.Http;
using AzureFunctions.Extensions.Swashbuckle.Attribute;
using EntrySheet.Api.Function.Helpers;
using EntrySheet.Api.Function.Hydration;
using EntrySheet.Api.Function.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.Extensions;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace EntrySheet.Api.Function.Handlers
{
    public class GpmGenerationHandler
    {
        private readonly ILogger<GpmGenerationHandler> _logger;
        private readonly IHttpRequestHelper _httpRequestHelper;
        private readonly IPlacingHydrator _placingHydrator;

        public GpmGenerationHandler(ILogger<GpmGenerationHandler> logger, IPlacingHydrator placingHydrator, IHttpRequestHelper httpRequestHelper)
        {
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
            _placingHydrator = placingHydrator ?? throw new ArgumentNullException(nameof(placingHydrator));
            _httpRequestHelper = httpRequestHelper ?? throw new ArgumentNullException(nameof(httpRequestHelper));
        }

        /// <summary>
        /// Generate GPM details for a given entry sheet
        /// </summary>       
        /// <returns>GPM details.</returns>
        /// <response code="200">Request processed successfully.</response>
        /// <response code="400">Invalid parameters supplied. </response>         
        /// <response code="403">The request is not authenticated with AAD or does not have the BEAS authorisation.</response>         
        /// <response code="500">Internal service error.</response>
        [FunctionName("GenerateGpmDetails")]
        [ProducesResponseType(typeof(string), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        [ProducesResponseType(typeof(EntrySheetDetailsModel), StatusCodes.Status422UnprocessableEntity)]
        public async Task<IActionResult> GenerateGpmDetailsAsync([HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "GpmGeneration"),
            RequestBodyType(typeof(EntrySheetDetailsModel), "EntrySheetDetails")] HttpRequest req)
        {
            var (authenticated, _) = await _httpRequestHelper.AuthenticateRequestAsync(req);

            if (!authenticated)
            {
                return new UnauthorizedResult();
            }

            try
            {
                var requestBody = await new StreamReader(req?.Body).ReadToEndAsync();

                var entrySheetDetailsModel = JsonConvert.DeserializeObject<EntrySheetDetailsModel>(requestBody);
                if (entrySheetDetailsModel == null)
                {
                    return new BadRequestResult();
                }

                var placings = _placingHydrator.Execute(entrySheetDetailsModel, req.GetDisplayUrl());
                return new OkObjectResult(placings);

            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error generating the GPM details for due to exception.");
                return new ExceptionResult(ex, false);
            }
        }
    }
}