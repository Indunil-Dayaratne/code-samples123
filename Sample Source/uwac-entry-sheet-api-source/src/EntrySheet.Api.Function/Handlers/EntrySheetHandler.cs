using AzureFunctions.Extensions.Swashbuckle.Attribute;
using EntrySheet.Api.Function.Models;
using EntrySheet.Api.Function.Services;
using EntrySheet.Api.Function.Helpers;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.Extensions;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System;
using System.IO;
using System.Threading.Tasks;
using System.Web.Http;
using EntrySheet.Api.Function.Repositories;

namespace EntrySheet.Api.Function.Handlers
{
    public class EntrySheetHandler
    {
        private readonly ILogger<EntrySheetHandler> _logger;
        private readonly IHttpRequestHelper _httpRequestHelper;
        private readonly IEntrySheetService _entrySheetService;
        private readonly IEntrySheetDetailsRepository _entrySheetDetailsRepository;

        public EntrySheetHandler(ILogger<EntrySheetHandler> logger,
            IHttpRequestHelper httpRequestHelper,
            IEntrySheetService entrySheetService, 
            IEntrySheetDetailsRepository entrySheetDetailsRepository)
        {
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
            _httpRequestHelper = httpRequestHelper ?? throw new ArgumentNullException(nameof(httpRequestHelper));
            _entrySheetService = entrySheetService ?? throw new ArgumentNullException(nameof(entrySheetService));
            _entrySheetDetailsRepository = entrySheetDetailsRepository ?? throw new ArgumentNullException(nameof(entrySheetDetailsRepository));
        }

        /// <summary>
        /// Fetch Entry Sheet details for a given BritPolicyId
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
        [FunctionName("GetEntrySheetDetails")]
        public async Task<IActionResult> GetEntrySheetDetailsAsync(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route =
                "EntrySheet/Policy/{britPolicyId}")]
            HttpRequest req, int britPolicyId)
        {
            try
            {
                var (authenticated, _) = await _httpRequestHelper.AuthenticateRequestAsync(req);

                if (!authenticated)
                {
                    return new UnauthorizedResult();
                }

                var entrySheetDetailsModel = await _entrySheetService.GetEntrySheetDetailsAsync(britPolicyId);

                if (entrySheetDetailsModel == null)
                {
                    return new NoContentResult();
                }

                return new OkObjectResult(entrySheetDetailsModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting entry sheet details for due to exception - {Message}", ex.Message);
                return new ExceptionResult(ex, false);
            }
        }

        /// <summary>
        /// Query Entry Sheets by BritPolicyIds
        /// </summary>       
        /// <returns>Risk data.</returns>
        /// <response code="200">Request processed successfully.</response>
        /// <response code="400">Invalid parameters supplied. </response>         
        /// <response code="403">The request is not authenticated with AAD or does not have the BEAS authorisation.</response>         
        /// <response code="500">Internal service error.</response>
        [FunctionName("GetEntrySheets")]
        [ProducesResponseType(typeof(string), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> GetEntrySheetsAsync(
            [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "EntrySheet/Policies")]
            HttpRequest req)
        {
            var (authenticated, _) = await _httpRequestHelper.AuthenticateRequestAsync(req);

            if (!authenticated)
            {
                return new UnauthorizedResult();
            }

            try
            {
                var requestBody = await new StreamReader(req?.Body).ReadToEndAsync();

                var britPolicyIds = JsonConvert.DeserializeObject<int[]>(requestBody);
                if (britPolicyIds == null || britPolicyIds.Length == 0)
                {
                    return new BadRequestResult();
                }

                var entrySheets = await _entrySheetDetailsRepository.GetLatestEntrySheetsAsync(britPolicyIds);
                return new OkObjectResult(entrySheets);

            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error querying entry sheets by BritPolicyIds for due to exception.");
                return new ExceptionResult(ex, false);
            }
        }

        /// <summary>
        /// Save Entry Sheet Details.
        /// </summary>       
        /// <returns>Risk data.</returns>
        /// <response code="200">Request processed successfully.</response>
        /// <response code="400">Invalid parameters supplied. </response>         
        /// <response code="403">The request is not authenticated with AAD or does not have the BEAS authorisation.</response>         
        /// <response code="500">Internal service error.</response>
        [FunctionName("SaveEntrySheetDetails")]
        [ProducesResponseType(typeof(string), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        [ProducesResponseType(typeof(EntrySheetDetailsModel), StatusCodes.Status422UnprocessableEntity)]
        public async Task<IActionResult> SaveEntrySheetDetailsAsync(
            [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "EntrySheet/Policy"),
             RequestBodyType(typeof(EntrySheetDetailsModel), "EntrySheetDetails")]
            HttpRequest req)
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
                if (entrySheetDetailsModel == null || entrySheetDetailsModel.BritPolicyId == 0
                                                   || string.IsNullOrEmpty(entrySheetDetailsModel.LastUpdatedBy))
                {
                    return new BadRequestResult();
                }

                var saveEntrySheetRequestModel = new SaveEntrySheetRequestModel
                    {EntrySheetDetails = entrySheetDetailsModel, SaveRequestApiUri = req.GetDisplayUrl()};
                var savedEntrySheetDetailsModel =
                    await _entrySheetService.SaveEntrySheetDetailsAsync(saveEntrySheetRequestModel);
                return new OkObjectResult(savedEntrySheetDetailsModel);

            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error saving entry sheet details for due to exception.");
                return new ExceptionResult(ex, false);
            }
        }
    }
}
