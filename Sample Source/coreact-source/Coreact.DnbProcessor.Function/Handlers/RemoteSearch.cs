
using AutofacOnFunctions.Services.Ioc;
using Coreact.DnbProcesser.Function;
using Coreact.DnbProcessor.Function.Helpers;
using Coreact.Entities;
using Coreact.Infrastructure.Base.Repository;
using Coreact.Infrastructure.Base.Services;
using CoreHelpers.WindowsAzure.Storage.Table;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.ServiceBus;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Table;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;

namespace Coreact.CoreProcessor.Function.Handlers
{
  public static class RemoteSearchHandler
  {
    [FunctionName("GetRemoteSearch")]
    public static async Task<IActionResult> RunGetRemoteSearch(
                [HttpTrigger(FunctionStartup.DEFAULT_AUTHORIZATIONLEVEL, "get", Route = "remotesearch/{keyword?}")]HttpRequest req,
                string keyword,
                [Inject]IFunctionRepository functionRepository,
                [Inject]IKeyVaultHelper keyVaultHelper
            )
    {
      if (!await functionRepository.BearerTokenValidator.ValidateRequest(req))
        return new UnauthorizedResult();

      try
      {
        var countryCode = req.Query.First(x => x.Key.Equals("countryCode")).Value.ToString();
        var activeOnly = bool.Parse(req.Query.First(x => x.Key.Equals("activeOnly")).Value.ToString());

        var results = await DnbHelper.GetDunsCorporateIdentity(functionRepository.FunctionCache,keyVaultHelper, keyword,countryCode, activeOnly);

        return new OkObjectResult(results);
      }
      catch (Exception ex)
      {
        functionRepository.Logger.LogError(ex, $"Error occured querying Duns using keywords {keyword}");

        return new StatusCodeResult(500);
      }
    }
  }
}
