using ESB.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.ServiceBus;
using Microsoft.Azure.ServiceBus.Core;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ESB.Repositories
{
    public class AzureRepository : IAzureRepository
    {
        protected ILogger _logger;
        private readonly TimeSpan _ttl;
        public const string SourceSystem = "SourceSystem";
        public const string FromIPAddress = "FromIPAddress";
        public const string MessageId = "MessageId";
        public const string ReferenceProperty = "ReferenceProperty";

        public AzureRepository(ILogger<AzureRepository> logger, IOptions<AzureBusSettings> busSettings)
        {
            _logger = logger;
            _ttl = busSettings.Value.TimeToLive;
        }

        public async Task<string> SendMessageWithBlobAsync(BusMessageContainers containers, string sourceSystem, string messageBody, string fromUser, string fromIpAddress)
        {
            string containerType = containers.SenderClient is TopicClient ? "Topic" : "Queue";
            _logger.LogDebug($"SendMessageWithBlobAsync - {containerType}={containers.CloudBlobContainer.Name}, sourceSystem={sourceSystem}, message={messageBody}, fromUser={fromUser}, fromIpAddress={fromIpAddress}");

            try
            {
                string messageId = Guid.NewGuid().ToString();
                KeyValuePair<string, string> sourceSystemMetadata = new KeyValuePair<string, string>(SourceSystem, sourceSystem);
                KeyValuePair<string, string> fromIpAddressMetadata = new KeyValuePair<string, string>(FromIPAddress, fromIpAddress);
                
                await SaveBlobAsync(containers.CloudBlobContainer, messageId, messageBody, new byte[0], string.Empty, sourceSystemMetadata, fromIpAddressMetadata);

                var emptyMetadata = Enumerable.Empty<KeyValuePair<string, object>>();
                await SendMessageAsync(containers.SenderClient, containerType, containers.CloudBlobContainer.Name, messageId, sourceSystem, fromIpAddress, emptyMetadata);

                return messageId;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"SendMessageWithBlobAsync error: {ex.Message}");
                throw;
            }
        }

        public async Task<string> SendMessageWithBlobAsync(BusMessageContainers containers, string sourceSystem, byte[] messageBody, string fromUser, string fromIpAddress, List<KeyValuePair<string, object>> metadata)
        {
            string containerType = containers.SenderClient is TopicClient ? "Topic" : "Queue";
            _logger.LogDebug($"SendMessageWithBlobAsync - {containerType}={containers.CloudBlobContainer.Name}, sourceSystem={sourceSystem}, message={messageBody}, fromUser={fromUser}, fromIpAddress={fromIpAddress}");

            try
            {
                string messageId = Guid.NewGuid().ToString();
                KeyValuePair<string, string> sourceSystemMetadata = new KeyValuePair<string, string>(SourceSystem, sourceSystem);
                KeyValuePair<string, string> fromIpAddressMetadata = new KeyValuePair<string, string>(FromIPAddress, fromIpAddress);
                
                await SaveBlobAsync(containers.CloudBlobContainer, messageId, string.Empty, messageBody, string.Empty, sourceSystemMetadata, fromIpAddressMetadata);

                //var emptyMetadata = Enumerable.Empty<KeyValuePair<string, object>>();
                await SendMessageAsync(containers.SenderClient, containerType, containers.CloudBlobContainer.Name, messageId, sourceSystem, fromIpAddress, metadata);

                return messageId;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"SendMessageWithBlobAsync error: {ex.Message}");
                throw;
            }
        }

        public async Task<string> SendMessageWithFileAsync(BusMessageContainers containers, string sourceSystem, string filePath, string fromUser, string fromIpAddress)
        {
            string containerType = containers.SenderClient is TopicClient ? "Topic" : "Queue";
            _logger.LogDebug($"SendMessageWithBlobAsync - {containerType}={containers.CloudBlobContainer.Name}, sourceSystem={sourceSystem}, filePath={filePath}, fromUser={fromUser}, fromIpAddress={fromIpAddress}");

            try
            {
                string messageId = Guid.NewGuid().ToString();
                KeyValuePair<string, string> sourceSystemMetadata = new KeyValuePair<string, string>(SourceSystem, sourceSystem);
                KeyValuePair<string, string> fromIpAddressMetadata = new KeyValuePair<string, string>(FromIPAddress, fromIpAddress);

                await SaveBlobAsync(containers.CloudBlobContainer, messageId, string.Empty, new byte[0], filePath, sourceSystemMetadata, fromIpAddressMetadata);

                var emptyMetadata = Enumerable.Empty<KeyValuePair<string, object>>();
                await SendMessageAsync(containers.SenderClient, containerType, containers.CloudBlobContainer.Name, messageId, sourceSystem, fromIpAddress, emptyMetadata);

                return messageId;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"SendMessageWithBlobAsync error: {ex.Message}");
                throw;
            }
        }

        public async Task<string> SendMessageWithMetadataAsync(BusMessageContainers containers, string sourceSystem, BusMessage busMessage, string fromUser, string fromIpAddress)
        {
            string containerType = containers.SenderClient is TopicClient ? "Topic" : "Queue";
            _logger.LogDebug($"SendMessageWithBlobAsync - {containerType}={containers.CloudBlobContainer.Name}, sourceSystem={sourceSystem}, busMessage={busMessage}, fromUser={fromUser}, fromIpAddress={fromIpAddress}");

            try
            {
                string messageId = Guid.NewGuid().ToString();
                string metadataBlobId = Guid.NewGuid().ToString();
                var blobMetadataReferences = new List<KeyValuePair<string, object>>();
                List<Task> blobTasks = new List<Task>();

                KeyValuePair<string, string> sourceSystemMetadata = new KeyValuePair<string, string>(SourceSystem, sourceSystem);
                KeyValuePair<string, string> fromIpAddressMetadata = new KeyValuePair<string, string>(FromIPAddress, fromIpAddress);
                Task contentTask = SaveBlobAsync(containers.CloudBlobContainer, messageId, busMessage.Content, new byte[0],string.Empty, sourceSystemMetadata, fromIpAddressMetadata);
                blobTasks.Add(contentTask);

                if (busMessage.BlobReferenceMetadata.Any())
                {
                    KeyValuePair<string, string> messsageIdMetadata = new KeyValuePair<string, string>(MessageId, messageId);

                    foreach (KeyValuePair<string, string> metadata in busMessage.BlobReferenceMetadata)
                    {
                        string referenceId = Guid.NewGuid().ToString();
                        blobMetadataReferences.Add(new KeyValuePair<string, object>(metadata.Key, referenceId));
                        KeyValuePair<string, string> referencePropertyMetadata = new KeyValuePair<string, string>(ReferenceProperty, metadata.Key);

                        Task metadataTask = SaveBlobAsync(containers.CloudBlobContainer, referenceId, metadata.Value, new byte[0], string.Empty, messsageIdMetadata, referencePropertyMetadata);
                        blobTasks.Add(metadataTask);
                    }
                }

                // save blobs before bus message to make sure there that there is no possibility of a message not pointing to a valid blob 
                await Task.WhenAll(blobTasks);

                IEnumerable<KeyValuePair<string, object>> busMetadata = busMessage.Metadata.Concat(blobMetadataReferences);
                await SendMessageAsync(containers.SenderClient, containerType, containers.CloudBlobContainer.Name, sourceSystem, messageId, fromIpAddress, busMetadata);

                return messageId;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"SendMessageWithBlobAsync error: {ex.Message}");
                throw;
            }
        }

        public async Task SaveBlobAsync(CloudBlobContainer container, string blobName, string blobStringContent, byte[] blobByteContent, string filePath, params KeyValuePair<string, string>[] metadata)
        {
            try
            {
                var blobContent = string.IsNullOrEmpty(blobStringContent)? blobStringContent:(blobByteContent.Length>0? Encoding.ASCII.GetString(blobByteContent) :filePath);
                _logger.LogDebug($"SaveBlobAsync - containerName={container.Name}, blobName={blobName}, blobContent={blobContent}, metadata=[ {string.Join(", ", metadata)} ]");

                // upload the blob
                CloudBlockBlob blob = container.GetBlockBlobReference(blobName);

                if (!string.IsNullOrEmpty(blobStringContent))
                {
                    await blob.UploadTextAsync(blobStringContent);
                }
                else if (blobByteContent.Length > 0)
                {
                    await blob.UploadFromByteArrayAsync(blobByteContent, 0, blobByteContent.Length);
                }
                else if (!string.IsNullOrEmpty(filePath))
                {
                    await blob.UploadFromFileAsync(filePath);
                }

                // set metadata
                blob.Metadata.Add("TTL", DateTimeOffset.UtcNow.Add(_ttl).ToString("o"));

                foreach (var pair in metadata)
                {
                    blob.Metadata.Add(pair);
                }
                await blob.SetMetadataAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"SaveBlobAsync error: {ex.Message}");
                throw;
            }
        }
        
        public async Task<string> SendMessageAsync(ISenderClient sender, string containerType, string name, string messageId, string sourceSystem, string fromIpAddress, IEnumerable<KeyValuePair<string, object>> metadata)
        {
            try
            {
                _logger.LogDebug($"SendMessageAsync - {containerType}={name}, messageId={messageId}, sourceSystem={sourceSystem}, fromIpAddress={fromIpAddress}, metadata=[ {string.Join(", ", metadata)} ]");

                var message = new Message()
                {
                    MessageId = messageId,
                    TimeToLive = _ttl
                };

                message.UserProperties.Add(SourceSystem, sourceSystem);
                message.UserProperties.Add(FromIPAddress, fromIpAddress);

                foreach (var pair in metadata)
                {
                    message.UserProperties.Add(pair);
                }

                await sender.SendAsync(message);
                return message.MessageId;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"SendMessageAsync error: {ex.Message}");
                throw;
            }
        }

    }


}
