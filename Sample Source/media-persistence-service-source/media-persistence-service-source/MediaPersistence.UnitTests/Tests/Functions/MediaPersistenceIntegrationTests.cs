using Autofac.Extras.Moq;
using FluentAssertions;
using FunctionAppHelper.Repository;
using FunctionAppHelper.Validators;
using MediaPersistence.Functions.Commands;
using MediaPersistence.Functions.Common;
using MediaPersistence.Functions.Entities;
using MediaPersistence.Functions.Helpers.Interfaces;
using MediaPersistence.Functions.Repositories;
using MediaPersistence.UnitTests.Base.Helpers;
using MediaPersistence.UnitTests.Mock;
using MediaPersistenceService;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.Internal;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using System.IO;
using System.Net.Http;
using System.Net.Http.Headers;

namespace MediaPersistence.UnitTests.Tests
{
    [TestClass]
    [ExcludeFromCodeCoverage]
    public class MediaPersistenceIntegrationTests
    {
        private ILogger _logger;
        private AutoMock _autoMock;
        private IMediaRepository _mediaRepository;
        
        [TestInitialize]
        public void Setup()
        {
            _logger = new LoggerFactory().CreateLogger("Test");
            _autoMock = AutoMock.GetLoose();
            _mediaRepository = new MediaRepository(_logger, _autoMock.Create<MockInvalidAuthenticationHelper>(), _autoMock.Create<MockBlobStorageHelper>());
            // add DI graph
            DIHelper.AddDependencies(_autoMock);
            Environment.SetEnvironmentVariable("AzureWebJobsStorage", "DefaultEndpointsProtocol=https;AccountName=medpersfuncstoruksdev;AccountKey=hwetBCzaKkuLeEk1GX1wEtXjECblKj1xpJIG+9Yi50m/AhCev0jF9/HrK9qysXkeqE4K1UNrQyFhcEWPMb6AOw==;EndpointSuffix=core.windows.net");
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

        private void AddExtraDIEntitiesWithBearerTokenValidator<T>(AutoMock am) where T : IBearerTokenValidator
        {
            am.Provide<IAuthenticationHelper, MockAuthenticationHelper>();
            am.Provide<IFunctionRepository, FunctionRepository>();
            am.Provide<IMediaRepository, MediaRepository>();
            am.Provide<IKeyVaultHelper, MockKeyVaultHelper>();
            am.Provide<IFunctionRepository, MockInvalidFunctionRepository>();
            am.Provide<IBearerTokenValidator, T>();
        }

        [TestMethod]
        public void TestGetMediaWithInvalidAccess()
        {
            using (var mock = _autoMock)
            {
                AddExtraDIEntities<MockInvalidAuthenticationHelper>(mock);
                var httpResult = MediaPersistenceService.MediaPersistenceFunctions.RunGetImageAsync(
                                    req: HttpTestHelper.CreateHttpRequest("GET", "http://localhost"),
                                    application: "Test",
                                    applicationArea: "UnitTests",
                                    docResourceLink: "TL1LAMvmjtQEAAAAAAAAAA==",
                                    attachmentResourceLink: "TL1LAMvmjtQEAAAAAAAAAJcutvc=",
                                    docId: "aaf4641f-7c75-4a57-aabf-d9fae34f3923",
                                    functionRepository: mock.Create<MockFunctionRepository>(),
                                    authenticationHelper: mock.Create<MockInvalidAuthenticationHelper>(),
                                    mediaRepository: mock.Create<MediaRepository>()
                                    ).Result;

                httpResult.Should().BeOfType<UnauthorizedResult>();

            }
        }


        [TestMethod]
        public void TestGetMediaWithInvalidBearerToken()
        {
            using (var mock = _autoMock)
            {
                AddExtraDIEntitiesWithBearerTokenValidator<MockInvalidBearerTokenValidator>(mock);
                var httpResult = MediaPersistenceService.MediaPersistenceFunctions.RunGetImageAsync(
                                    req: HttpTestHelper.CreateHttpRequest("GET", "http://localhost"),
                                    application: "Test",
                                    applicationArea: "UnitTests",
                                    docResourceLink: "TL1LAMvmjtQEAAAAAAAAAA==",
                                    attachmentResourceLink: "TL1LAMvmjtQEAAAAAAAAAJcutvc=",
                                    docId: "aaf4641f-7c75-4a57-aabf-d9fae34f3923",
                                    functionRepository: mock.Create<MockInvalidFunctionRepository>(),
                                    authenticationHelper: mock.Create<MockInvalidAuthenticationHelper>(),
                                    mediaRepository: mock.Create<MediaRepository>()
                                    ).Result;

                httpResult.Should().BeOfType<UnauthorizedResult>();

            }
        }

        [TestMethod]
        public void TestGetMediaWithValidMetadata()
        {
            using (var mock = _autoMock)
            {
                AddExtraDIEntities<MockAuthenticationHelper>(mock);
                var httpResult = MediaPersistenceService.MediaPersistenceFunctions.RunGetImageAsync(
                                    req: HttpTestHelper.CreateHttpRequest("GET", "http://localhost"),
                                    application: "Test",
                                    applicationArea: "UnitTests",
                                    docResourceLink: "Tep0ANS+SkkBAAAAAAAAAA==",
                                    attachmentResourceLink: "Tep0ANS+SkkBAAAAAAAAAMfye8o=",
                                    docId: "e0b89bae-1c97-4e24-9d9c-ef16fe0e8ccc",
                                    functionRepository: mock.Create<MockFunctionRepository>(),
                                    authenticationHelper: mock.Create<MockAuthenticationHelper>(),
                                    mediaRepository: mock.Create<MediaRepository>()
                                    ).Result;

                httpResult.Should().BeOfType<FileContentResult>();

            }
        }

        [TestMethod]
        public void TestGetMediaWithInvalidMetadata()
        {
            using (var mock = _autoMock)
            {
                AddExtraDIEntities<MockAuthenticationHelper>(mock);
                var httpResult = MediaPersistenceService.MediaPersistenceFunctions.RunGetImageAsync(
                                    req: HttpTestHelper.CreateHttpRequest("GET", "http://localhost"),
                                    application: "Blah",
                                    applicationArea: "BlahBlah",
                                    docResourceLink: "TL1LAMvmjtQEAAAAAAAAAA==",
                                    attachmentResourceLink: "TL1LAMvmjtQEAAAAAAAAAJcutvc=",
                                    docId: "aaf4641f-7c75-4a57-aabf-d9fae34f3923",
                                    functionRepository: mock.Create<MockFunctionRepository>(),
                                    authenticationHelper: mock.Create<MockAuthenticationHelper>(),
                                    mediaRepository: mock.Create<MediaRepository>()
                                    ).Result;

                httpResult.Should().BeOfType<UnauthorizedResult>();

            }
        }

        private FormCollection AddFileToFormCollection(string filename, string contentType)
        {
            var rootDir = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);

            MemoryStream data = new MemoryStream();
            Stream str = File.OpenRead(rootDir + filename);


            str.CopyTo(data);
            data.Seek(0, SeekOrigin.Begin);
            byte[] buf = new byte[data.Length];
            data.Read(buf, 0, buf.Length);

            var forms = new Dictionary<string, Microsoft.Extensions.Primitives.StringValues>();
            forms.Add("Form1", new Microsoft.Extensions.Primitives.StringValues("Form2"));

            var formFiles = new FormFileCollection();
            var file = new FormFile(data, 0, data.Length, filename, filename)
            {
                Headers = new HeaderDictionary(),
                ContentType = contentType
            };

            formFiles.Add(file);

            FormCollection col = new FormCollection(forms, formFiles);

            return col;
        }

