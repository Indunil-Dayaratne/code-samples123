using Coreact.Infrastructure.Base.Services;
using Microsoft.Azure.ServiceBus;
using Microsoft.Azure.ServiceBus.Core;
using Microsoft.Azure.ServiceBus.Primitives;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace Coreact.Infrastructure.Base.Helper
{
  public class ServiceBusHelper
  {

    public static async Task<T> CreateSBClientFromKeyVaultValue<T>(IKeyVaultHelper kvHelper, string itemName, string policyName)
      where T : class, ISenderClient
    {
      var svcBusEndpoint = Environment.GetEnvironmentVariable("SERVICE_BUS_ENDPOINT");
      var sharedAccessVariableName = itemName + "-" + policyName + "-sak";
      var sharedAccessKey = await kvHelper.GetKeyVaultValue(sharedAccessVariableName);
      var tokenProvider = SharedAccessSignatureTokenProvider.CreateSharedAccessSignatureTokenProvider(policyName, sharedAccessKey, TimeSpan.FromMinutes(1));

      T t;

      if (typeof(T).Equals(typeof(QueueClient)))
        t = new QueueClient(svcBusEndpoint, itemName, tokenProvider) as T;
      else
        t = new TopicClient(svcBusEndpoint, itemName, tokenProvider) as T;

      t.ServiceBusConnection.TransportType = TransportType.AmqpWebSockets;

      return t;
    }

    public static Message CreateMessageFromObject(object obj)
    {
      var body = JsonConvert.SerializeObject(obj);

      var message = new Message(Encoding.UTF8.GetBytes(body));

      return message;
    }
  }
}
