using Autofac.Extras.Moq;
using FluentAssertions;
using FunctionAppHelper.Repository;
using FunctionAppHelper.Validators;
using MediaPersistence.Functions.Commands;
using MediaPersistence.Functions.Common;
using MediaPersistence.Functions.Entities;
using MediaPersistence.Functions.Helpers;
using MediaPersistence.Functions.Helpers.Interfaces;
using MediaPersistence.Functions.Repositories;
using MediaPersistence.UnitTests.Base.Helpers;
using MediaPersistence.UnitTests.Mock;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.Internal;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Diagnostics.CodeAnalysis;
using System.IO;

namespace MediaPersistence.UnitTests.Tests
{
    [TestClass]
    [ExcludeFromCodeCoverage]
    public class RepositoryTests
    {
        private ILogger _logger;
        private AutoMock _autoMock;
        private IMediaRepository _mediaRepository;

        [TestInitialize]
        public void Setup()
        {
            _logger = new LoggerFactory().CreateLogger("Test");
            _autoMock = AutoMock.GetLoose();
            _mediaRepository = new MediaRepository(_logger, _autoMock.Create<MockAuthenticationHelper>(), _autoMock.Create<MockBlobStorageHelper>());
            // add DI graph
            DIHelper.AddDependencies(_autoMock);
            Environment.SetEnvironmentVariable("MediaDBEndpoint", @"https://apps-common-cosmos-nonprod.documents.azure.com:443/");
            Environment.SetEnvironmentVariable("MediaDbId", "Tep0AA==");
            Environment.SetEnvironmentVariable("MediaCollId", "Tep0ANS+Skk=");
            Environment.SetEnvironmentVariable("audience", "https://media-persistence-func-dev.azurewebsites.net");
            Environment.SetEnvironmentVariable("AzureBlobStorageConnectionStringKey", "storage-conection-string");
            Environment.SetEnvironmentVariable("AzureBlobStorageContainer", "medpersfuncstoruksdev");
            Environment.SetEnvironmentVariable("CosmosDatabaseName", "shared");
            Environment.SetEnvironmentVariable("CosmosContainer", "media-container-dev");
        }

        private void AddExtraDIEntities<T>(AutoMock am) where T : IAuthenticationHelper
        {
            am.Provide<IAuthenticationHelper, T>();
            am.Provide<IFunctionRepository, FunctionRepository>();
            am.Provide<IMediaRepository, MediaRepository>();
            am.Provide<IKeyVaultHelper, MockKeyVaultHelper>();
            am.Provide<IFunctionRepository, MockFunctionRepository>();
            am.Provide<IBearerTokenValidator, MockBearerTokenValidator>();
        }

        [TestMethod]
        public void TestGetValidMedia()
        {
            using (var mock = _autoMock)
            {
                AddExtraDIEntities<MockAuthenticationHelper>(mock);
                Environment.SetEnvironmentVariable("AzureWebJobsStorage", "DefaultEndpointsProtocol=https;AccountName=medpersfuncstoruksdev;AccountKey=hwetBCzaKkuLeEk1GX1wEtXjECblKj1xpJIG+9Yi50m/AhCev0jF9/HrK9qysXkeqE4K1UNrQyFhcEWPMb6AOw==;EndpointSuffix=core.windows.net");
                UserRoleCommand command = new UserRoleCommand { ApplicationName = "Test", ApplicationAreaName = "UnitTests" };
                var result = _mediaRepository.GetAsync("Tep0ANS+SkkBAAAAAAAAAA==", "Tep0ANS+SkkBAAAAAAAAAMfye8o=", "e0b89bae-1c97-4e24-9d9c-ef16fe0e8ccc", command).Result;

                result.Should().NotBeNullOrEmpty();
                result.Should().BeAssignableTo<byte[]>();
            }
        }

