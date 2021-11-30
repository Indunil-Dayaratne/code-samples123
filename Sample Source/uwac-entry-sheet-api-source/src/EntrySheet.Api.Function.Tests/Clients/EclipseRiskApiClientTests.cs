using System;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Reflection;
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
using Newtonsoft.Json;
using Xunit;

namespace EntrySheet.Api.Function.Tests.Clients
{
    public class EclipseRiskApiClientTests
    {
        private readonly Mock<ILogger<EclipseRiskApiClient>> _mockLogger;
        private readonly IOptions<EclipseRiskApiOptions> _eclipseRiskApiOptions;
        private readonly Mock<IHttpClientFactory> _mockHttpClientFactory;
        private readonly Mock<ITokenServiceHelper> _mockTokenServiceHelper;

        public EclipseRiskApiClientTests()
        {
            _mockLogger = new Mock<ILogger<EclipseRiskApiClient>>();
            _mockHttpClientFactory = new Mock<IHttpClientFactory>();
            _mockTokenServiceHelper = new Mock<ITokenServiceHelper>();

            Environment.SetEnvironmentVariable("tenantid", "8cee18df-5e2a-4664-8d07-0566ffea6dcd");

            _eclipseRiskApiOptions = Options.Create(new EclipseRiskApiOptions
            {
                AzureConnectionString = "RunAs=App;AppId=8be45412-d1fc-4839-8619-03208d1971fd;TenantId=8cee18df-5e2a-4664-8d07-0566ffea6dcd;AppKey=PwZKY0dAyt_46.PS.Eb2P-.FhE4Bo7PQ~-",
                BaseUrl = "https://eclipse-risk-api-func-uks-dev.azurewebsites.net",
                ClientId = "8be45412-d1fc-4839-8619-03208d1971fd",
            });

        }

        [Fact]
        public async Task GetEclipseRiskGpmDetailsAsync_Throws_Exception_When_PolicyRef_ISNull()
        {
            var mockHttpMessageHandler = new Mock<HttpMessageHandler>();

            var client = new HttpClient(mockHttpMessageHandler.Object);

            _mockHttpClientFactory.Setup(x => x.CreateClient(It.IsAny<string>())).Returns(client);

            var eclipseRiskApiClient = new EclipseRiskApiClient(_mockLogger.Object, _eclipseRiskApiOptions, _mockHttpClientFactory.Object, _mockTokenServiceHelper.Object);

            await Assert.ThrowsAsync<ArgumentNullException>(() => eclipseRiskApiClient.GetEclipseRiskGpmDetailsAsync(null));
        }

        [Fact]
        public async Task GetEclipseRiskGpmDetailsAsync_Throws_Exception_When_ReturnResult_Is_Null()
        {
            var mockHttpMessageHandler = new Mock<HttpMessageHandler>();
            mockHttpMessageHandler.Protected()
                .Setup<Task<HttpResponseMessage>>("SendAsync", ItExpr.IsAny<HttpRequestMessage>(), ItExpr.IsAny<CancellationToken>())
                .ReturnsAsync(new HttpResponseMessage
                {
                    StatusCode = HttpStatusCode.OK,
                    Content = new StringContent("")
                });

            var client = new HttpClient(mockHttpMessageHandler.Object);

            _mockHttpClientFactory.Setup(x => x.CreateClient(It.IsAny<string>())).Returns(client);

            var eclipseRiskApiClient = new EclipseRiskApiClient(_mockLogger.Object, _eclipseRiskApiOptions, _mockHttpClientFactory.Object, _mockTokenServiceHelper.Object);

            await Assert.ThrowsAsync<ApplicationException>(() => eclipseRiskApiClient.GetEclipseRiskGpmDetailsAsync("TESTPOLICY"));
        }

        [Fact]
        public async Task GetEclipseRiskGpmDetailsAsync_Successful()
        {
            var baseFolder = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
            var dataFilePath = Path.Combine(baseFolder, @".\Data\GP942A21A000", "GP942A21A000_Placing.json");
            string json = File.ReadAllText(dataFilePath);
            var mockHttpMessageHandler = new Mock<HttpMessageHandler>();
            mockHttpMessageHandler.Protected()
                .Setup<Task<HttpResponseMessage>>("SendAsync", ItExpr.IsAny<HttpRequestMessage>(), ItExpr.IsAny<CancellationToken>())
                .ReturnsAsync(new HttpResponseMessage
                {
                    StatusCode = HttpStatusCode.OK,
                    Content = new StringContent(json)
                });

            var client = new HttpClient(mockHttpMessageHandler.Object);

            _mockHttpClientFactory.Setup(x => x.CreateClient(It.IsAny<string>())).Returns(client);

            var eclipseRiskApiClient = new EclipseRiskApiClient(_mockLogger.Object, _eclipseRiskApiOptions, _mockHttpClientFactory.Object, _mockTokenServiceHelper.Object);

            var result = await eclipseRiskApiClient.GetEclipseRiskGpmDetailsAsync("GP942A21A000");
            Assert.Equal("GP942A21A000", result.ContractSections.First().SectionReference);
        }

