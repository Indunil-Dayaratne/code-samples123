using AutofacOnFunctions.Services.Ioc;
using Coreact.CoreProcesser.Function;
using Coreact.CoreProcesser.Function.Repository;
using Coreact.CoreProcesser.Function.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.ServiceBus;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace Coreact.CoreProcessor.Function.Handlers
{
  public static class PreProcesser
  {
    [FunctionName("Initiate")]
    public static async Task<IActionResult> CreateInitiate(
                [HttpTrigger(FunctionStartup.DEFAULT_AUTHORIZATIONLEVEL, "get", Route = "initiate/{type}")]HttpRequest req,
                string type,
                [Inject]IFunctionRepository functionRepository,
                [Inject]IKeyVaultHelper keyVaultHelper
            )
    {
      if (!await functionRepository.BearerTokenValidator.ValidateRequest(req))
        return new UnauthorizedResult();

      try
      {

        // get ServiceBus Connection String (MSI protected)
        var queueConnectionString = await keyVaultHelper.GetKeyVaultValue(Environment.GetEnvironmentVariable("COREACT_SERVICEBUS_CP_QUEUE_CONNECTIONSTRING_KV"));

        var queueClient = new QueueClient(new ServiceBusConnectionStringBuilder(queueConnectionString));

        var coreactInitiateId = Guid.NewGuid();

        var body = "{\"InitiateId\": \"" + coreactInitiateId + "\", \"type\":\"" + type + "\"}";

        var message = new Message(Encoding.UTF8.GetBytes(body));

        await queueClient.SendAsync(message);

        return new OkObjectResult(coreactInitiateId);
      }
      catch(Exception ex)
      {
          functionRepository.Logger.LogError(ex, $"Error occured initiating coreact task of type {type}");

          return new StatusCodeResult(500);
       }
    }
  }
}