        [TestMethod]
        public void TestSaveMediaWithInvalidAccess()
        {
            using (var mock = _autoMock)
            {
                AddExtraDIEntities<MockInvalidAuthenticationHelper>(mock);

                var col = AddFileToFormCollection(@"\D6Ntjj2W4AAyOed.jpg", Constants.IMAGE_MIME_TYPE_JPEG);

                var request = HttpTestHelper.CreateHttpRequest("POST", "http://localhost", null, null);

                request.Form = col;
                request.Path = new PathString(@"/api/MediaPersistenceService/v1/SaveImage");
                request.Headers.Add("Content-Type", new Microsoft.Extensions.Primitives.StringValues(Constants.IMAGE_MIME_TYPE_JPEG));

                var httpResult = MediaPersistenceService.MediaPersistenceFunctions.RunSaveImageAsync(
                                    req: request,
                                    application: "Test",
                                    applicationArea: "UnitTests",
                                    functionRepository: mock.Create<MockFunctionRepository>(),
                                    authenticationHelper: mock.Create<MockInvalidAuthenticationHelper>(),
                                    mediaRepository: mock.Create<MediaRepository>()
                                    ).Result;



                httpResult.Should().BeOfType<UnauthorizedResult>();
                
            }

        }

        [TestMethod]
        public void TestSaveMediaWithInvalidBearerToken()
        {
            using (var mock = _autoMock)
            {

                var col = AddFileToFormCollection(@"\D6Ntjj2W4AAyOed.jpg", Constants.IMAGE_MIME_TYPE_JPEG);

                var request = HttpTestHelper.CreateHttpRequest("POST", "http://localhost", null, null);

                request.Form = col;
                request.Path = new PathString(@"/api/MediaPersistenceService/v1/SaveImage");
                request.Headers.Add("Content-Type", new Microsoft.Extensions.Primitives.StringValues(Constants.IMAGE_MIME_TYPE_JPEG));

                var httpResult = MediaPersistenceService.MediaPersistenceFunctions.RunSaveImageAsync(
                                    req: request,
                                    application: "Test",
                                    applicationArea: "UnitTests",
                                    functionRepository: mock.Create<MockInvalidFunctionRepository>(),
                                    authenticationHelper: mock.Create<MockInvalidAuthenticationHelper>(),
                                    mediaRepository: mock.Create<MediaRepository>()
                                    ).Result;



                httpResult.Should().BeOfType<UnauthorizedResult>();

            }

        }

