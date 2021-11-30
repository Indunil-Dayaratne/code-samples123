
using AutofacOnFunctions.Services.Ioc;
using Coreact.CoreProcesser.Function;
using Coreact.Entities;
using Coreact.Infrastructure.Base.Helper;
using Coreact.Infrastructure.Base.Repository;
using Coreact.Infrastructure.Base.Services;
using CoreHelpers.WindowsAzure.Storage.Table;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Management.ServiceBus.Models;
using Microsoft.Azure.ServiceBus;
using Microsoft.Azure.ServiceBus.Primitives;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Linq;
using Coreact.CoreProcessor.Function.Helpers;

namespace Coreact.CoreProcessor.Function.Handlers
{
  public static class Processor
  {

    public static TypeTemplateEntity GetTypeTemplateEntity(string typeName)
    {
      var typeTemplate = new TypeTemplateEntity
      {
        Name = typeName,
        Id = "1",
        Endpoints = new List<EndPointEntity>
          {
            new EndPointEntity{Name = "dnbpkyc",TopicName = "dnbpkyc-message-out",Type =typeName,UrlFragment = "kyc"},
            new EndPointEntity{Name = "dnbpci",TopicName = "dnbpci-message-out",Type = typeName,UrlFragment = "ci",},
            //new EndPointEntity{Name = "dnbpcomp",TopicName = "dnbpcomp-message-out",Type = typeName,UrlFragment = "comp"},
            new EndPointEntity{Name = "dnbpown",TopicName = "dnbpown-message-out",Type =typeName,UrlFragment = "own"},
            new EndPointEntity{Name = "dnbpcl",TopicName = "dnbpcl-message-out",Type =typeName,UrlFragment = "cl"},
            new EndPointEntity{Name = "dnbpml",TopicName = "dnbpml-message-out",Type =typeName,UrlFragment = "ml"},
            //new EndPointEntity{Name = "dnbpvi",TopicName = "dnbpvi-message-out",Type =typeName,UrlFragment = "vi"},
            //new EndPointEntity{Name = "dnbpcr",TopicName = "dnbpcr-message-out",Type =typeName,UrlFragment = "cr"},
            //new EndPointEntity{Name = "dnbpleb",TopicName = "dnbpleb-message-out",Type =typeName,UrlFragment = "leb"},
            //new EndPointEntity{Name = "dnbplej",TopicName = "dnbplej-message-out",Type =typeName,UrlFragment = "lej"},
            //new EndPointEntity{Name = "dnbples",TopicName = "dnbples-message-out",Type =typeName,UrlFragment = "les"},
            //new EndPointEntity{Name = "dnbpmed",TopicName = "dnbpmed-message-out",Type =typeName,UrlFragment = "med"},
            //new EndPointEntity{Name = "dnbppr",TopicName = "dnbppr-message-out",Type =typeName,UrlFragment = "pr"},
            new EndPointEntity{Name = "remotesearch",UrlFragment = "remotesearch"},
            new EndPointEntity{Name = "internalsearch",UrlFragment ="internalsearch"},
            new EndPointEntity{Name = "signalr",UrlFragment = "signalrinfo"}
          }
      };

      return typeTemplate;
    }

    [FunctionName("GetProcess")]
    public static async Task<IActionResult> RunGetProcess(
               [HttpTrigger(FunctionStartup.DEFAULT_AUTHORIZATIONLEVEL, "get", Route = "process/{type}/{id}")]HttpRequest req,
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
        using (var storageContext = await ProcessHelper.CreateStorageContext(keyVaultHelper))
        {
          storageContext.AddAttributeMapper(typeof(ProcessorStubEntity), ProcessHelper.GetAppPrefix() + "proctable");

          var query = await storageContext.QueryAsync<ProcessorStubEntity>(id);

          // check for existance of entity
          if (query.Any(s => s.Type.Name.Equals(type)))
          {
            return new OkObjectResult(query.OrderBy(s => s.Version).First());
          }
          else
            return new NotFoundResult();
        }
      }
      catch (Exception ex)
      {
        functionRepository.Logger.LogError(ex, $"An exception has occured getting process {type} {id}");

        throw;
      }
    }

    [FunctionName("GetType")]
    public static async Task<IActionResult> RunGetType(
               [HttpTrigger(FunctionStartup.DEFAULT_AUTHORIZATIONLEVEL, "get", Route = "type/{typeName}")]HttpRequest req,
               string typeName,
               [Inject]IFunctionRepository functionRepository,
               [Inject]IKeyVaultHelper keyVaultHelper
           )
    {
      if (!await functionRepository.BearerTokenValidator.ValidateRequest(req))
        return new UnauthorizedResult();

      try
      {
        return new OkObjectResult(GetTypeTemplateEntity(typeName));
      }
      catch (Exception ex)
      {
        functionRepository.Logger.LogError(ex, $"An exception has occured {ex.Message}");

        throw;
      }
    }

    [FunctionName("Processor")]
    public static async Task ExecuteProcessor(
                [ServiceBusTrigger("proc-message-in",Connection ="COREACT_NAMESPACE_LISTEN_CONNECTIONSTRING")]
                string queueItem,
                Int32 deliveryCount,
                DateTime enqueuedTimeUtc,
                string messageId,
                [Inject]IFunctionRepository functionRepository,
                [Inject]IKeyVaultHelper keyVaultHelper
            )
    {
      try
      {
        var message = JsonConvert.DeserializeObject<CoreactMessage>(queueItem);

        var typeTemplate = GetTypeTemplateEntity(message.Type);

        using (var storageContext = await ProcessHelper.CreateStorageContext(keyVaultHelper))
        {
          storageContext.AddAttributeMapper(typeof(ProcessorStubEntity), ProcessHelper.GetAppPrefix() +  "proctable");
          // save stub entry for id
          var entity = new ProcessorStubEntity
          {
            Id = message.Id,
            Version = (DateTime.MaxValue.Ticks - DateTime.UtcNow.Ticks).ToString("d20"),
            ProcessId = message.ProcessId,
            Type = typeTemplate,
            CreatedOn = DateTime.Now
          };

          await storageContext.MergeOrInsertAsync<ProcessorStubEntity>(entity);
        }

        foreach (var endPoint in typeTemplate.Endpoints.Where(x => !string.IsNullOrEmpty(x.TopicName)))
        {
          var topicClient = await ServiceBusHelper.CreateSBClientFromKeyVaultValue<TopicClient>(
             keyVaultHelper,
             endPoint.TopicName,"sendpolicy");

          message.TargetProcessor = endPoint.Name;
          message.TypeTemplate = typeTemplate;

          await topicClient.SendAsync(ServiceBusHelper.CreateMessageFromObject(message));
        }
      }
      catch(Exception ex)
      {
        functionRepository.Logger.LogError(ex, $"An exception has occured processing message {queueItem}");

        throw;
      }
    }
  }
}
