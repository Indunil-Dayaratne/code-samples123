
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
  public static class KycProcessor
  {
    [FunctionName("GetKycQuery")]
    public static async Task<IActionResult> ExecuteGetKycQuery(
                [HttpTrigger(FunctionStartup.DEFAULT_AUTHORIZATIONLEVEL, "get", Route = "query/kyc/{dunsNumber}")]HttpRequest req,
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
        var data = await DnbHelper.GetKYC(functionRepository.FunctionCache, keyVaultHelper, dunsNumber);
        return new OkObjectResult(data);
      }
      catch (Exception ex)
      {
        functionRepository.Logger.LogError(ex, $"Error occured getting Kyc data using dunsNumber {dunsNumber}");

        return new StatusCodeResult(500);
      }
    }

    [FunctionName("GetKyc")]
    public static async Task<IActionResult> ExecuteGetKyc(
                [HttpTrigger(FunctionStartup.DEFAULT_AUTHORIZATIONLEVEL, "get", Route = "kyc/{dunsNumber}")]HttpRequest req,
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
        var data = await DnbHelper.GetDataFromTable(keyVaultHelper, DnbHelper.GetAppPrefix() + "dnbpkyctable", dunsNumber);
        return new OkObjectResult(data);
      }
      catch (Exception ex)
      {
        functionRepository.Logger.LogError(ex, $"Error occured getting Kyc data using dunsNumber {dunsNumber}");

        return new StatusCodeResult(500);
      }
    }

    [FunctionName("KycProcessor")]
    public static async Task ExecuteKycProcessor(
                [ServiceBusTrigger("dnbpkyc-message-out","dnbpkyc-sub-message-out",Connection ="COREACT_TOPIC_DNBPKYC_LISTEN_CONNECTIONSTRING")]
                string queueItem,
                Int32 deliveryCount,
                DateTime enqueuedTimeUtc,
                string messageId,
                [SignalR(HubName = "coreact")]IAsyncCollector<SignalRMessage> signalRMessages,
                [Inject]IFunctionRepository functionRepository,
                [Inject]IKeyVaultHelper keyVaultHelper
            )
    {
      var message = JsonConvert.DeserializeObject<CoreactMessage>(queueItem);

      try
      {
        if (!message.TargetProcessor.Contains("dnbpkyc"))
          throw new ServiceBusException(true, $"Message is for a different subscription {message}");
        var data = await DnbHelper.GetKYC(functionRepository.FunctionCache, keyVaultHelper, message.Id);
        var entity = await DnbHelper.CreateProcessorEntityAndSaveBlob(keyVaultHelper,
        "coreactdnbblobstore", message, data);

        await DnbHelper.SaveDataToTable(keyVaultHelper, DnbHelper.GetAppPrefix() + "dnbpkyctable", entity);

        await DnbHelper.CreateAndSendSignalRMessage(signalRMessages, message, "dnbpkyc", "complete");
      }
      catch (Exception ex)
      {
        functionRepository.Logger.LogError(ex, $"An exception has occured processing message {queueItem}");

        await DnbHelper.CreateAndSendSignalRMessage(signalRMessages, message, "dnbpkyc", "error");

        throw;
      }
    }
  }
}
