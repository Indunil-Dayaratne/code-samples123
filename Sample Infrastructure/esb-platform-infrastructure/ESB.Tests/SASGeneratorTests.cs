using ESB.Models;
using ESB.Services;
using Microsoft.Azure.ServiceBus;
using Microsoft.Azure.ServiceBus.Primitives;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Options;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;
using Moq;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Xunit;

namespace ESB.Tests
{
    public class SASGeneratorTests
    {
        public SASGenerator GetSASGenerator()
        {
            var logger = LoggerUtils.LoggerMock<SASGenerator>();
            var busSettings = AzureRepositoryTests.GetAzureBusSettings();
            AzureBusSettings settings = busSettings.Value;
            settings.ConnectionString = "Endpoint=sb://dev-gjest-brit-esb-bus.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=C7PlIzJ/l98lvknvqGJVNz5ENUU8sPiFTQqv/paA5tM=";
            settings.ResourceGroupName = "dev-gjest";
            settings.AppId = "33423d6f-28cc-4ece-9351-6c1332d777b2";
            settings.SecretKey = "qtPRUSYLTPwZFcjR6MoYNoUXX8IDOXd+rctaBB3HuW0=";
            settings.TenantId = "0ba385a0-ca88-45f6-8e03-adc1c8d058c5";
            settings.SubscriptionId = "24a4f011-3ee8-46c8-ab06-97e70613c3fa";

            var storageSettings = AzureRepositoryTests.GetAzureStorageSettings();

            var loggerTokenProvider = LoggerUtils.LoggerMock<BusSASTokenProviderFactory>();
            var cache = new MemoryCache(new MemoryCacheOptions());
            BusSASTokenProviderFactory factory = new BusSASTokenProviderFactory(loggerTokenProvider.Object, cache, busSettings);

            var sasGenerator = new SASGenerator(logger.Object, storageSettings, busSettings, factory);
            return sasGenerator;
        }

        [Fact]
        public async void GetBusInformationTest()
        {
            var sasGenerator = GetSASGenerator();
            var busInformation = await sasGenerator.GetBusInformationAsync();
        }

        [Fact]
        public async void CreateBlobContainerSASToken()
        {
            var sasGenerator = GetSASGenerator();
            TokenDetails details = await sasGenerator.CreateBlobContainerSASTokenAsync(AzureRepositoryTests.TopicName);
        }

        [Fact]
        public async void CreateTopicSASToken()
        {
            var sasGenerator = GetSASGenerator();
            //TokenDetails token = await sasGenerator.CreateTopicSASTokenAsync("eclipse-policy-out");
        }

        [Fact]
        public async Task CreateBlobContainerSASToken_ValidateToken()
        {
            const string containerName = "eclipse-policy-in";
            var azureRepository = AzureRepositoryTests.GetAzureRepository();
            var containerCache = QueueControllerTests.GetContainerCache();
            var containers = containerCache.GetTopicContainers(containerName);
            var messageBody = $"Unit test {Guid.NewGuid()} Now={DateTime.Now.ToString("o")}";
            var blobName = Guid.NewGuid().ToString();
            await azureRepository.SaveBlobAsync(containers.CloudBlobContainer, blobName, messageBody, new byte[0], string.Empty, AzureRepositoryTests.SourceSystemMetadata, AzureRepositoryTests.FromIpAddressMetadata);

            var sasGenerator = GetSASGenerator();
            TokenDetails token = await sasGenerator.CreateBlobContainerSASTokenAsync(containerName);

            Uri uri = new Uri($"{token.Url}/{blobName}{token.SASToken}");
            CloudBlockBlob blob = new CloudBlockBlob(uri);

            var blobContent = await blob.DownloadTextAsync();

            Assert.Equal(messageBody, blobContent);

            // test delete - should only have read permission
            StorageException ex = await Assert.ThrowsAsync<StorageException>(async () => await blob.DeleteAsync());
            Assert.Equal("This request is not authorized to perform this operation using this permission.", ex.Message);

            // also get blob via the container, this is probably the best way for a client would get the blob that is listening on a topic
            var storageAccount = CloudStorageAccount.Parse(AzureRepositoryTests.StorageConnectionString);
            Uri containerTokenUri = new Uri($"{token.Url}/{token.SASToken}");
            CloudBlobContainer container = new CloudBlobContainer(containerTokenUri);
            blob = container.GetBlockBlobReference(blobName);
            blobContent = await blob.DownloadTextAsync();

            // test update - should only have read permission
            ex = await Assert.ThrowsAsync<StorageException>(async () => await blob.UploadTextAsync("updates"));
            Assert.Equal("This request is not authorized to perform this operation using this permission.", ex.Message);

            // test list - should only have read permission
            BlobContinuationToken continuationToken = new BlobContinuationToken();
            ex = await Assert.ThrowsAsync<StorageException>(async () => await container.ListBlobsSegmentedAsync(continuationToken));
            Assert.Equal("This request is not authorized to perform this operation using this permission.", ex.Message);

            // get the blob using the connection string - will have delete permission
            blob = BlobReader.GetBlob(AzureRepositoryTests.TopicName, blobName);

            // clean up
            await blob.DeleteAsync();
        }

