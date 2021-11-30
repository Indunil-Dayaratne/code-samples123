using Autofac.Extras.Moq;
using FluentAssertions;
using MediaPersistence.Functions.Helpers;
using MediaPersistence.Functions.Helpers.Interfaces;
using MediaPersistence.UnitTests.Base.Helpers;
using MediaPersistence.UnitTests.Mock;
using Microsoft.Extensions.Logging;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Moq;
using System;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using System.IO;
using System.Text;
using System.Threading.Tasks;

namespace MediaPersistence.UnitTests.Tests.Helpers
{
    [TestClass]
    [ExcludeFromCodeCoverage]
    public class BlobStorageHelperTests
    {
        private Mock<IKeyVaultHelper> _keyVaultMock;
        private IBlobStorageHelper _blobStorageHelper;

        [TestInitialize]
        public void Setup()
        {
            _keyVaultMock = new Mock<IKeyVaultHelper>();
            _keyVaultMock
                .Setup(x => x.GetKeyVaultValueAsync(It.IsAny<string>()))
                .Returns(Task.FromResult("DefaultEndpointsProtocol=https;AccountName=medpersfuncstoruksdev;AccountKey=JRoZG21zXmk2PXCf+Oo1uP7s2xCGSKjA/FsfiUVYFGgc+HfKmtTCI8Kgm4zjwvXzgrLw4NkHr25f/fQvKhtmQA==;EndpointSuffix=core.windows.net"));
            
            Environment.SetEnvironmentVariable("AzureBlobStorageConnectionStringKey", "storage-conection-string");
            Environment.SetEnvironmentVariable("AzureBlobStorageContainer", "medperscontainuksdev");

            _blobStorageHelper = new BlobStorageHelper(_keyVaultMock.Object);  
        }

        [TestMethod]     
        public async Task TestGetItem()
        {
            var result = await _blobStorageHelper.GetItemAsync(new Uri("https://medpersfuncstoruksdev.blob.core.windows.net/medperscontainuksdev/unit-test/D6Ntjj2W4AAyOed.jpg")).ConfigureAwait(false);

            result.Should().NotBeNull();
            result.Should().BeOfType<byte[]>();
        }

        [TestMethod]
        public async Task TestSave()
        {
            using (var stream = new MemoryStream(Encoding.UTF8.GetBytes("fakeContents")))
            {                
                var result = await _blobStorageHelper.SaveAsync("unit-test/fakeBlobReference.txt", stream).ConfigureAwait(false);

                result.Should().NotBeNull();
                result.Should().BeOfType<string>();
            }
        }
    }
}