        [Fact]
        public async Task SubmitCreateRiskRequestAsync_Throws_Exception_When_RiskMapperModel_IsNull()
        {
            var mockHttpMessageHandler = new Mock<HttpMessageHandler>();

            var client = new HttpClient(mockHttpMessageHandler.Object);

            _mockHttpClientFactory.Setup(x => x.CreateClient(It.IsAny<string>())).Returns(client);

            var eclipseRiskApiClient = new EclipseRiskApiClient(_mockLogger.Object, _eclipseRiskApiOptions, _mockHttpClientFactory.Object, _mockTokenServiceHelper.Object);

            await Assert.ThrowsAsync<ArgumentNullException>(() => eclipseRiskApiClient.SubmitCreateRiskRequestAsync(null, "1234"));
        }

        [Fact]
        public async Task SubmitCreateRiskRequestAsync_Throws_Exception_When_PolicyReference_IsNull()
        {
            var mockHttpMessageHandler = new Mock<HttpMessageHandler>();

            var client = new HttpClient(mockHttpMessageHandler.Object);

            _mockHttpClientFactory.Setup(x => x.CreateClient(It.IsAny<string>())).Returns(client);

            var eclipseRiskApiClient = new EclipseRiskApiClient(_mockLogger.Object, _eclipseRiskApiOptions, _mockHttpClientFactory.Object, _mockTokenServiceHelper.Object);

            await Assert.ThrowsAsync<ArgumentNullException>(() => eclipseRiskApiClient.SubmitCreateRiskRequestAsync(new RiskMapperModel(), null));
        }

        [Fact]
        public async Task SubmitCreateRiskRequestAsync_Successful()
        {
            var messageId = Guid.NewGuid().ToString();
            var json = JsonConvert.SerializeObject(messageId);
            var mockHttpMessageHandler = new Mock<HttpMessageHandler>();
            mockHttpMessageHandler.Protected()
                .Setup<Task<HttpResponseMessage>>("SendAsync", ItExpr.IsAny<HttpRequestMessage>(), ItExpr.IsAny<CancellationToken>())
                .ReturnsAsync(new HttpResponseMessage
                {
                    StatusCode = HttpStatusCode.OK,
                    Content = new StringContent(json)
                });

            var client = new HttpClient(mockHttpMessageHandler.Object);

            _mockHttpClientFactory.Setup(x => x.CreateClient(It.IsAny<string>())).Returns(client);

            var eclipseRiskApiClient = new EclipseRiskApiClient(_mockLogger.Object, _eclipseRiskApiOptions, _mockHttpClientFactory.Object, _mockTokenServiceHelper.Object);

            var riskMapperModel = new RiskMapperModel { CorelationId = Guid.NewGuid(), Placing = new Placing(), UserName = "ixdayaratne" };
            var createRiskResponseModel = await eclipseRiskApiClient.SubmitCreateRiskRequestAsync(riskMapperModel, "1234");

            Assert.NotNull(createRiskResponseModel);
            Assert.Equal(createRiskResponseModel.MessageId, messageId);
        }

        [Fact]
        public async Task SubmitCreateRiskRequestAsync_Returns_ValidationModel_For_Invalid_CreateRisk_Request()
        {
            var json = JsonConvert.SerializeObject(new RiskValidationModel { IsValid = false });
            var mockHttpMessageHandler = new Mock<HttpMessageHandler>();
            mockHttpMessageHandler.Protected()
                .Setup<Task<HttpResponseMessage>>("SendAsync", ItExpr.IsAny<HttpRequestMessage>(), ItExpr.IsAny<CancellationToken>())
                .ReturnsAsync(new HttpResponseMessage
                {
                    StatusCode = HttpStatusCode.UnprocessableEntity,
                    Content = new StringContent(json)
                });

            var client = new HttpClient(mockHttpMessageHandler.Object);

            _mockHttpClientFactory.Setup(x => x.CreateClient(It.IsAny<string>())).Returns(client);

            var eclipseRiskApiClient = new EclipseRiskApiClient(_mockLogger.Object, _eclipseRiskApiOptions, _mockHttpClientFactory.Object, _mockTokenServiceHelper.Object);

            var riskMapperModel = new RiskMapperModel { CorelationId = Guid.NewGuid(), Placing = new Placing(), UserName = "ixdayaratne" };
            var createRiskResponseModel = await eclipseRiskApiClient.SubmitCreateRiskRequestAsync(riskMapperModel, "1234");

            Assert.NotNull(createRiskResponseModel);
            Assert.False(createRiskResponseModel.RiskValidationModel.IsValid);
        }
    }
}