        [TestMethod]
        public void TestSaveValidMedia()
        {
            using (var mock = _autoMock)
            {
                AddExtraDIEntities<MockAuthenticationHelper>(mock);

                var col = AddFileToFormCollection(@"\D6Ntjj2W4AAyOed.jpg", Constants.IMAGE_MIME_TYPE_JPEG);

                var request = HttpTestHelper.CreateHttpRequest("POST", "http://localhost", null, null);

                request.Form = col;
                request.Path = new PathString(@"/api/MediaPersistenceService/v1/SaveImage");
                request.Headers.Add("Content-Type", new Microsoft.Extensions.Primitives.StringValues(Constants.IMAGE_MIME_TYPE_JPEG));
                var httpResult = MediaPersistenceService.MediaPersistenceFunctions.RunSaveImageAsync(
                                    req: request,
                                    application: "Test",
                                    applicationArea: "UnitTests",
                                    functionRepository: mock.Create<MockFunctionRepository>(),
                                    authenticationHelper: mock.Create<MockAuthenticationHelper>(),
                                    mediaRepository: mock.Create<MediaRepository>()
                                    ).Result;

                httpResult.Should().BeOfType<OkObjectResult>();
                var result = (httpResult as OkObjectResult).Value;
                ((Response_SaveMedia)result).link.Should().Subject.Should().Match(v => v.ToString().StartsWith("https://media-persistence-func", StringComparison.InvariantCultureIgnoreCase) 
                                                        && !v.ToString().EndsWith(".jpg", StringComparison.InvariantCultureIgnoreCase));
            }

        }

        [TestMethod]
        public void TestSaveInvalidMedia()
        {
            using (var mock = _autoMock)
            {
                AddExtraDIEntities<MockAuthenticationHelper>(mock);
                Environment.SetEnvironmentVariable("AzureWebJobsStorage", "DefaultEndpointsProtocol=https;AccountName=medpersfuncstoruksdev;AccountKey=hwetBCzaKkuLeEk1GX1wEtXjECblKj1xpJIG+9Yi50m/AhCev0jF9/HrK9qysXkeqE4K1UNrQyFhcEWPMb6AOw==;EndpointSuffix=core.windows.net");

                var col = AddFileToFormCollection(@"\Dummy.pdf", "application/pdf");

                var request = HttpTestHelper.CreateHttpRequest("POST", "http://localhost", null, null);

                request.Form = col;
                request.Path = new PathString(@"/api/MediaPersistenceService/v1/SaveImage");
                request.Headers.Add("Content-Type", new Microsoft.Extensions.Primitives.StringValues("application/pdf"));

                var httpResult = MediaPersistenceService.MediaPersistenceFunctions.RunSaveImageAsync(
                                    req: request,
                                    application: "Test",
                                    applicationArea: "UnitTests",
                                    functionRepository: mock.Create<MockFunctionRepository>(),
                                    authenticationHelper: mock.Create<MockAuthenticationHelper>(),
                                    mediaRepository: mock.Create<MediaRepository>()
                                    ).Result;



                httpResult.Should().BeOfType<UnauthorizedResult>();
                
            }

        }


