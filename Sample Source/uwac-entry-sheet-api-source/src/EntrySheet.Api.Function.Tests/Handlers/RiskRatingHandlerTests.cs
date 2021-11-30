using System.Collections.Generic;
using System.Threading.Tasks;
using BritServices.BearerTokenHelper.Models;
using EntrySheet.Api.Function.Handlers;
using EntrySheet.Api.Function.Helpers;
using EntrySheet.Api.Function.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Moq;
using Xunit;

namespace EntrySheet.Api.Function.Tests.Handlers
{
    public class RiskRatingHandlerTests
    {
        [Fact]
        public async Task GetRiskRatingsAsync_Returns_UnAuthorized_Correctly()
        {
            // Arrange
            var mockLogger = new Mock<ILogger<RiskRatingHandler>>();
            var mockHttpRequestHelper = new Mock<IHttpRequestHelper>();
            var mockRiskRatingService = new Mock<IRiskRatingService>();

            var mockResponse = Task.FromResult<(bool, AADUserDetail)>((false, null));
            mockHttpRequestHelper.Setup(x => x.AuthenticateRequestAsync(It.IsAny<HttpRequest>())).Returns(mockResponse);

            // Act
            var riskRatingHandler = new RiskRatingHandler(mockLogger.Object, mockHttpRequestHelper.Object, mockRiskRatingService.Object);
            var response = await riskRatingHandler.GetRiskRatingsAsync(It.IsAny<HttpRequest>());

            // Assert
            Assert.IsType<UnauthorizedResult>(response);
        }

        [Fact]
        public async Task GetRiskRatingsAsync_Returns_RiskRatings_List()
        {
            // Arrange
            var mockLogger = new Mock<ILogger<RiskRatingHandler>>();
            var mockHttpRequestHelper = new Mock<IHttpRequestHelper>();

            var mockResponse = Task.FromResult<(bool, AADUserDetail)>((true, null));
            mockHttpRequestHelper.Setup(x => x.AuthenticateRequestAsync(It.IsAny<HttpRequest>())).Returns(mockResponse);

            var mockRiskRatingService = new Mock<IRiskRatingService>();
            mockRiskRatingService.Setup(x => x.GetRiskRatings()).Returns(new List<string> { "A", "B" });

            // Act
            var riskRatingHandler = new RiskRatingHandler(mockLogger.Object, mockHttpRequestHelper.Object, mockRiskRatingService.Object);
            var response = await riskRatingHandler.GetRiskRatingsAsync(It.IsAny<HttpRequest>());

            // Assert
            Assert.IsType<OkObjectResult>(response);
            var content = response as OkObjectResult;
            Assert.IsType<List<string>>(content.Value);
        }
    }
}