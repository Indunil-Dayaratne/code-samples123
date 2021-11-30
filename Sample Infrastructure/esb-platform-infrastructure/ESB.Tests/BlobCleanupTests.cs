using ESB.Services;
using System;
using System.Collections.Generic;
using System.Text;
using Xunit;

namespace ESB.Tests
{
    public class BlobCleanupTests
    {
        [Fact]
        public async void RemoveExpiredBlobsTestAsync()
        {
            var logger = LoggerUtils.LoggerMock<BlobCleanup>();
            var storageSettings = AzureRepositoryTests.GetAzureStorageSettings();

            BlobCleanup cleanup = new BlobCleanup(logger.Object, storageSettings);
            await cleanup.RemoveExpiredBlobsAsync();
        }
    }
}
