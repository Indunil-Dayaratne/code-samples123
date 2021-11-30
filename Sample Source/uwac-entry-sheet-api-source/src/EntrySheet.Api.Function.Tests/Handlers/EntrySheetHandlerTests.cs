using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using BritServices.BearerTokenHelper.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Moq;
using System.Threading.Tasks;
using System.Web.Http;
using EntrySheet.Api.Function.Handlers;
using EntrySheet.Api.Function.Helpers;
using EntrySheet.Api.Function.Models;
using EntrySheet.Api.Function.Repositories;
using EntrySheet.Api.Function.Services;
using Newtonsoft.Json;
using Xunit;

namespace EntrySheet.Api.Function.Tests.Handlers
{
    public class EntrySheetHandlerTests
    {
        [Fact]
        public async Task GetEntrySheetDetailsAsync_Returns_UnAuthorized_Correctly()
        {
            // Arrange
            var mockLogger = new Mock<ILogger<EntrySheetHandler>>();
            var mockHttpRequestHelper = new Mock<IHttpRequestHelper>();
            var mockEntrySheetService = new Mock<IEntrySheetService>();
            var mockEntrySheetDetailsRepository = new Mock<IEntrySheetDetailsRepository>();

            var mockResponse = Task.FromResult<(bool, AADUserDetail)>((false, null));
            mockHttpRequestHelper.Setup(x => x.AuthenticateRequestAsync(It.IsAny<HttpRequest>())).Returns(mockResponse);

            // Act
            var entrySheetHandler = new EntrySheetHandler(mockLogger.Object, mockHttpRequestHelper.Object,
                mockEntrySheetService.Object, mockEntrySheetDetailsRepository.Object);
            var response = await entrySheetHandler.GetEntrySheetDetailsAsync(It.IsAny<HttpRequest>(), It.IsAny<int>());

            // Assert
            Assert.IsType<UnauthorizedResult>(response);
        }

        [Fact]
        public async Task GetEntrySheetDetailsAsync_Returns_NoContentResult_If_Theres_No_Data()
        {
            // Arrange
            var mockLogger = new Mock<ILogger<EntrySheetHandler>>();
            var mockHttpRequestHelper = new Mock<IHttpRequestHelper>();

            var mockResponse = Task.FromResult<(bool, AADUserDetail)>((true, null));
            mockHttpRequestHelper.Setup(x => x.AuthenticateRequestAsync(It.IsAny<HttpRequest>())).Returns(mockResponse);

            var mockEntrySheetService = new Mock<IEntrySheetService>();
            mockEntrySheetService.Setup(x => x.GetEntrySheetDetailsAsync(It.IsAny<int>()))
                .Returns(Task.FromResult<EntrySheetDetailsModel>(null));

            var mockEntrySheetDetailsRepository = new Mock<IEntrySheetDetailsRepository>();

            // Act
            var entrySheetHandler = new EntrySheetHandler(mockLogger.Object, mockHttpRequestHelper.Object,
                mockEntrySheetService.Object, mockEntrySheetDetailsRepository.Object);
            var response = await entrySheetHandler.GetEntrySheetDetailsAsync(It.IsAny<HttpRequest>(), It.IsAny<int>());

            // Assert
            Assert.IsType<NoContentResult>(response);
        }

        [Fact]
        public async Task GetEntrySheetDetailsAsync_Returns_Correct_PolicyRiskDetails_Object()
        {
            // Arrange
            var mockLogger = new Mock<ILogger<EntrySheetHandler>>();
            var mockHttpRequestHelper = new Mock<IHttpRequestHelper>();

            var mockResponse = Task.FromResult<(bool, AADUserDetail)>((true, null));
            mockHttpRequestHelper.Setup(x => x.AuthenticateRequestAsync(It.IsAny<HttpRequest>())).Returns(mockResponse);

            var mockEntrySheetService = new Mock<IEntrySheetService>();
            mockEntrySheetService.Setup(x => x.GetEntrySheetDetailsAsync(It.IsAny<int>()))
                .Returns(Task.FromResult<EntrySheetDetailsModel>(new EntrySheetDetailsModel()));

            var mockEntrySheetDetailsRepository = new Mock<IEntrySheetDetailsRepository>();

            // Act
            var entrySheetHandler = new EntrySheetHandler(mockLogger.Object, mockHttpRequestHelper.Object,
                mockEntrySheetService.Object, mockEntrySheetDetailsRepository.Object);
            var response = await entrySheetHandler.GetEntrySheetDetailsAsync(It.IsAny<HttpRequest>(), It.IsAny<int>());

            // Assert
            Assert.IsType<OkObjectResult>(response);
            var content = response as OkObjectResult;
            Assert.IsType<EntrySheetDetailsModel>(content.Value);
        }

