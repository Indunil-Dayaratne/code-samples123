using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace ESB.Tests
{
    public class BlobReader
    {
        public static CloudBlockBlob GetBlob(string containerName, string blobName, string SASToken)
        {
            var storageAccount = CloudStorageAccount.Parse(AzureRepositoryTests.StorageConnectionString);
            Uri uri = new Uri(storageAccount.BlobEndpoint, $"{containerName}/{blobName}{SASToken}");
            CloudBlockBlob blob = new CloudBlockBlob(uri);
            return blob;
        }

        public static CloudBlockBlob GetBlob(string containerName, string blobName)
        {
            var storageAccount = CloudStorageAccount.Parse(AzureRepositoryTests.StorageConnectionString);
            Uri uri = new Uri(storageAccount.BlobEndpoint, $"{containerName}/{blobName}");
            CloudBlockBlob blob = new CloudBlockBlob(uri, storageAccount.Credentials);
            return blob;
        }

    }
}
