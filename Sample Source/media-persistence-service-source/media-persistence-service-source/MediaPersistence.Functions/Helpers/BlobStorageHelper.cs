using MediaPersistence.Functions.Helpers.Interfaces;
using Microsoft.WindowsAzure.Storage;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Threading.Tasks;

namespace MediaPersistence.Functions.Helpers
{
    public class BlobStorageHelper : IBlobStorageHelper
    {
        private readonly IKeyVaultHelper _keyVault;
        private readonly string _connectionStringKey;
        private readonly string _container;

        public BlobStorageHelper(IKeyVaultHelper keyVault)
        {
            _keyVault = keyVault;
            _connectionStringKey = Environment.GetEnvironmentVariable("AzureBlobStorageConnectionStringKey");
            _container = Environment.GetEnvironmentVariable("AzureBlobStorageContainer");
        }

        public async Task<byte[]> GetItemAsync(Uri blobUri)
        {
            var connectionString = await _keyVault.GetKeyVaultValueAsync(_connectionStringKey).ConfigureAwait(false);

            var storageAccountDetails = CloudStorageAccount.Parse(connectionString);
            var blobClient = storageAccountDetails.CreateCloudBlobClient();
            var blob = await blobClient.GetBlobReferenceFromServerAsync(blobUri).ConfigureAwait(false);

            using (var stream = new MemoryStream())
            {   
                await blob.DownloadToStreamAsync(stream).ConfigureAwait(false);
                return stream.ToArray();
            }
        }

        public async Task<string> SaveAsync(string blobReference, Stream stream)
        {
            var connectionString = await _keyVault.GetKeyVaultValueAsync(_connectionStringKey).ConfigureAwait(false);

            var storageAccountDetails = CloudStorageAccount.Parse(connectionString);
            var blobClient = storageAccountDetails.CreateCloudBlobClient();
            var blobContainer = blobClient.GetContainerReference(_container);

            var blockBlob = blobContainer.GetBlockBlobReference(blobReference);

            await blockBlob.UploadFromStreamAsync(stream).ConfigureAwait(false);
            
            return blockBlob.Uri.ToString();
        }
    }
}