        [Fact]
        public async Task SaveEntrySheetDetailsAsync_Returns_ExceptionResult_When_RequestBody_Is_Null()
        {
            // Arrange
            var mockLogger = new Mock<ILogger<EntrySheetHandler>>();
            var mockHttpRequestHelper = new Mock<IHttpRequestHelper>();
            var mockEntrySheetService = new Mock<IEntrySheetService>();
            var mockEntrySheetDetailsRepository = new Mock<IEntrySheetDetailsRepository>();

            var mockResponse = Task.FromResult<(bool, AADUserDetail)>((true, null));
            mockHttpRequestHelper.Setup(x => x.AuthenticateRequestAsync(It.IsAny<HttpRequest>())).Returns(mockResponse);

            // Act
            var entrySheetHandler = new EntrySheetHandler(mockLogger.Object, mockHttpRequestHelper.Object,
                mockEntrySheetService.Object, mockEntrySheetDetailsRepository.Object);
            var response = await entrySheetHandler.SaveEntrySheetDetailsAsync(It.IsAny<HttpRequest>());

            // Assert
            Assert.IsType<ExceptionResult>(response);
        }

        [Fact]
        public async Task SaveEntrySheetDetailsAsync_Returns_BadRequestResult_When_BritPolicyId_Is_Zero()
        {
            // Arrange
            var mockLogger = new Mock<ILogger<EntrySheetHandler>>();
            var mockHttpRequestHelper = new Mock<IHttpRequestHelper>();
            var mockEntrySheetService = new Mock<IEntrySheetService>();
            var mockEntrySheetDetailsRepository = new Mock<IEntrySheetDetailsRepository>();

            var mockResponse = Task.FromResult<(bool, AADUserDetail)>((true, null));
            mockHttpRequestHelper.Setup(x => x.AuthenticateRequestAsync(It.IsAny<HttpRequest>())).Returns(mockResponse);

            var entrySheetDetailsModel = new EntrySheetDetailsModel {LastUpdatedBy = "WREN\\ixdayaratne" };
            var httpRequest = new Mock<HttpRequest>();

            var json = JsonConvert.SerializeObject(entrySheetDetailsModel);
            var byteArray = Encoding.ASCII.GetBytes(json);
            httpRequest.Setup(x => x.Body).Returns(new MemoryStream(byteArray));

            // Act
            var entrySheetHandler = new EntrySheetHandler(mockLogger.Object, mockHttpRequestHelper.Object,
                mockEntrySheetService.Object, mockEntrySheetDetailsRepository.Object);
            var response = await entrySheetHandler.SaveEntrySheetDetailsAsync(httpRequest.Object);

            // Assert
            Assert.IsType<BadRequestResult>(response);
        }

        [Fact]
        public async Task SaveEntrySheetDetailsAsync_Returns_BadRequestResult_When_LastUpdatedBy_Is_Null()
        {
            // Arrange
            var mockLogger = new Mock<ILogger<EntrySheetHandler>>();
            var mockHttpRequestHelper = new Mock<IHttpRequestHelper>();
            var mockEntrySheetService = new Mock<IEntrySheetService>();
            var mockEntrySheetDetailsRepository = new Mock<IEntrySheetDetailsRepository>();

            var mockResponse = Task.FromResult<(bool, AADUserDetail)>((true, null));
            mockHttpRequestHelper.Setup(x => x.AuthenticateRequestAsync(It.IsAny<HttpRequest>())).Returns(mockResponse);

            var entrySheetDetailsModel = new EntrySheetDetailsModel {BritPolicyId = 1234};
            var httpRequest = new Mock<HttpRequest>();

            var json = JsonConvert.SerializeObject(entrySheetDetailsModel);
            var byteArray = Encoding.ASCII.GetBytes(json);
            httpRequest.Setup(x => x.Body).Returns(new MemoryStream(byteArray));

            // Act
            var entrySheetHandler = new EntrySheetHandler(mockLogger.Object, mockHttpRequestHelper.Object,
                mockEntrySheetService.Object, mockEntrySheetDetailsRepository.Object);
            var response = await entrySheetHandler.SaveEntrySheetDetailsAsync(httpRequest.Object);

            // Assert
            Assert.IsType<BadRequestResult>(response);
        }

