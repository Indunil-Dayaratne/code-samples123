using Microsoft.Azure.Management.ServiceBus.Fluent;
using Microsoft.Azure.ServiceBus.Primitives;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ESB.Services
{
    public interface IBusSASTokenProviderFactory
    {
        Task<ITokenProvider> GetQueueTokenProviderAsync(string queueName);
        Task<ITokenProvider> GetTopicTokenProviderAsync(string topicName);
        Task<IServiceBusNamespace> GetServiceBusNamespaceAsync();
    }
}
