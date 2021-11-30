using System;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Reflection;
using System.Threading;
using System.Threading.Tasks;
using EntrySheet.Api.Function.Clients;
using EntrySheet.Api.Function.Helpers;
using EntrySheet.Api.Function.Settings;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Moq;
using Moq.Protected;
using Xunit;

namespace EntrySheet.Api.Function.Tests.Clients
{
    public class BritCacheClientTests
    {
        private readonly Mock<IHttpClientFactory> _mockHttpClientFactory;
        private readonly IOptions<BritCacheOptions> _options;
        private readonly Mock<ITokenServiceHelper> _mockTokenServiceHelper;

        public BritCacheClientTests()
        {
            _mockHttpClientFactory = new Mock<IHttpClientFactory>();
            _mockTokenServiceHelper = new Mock<ITokenServiceHelper>();

            Environment.SetEnvironmentVariable("tenantid", "8cee18df-5e2a-4664-8d07-0566ffea6dcd");

            _options = Microsoft.Extensions.Options.Options.Create(new BritCacheOptions
            {
                AzureConnectionString = "RunAs=App;AppId=b7777946-a31b-4eed-8db3-7c9f07f82f92;TenantId=8cee18df-5e2a-4664-8d07-0566ffea6dcd;AppKey=oi-K.oTp9L57GvbF_6rhoP98tntupQ1~Z.",
                BaseURL = "https://somewebsite.net/",
                ClientId = "b7777946-a31b-4eed-8db3-7c9f07f82f92"
            });
        }

        [Fact]
        public async Task GetEclipsePoliciesAsync_Successful()
        {
            var baseFolder = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
            var dataFilePath = Path.Combine(baseFolder, @".\Data\Single_Section_Multi_Line_Policy_10044A20A000", "1098461_BritCache_GetEclipsePoliciesAsyncResult.json");
            var json = File.ReadAllText(dataFilePath);

            var mockLogger = new Mock<ILogger<BritCacheClient>>();
            var mockHttpMessageHandler = new Mock<HttpMessageHandler>();
            mockHttpMessageHandler.Protected()
                .Setup<Task<HttpResponseMessage>>("SendAsync", ItExpr.IsAny<HttpRequestMessage>(), ItExpr.IsAny<CancellationToken>())
                .ReturnsAsync(new HttpResponseMessage
                {
                    StatusCode = HttpStatusCode.OK,
                    Content = new StringContent(json),
                });

            var client = new HttpClient(mockHttpMessageHandler.Object) { BaseAddress = new Uri("https://abc.co.uk") };

            _mockHttpClientFactory.Setup(x => x.CreateClient(It.IsAny<string>())).Returns(client);

            var britCacheClient = new BritCacheClient(mockLogger.Object, _mockHttpClientFactory.Object, _options, _mockTokenServiceHelper.Object);

            var policies = await britCacheClient.GetEclipsePoliciesAsync(new []{1098461});

            Assert.NotNull(policies);
            Assert.True(policies.Count() == 1);
            Assert.True(policies.First().BritPolicyId == 1098461);
            Assert.True(policies.First().PolicyReference == "10044A20A000");
        }

        [Fact]
        public async Task GetEclipsePoliciesAsyncReturnsNullForUnsuccessfulRequest()
        {
            var mockLogger = new Mock<ILogger<BritCacheClient>>();
            var mockHttpMessageHandler = new Mock<HttpMessageHandler>();
            mockHttpMessageHandler.Protected()
                .Setup<Task<HttpResponseMessage>>("SendAsync", ItExpr.IsAny<HttpRequestMessage>(), ItExpr.IsAny<CancellationToken>())
                .ReturnsAsync(new HttpResponseMessage
                {
                    StatusCode = HttpStatusCode.BadRequest,
                    Content = new StringContent(string.Empty),
                });

            var client = new HttpClient(mockHttpMessageHandler.Object) { BaseAddress = new Uri("https://abc.co.uk") };

            _mockHttpClientFactory.Setup(x => x.CreateClient(It.IsAny<string>())).Returns(client);

            var britCacheClient = new BritCacheClient(mockLogger.Object, _mockHttpClientFactory.Object, _options, _mockTokenServiceHelper.Object);

            var policies = await britCacheClient.GetEclipsePoliciesAsync(new []{1098461});

            Assert.Null(policies);
        }

        [Fact]
        public async Task GetEclipsePoliciesAsync_Throws_Exception_When_BritPolicyIds_IsNull()
        {
            var mockLogger = new Mock<ILogger<BritCacheClient>>();
            var britCacheClient = new BritCacheClient(mockLogger.Object, _mockHttpClientFactory.Object, _options, _mockTokenServiceHelper.Object);

            await Assert.ThrowsAsync<ArgumentNullException>(() => britCacheClient.GetEclipsePoliciesAsync(null));
        }
    }
}