        [Fact]
        public async Task SaveEntrySheetDetailsAsync_Returns_UnAuthorized_Correctly()
        {
            // Arrange
            var mockLogger = new Mock<ILogger<EntrySheetHandler>>();
            var mockHttpRequestHelper = new Mock<IHttpRequestHelper>();
            var mockEntrySheetService = new Mock<IEntrySheetService>();
            var mockEntrySheetDetailsRepository = new Mock<IEntrySheetDetailsRepository>();

            var mockResponse = Task.FromResult<(bool, AADUserDetail)>((false, null));
            mockHttpRequestHelper.Setup(x => x.AuthenticateRequestAsync(It.IsAny<HttpRequest>())).Returns(mockResponse);

            // Act
            var entrySheetHandler = new EntrySheetHandler(mockLogger.Object, mockHttpRequestHelper.Object,
                mockEntrySheetService.Object, mockEntrySheetDetailsRepository.Object);
            var response = await entrySheetHandler.SaveEntrySheetDetailsAsync(It.IsAny<HttpRequest>());

            // Assert
            Assert.IsType<UnauthorizedResult>(response);
        }

        [Fact]
        public async Task SaveEntrySheetDetailsAsync_Successfully_Persists_Model_Via_EntrySheetService()
        {
            // Arrange
            var mockLogger = new Mock<ILogger<EntrySheetHandler>>();
            var mockHttpRequestHelper = new Mock<IHttpRequestHelper>();
            var mockEntrySheetService = new Mock<IEntrySheetService>();
            var mockEntrySheetDetailsRepository = new Mock<IEntrySheetDetailsRepository>();

            var mockResponse = Task.FromResult<(bool, AADUserDetail)>((true, null));
            mockHttpRequestHelper.Setup(x => x.AuthenticateRequestAsync(It.IsAny<HttpRequest>())).Returns(mockResponse);

            var entrySheetDetailsModel = new EntrySheetDetailsModel { BritPolicyId = 1234, LastUpdatedBy = "WREN\\ixdayaratne"};
            var httpRequest = new Mock<HttpRequest>();

            var json = JsonConvert.SerializeObject(entrySheetDetailsModel);
            var byteArray = Encoding.ASCII.GetBytes(json);
            httpRequest.Setup(x => x.Body).Returns(new MemoryStream(byteArray));

            var mockSaveResponse = Task.FromResult(new SaveEntrySheetResponseModel {SavedEntrySheet = entrySheetDetailsModel});
            mockEntrySheetService.Setup(x => x.SaveEntrySheetDetailsAsync(It.IsAny<SaveEntrySheetRequestModel>())).Returns(mockSaveResponse);

            // Act
            var entrySheetHandler = new EntrySheetHandler(mockLogger.Object, mockHttpRequestHelper.Object,
                mockEntrySheetService.Object, mockEntrySheetDetailsRepository.Object);
            var response = await entrySheetHandler.SaveEntrySheetDetailsAsync(httpRequest.Object);

            // Assert
            Assert.IsType<OkObjectResult>(response);
            var content = response as OkObjectResult;
            Assert.IsType<SaveEntrySheetResponseModel>(content.Value);
        }

