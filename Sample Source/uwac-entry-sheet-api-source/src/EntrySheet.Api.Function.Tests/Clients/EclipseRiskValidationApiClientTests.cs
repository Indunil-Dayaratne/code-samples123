using System;
using System.Net;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using Brit.Risk.Entities;
using EntrySheet.Api.Function.Clients;
using EntrySheet.Api.Function.Helpers;
using EntrySheet.Api.Function.Models;
using EntrySheet.Api.Function.Settings;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Moq;
using Moq.Protected;
using System.Text.Json;
using Xunit;

namespace EntrySheet.Api.Function.Tests.Clients
{
    public class EclipseRiskValidationApiClientTests
    {
        private readonly Mock<ILogger<EclipseRiskValidationApiClient>> _mockLogger;
        private readonly IOptions<EclipseRiskValidationApiOptions> _eclipseRiskValidationApiOptions;
        private readonly Mock<IHttpClientFactory> _mockHttpClientFactory;
        private readonly Mock<ITokenServiceHelper> _mockTokenServiceHelper;

        public EclipseRiskValidationApiClientTests()
        {
            _mockLogger = new Mock<ILogger<EclipseRiskValidationApiClient>>();
            _mockHttpClientFactory = new Mock<IHttpClientFactory>();
            _mockTokenServiceHelper = new Mock<ITokenServiceHelper>();

            Environment.SetEnvironmentVariable("tenantid", "8cee18df-5e2a-4664-8d07-0566ffea6dcd");

            _eclipseRiskValidationApiOptions = Options.Create(new EclipseRiskValidationApiOptions
            {
                AzureConnectionString = "RunAs=App;AppId=21ae1f9b-acfa-4436-a6f5-6e41d2eaf0a7;TenantId=8cee18df-5e2a-4664-8d07-0566ffea6dcd;AppKey=tuqy0.g-B-4cEhOphpHg3W5Sf~BlwN27jc",
                BaseUrl = "https://eclipse-risk-validator-func-uks-dev.azurewebsites.net",
                ClientId = "21ae1f9b-acfa-4436-a6f5-6e41d2eaf0a7",
            });
        }

        [Fact]
        public async Task ValidateGpmDetailsAsync_Throws_Exception_When_Placing_IsNull()
        {
            var mockHttpMessageHandler = new Mock<HttpMessageHandler>();

            var client = new HttpClient(mockHttpMessageHandler.Object);

            _mockHttpClientFactory.Setup(x => x.CreateClient(It.IsAny<string>())).Returns(client);

            var eclipseRiskValidationApiClient = new EclipseRiskValidationApiClient(_mockLogger.Object, _mockTokenServiceHelper.Object, _eclipseRiskValidationApiOptions, _mockHttpClientFactory.Object);

            await Assert.ThrowsAsync<ArgumentNullException>(() => eclipseRiskValidationApiClient.ValidateGpmDetailsAsync(null, "1234"));
        }

        [Fact]
        public async Task ValidateGpmDetailsAsync_Throws_Exception_When_PolicyReference_IsNull()
        {
            var mockHttpMessageHandler = new Mock<HttpMessageHandler>();

            var client = new HttpClient(mockHttpMessageHandler.Object);

            _mockHttpClientFactory.Setup(x => x.CreateClient(It.IsAny<string>())).Returns(client);

            var eclipseRiskValidationApiClient = new EclipseRiskValidationApiClient(_mockLogger.Object, _mockTokenServiceHelper.Object, _eclipseRiskValidationApiOptions, _mockHttpClientFactory.Object);

            await Assert.ThrowsAsync<ArgumentNullException>(() => eclipseRiskValidationApiClient.ValidateGpmDetailsAsync(new Placing(), string.Empty));
        }

        [Fact]
        public async Task ValidateGpmDetailsAsync_Successful()
        {
            var riskValidationModel = new RiskValidationModel { IsValid = true };
            string json = JsonSerializer.Serialize(riskValidationModel, JsonOptions.JsonSerializerOptions); 
            var mockLogger = new Mock<ILogger<EclipseRiskValidationApiClient>>();
            var mockHttpMessageHandler = new Mock<HttpMessageHandler>();
            mockHttpMessageHandler.Protected()
                .Setup<Task<HttpResponseMessage>>("SendAsync", ItExpr.IsAny<HttpRequestMessage>(), ItExpr.IsAny<CancellationToken>())
                .ReturnsAsync(new HttpResponseMessage
                {
                    StatusCode = HttpStatusCode.OK,
                    Content = new StringContent(json),
                });

            var client = new HttpClient(mockHttpMessageHandler.Object) { BaseAddress = new Uri("https://eclipse-risk-validator-func-uks-dev.azurewebsites.net") };

            _mockHttpClientFactory.Setup(x => x.CreateClient(It.IsAny<string>())).Returns(client);

            var eclipseRiskValidationApiClient = new EclipseRiskValidationApiClient(mockLogger.Object, _mockTokenServiceHelper.Object, _eclipseRiskValidationApiOptions, _mockHttpClientFactory.Object);

            var validationModel = await eclipseRiskValidationApiClient.ValidateGpmDetailsAsync(new Placing(), "1234");

            Assert.NotNull(validationModel);
            Assert.True(validationModel.IsValid);
        }
    }
}