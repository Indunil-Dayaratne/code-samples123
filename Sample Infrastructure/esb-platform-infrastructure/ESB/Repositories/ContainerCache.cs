using ESB.Models;
using Microsoft.Azure.ServiceBus.Core;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Azure.ServiceBus;

namespace ESB.Repositories
{
    public class ContainerCache : IContainerCache
    {
        private ConcurrentDictionary<string, BusMessageContainers> _clients = new ConcurrentDictionary<string, BusMessageContainers>();
        private readonly ILogger _logger;
        private CloudStorageAccount _storageAccount;
        private CloudBlobClient _blobClient;
        protected string _busConnectionString;

        public ContainerCache(ILogger<ContainerCache> logger, IOptions<AzureStorageSettings> storageSettings, IOptions<AzureBusSettings> busSettings)
        {
            _logger = logger;
            _storageAccount = CloudStorageAccount.Parse(storageSettings.Value.ConnectionString);
            _blobClient = _storageAccount.CreateCloudBlobClient();
            _busConnectionString = busSettings.Value.ConnectionString;
        }

        public BusMessageContainers GetTopicContainers(string topicName)
        {
            return _clients.GetOrAdd(topicName, (addName) => CreateContainers(addName, CreateTopicClient));
        }

        public BusMessageContainers GetQueueContainers(string queueName)
        {
            return _clients.GetOrAdd(queueName, (addName) => CreateContainers(addName, CreateQueueClient));
        }

        private ISenderClient CreateTopicClient(string topicName) => new TopicClient(_busConnectionString, topicName);
        private ISenderClient CreateQueueClient(string queueName) => new QueueClient(_busConnectionString, queueName);


        public BusMessageContainers CreateContainers(string name, Func<string, ISenderClient> createClient)
        {
            try
            {
                CloudBlobContainer container = _blobClient.GetContainerReference(name);
                ISenderClient client = createClient(name);

                BusMessageContainers containers = new BusMessageContainers
                {
                    CloudBlobContainer = container,
                    SenderClient = client
                };

                return containers;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"CreateContainers, name={name}, error:{ex.Message}");
                throw;
            }
        }

    }
}
