
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
using Newtonsoft.Json.Linq;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace Coreact.CoreProcessor.Function.Handlers
{
  public static class OwnershipProcessor
  {
    [FunctionName("GetOwnQuery")]
    public static async Task<IActionResult> ExecuteGetOwnQuery(
                [HttpTrigger(FunctionStartup.DEFAULT_AUTHORIZATIONLEVEL, "get", Route = "query/own/{dunsNumber}")]HttpRequest req,
                string dunsNumber,
                [Inject]IFunctionRepository functionRepository,
                [Inject]IKeyVaultHelper keyVaultHelper
            )
    {

      if (!await functionRepository.BearerTokenValidator.ValidateRequest(req))
        return new UnauthorizedResult();

      if (string.IsNullOrEmpty(dunsNumber))
        return new NotFoundObjectResult("Parameter dunsNumber is missing");

      try
      {
        var data = await DnbHelper.GetOwnership(functionRepository.FunctionCache, keyVaultHelper, dunsNumber);
        return new OkObjectResult(data);
      }
      catch (Exception ex)
      {
        functionRepository.Logger.LogError(ex, $"Error occured getting CI data using dunsNumber {dunsNumber}");

        return new StatusCodeResult(500);
      }

    }
    [FunctionName("GetOwn")]
    public static async Task<IActionResult> ExecuteGetOwn(
                [HttpTrigger(FunctionStartup.DEFAULT_AUTHORIZATIONLEVEL, "get", Route = "own/{dunsNumber}")]HttpRequest req,
                string dunsNumber,
                [Inject]IFunctionRepository functionRepository,
                [Inject]IKeyVaultHelper keyVaultHelper
            )
    {

      if (!await functionRepository.BearerTokenValidator.ValidateRequest(req))
        return new UnauthorizedResult();

      if (string.IsNullOrEmpty(dunsNumber))
        return new NotFoundObjectResult("Parameter dunsNumber is missing");

      try
      {
        var data = await DnbHelper.GetDataFromTable(keyVaultHelper, DnbHelper.GetAppPrefix() + "dnbpowntable", dunsNumber);
        return new OkObjectResult(data);
      }
      catch (Exception ex)
      {
        functionRepository.Logger.LogError(ex, $"Error occured getting CI data using dunsNumber {dunsNumber}");

        return new StatusCodeResult(500);
      }
    }

    [FunctionName("OwnershipProcessor")]
    public static async Task ExecuteOwnershipProcessor(
                [ServiceBusTrigger("dnbpown-message-out","dnbpown-sub-message-out",Connection ="COREACT_TOPIC_DNBPOWN_LISTEN_CONNECTIONSTRING")]
                string queueItem,
                Int32 deliveryCount,
                DateTime enqueuedTimeUtc,
                string messageId,
                [SignalR(HubName ="coreact")]IAsyncCollector<SignalRMessage> signalRMessages,
                [Inject]IFunctionRepository functionRepository,
                [Inject]IKeyVaultHelper keyVaultHelper
            )
    {

      var message = JsonConvert.DeserializeObject<CoreactMessage>(queueItem);
      try
      {
        if (!message.TargetProcessor.Contains("dnbpown"))
          throw new ServiceBusException(true, $"Message is for a different subscription {message}");
        var data = await DnbHelper.GetOwnership(functionRepository.FunctionCache, keyVaultHelper, message.Id);
        var entity = await DnbHelper.CreateProcessorEntityAndSaveBlob(keyVaultHelper,
        "coreactdnbblobstore", message, data);

        await DnbHelper.SaveDataToTable(keyVaultHelper, DnbHelper.GetAppPrefix() + "dnbpowntable", entity);

        await DnbHelper.CreateAndSendSignalRMessage(signalRMessages, message, "dnbpown", "complete");
      
      }
      catch(Exception ex)
      {
        functionRepository.Logger.LogError(ex, $"An exception has occured processing message {queueItem}");

        await DnbHelper.CreateAndSendSignalRMessage(signalRMessages, message, "dnbpown", "error");

        throw;
      }
    }
  }
}