        [TestMethod]
        public void TestGetBlobMediaWithInvalidAccess()
        {
            using (var mock = _autoMock)
            {
                AddExtraDIEntities<MockInvalidAuthenticationHelper>(mock);
                var httpResult = MediaPersistenceService.MediaPersistenceFunctions.GetBlobImageAsync(
                                    req: HttpTestHelper.CreateHttpRequest("GET", "http://localhost"),
                                    application: "Test",
                                    applicationArea: "UnitTests",
                                    docId: "aaf4641f-7c75-4a57-aabf-d9fae34f3923",
                                    functionRepository: mock.Create<MockFunctionRepository>(),
                                    authenticationHelper: mock.Create<MockInvalidAuthenticationHelper>(),
                                    mediaRepository: mock.Create<MediaRepository>()
                                    ).Result;

                httpResult.Should().BeOfType<UnauthorizedResult>();

            }
        }


        [TestMethod]
        public void TestGetBlobMediaWithInvalidBearerToken()
        {
            using (var mock = _autoMock)
            {
                AddExtraDIEntitiesWithBearerTokenValidator<MockInvalidBearerTokenValidator>(mock);
                var httpResult = MediaPersistenceService.MediaPersistenceFunctions.GetBlobImageAsync(
                                    req: HttpTestHelper.CreateHttpRequest("GET", "http://localhost"),
                                    application: "Test",
                                    applicationArea: "UnitTests",
                                    docId: "aaf4641f-7c75-4a57-aabf-d9fae34f3923",
                                    functionRepository: mock.Create<MockInvalidFunctionRepository>(),
                                    authenticationHelper: mock.Create<MockInvalidAuthenticationHelper>(),
                                    mediaRepository: mock.Create<MediaRepository>()
                                    ).Result;

                httpResult.Should().BeOfType<UnauthorizedResult>();

            }
        }

        [TestMethod]
        public void TestGetBlobMediaWithValidMetadata()
        {
            using (var mock = _autoMock)
            {
                AddExtraDIEntities<MockAuthenticationHelper>(mock);
                var httpResult = MediaPersistenceService.MediaPersistenceFunctions.GetBlobImageAsync(
                                    req: HttpTestHelper.CreateHttpRequest("GET", "http://localhost"),
                                    application: "Test",
                                    applicationArea: "UnitTests",
                                    docId: "e0b89bae-1c97-4e24-9d9c-ef16fe0e8ccc",
                                    functionRepository: mock.Create<MockFunctionRepository>(),
                                    authenticationHelper: mock.Create<MockAuthenticationHelper>(),
                                    mediaRepository: mock.Create<MediaRepository>()
                                    ).Result;

                httpResult.Should().BeOfType<FileContentResult>();

            }
        }

        [TestMethod]
        public void TestGetBlobMediaWithInvalidMetadata()
        {
            using (var mock = _autoMock)
            {
                AddExtraDIEntities<MockAuthenticationHelper>(mock);
                var httpResult = MediaPersistenceService.MediaPersistenceFunctions.GetBlobImageAsync(
                                    req: HttpTestHelper.CreateHttpRequest("GET", "http://localhost"),
                                    application: "Blah",
                                    applicationArea: "BlahBlah",
                                    docId: "aaf4641f-7c75-4a57-aabf-d9fae34f3923",
                                    functionRepository: mock.Create<MockFunctionRepository>(),
                                    authenticationHelper: mock.Create<MockAuthenticationHelper>(),
                                    mediaRepository: mock.Create<MediaRepository>()
                                    ).Result;

                httpResult.Should().BeOfType<UnauthorizedResult>();

            }
        }
    }
}
