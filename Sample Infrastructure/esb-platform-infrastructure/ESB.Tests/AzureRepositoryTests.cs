using ESB.Models;
using ESB.Repositories;
using Microsoft.Extensions.Options;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;
using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using Xunit;

namespace ESB.Tests
{
    public class AzureRepositoryTests
    {
        // these settings are used for the mocked configuration settings
        public const string BusConnectionString = "Endpoint=sb://dev-gjest-brit-esb-bus.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=C7PlIzJ/l98lvknvqGJVNz5ENUU8sPiFTQqv/paA5tM=";
        public static readonly TimeSpan TimeToLive = TimeSpan.FromHours(24);
        public static readonly TimeSpan SASTokenDuration = TimeSpan.FromSeconds(60);
        public static readonly TimeSpan SASTokenRefreshDuration = TimeSpan.FromSeconds(10);
        public const int SASTokenRefreshMinSeconds = 60;

        // change to true to use emulated storage
        public const bool UseDevelopmentStorage = false;

        public static readonly string StorageConnectionString = UseDevelopmentStorage ? "UseDevelopmentStorage=true" : "DefaultEndpointsProtocol=https;AccountName=devesbstore;AccountKey=zyH1zLSOXWqL15d1GsVBUJ5Nc8sMdeG2oS8L4pUb7qGF5xwJdvgUgdO1GY/rBixdJCqX8pb80cmTOLrFVSS8VQ==;EndpointSuffix=core.windows.net";
        public const string TopicName = "eclipse-policy-out";
        public const string QueueName = "eclipse-policy-in";
        public const string SourceSystem = "UnitTest";
        public const string FromIPAddress = "1.2.3.4";
        public static readonly KeyValuePair<string, string> SourceSystemMetadata = new KeyValuePair<string, string>(AzureRepository.SourceSystem, SourceSystem);
        public static readonly KeyValuePair<string, string> FromIpAddressMetadata = new KeyValuePair<string, string>(AzureRepository.FromIPAddress, FromIPAddress);

        public static IOptions<AzureBusSettings>GetAzureBusSettings()
        {
            // use hard coded settings for unit tests - settings are NOT read from config file
            var settings = new AzureBusSettings
            {
                ConnectionString = BusConnectionString,
                TimeToLive = TimeToLive
            };

            return Options.Create(settings);
        }

        public static IOptions<AzureStorageSettings> GetAzureStorageSettings()
        {
            // use hard coded settings for unit tests - settings are NOT read from config file
            var settings = new AzureStorageSettings
            {
                ConnectionString = StorageConnectionString,
                SASTokenDuration = SASTokenDuration,
                SASTokenRefreshDuration = SASTokenRefreshDuration
           };

            return Options.Create(settings);
        }

        public static AzureRepository GetAzureRepository()
        {
            var logger = LoggerUtils.LoggerMock<AzureRepository>();
            var storageSettings = GetAzureStorageSettings();
            var busSettings = GetAzureBusSettings();
            var azureRepository = new AzureRepository(logger.Object, busSettings);
            return azureRepository;
        }

        [Fact]
        public async Task SaveBlobAsync_ValidContainer()
        {
            var azureRepository = GetAzureRepository();
            var containerCache = QueueControllerTests.GetContainerCache();
            var containers = containerCache.GetTopicContainers(TopicName);
            var blobContent = $"Unit test {Guid.NewGuid()} Now={DateTime.Now.ToString("o")}";
            var blobName = Guid.NewGuid().ToString();

            await azureRepository.SaveBlobAsync(containers.CloudBlobContainer, blobName, blobContent, new byte[0], string.Empty, SourceSystemMetadata, FromIpAddressMetadata);

            // check the blob
            var blob = BlobReader.GetBlob(TopicName, blobName);
            var blobDownloadedContent = await blob.DownloadTextAsync();

            Assert.Equal(blobDownloadedContent, blobContent);

            var ttl = blob.Metadata["TTL"];
            var sourceSystem = blob.Metadata[AzureRepository.SourceSystem];
            var sourceIPAddress = blob.Metadata[AzureRepository.FromIPAddress];

            DateTime expires = DateTime.Parse(ttl);

            Assert.True(expires > DateTime.Now);
            Assert.Equal(sourceSystem, SourceSystem);
            Assert.Equal(sourceIPAddress, FromIPAddress);

            // clean up
            await blob.DeleteAsync();
        }

        [Fact]
        public async Task SaveBlobAsync_InvalidContainer()
        {
            var azureRepository = GetAzureRepository();
            var containerCache = QueueControllerTests.GetContainerCache();
            var containers = containerCache.GetTopicContainers("zzzzz");
            var blobName = Guid.NewGuid().ToString();

            // does not error until you try to save blob
            StorageException ex = await Assert.ThrowsAsync<StorageException>(async () => await azureRepository.SaveBlobAsync(containers.CloudBlobContainer, blobName, "body", new byte[0], string.Empty));
            Assert.Equal("The specified container does not exist.", ex.Message);
        }

