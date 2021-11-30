using EntrySheet.Api.Function.Helpers;
using Microsoft.Extensions.Logging;
using Moq;
using System.Reflection;
using System.Threading.Tasks;
using EntrySheet.Api.Function.Services;
using Xunit;

namespace EntrySheet.Api.Function.Tests.Services
{
    public class EPlacingServiceTests
    {
        [Fact]
        public async Task GetEPlacingValues_Returns_Successfully()
        {
            var mockLogger = new Mock<ILogger<EPlacingService>>();
            var mockAssemblyHelper = new Mock<IAssemblyHelper>();
            var path = Assembly.GetExecutingAssembly().Location.Replace("EntrySheet.Api.Function.Tests.dll", "");
            mockAssemblyHelper.Setup(x => x.GetLocationOfExecutingAssembly()).Returns(path);

            var ePlacingService = new EPlacingService(mockLogger.Object, mockAssemblyHelper.Object);
            var result = await ePlacingService.GetEPlacingValuesAsync();

            Assert.NotEmpty(result);
        }
    }
}
