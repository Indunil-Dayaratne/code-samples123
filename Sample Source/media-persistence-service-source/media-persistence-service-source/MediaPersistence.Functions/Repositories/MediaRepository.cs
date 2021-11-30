using MediaPersistence.Functions.Commands;
using MediaPersistence.Functions.Entities;
using MediaPersistence.Functions.Helpers;
using MediaPersistence.Functions.Helpers.Interfaces;
using Microsoft.Azure.Cosmos;
using Microsoft.Azure.Documents;
using Microsoft.Azure.Documents.Client;
using Microsoft.Extensions.Logging;
using System;
using System.IO;
using System.Threading.Tasks;

namespace MediaPersistence.Functions.Repositories
{
    public class MediaRepository : IMediaRepository
    {
        private readonly ILogger _logger;
        private readonly IAuthenticationHelper _authenticationHelper;
        private readonly IBlobStorageHelper _blobStorageHelper;
        private readonly string _mediaDBEndpoint;

        public MediaRepository(ILogger logger, IAuthenticationHelper authenticationHelper, IBlobStorageHelper blobStorageHelper)
        {
            _logger = logger;
            _authenticationHelper = authenticationHelper;
            _blobStorageHelper = blobStorageHelper;
            _mediaDBEndpoint = Environment.GetEnvironmentVariable("MediaDBEndpoint");
        }

        [Obsolete("This method is obsolete. Use GetAsync(docId, command), instead.")]
        public async Task<byte[]> GetAsync(string docResourceId, string attachmentResourceId, string docId, UserRoleCommand command)
        {
            try
            {
                var mediaDoc = await GetDocumentAsync(docId).ConfigureAwait(false);
                
                if (!string.IsNullOrEmpty(mediaDoc.FileUrl))
                {
                    if (string.Equals(command?.ApplicationName, mediaDoc.Application, StringComparison.InvariantCultureIgnoreCase) &&
                        string.Equals(command?.ApplicationAreaName, mediaDoc.ApplicationArea, StringComparison.InvariantCultureIgnoreCase))
                    {
                        return await _blobStorageHelper.GetItemAsync(new Uri(mediaDoc.FileUrl)).ConfigureAwait(false);
                    }

                    return null;
                }

                var mediaDbKey = await _authenticationHelper.GetMediaDBAccessTokenAsync().ConfigureAwait(false);

                using(var storageClient = new DocumentClient(new Uri(_mediaDBEndpoint), mediaDbKey))
                {
                    var docUrl = UriFactory.CreateDocumentUri(Environment.GetEnvironmentVariable("MediaDbId"), Environment.GetEnvironmentVariable("MediaCollId"), docResourceId);
                    var doc = await storageClient.ReadDocumentAsync<MediaDoc>(docUrl,
                        new Microsoft.Azure.Documents.Client.RequestOptions
                        {
                            PartitionKey = new Microsoft.Azure.Documents.PartitionKey(docId)
                        }).ConfigureAwait(false);


                    if (string.Equals(command?.ApplicationName, doc.Document.Application, StringComparison.InvariantCultureIgnoreCase) &&
                        string.Equals(command?.ApplicationAreaName, doc.Document.ApplicationArea, StringComparison.InvariantCultureIgnoreCase))
                    {
                        var attachmentLink = UriFactory.CreateAttachmentUri(Environment.GetEnvironmentVariable("MediaDbId"),
                            Environment.GetEnvironmentVariable("MediaCollId"), docResourceId, attachmentResourceId);

                        var requestOptions = new Microsoft.Azure.Documents.Client.RequestOptions
                        {
                            PartitionKey = new Microsoft.Azure.Documents.PartitionKey(docId)
                        };

                        var attachment = await storageClient.ReadAttachmentAsync(attachmentLink, requestOptions).ConfigureAwait(false);

                        var mediaReponse = await storageClient.ReadMediaAsync(attachment.Resource.MediaLink).ConfigureAwait(false);

                        var image = mediaReponse.Media;
                        MemoryStream ms = new MemoryStream();
                        await image.CopyToAsync(ms).ConfigureAwait(false);
                        var response = ms.ToArray();

                        await UpdateToBlobAsync(mediaDbKey, 
                            Path.GetExtension(mediaReponse.Slug), 
                            mediaDoc, 
                            mediaReponse.Media).ConfigureAwait(false);

                        await storageClient.DeleteAttachmentAsync(attachmentLink, requestOptions).ConfigureAwait(false);
                
                        return response;
                    }

                    return null;
                }     
            }
            catch (Exception ex)
            {
                _logger.LogError(message: "Error", ex);
                return null;
            }
        }