        [Fact]
        public async Task SaveBlobAsync_InvalidKey()
        {
            var azureRepository = GetAzureRepository();

            if (!UseDevelopmentStorage)
            {
                var connectionString = StorageConnectionString.Replace("AccountKey=ch9sOd9pgntcey8ycad/KlhjC3YwCUiwiYYXXIca58RxlnffxeueKgrsR+Gpj/01rAUa6zsIhJTWlyu3FZVY2w==;", "AccountKey=Zh9sOd9pgntcey8ycad/KlhjC3YwCUiwiYYXXIca58RxlnffxeueKgrsR+Gpj/01rAUa6zsIhJTWlyu3FZVY2w==;");

                var storageAccount = CloudStorageAccount.Parse(connectionString);
                var blobClient = storageAccount.CreateCloudBlobClient();

                CloudBlobContainer blobContainer = blobClient.GetContainerReference(TopicName);
                var blobName = Guid.NewGuid().ToString();

                // does not error until you try to save blob
                StorageException ex = await Assert.ThrowsAsync<StorageException>(async () => await azureRepository.SaveBlobAsync(blobContainer, blobName, "body", new byte[0], string.Empty));
                Assert.Equal("Server failed to authenticate the request. Make sure the value of Authorization header is formed correctly including the signature.", ex.Message);
            }
        }

        [Fact]
        public async Task SaveBlobAsync_InvalidAccountName()
        {
            var azureRepository = GetAzureRepository();

            if (!UseDevelopmentStorage)
            {
                var connectionString = StorageConnectionString.Replace("AccountName=devgjestbritesbstor;", "AccountName=invalidgjestbritesbstor;");

                var storageAccount = CloudStorageAccount.Parse(connectionString);
                var blobClient = storageAccount.CreateCloudBlobClient();

                CloudBlobContainer blobContainer = blobClient.GetContainerReference(TopicName);
                var blobName = Guid.NewGuid().ToString();

                // does not error until you try to save blob
                StorageException ex = await Assert.ThrowsAsync<StorageException>(async () => await azureRepository.SaveBlobAsync(blobContainer, blobName, "body", new byte[0], string.Empty));
                Assert.Equal("Bad Gateway", ex.Message);
            }
        }


        [Fact]
        public async Task SaveByteBlobAsync_ValidContainer()
        {
            var azureRepository = GetAzureRepository();
            var containerCache = QueueControllerTests.GetContainerCache();
            var containers = containerCache.GetTopicContainers(TopicName);
            var stringBlobContent = $"Unit test {Guid.NewGuid()} Now={DateTime.Now.ToString("o")}";
            var blobContent = Encoding.ASCII.GetBytes(stringBlobContent);
            var blobName = Guid.NewGuid().ToString();

            await azureRepository.SaveBlobAsync(containers.CloudBlobContainer, blobName, string.Empty, blobContent, string.Empty, SourceSystemMetadata, FromIpAddressMetadata);

            // check the blob
            var blob = BlobReader.GetBlob(TopicName, blobName);
            await blob.FetchAttributesAsync();
            byte[] blobDownloadedContent = new byte[blob.Properties.Length];
            await blob.DownloadToByteArrayAsync(blobDownloadedContent, 0);
            var stringBlobDownloadedContent = Encoding.ASCII.GetString(blobDownloadedContent);

            Assert.Equal(blobDownloadedContent, blobContent);
            Assert.Equal(stringBlobDownloadedContent, stringBlobContent);

            var ttl = blob.Metadata["TTL"];
            var sourceSystem = blob.Metadata[AzureRepository.SourceSystem];
            var sourceIPAddress = blob.Metadata[AzureRepository.FromIPAddress];

            DateTime expires = DateTime.Parse(ttl);

            Assert.True(expires > DateTime.Now);
            Assert.Equal(sourceSystem, SourceSystem);
            Assert.Equal(sourceIPAddress, FromIPAddress);

            // clean up
            await blob.DeleteAsync();
        }

        [Fact]
        public async Task SaveFileAsync_ValidContainer()
        {
            var azureRepository = GetAzureRepository();
            var containerCache = QueueControllerTests.GetContainerCache();
            var containers = containerCache.GetTopicContainers(TopicName);
            var filePath = Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location),"TestFiles/TestUploadFile.docx");
            var downloadFilePath = @"C:\TestDownloadFile.docx";
            var blobName = Guid.NewGuid().ToString();
            byte[] fileBytes = System.IO.File.ReadAllBytes(filePath);
            await azureRepository.SaveBlobAsync(containers.CloudBlobContainer, blobName, string.Empty, new byte[0], filePath, SourceSystemMetadata, FromIpAddressMetadata);

            // check the blob
            var blob = BlobReader.GetBlob(TopicName, blobName);
            await blob.DownloadToFileAsync(downloadFilePath, FileMode.Create);
            byte[] downloadedFleBytes = System.IO.File.ReadAllBytes(downloadFilePath);
            
            Assert.Equal(downloadedFleBytes, fileBytes);

            var ttl = blob.Metadata["TTL"];
            var sourceSystem = blob.Metadata[AzureRepository.SourceSystem];
            var sourceIPAddress = blob.Metadata[AzureRepository.FromIPAddress];

            DateTime expires = DateTime.Parse(ttl);

            Assert.True(expires > DateTime.Now);
            Assert.Equal(sourceSystem, SourceSystem);
            Assert.Equal(sourceIPAddress, FromIPAddress);

            // clean up
            await blob.DeleteAsync();
        }
    }
}
