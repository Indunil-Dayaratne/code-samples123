using BritServices.BearerTokenHelper.Models;
using EntrySheet.Api.Function.Handlers;
using EntrySheet.Api.Function.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Moq;
using System.Collections.Generic;
using System.Threading.Tasks;
using EntrySheet.Api.Function.Helpers;
using Xunit;

namespace EntrySheet.Api.Function.Tests.Handlers
{
    public class CurrencyHandlerTests
    {
        [Fact]
        public async Task GetCurrenciesAsync_Returns_UnAuthorized_Correctly()
        {
            // Arrange
            var mockLogger = new Mock<ILogger<CurrencyHandler>>();
            var mockHttpRequestHelper = new Mock<IHttpRequestHelper>();
            var mockCurrencyService = new Mock<ICurrencyService>();

            var mockResponse = Task.FromResult<(bool, AADUserDetail)>((false, null));
            mockHttpRequestHelper.Setup(x => x.AuthenticateRequestAsync(It.IsAny<HttpRequest>())).Returns(mockResponse);

            // Act
            var currencyHandler = new CurrencyHandler(mockLogger.Object, mockHttpRequestHelper.Object, mockCurrencyService.Object);
            var response = await currencyHandler.GetCurrenciesAsync(It.IsAny<HttpRequest>());

            // Assert
            Assert.IsType<UnauthorizedResult>(response);
        }

        [Fact]
        public async Task GetCurrenciesAsync_Returns_Correct_Currency_List()
        {
            // Arrange
            var mockLogger = new Mock<ILogger<CurrencyHandler>>();
            var mockHttpRequestHelper = new Mock<IHttpRequestHelper>();

            var mockResponse = Task.FromResult<(bool, AADUserDetail)>((true, null));
            mockHttpRequestHelper.Setup(x => x.AuthenticateRequestAsync(It.IsAny<HttpRequest>())).Returns(mockResponse);

            var mockCurrencyService = new Mock<ICurrencyService>();
            mockCurrencyService.Setup(x => x.GetCurrencyAsync()).Returns(Task.FromResult<List<string>>(new List<string>() {"GBP" }));

            // Act
            var currencyHandler = new CurrencyHandler(mockLogger.Object, mockHttpRequestHelper.Object, mockCurrencyService.Object);
            var response = await currencyHandler.GetCurrenciesAsync(It.IsAny<HttpRequest>());

            // Assert
            Assert.IsType<OkObjectResult>(response);
            var content = response as OkObjectResult;
            Assert.IsType<List<string>>(content.Value);
        }
    }
}