        public async Task<byte[]> GetAsync(string docId, UserRoleCommand command)
        {
            try
            {
                var mediaDoc = await GetDocumentAsync(docId).ConfigureAwait(false);

                if (string.Equals(command?.ApplicationName, mediaDoc.Application, StringComparison.InvariantCultureIgnoreCase) &&
                    string.Equals(command?.ApplicationAreaName, mediaDoc.ApplicationArea, StringComparison.InvariantCultureIgnoreCase))
                {
                    return await _blobStorageHelper.GetItemAsync(new Uri(mediaDoc.FileUrl)).ConfigureAwait(false);
                }

                return null;
            }
            catch (Exception ex)
            {
                _logger.LogError(message: "Error", ex);
                return null;
            }
        }

        private async Task<MediaDoc> GetDocumentAsync(string docId)
        {
            var mediaDbKey = await _authenticationHelper.GetMediaDBAccessTokenAsync().ConfigureAwait(false);
            using (var client = new CosmosClient(_mediaDBEndpoint, mediaDbKey))
            {
                var container = GetContainer(client);

                var itemResponse = await container.ReadItemAsync<MediaDoc>(docId, new Microsoft.Azure.Cosmos.PartitionKey(docId)).ConfigureAwait(false);

                return itemResponse.Resource;
            }
        }

        public async Task<string> SaveAsync(MediaMetadata input, UserRoleCommand command)
        {
            var mediaDbKey = await _authenticationHelper.GetMediaDBAccessTokenAsync().ConfigureAwait(false);
            var docId = Guid.NewGuid();

            using (var stream = new MemoryStream())
            {
                input?.File.CopyTo(stream);

                stream.Position = 0;
                var fileName = $"{docId}{input?.FileExtension}";

                var url = await _blobStorageHelper.SaveAsync(fileName, stream).ConfigureAwait(false);

                var myDoc = new MediaDoc
                {
                    Id = docId.ToString(),
                    Application = command?.ApplicationName,
                    ApplicationArea = command?.ApplicationAreaName,
                    User = command?.UserPrincipalName,
                    DataClassification = "Internal",
                    FileUrl = url
                };

                using (var client = new CosmosClient(_mediaDBEndpoint, mediaDbKey))
                {
                    var container = GetContainer(client);
                    await container.CreateItemAsync(myDoc, new Microsoft.Azure.Cosmos.PartitionKey(myDoc.Id)).ConfigureAwait(false);
                }

                return $"RetrieveImage/{command?.ApplicationName}/{command?.ApplicationAreaName}/{docId}";
            }
        }

        private async Task UpdateToBlobAsync(string mediaDbKey, string fileExtension,  MediaDoc doc, Stream stream)
        {
            stream.Position = 0;
            var fileName = $"{doc.Id}{fileExtension}";

            var url = await _blobStorageHelper.SaveAsync(fileName, stream).ConfigureAwait(false);
            doc.FileUrl = url;

            using (var client = new CosmosClient(_mediaDBEndpoint, mediaDbKey))
            {
                var container = GetContainer(client);
                await container.UpsertItemAsync(doc, new Microsoft.Azure.Cosmos.PartitionKey(doc.Id)).ConfigureAwait(false);
            }
        }

        private static Container GetContainer(CosmosClient client)
        {
            return client.GetContainer(Environment.GetEnvironmentVariable("CosmosDatabaseName"), Environment.GetEnvironmentVariable("CosmosContainer"));
        }
    }
}
