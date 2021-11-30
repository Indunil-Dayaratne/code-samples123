using BritServices.BearerTokenHelper.Models;
using EntrySheet.Api.Function.Handlers;
using EntrySheet.Api.Function.Helpers;
using EntrySheet.Api.Function.Models;
using EntrySheet.Api.Function.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Moq;
using System.Collections.Generic;
using System.Threading.Tasks;
using Xunit;

namespace EntrySheet.Api.Function.Tests.Handlers
{
    public class IndustryCodeHandlerTests
    {
        [Fact]
        public async Task GetIndustryCodesAsyncc_Returns_UnAuthorized_Correctly()
        {
            // Arrange
            var mockLogger = new Mock<ILogger<IndustryCodeHandler>>();
            var mockHttpRequestHelper = new Mock<IHttpRequestHelper>();
            var mockIndustrycodeservice = new Mock<IIndustryCodeService>();

            var mockResponse = Task.FromResult<(bool, AADUserDetail)>((false, null));
            mockHttpRequestHelper.Setup(x => x.AuthenticateRequestAsync(It.IsAny<HttpRequest>())).Returns(mockResponse);

            // Act
            var industryCodesHandler = new IndustryCodeHandler(mockLogger.Object, mockHttpRequestHelper.Object, mockIndustrycodeservice.Object);
            var response = await industryCodesHandler.GetIndustryCodesAsync(It.IsAny<HttpRequest>());

            // Assert
            Assert.IsType<UnauthorizedResult>(response);
        }

        [Fact]
        public async Task GetIndustryCodesAsyncc_Returns_Correct_Currency_List()
        {
            // Arrange
            var mockLogger = new Mock<ILogger<IndustryCodeHandler>>();
            var mockHttpRequestHelper = new Mock<IHttpRequestHelper>();

            var mockResponse = Task.FromResult<(bool, AADUserDetail)>((true, null));
            mockHttpRequestHelper.Setup(x => x.AuthenticateRequestAsync(It.IsAny<HttpRequest>())).Returns(mockResponse);

            var mockIndustrycodeservice = new Mock<IIndustryCodeService>();
            mockIndustrycodeservice.Setup(x => x.GetIndustryCodesAsync()).Returns(Task.FromResult<IEnumerable<IndustryCodeModel>>
                (new List<IndustryCodeModel>() { new IndustryCodeModel() }));

            // Act
            var industryCodesHandler = new IndustryCodeHandler(mockLogger.Object, mockHttpRequestHelper.Object, mockIndustrycodeservice.Object);
            var response = await industryCodesHandler.GetIndustryCodesAsync(It.IsAny<HttpRequest>());

            // Assert
            Assert.IsType<OkObjectResult>(response);
        }
    }
}