        [TestMethod]
        public void TestGetInvalidMedia()
        {
            using (var mock = _autoMock)
            {
                AddExtraDIEntities<MockAuthenticationHelper>(mock);
                Environment.SetEnvironmentVariable("AzureWebJobsStorage", "DefaultEndpointsProtocol=https;AccountName=medpersfuncstoruksdev;AccountKey=hwetBCzaKkuLeEk1GX1wEtXjECblKj1xpJIG+9Yi50m/AhCev0jF9/HrK9qysXkeqE4K1UNrQyFhcEWPMb6AOw==;EndpointSuffix=core.windows.net");
                UserRoleCommand command = new UserRoleCommand { ApplicationName = "Britflow", ApplicationAreaName = "Query" };
                var result = _mediaRepository.GetAsync("documentLink","jpg.jpg.jpg", "docId", command).Result;

                result.Should().BeNull();
            }
        }

        [TestMethod]
        public void TestGetBlobValidMedia()
        {
            using (var mock = _autoMock)
            {
                AddExtraDIEntities<MockAuthenticationHelper>(mock);
                Environment.SetEnvironmentVariable("AzureWebJobsStorage", "DefaultEndpointsProtocol=https;AccountName=medpersfuncstoruksdev;AccountKey=hwetBCzaKkuLeEk1GX1wEtXjECblKj1xpJIG+9Yi50m/AhCev0jF9/HrK9qysXkeqE4K1UNrQyFhcEWPMb6AOw==;EndpointSuffix=core.windows.net");
                UserRoleCommand command = new UserRoleCommand { ApplicationName = "Test", ApplicationAreaName = "UnitTests" };
                var result = _mediaRepository.GetAsync("e0b89bae-1c97-4e24-9d9c-ef16fe0e8ccc", command).Result;

                result.Should().NotBeNullOrEmpty();
                result.Should().BeAssignableTo<byte[]>();
            }
        }

                [TestMethod]
        public void TestGetBlobInvalidMedia()
        {
            using (var mock = _autoMock)
            {
                AddExtraDIEntities<MockAuthenticationHelper>(mock);
                Environment.SetEnvironmentVariable("AzureWebJobsStorage", "DefaultEndpointsProtocol=https;AccountName=medpersfuncstoruksdev;AccountKey=hwetBCzaKkuLeEk1GX1wEtXjECblKj1xpJIG+9Yi50m/AhCev0jF9/HrK9qysXkeqE4K1UNrQyFhcEWPMb6AOw==;EndpointSuffix=core.windows.net");
                UserRoleCommand command = new UserRoleCommand { ApplicationName = "Britflow", ApplicationAreaName = "Query" };
                var result = _mediaRepository.GetAsync( "docId", command).Result;

                result.Should().BeNull();
            }
        }

        [TestMethod]
        public void TestSaveValidMedia()
        {
            using (var mock = _autoMock)
            {
                AddExtraDIEntities<MockAuthenticationHelper>(mock);
                Environment.SetEnvironmentVariable("AzureWebJobsStorage", "DefaultEndpointsProtocol=https;AccountName=medpersfuncstoruksdev;AccountKey=hwetBCzaKkuLeEk1GX1wEtXjECblKj1xpJIG+9Yi50m/AhCev0jF9/HrK9qysXkeqE4K1UNrQyFhcEWPMb6AOw==;EndpointSuffix=core.windows.net");
                UserRoleCommand command = new UserRoleCommand { ApplicationName = "Test", ApplicationAreaName = "UnitTests", UserPrincipalName = "test.user@britinsurance.com" };

                var rootDir = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);
              
                MemoryStream data = new MemoryStream();
                Stream str = File.OpenRead(rootDir + @"\D6Ntjj2W4AAyOed.jpg");
             
                str.CopyTo(data);
                data.Seek(0, SeekOrigin.Begin); 
                byte[] buf = new byte[data.Length];
                data.Read(buf, 0, buf.Length);

                MediaMetadata mediaMetadata = new MediaMetadata { 
                                                File = new FormFile(data, 0, data.Length, "Test.jpg", "Test.jpg"),
                                                FileExtension = Constants.IMAGE_FILENAME_EXTENSION_JPG,
                                                MimeType = Constants.IMAGE_MIME_TYPE_JPEG
                                               };

                var result = _mediaRepository.SaveAsync(mediaMetadata, command).Result;

                result.Should().NotBeNull();

            }
        }
    }
}
