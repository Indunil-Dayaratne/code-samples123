
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
using System.Net;
using System.Threading.Tasks;

namespace Coreact.CoreProcessor.Function.Handlers
{
  public static class CompProcessor
  {
    [FunctionName("GetComp")]
    public static async Task<IActionResult> ExecuteGetComp(
                [HttpTrigger(FunctionStartup.DEFAULT_AUTHORIZATIONLEVEL, "get", Route = "comp/{dunsNumber}")]HttpRequest req,
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
        var data = await DnbHelper.GetDataFromTable(keyVaultHelper,DnbHelper.GetAppPrefix() + "dnbpcomptable",dunsNumber);

        return new OkObjectResult(data);
      }
      catch (Exception ex)
      {
        functionRepository.Logger.LogError(ex, $"Error occured getting Comprehensive Report data using dunsNumber {dunsNumber}");

        return new StatusCodeResult(500);
      }
    }

    [FunctionName("CompProcessor")]
    public static async Task ExecuteCompProcessor(
                [ServiceBusTrigger("dnbpcomp-message-out","dnbpcomp-sub-message-out",Connection ="COREACT_TOPIC_DNBPCOMP_LISTEN_CONNECTIONSTRING")]
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

      System.Net.ServicePointManager.SecurityProtocol |= SecurityProtocolType.Tls11 | SecurityProtocolType.Tls12;

      try
      {
        if (!message.TargetProcessor.Contains("dnbpcomp"))
          throw new ServiceBusException(true, $"Message is for a different subscription {message}");

        var data = await DnbHelper.GetComprehensiveReport(functionRepository.FunctionCache, keyVaultHelper, message.Id);

        var entity = await DnbHelper.CreateProcessorEntityAndSaveBlob(keyVaultHelper,
        "coreactdnbblobstore",message,data);

        await DnbHelper.SaveDataToTable(keyVaultHelper, DnbHelper.GetAppPrefix() + "dnbpcomptable", entity);

        await DnbHelper.CreateAndSendSignalRMessage(signalRMessages,message,"dnbpcomp","complete");
      }
      catch(Exception ex)
      {
        functionRepository.Logger.LogError(ex, $"An exception has occured processing message {queueItem}");

        await DnbHelper.CreateAndSendSignalRMessage(signalRMessages,message,"dnbpcomp","error");

        throw;
      }
    }
  }
}
