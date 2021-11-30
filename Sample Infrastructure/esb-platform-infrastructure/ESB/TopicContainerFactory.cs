using Microsoft.Azure.ServiceBus;
using Microsoft.Extensions.Options;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
/*
namespace ESB
{
    public interface ITopicContainerFactory
    {
        TopicContainers GetContainers(string topic);
    }

    public class TopicContainers
    {
        public CloudBlobContainer CloudBlobContainer { get; set;}
        public ITopicClient TopicClient { get; set;  }
    }

    public class TopicContainerFactory : ITopicContainerFactory
    {
        private ConcurrentDictionary<string, TopicContainers> _clients = new ConcurrentDictionary<string, TopicContainers>();
        private string _connectionString;
        private CloudStorageAccount _storageAccount;
        CloudBlobClient _blobClient;

        public TopicContainerFactory(IOptions<AzureStorageSettings> storageSettings, IOptions<AzureBusSettings> busSettings)
        {
            _connectionString = busSettings.Value.ConnectionString;
            _storageAccount = CloudStorageAccount.Parse(storageSettings.Value.ConnectionString);
            _blobClient = _storageAccount.CreateCloudBlobClient();
        }

        public TopicContainers GetContainers(string topic)
        {
            var q = new QueueClient();
            q.
            if (!_clients.TryGetValue(topic, out TopicContainers containers))
            {
                ITopicClient client = new TopicClient(_connectionString, topic);
                CloudBlobContainer blobContainer = _blobClient.GetContainerReference(topic);
                containers = new TopicContainers()
                {
                    CloudBlobContainer = blobContainer,
                    TopicClient = client
                };
                _clients.TryAdd(topic, containers);
            }
            return containers;
        }
    }
}
*/