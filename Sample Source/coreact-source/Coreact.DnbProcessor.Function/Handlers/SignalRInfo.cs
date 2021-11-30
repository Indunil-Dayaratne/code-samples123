
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
using Microsoft.Azure.WebJobs.Extensions.SignalRService;
using Microsoft.Extensions.Logging;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Table;
using Newtonsoft.Json;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace Coreact.CoreProcessor.Function.Handlers
{
  public static class SignalRInfo
  {
    [FunctionName("GetSignalRInfo")]
    public static IActionResult ExecuteGetSignalRInfo(
                [HttpTrigger(FunctionStartup.DEFAULT_AUTHORIZATIONLEVEL, "post", Route = "negotiate")]HttpRequest req,
               [SignalRConnectionInfo(HubName = "coreact")]SignalRConnectionInfo connectionInfo
            )
    {
      return new OkObjectResult(connectionInfo);
    }


  }
}
