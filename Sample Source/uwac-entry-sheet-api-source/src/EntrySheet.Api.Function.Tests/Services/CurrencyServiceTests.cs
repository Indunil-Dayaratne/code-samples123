using EntrySheet.Api.Function.Helpers;
using EntrySheet.Api.Function.Services;
using Microsoft.Extensions.Logging;
using Moq;
using System.Reflection;
using System.Threading.Tasks;
using Xunit;

namespace EntrySheet.Api.Function.Tests.Services
{
    public class CurrencyServiceTests
    {
        [Fact]
        public async Task GetCurrencies_Returns_Successfully()
        {
            var mockLogger = new Mock<ILogger<CurrencyService>>();
            var mockAssemblyHelper = new Mock<IAssemblyHelper>();
            var file = Assembly.GetExecutingAssembly().Location.Replace("EntrySheet.Api.Function.Tests.dll", "");
            mockAssemblyHelper.Setup(x => x.GetLocationOfExecutingAssembly()).Returns(file);

            var currencyService = new CurrencyService(mockLogger.Object, mockAssemblyHelper.Object);
            var result = await currencyService.GetCurrencyAsync();

            Assert.NotEmpty(result);
        }
    }
}