        [Fact]
        public async Task CreateBlobContainerSASToken_ValidateExpired()
        {
            var azureRepository = AzureRepositoryTests.GetAzureRepository();
            var containerCache = QueueControllerTests.GetContainerCache();
            var containers = containerCache.GetTopicContainers(AzureRepositoryTests.TopicName);
            var messageBody = $"Unit test {Guid.NewGuid()} Now={DateTime.Now.ToString("o")}";
            var blobName = Guid.NewGuid().ToString();

            await azureRepository.SaveBlobAsync(containers.CloudBlobContainer, blobName, messageBody , new byte[0], string.Empty,AzureRepositoryTests.SourceSystemMetadata, AzureRepositoryTests.FromIpAddressMetadata);

            var logger = LoggerUtils.LoggerMock<SASGenerator>();
            var busSettings = AzureRepositoryTests.GetAzureBusSettings();
            var storageSettings = AzureRepositoryTests.GetAzureStorageSettings();
            storageSettings.Value.SASTokenDuration = TimeSpan.FromSeconds(10);

            var sasGenerator = GetSASGenerator();
            TokenDetails token = await sasGenerator.CreateBlobContainerSASTokenAsync(AzureRepositoryTests.TopicName);

            TimeSpan waitTime = token.Expires - DateTimeOffset.UtcNow;
            // add some padding to compensate for clocks being slightly out of sync
            const int padding = 5000;
            Thread.Sleep((int)waitTime.TotalMilliseconds + padding);

            // test trying to read the blob with an expired token
            var blob = BlobReader.GetBlob(AzureRepositoryTests.TopicName, blobName, token.SASToken);
            StorageException ex = await Assert.ThrowsAsync<StorageException>(async () => await blob.DownloadTextAsync());
            Assert.Equal("Server failed to authenticate the request. Make sure the value of Authorization header is formed correctly including the signature.", ex.Message);

            // get the blob using the connection string - will have delete permission
            blob = BlobReader.GetBlob(AzureRepositoryTests.TopicName, blobName);

            // clean up
            await blob.DeleteAsync();
        }

        [Fact]
        public async void CreateTopicSASToken_ValidateTokenAsync()
        {
            /*
            var controller = TopicControllerTests.GetTopicController();
            var topic = "eclipse-policy-out";
            var subscription = "signalR";
            var messageBody = $"messageBody now={DateTime.Now.ToString("o")}";

            var containerCache = QueueControllerTests.GetContainerCache();
            var containers = containerCache.GetTopicContainers(topic);

            var messageId = await controller.PostMessageAsync(topic, "UnitTest", messageBody);

            var sasGenerator = GetSASGenerator();
            var tokenDetails = await sasGenerator.GetTopicSASTokenAsync(topic);

            var connection = new ServiceBusConnectionStringBuilder(tokenDetails.Url, topic, tokenDetails.SASToken);

            var messageHandlerOptions = new MessageHandlerOptions((e) =>
            {
                return Task.CompletedTask;
            })
            {
                MaxConcurrentCalls = 1,
                AutoComplete = false,
            };

            bool foundMessage = false;
            var subscriptionClient = new SubscriptionClient(connection, subscription);
            var waitOnMessage = new CancellationTokenSource();
            Task t = Task.Run(() =>
            {
                // Register the function that processes messages.

                subscriptionClient.RegisterMessageHandler(async (message, cancellationToken) =>
                {
                    if (message.MessageId == messageId)
                    {
                        foundMessage = true;

                        // download blob content
                        var newBlob = containers.CloudBlobContainer.GetBlockBlobReference(messageId);
                        var content = await newBlob.DownloadTextAsync();

                        Assert.Equal(content, messageBody);

                        await subscriptionClient.CompleteAsync(message.SystemProperties.LockToken);
                        waitOnMessage.Cancel();
                    }
                }, messageHandlerOptions);
                Thread.Sleep(20000);
            }, waitOnMessage.Token);

            t.Wait();

            Assert.True(foundMessage);
            */
        }

        [Fact]
        public void GetMainSASToken()
        {
            var sasGenerator = GetSASGenerator();
            //sasGenerator.GetMainSASToken();

        }

        [Fact]
        public async Task SetGetContainerLastUpdatedTestAsync()
        {
            var sasGenerator = GetSASGenerator();
            string lastUpdated = DateTimeOffset.Now.ToString("o");
            const string containerName = "eclipse-policy-out";
            await sasGenerator.SetContainerLastUpdatedAsync(containerName, lastUpdated);
            string lastUpdatedResult = await sasGenerator.GetContainerLastUpdatedAsync(containerName);
            Assert.Equal(lastUpdated, lastUpdatedResult);
        }

    }
}
