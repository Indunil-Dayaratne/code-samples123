using ESB.Models;
using Microsoft.Azure.Management.ResourceManager.Fluent;
using Microsoft.Azure.Management.ResourceManager.Fluent.Authentication;
using Microsoft.Azure.Management.ResourceManager.Fluent.Core;
using Microsoft.Azure.Management.ServiceBus.Fluent;
using Microsoft.Azure.ServiceBus;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using System.Web;

namespace ESB.Services
{
    public class SASGenerator : ISASGenerator
    {
        private readonly ILogger _logger;
        private readonly AzureBusSettings _busSettings;
        private readonly AzureStorageSettings _storageSettings;
        private readonly IBusSASTokenProviderFactory _busSASTokenProviderFactory;
        protected ConcurrentDictionary<string, TokenDetails> _storageTokens = new ConcurrentDictionary<string, TokenDetails>();
        private const string _readPolicyName1 = "read1";
        private const string _readPolicyName2 = "read2";
        private const string _listenPolicyRuleName = "listen";
        private const string _lastUpdated = "lastUpdated";

        public SASGenerator(ILogger<SASGenerator> logger, IOptions<AzureStorageSettings> storageSettings, IOptions<AzureBusSettings> busSettings, IBusSASTokenProviderFactory busSASTokenProviderFactory)
        {
            _logger = logger;
            _busSettings = busSettings.Value;
            _storageSettings = storageSettings.Value;
            _busSASTokenProviderFactory = busSASTokenProviderFactory;
        }

        public async Task<TokenDetails> GetBlobContainerSASTokenAsync(string containerName)
        {
            try
            {
                bool hasValidToken = false;
                if (_storageTokens.TryGetValue(containerName, out TokenDetails tokenDetails))
                {
                    // only use token if has not expired or is not due to expire soon
                    hasValidToken = tokenDetails.Expires + _storageSettings.SASTokenRefreshDuration > DateTimeOffset.UtcNow;
                }

                if (!hasValidToken)
                {
                    // create a new token and add to the dictionary
                    tokenDetails = await CreateBlobContainerSASTokenAsync(containerName);
                    _storageTokens[containerName] = tokenDetails;
                }

                return tokenDetails;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"GetBlobContainerSASToken, containerName={containerName}, error: {ex.Message}");
                throw;
            }
        }

        public async Task<TokenDetails> CreateBlobContainerSASTokenAsync(string containerName)
        {
            CloudStorageAccount storageAccount = CloudStorageAccount.Parse(_storageSettings.ConnectionString);
            CloudBlobClient blobClient = storageAccount.CreateCloudBlobClient();

            // Get a reference to the container for which shared access signature will be created.
            CloudBlobContainer container = blobClient.GetContainerReference(containerName);

            // Create blob container permissions, consisting of a shared access policy and a public access setting. 
            BlobContainerPermissions containerPermissions = await container.GetPermissionsAsync();

            var keys = containerPermissions.SharedAccessPolicies.Keys;

            // alternate between using read1 and read2 policies
            bool hasPolicy1 = containerPermissions.SharedAccessPolicies.ContainsKey(_readPolicyName1);
            bool hasPolicy2 = containerPermissions.SharedAccessPolicies.ContainsKey(_readPolicyName2);
            string usePolicy;

            if (hasPolicy1 && hasPolicy2)
            {
                // both policies exist, replace the oldest
                var policy1 = containerPermissions.SharedAccessPolicies[_readPolicyName1];
                var policy2 = containerPermissions.SharedAccessPolicies[_readPolicyName2];
                usePolicy = policy1.SharedAccessExpiryTime < policy2.SharedAccessExpiryTime ? _readPolicyName1 : _readPolicyName2;
                containerPermissions.SharedAccessPolicies.Remove(usePolicy);
            }
            else
            {
                usePolicy = hasPolicy1 ? _readPolicyName2 : _readPolicyName1;
            }

            DateTimeOffset expires = DateTimeOffset.UtcNow + _storageSettings.SASTokenDuration;

            // create policy for read access
            containerPermissions.SharedAccessPolicies.Add(usePolicy, new SharedAccessBlobPolicy()
            {
                // To ensure SAS is valid immediately, don’t set start time.
                // This way, you can avoid failures caused by small clock differences.
                SharedAccessExpiryTime = expires,
                Permissions = SharedAccessBlobPermissions.Read
            });

            // Set the permission policy on the container.
            await container.SetPermissionsAsync(containerPermissions);

            // Get the shared access signature to share with users.
            string sasToken = container.GetSharedAccessSignature(null, usePolicy, SharedAccessProtocol.HttpsOnly, null);

            return new TokenDetails
            {
                Url = container.Uri.AbsoluteUri,
                SASToken = sasToken,
                Expires = expires
            };
        }