        [Fact]
        public async Task SaveEntrySheetDetailsAsync_Returns_ExceptionResult_When_Exception_Is_Thrown()
        {
            // Arrange
            var mockLogger = new Mock<ILogger<EntrySheetHandler>>();
            var mockHttpRequestHelper = new Mock<IHttpRequestHelper>();
            var mockEntrySheetService = new Mock<IEntrySheetService>();
            var mockEntrySheetDetailsRepository = new Mock<IEntrySheetDetailsRepository>();

            var mockResponse = Task.FromResult<(bool, AADUserDetail)>((true, null));
            mockHttpRequestHelper.Setup(x => x.AuthenticateRequestAsync(It.IsAny<HttpRequest>())).Returns(mockResponse);

            var entrySheetDetailsModel = new EntrySheetDetailsModel { BritPolicyId = 1234, LastUpdatedBy = "WREN\\ixdayaratne" };
            var httpRequest = new Mock<HttpRequest>();

            var json = JsonConvert.SerializeObject(entrySheetDetailsModel);
            var byteArray = Encoding.ASCII.GetBytes(json);
            httpRequest.Setup(x => x.Body).Returns(new MemoryStream(byteArray));

            mockEntrySheetService.Setup(x => x.SaveEntrySheetDetailsAsync(It.IsAny<SaveEntrySheetRequestModel>())).Throws(new Exception());

            // Act
            var entrySheetHandler = new EntrySheetHandler(mockLogger.Object, mockHttpRequestHelper.Object,
                mockEntrySheetService.Object, mockEntrySheetDetailsRepository.Object);
            var response = await entrySheetHandler.SaveEntrySheetDetailsAsync(httpRequest.Object);

            // Assert
            Assert.IsType<ExceptionResult>(response);
        }

        [Fact]
        public async Task GetEntrySheetsAsync_Returns_ExceptionResult_When_RequestBody_Is_Null()
        {
            // Arrange
            var mockLogger = new Mock<ILogger<EntrySheetHandler>>();
            var mockHttpRequestHelper = new Mock<IHttpRequestHelper>();
            var mockEntrySheetService = new Mock<IEntrySheetService>();
            var mockEntrySheetDetailsRepository = new Mock<IEntrySheetDetailsRepository>();

            var mockResponse = Task.FromResult<(bool, AADUserDetail)>((true, null));
            mockHttpRequestHelper.Setup(x => x.AuthenticateRequestAsync(It.IsAny<HttpRequest>())).Returns(mockResponse);

            // Act
            var entrySheetHandler = new EntrySheetHandler(mockLogger.Object, mockHttpRequestHelper.Object,
                mockEntrySheetService.Object, mockEntrySheetDetailsRepository.Object);
            var response = await entrySheetHandler.GetEntrySheetsAsync(It.IsAny<HttpRequest>());

            // Assert
            Assert.IsType<ExceptionResult>(response);
        }


        [Fact]
        public async Task GetEntrySheetsAsync_Returns_BadRequestResult_When_BritPolicyIds_Are_Empty()
        {
            // Arrange
            var mockLogger = new Mock<ILogger<EntrySheetHandler>>();
            var mockHttpRequestHelper = new Mock<IHttpRequestHelper>();
            var mockEntrySheetService = new Mock<IEntrySheetService>();
            var mockEntrySheetDetailsRepository = new Mock<IEntrySheetDetailsRepository>();

            var mockResponse = Task.FromResult<(bool, AADUserDetail)>((true, null));
            mockHttpRequestHelper.Setup(x => x.AuthenticateRequestAsync(It.IsAny<HttpRequest>())).Returns(mockResponse);

            var britPolicyIds = new int[0];
            var httpRequest = new Mock<HttpRequest>();

            var json = JsonConvert.SerializeObject(britPolicyIds);
            var byteArray = Encoding.ASCII.GetBytes(json);
            httpRequest.Setup(x => x.Body).Returns(new MemoryStream(byteArray));

            // Act
            var entrySheetHandler = new EntrySheetHandler(mockLogger.Object, mockHttpRequestHelper.Object,
                mockEntrySheetService.Object, mockEntrySheetDetailsRepository.Object);
            var response = await entrySheetHandler.GetEntrySheetsAsync(httpRequest.Object);

            // Assert
            Assert.IsType<BadRequestResult>(response);
        }

