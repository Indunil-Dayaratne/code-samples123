using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using System.Web.Http;
using Brit.Risk.Entities;
using BritServices.BearerTokenHelper.Models;
using EntrySheet.Api.Function.Handlers;
using EntrySheet.Api.Function.Helpers;
using EntrySheet.Api.Function.Hydration;
using EntrySheet.Api.Function.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Moq;
using Newtonsoft.Json;
using Xunit;

namespace EntrySheet.Api.Function.Tests.Handlers
{
    public class GpmGenerationHandlerTests
    {
        [Fact]
        public async Task GenerateGpmDetailsAsync_Returns_ExceptionResult_When_RequestBody_Is_Null()
        {
            // Arrange
            var mockLogger = new Mock<ILogger<GpmGenerationHandler>>();
            var mockHttpRequestHelper = new Mock<IHttpRequestHelper>();
            var mockPlacingHydrator = new Mock<IPlacingHydrator>();

            var mockResponse = Task.FromResult<(bool, AADUserDetail)>((true, null));
            mockHttpRequestHelper.Setup(x => x.AuthenticateRequestAsync(It.IsAny<HttpRequest>())).Returns(mockResponse);

            // Act
            var gpmGenerationHandler = new GpmGenerationHandler(mockLogger.Object,
                mockPlacingHydrator.Object, mockHttpRequestHelper.Object);
            var response = await gpmGenerationHandler.GenerateGpmDetailsAsync(It.IsAny<HttpRequest>());

            // Assert
            Assert.IsType<ExceptionResult>(response);
        }

        [Fact]
        public async Task GenerateGpmDetailsAsync_Returns_UnAuthorized_Correctly()
        {
            // Arrange
            var mockLogger = new Mock<ILogger<GpmGenerationHandler>>();
            var mockHttpRequestHelper = new Mock<IHttpRequestHelper>();
            var mockPlacingHydrator = new Mock<IPlacingHydrator>();

            var mockResponse = Task.FromResult<(bool, AADUserDetail)>((false, null));
            mockHttpRequestHelper.Setup(x => x.AuthenticateRequestAsync(It.IsAny<HttpRequest>())).Returns(mockResponse);

            // Act
            var gpmGenerationHandler = new GpmGenerationHandler(mockLogger.Object,
                mockPlacingHydrator.Object, mockHttpRequestHelper.Object);
            var response = await gpmGenerationHandler.GenerateGpmDetailsAsync(It.IsAny<HttpRequest>());

            // Assert
            Assert.IsType<UnauthorizedResult>(response);
        }

        [Fact]
        public async Task GenerateGpmDetailsAsync_Returns_ExceptionResult_When_Exception_Is_Thrown()
        {
            // Arrange
            var mockLogger = new Mock<ILogger<GpmGenerationHandler>>();
            var mockHttpRequestHelper = new Mock<IHttpRequestHelper>();
            var mockPlacingHydrator = new Mock<IPlacingHydrator>();

            var mockResponse = Task.FromResult<(bool, AADUserDetail)>((true, null));
            mockHttpRequestHelper.Setup(x => x.AuthenticateRequestAsync(It.IsAny<HttpRequest>())).Returns(mockResponse);

            var entrySheetDetailsModel = new EntrySheetDetailsModel { BritPolicyId = 1234, LastUpdatedBy = "WREN\\ixdayaratne" };
            var httpRequest = new Mock<HttpRequest>();

            var json = JsonConvert.SerializeObject(entrySheetDetailsModel);
            var byteArray = Encoding.ASCII.GetBytes(json);
            httpRequest.Setup(x => x.Body).Returns(new MemoryStream(byteArray));

            mockPlacingHydrator.Setup(x => x.Execute(It.IsAny<EntrySheetDetailsModel>(), It.IsAny<string>())).Throws<Exception>();

            // Act
            var gpmGenerationHandler = new GpmGenerationHandler(mockLogger.Object,
                mockPlacingHydrator.Object, mockHttpRequestHelper.Object);
            var response = await gpmGenerationHandler.GenerateGpmDetailsAsync(httpRequest.Object);

            // Assert
            Assert.IsType<ExceptionResult>(response);
        }

        [Fact]
        public async Task GenerateGpmDetailsAsync_Returns_BadRequestResult_When_EntrySheetDetailsModel_Is_Null()
        {
            // Arrange
            var mockLogger = new Mock<ILogger<GpmGenerationHandler>>();
            var mockHttpRequestHelper = new Mock<IHttpRequestHelper>();
            var mockPlacingHydrator = new Mock<IPlacingHydrator>();

            var mockResponse = Task.FromResult<(bool, AADUserDetail)>((true, null));
            mockHttpRequestHelper.Setup(x => x.AuthenticateRequestAsync(It.IsAny<HttpRequest>())).Returns(mockResponse);

            var httpRequest = new Mock<HttpRequest>();

            var byteArray = Encoding.ASCII.GetBytes(string.Empty);
            httpRequest.Setup(x => x.Body).Returns(new MemoryStream(byteArray));

            // Act
            var gpmGenerationHandler = new GpmGenerationHandler(mockLogger.Object,
                mockPlacingHydrator.Object, mockHttpRequestHelper.Object);
            var response = await gpmGenerationHandler.GenerateGpmDetailsAsync(httpRequest.Object);

            // Assert
            Assert.IsType<BadRequestResult>(response);
        }

        [Fact]
        public async Task GenerateGpmDetailsAsync_Returns_Returns_PlacingDetails_For_Valid_EntrySheetDetailsModel()
        {
            // Arrange
            var mockLogger = new Mock<ILogger<GpmGenerationHandler>>();
            var mockHttpRequestHelper = new Mock<IHttpRequestHelper>();
            var mockPlacingHydrator = new Mock<IPlacingHydrator>();

            var mockResponse = Task.FromResult<(bool, AADUserDetail)>((true, null));
            mockHttpRequestHelper.Setup(x => x.AuthenticateRequestAsync(It.IsAny<HttpRequest>())).Returns(mockResponse);

            var entrySheetDetailsModel = new EntrySheetDetailsModel { BritPolicyId = 1234, LastUpdatedBy = "WREN\\ixdayaratne" };
            var httpRequest = new Mock<HttpRequest>();

            var json = JsonConvert.SerializeObject(entrySheetDetailsModel);
            var byteArray = Encoding.ASCII.GetBytes(json);
            httpRequest.Setup(x => x.Body).Returns(new MemoryStream(byteArray));

            mockPlacingHydrator.Setup(x => x.Execute(It.IsAny<EntrySheetDetailsModel>(), It.IsAny<string>()))
                .Returns(new List<Placing> {new Placing()});

            // Act
            var gpmGenerationHandler = new GpmGenerationHandler(mockLogger.Object,
                mockPlacingHydrator.Object, mockHttpRequestHelper.Object);
            var response = await gpmGenerationHandler.GenerateGpmDetailsAsync(httpRequest.Object);

            // Assert
            Assert.IsType<OkObjectResult>(response);
            var content = response as OkObjectResult;
            Assert.IsType<List<Placing>>(content.Value);

        }
    }
}