using BritServices.BearerTokenHelper.Models;
using EntrySheet.Api.Function.Handlers;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Moq;
using System.Collections.Generic;
using System.Threading.Tasks;
using EntrySheet.Api.Function.Helpers;
using EntrySheet.Api.Function.Services;
using Xunit;

namespace EntrySheet.Api.Function.Tests.Handlers
{
    public class EPlacingHandlerTests
    {
        [Fact]
        public async Task GetEPlacingAsync_Returns_UnAuthorized_Correctly()
        {
            // Arrange
            var mockLogger = new Mock<ILogger<EPlacingHandler>>();
            var mockHttpRequestHelper = new Mock<IHttpRequestHelper>();
            var mockEPlacingService = new Mock<IEPlacingService>();

            var mockResponse = Task.FromResult<(bool, AADUserDetail)>((false, null));
            mockHttpRequestHelper.Setup(x => x.AuthenticateRequestAsync(It.IsAny<HttpRequest>())).Returns(mockResponse);

            // Act
            var ePlacingHandler = new EPlacingHandler(mockLogger.Object, mockHttpRequestHelper.Object, mockEPlacingService.Object);
            var response = await ePlacingHandler.GetEPlacingAsync(It.IsAny<HttpRequest>());

            // Assert
            Assert.IsType<UnauthorizedResult>(response);
        }

        [Fact]
        public async Task GetEPlacingAsync_Returns_Correct_Currency_List()
        {
            // Arrange
            var mockLogger = new Mock<ILogger<EPlacingHandler>>();
            var mockHttpRequestHelper = new Mock<IHttpRequestHelper>();

            var mockResponse = Task.FromResult<(bool, AADUserDetail)>((true, null));
            mockHttpRequestHelper.Setup(x => x.AuthenticateRequestAsync(It.IsAny<HttpRequest>())).Returns(mockResponse);

            var mockEPlacingService = new Mock<IEPlacingService>();
            mockEPlacingService.Setup(x => x.GetEPlacingValuesAsync()).Returns(Task.FromResult<IEnumerable<string>>(new List<string>() { "Placing" }));

            // Act
            var ePlacingHandler = new EPlacingHandler(mockLogger.Object, mockHttpRequestHelper.Object, mockEPlacingService.Object);
            var response = await ePlacingHandler.GetEPlacingAsync(It.IsAny<HttpRequest>());

            // Assert
            Assert.IsType<OkObjectResult>(response);
            var content = response as OkObjectResult;
            Assert.IsType<List<string>>(content.Value);
        }
    }
}