        public async Task<string> GetContainerLastUpdatedAsync(string containerName)
        {
            try
            {
                AppContext.SetSwitch("System.Net.Http.UseSocketsHttpHandler", false);

                string lastUpdated = null;
                CloudStorageAccount storageAccount = CloudStorageAccount.Parse(_storageSettings.ConnectionString);
                CloudBlobClient blobClient = storageAccount.CreateCloudBlobClient();
                CloudBlobContainer container = blobClient.GetContainerReference(containerName);
                await container.FetchAttributesAsync();
                container.Metadata.TryGetValue(_lastUpdated, out lastUpdated);
                return lastUpdated;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"GetLastUpdated, error:{ex.Message}");
                throw;
            }
        }

        public async Task SetContainerLastUpdatedAsync(string containerName, string lastUpdated)
        {
            try
            {
                CloudStorageAccount storageAccount = CloudStorageAccount.Parse(_storageSettings.ConnectionString);
                CloudBlobClient blobClient = storageAccount.CreateCloudBlobClient();
                CloudBlobContainer container = blobClient.GetContainerReference(containerName);
                container.Metadata[_lastUpdated] = lastUpdated;
                await container.SetMetadataAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"SetLastUpdated, error:{ex.Message}");
                throw;
            }
        }

        public async Task<ESBInformation> GetBusInformationAsync()
        {
            try
            {
                ESBInformation busInfo = new ESBInformation();

                IServiceBusNamespace servicebus = await _busSASTokenProviderFactory.GetServiceBusNamespaceAsync();
                Task<IPagedCollection<IQueue>> queuesTask = servicebus.Queues.ListAsync();
                Task<IPagedCollection<ITopic>> topicsTask = servicebus.Topics.ListAsync();

                await topicsTask;

                var subscriptionTasks = new List<Task<IPagedCollection<Microsoft.Azure.Management.ServiceBus.Fluent.ISubscription>>>();

                foreach (ITopic topic in topicsTask.Result)
                {
                    Task<IPagedCollection<Microsoft.Azure.Management.ServiceBus.Fluent.ISubscription>> subscriptionTask = topic.Subscriptions.ListAsync();
                    subscriptionTasks.Add(subscriptionTask);
                }

                await Task.WhenAll(subscriptionTasks);

                busInfo.Topics = topicsTask.Result.Zip(subscriptionTasks, (topic, task) => new BusTopic
                {
                    Name = topic.Name,
                    Subscriptions = task.Result.Select(s => new Subscription
                    {
                        Name = s.Name,
                        MessageCount = s.MessageCount
                    }).ToList()
                }).ToList();

                await queuesTask;

                busInfo.Queues = queuesTask.Result.Select(q => new BusQueue
                {
                    Name = q.Name,
                    MessageCount = q.MessageCount
                }).ToList();

                Dictionary<string, BusItem> busItemLookup = busInfo.Queues.Cast<BusItem>().ToDictionary(q => q.Name);
                foreach (BusItem topic in busInfo.Topics)
                {
                    busItemLookup.Add(topic.Name, topic);
                }

                CloudStorageAccount storageAccount = CloudStorageAccount.Parse(_storageSettings.ConnectionString);
                busInfo.StorageLocation = storageAccount.BlobEndpoint.AbsoluteUri;
                busInfo.BusLocation = servicebus.Fqdn;
                busInfo.BusSASTokenDuration = _busSettings.SASTokenDuration;
                busInfo.BusTokenProviderCacheDuration = _busSettings.TokenProviderCacheDuration;
                busInfo.BlobSASTokenDuration = _storageSettings.SASTokenDuration;
                busInfo.BlobSASTokenRefreshDuration = _storageSettings.SASTokenRefreshDuration;

                CloudBlobClient blobClient = storageAccount.CreateCloudBlobClient();

                BlobContinuationToken continuationToken = null;
                do
                {
                    ContainerResultSegment segment = await blobClient.ListContainersSegmentedAsync(continuationToken);
                    continuationToken = segment.ContinuationToken;

                    foreach (CloudBlobContainer container in segment.Results)
                    {
                        if (busItemLookup.TryGetValue(container.Name, out BusItem busItem))
                        {
                            busItem.HasBlobContainer = true;
                        }
                    }
                } while (continuationToken != null);

                return busInfo;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"GetTopics, error: {ex.Message}");
                throw;
            }
        }


    }
}
