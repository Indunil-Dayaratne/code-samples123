
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
  public static class InfoProcessor
  {

    [FunctionName("GetCiQuery")]
    public static async Task<IActionResult> ExecuteGetCiQuery(
                [HttpTrigger(FunctionStartup.DEFAULT_AUTHORIZATIONLEVEL, "get", Route = "query/ci/{dunsNumber}")]HttpRequest req,
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
        var data = await DnbHelper.GetDetailedCompanyPrem(functionRepository.FunctionCache, keyVaultHelper, dunsNumber);
        return new OkObjectResult(data);

      }
      catch (Exception ex)
      {
        functionRepository.Logger.LogError(ex, $"Error occured getting CI data using dunsNumber {dunsNumber}");

        return new StatusCodeResult(500);
      }
    }


    [FunctionName("GetCi")]
    public static async Task<IActionResult> ExecuteGetCi(
                [HttpTrigger(FunctionStartup.DEFAULT_AUTHORIZATIONLEVEL, "get", Route = "ci/{dunsNumber}")]HttpRequest req,
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
        var data = await DnbHelper.GetDataFromTable(keyVaultHelper, DnbHelper.GetAppPrefix() + "dnbpcitable", dunsNumber);
        return new OkObjectResult(data);
      
      }
      catch (Exception ex)
      {
        functionRepository.Logger.LogError(ex, $"Error occured getting CI data using dunsNumber {dunsNumber}");

        return new StatusCodeResult(500);
      }
    }

    [FunctionName("InfoProcessor")]
    public static async Task ExecuteInfoProcessor(
                [ServiceBusTrigger("dnbpci-message-out","dnbpci-sub-message-out",Connection ="COREACT_TOPIC_DNBPCI_LISTEN_CONNECTIONSTRING")]
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
        if (!message.TargetProcessor.Contains("dnbpci"))
          throw new ServiceBusException(true, $"Message is for a different subscription {message}");
        var data = await DnbHelper.GetDetailedCompanyPrem(functionRepository.FunctionCache, keyVaultHelper, message.Id);
        var entity = await DnbHelper.CreateProcessorEntityAndSaveBlob(keyVaultHelper,
        "coreactdnbblobstore", message, data);

        await DnbHelper.SaveDataToTable(keyVaultHelper, DnbHelper.GetAppPrefix() + "dnbpcitable", entity);

        await DnbHelper.CreateAndSendSignalRMessage(signalRMessages, message, "dnbpci", "complete");
      }
      catch(Exception ex)
      {
        functionRepository.Logger.LogError(ex, $"An exception has occured processing message {queueItem}");

        await DnbHelper.CreateAndSendSignalRMessage(signalRMessages, message, "dnbpci", "error");

        throw;
      }
    }
  }
}
