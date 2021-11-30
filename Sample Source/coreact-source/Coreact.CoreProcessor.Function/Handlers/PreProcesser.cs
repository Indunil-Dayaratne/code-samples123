
using AutofacOnFunctions.Services.Ioc;
using Coreact.CoreProcesser.Function;
using Coreact.Entities;
using Coreact.Infrastructure.Base.Helper;
using Coreact.Infrastructure.Base.Repository;
using Coreact.Infrastructure.Base.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.ServiceBus;
using Microsoft.Azure.ServiceBus.Primitives;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using System.Web;

namespace Coreact.CoreProcessor.Function.Handlers
{
  public static class PreProcesser
  {

    [FunctionName("UpdateProcess")]
    public static async Task<IActionResult> UpdateProcess(
               [HttpTrigger(FunctionStartup.DEFAULT_AUTHORIZATIONLEVEL, "put", Route = "process/{type}/{id}")]HttpRequest req,
               string type,
               string id,
               [Inject]IFunctionRepository functionRepository,
               [Inject]IKeyVaultHelper keyVaultHelper
           )
    {
      if (!await functionRepository.BearerTokenValidator.ValidateRequest(req))
        return new UnauthorizedResult();

      try
      {
        var queueClient = await ServiceBusHelper.CreateSBClientFromKeyVaultValue<QueueClient>(
          keyVaultHelper,
          "proc-message-in",
          "sendpolicy");

        var coreactMessage = new CoreactMessage { Type = type, ProcessId = Guid.NewGuid().ToString(), Id = id, CreatedOn = DateTime.Now };

        await queueClient.SendAsync(ServiceBusHelper.CreateMessageFromObject(coreactMessage));

        return new OkObjectResult(coreactMessage.ProcessId);
      }
      catch (Exception ex)
      {
        functionRepository.Logger.LogError(ex, $"Error occured initiating coreact task of id {id}");

        return new StatusCodeResult(500);
      }
    }

    [FunctionName("CreateProcess")]
    public static async Task<IActionResult> CreateProcess(
                [HttpTrigger(FunctionStartup.DEFAULT_AUTHORIZATIONLEVEL, "post", Route = "process/{type}/{id}")]HttpRequest req,
                string type,
                string id,
                [Inject]IFunctionRepository functionRepository,
                [Inject]IKeyVaultHelper keyVaultHelper
            )
    {
      if (!await functionRepository.BearerTokenValidator.ValidateRequest(req))
        return new UnauthorizedResult();

      var coreactMessage = new CoreactMessage { ProcessId = Guid.NewGuid().ToString(), CreatedOn = DateTime.Now, Type = type, Id = id};

      try
      {
        var queueClient = await ServiceBusHelper.CreateSBClientFromKeyVaultValue<QueueClient>(
          keyVaultHelper,
          "proc-message-in",
          "sendpolicy");

        // deserialize message
        var requestBody = await new StreamReader(req.Body).ReadToEndAsync();

        await queueClient.SendAsync(ServiceBusHelper.CreateMessageFromObject(coreactMessage));

        return new OkObjectResult(coreactMessage.ProcessId);
      }
      catch (Exception ex)
      {
        functionRepository.Logger.LogError(ex, $"Error occured initiating coreact task of type {coreactMessage.Type}");

        return new StatusCodeResult(500);
      }
    }
  }
}