        [Fact]
        public async Task GetEntrySheetsAsync_Returns_UnAuthorized_Correctly()
        {
            // Arrange
            var mockLogger = new Mock<ILogger<EntrySheetHandler>>();
            var mockHttpRequestHelper = new Mock<IHttpRequestHelper>();
            var mockEntrySheetService = new Mock<IEntrySheetService>();
            var mockEntrySheetDetailsRepository = new Mock<IEntrySheetDetailsRepository>();

            var mockResponse = Task.FromResult<(bool, AADUserDetail)>((false, null));
            mockHttpRequestHelper.Setup(x => x.AuthenticateRequestAsync(It.IsAny<HttpRequest>())).Returns(mockResponse);

            // Act
            var entrySheetHandler = new EntrySheetHandler(mockLogger.Object, mockHttpRequestHelper.Object,
                mockEntrySheetService.Object, mockEntrySheetDetailsRepository.Object);
            var response = await entrySheetHandler.GetEntrySheetsAsync(It.IsAny<HttpRequest>());

            // Assert
            Assert.IsType<UnauthorizedResult>(response);
        }

        [Fact]
        public async Task GetEntrySheetsAsync_Returns_Data_Successfully_Via_EntrySheetDetailsRepository()
        {
            // Arrange
            var mockLogger = new Mock<ILogger<EntrySheetHandler>>();
            var mockHttpRequestHelper = new Mock<IHttpRequestHelper>();
            var mockEntrySheetService = new Mock<IEntrySheetService>();
            var mockEntrySheetDetailsRepository = new Mock<IEntrySheetDetailsRepository>();

            var mockResponse = Task.FromResult<(bool, AADUserDetail)>((true, null));
            mockHttpRequestHelper.Setup(x => x.AuthenticateRequestAsync(It.IsAny<HttpRequest>())).Returns(mockResponse);

            var britPolicyIds = new[] { 1234, 1258 };
            var httpRequest = new Mock<HttpRequest>();

            var json = JsonConvert.SerializeObject(britPolicyIds);
            var byteArray = Encoding.ASCII.GetBytes(json);
            httpRequest.Setup(x => x.Body).Returns(new MemoryStream(byteArray));

            var mockGetEntrySheetsResponse = Task.FromResult(new List<EntrySheetDetailsModel> {new EntrySheetDetailsModel {BritPolicyId = 1234}, new EntrySheetDetailsModel { BritPolicyId = 1258 } });
            mockEntrySheetDetailsRepository.Setup(x => x.GetLatestEntrySheetsAsync(It.IsAny<int[]>()))
                .Returns(mockGetEntrySheetsResponse);

            // Act
            var entrySheetHandler = new EntrySheetHandler(mockLogger.Object, mockHttpRequestHelper.Object,
                mockEntrySheetService.Object, mockEntrySheetDetailsRepository.Object);
            var response = await entrySheetHandler.GetEntrySheetsAsync(httpRequest.Object);

            // Assert
            Assert.IsType<OkObjectResult>(response);
            var content = response as OkObjectResult;
            Assert.IsType<List<EntrySheetDetailsModel>>(content.Value);
        }

        [Fact]
        public async Task GetEntrySheetsAsync_Returns_ExceptionResult_When_Exception_Is_Thrown()
        {
            // Arrange
            var mockLogger = new Mock<ILogger<EntrySheetHandler>>();
            var mockHttpRequestHelper = new Mock<IHttpRequestHelper>();
            var mockEntrySheetService = new Mock<IEntrySheetService>();
            var mockEntrySheetDetailsRepository = new Mock<IEntrySheetDetailsRepository>();

            var mockResponse = Task.FromResult<(bool, AADUserDetail)>((true, null));
            mockHttpRequestHelper.Setup(x => x.AuthenticateRequestAsync(It.IsAny<HttpRequest>())).Returns(mockResponse);

            var britPolicyIds = new[] { 1234, 1258 };
            var httpRequest = new Mock<HttpRequest>();

            var json = JsonConvert.SerializeObject(britPolicyIds);
            var byteArray = Encoding.ASCII.GetBytes(json);
            httpRequest.Setup(x => x.Body).Returns(new MemoryStream(byteArray));

            mockEntrySheetDetailsRepository.Setup(x => x.GetLatestEntrySheetsAsync(It.IsAny<int[]>()))
                .Throws<Exception>();

            // Act
            var entrySheetHandler = new EntrySheetHandler(mockLogger.Object, mockHttpRequestHelper.Object,
                mockEntrySheetService.Object, mockEntrySheetDetailsRepository.Object);
            var response = await entrySheetHandler.GetEntrySheetsAsync(httpRequest.Object);

            // Assert
            Assert.IsType<ExceptionResult>(response);
        }
    }
}
