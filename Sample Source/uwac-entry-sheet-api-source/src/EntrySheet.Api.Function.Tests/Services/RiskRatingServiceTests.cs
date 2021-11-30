using System.Reflection;
using System.Threading.Tasks;
using EntrySheet.Api.Function.Helpers;
using EntrySheet.Api.Function.Services;
using Microsoft.Extensions.Logging;
using Moq;
using Xunit;

namespace EntrySheet.Api.Function.Tests.Services
{
    public class RiskRatingServiceTests
    {
        [Fact]
        public void GetRiskRatings_Returns_Successfully()
        {
            var mockLogger = new Mock<ILogger<RiskRatingService>>();
            var mockAssemblyHelper = new Mock<IAssemblyHelper>();
            var file = Assembly.GetExecutingAssembly().Location.Replace("EntrySheet.Api.Function.Tests.dll", "");
            mockAssemblyHelper.Setup(x => x.GetLocationOfExecutingAssembly()).Returns(file);

            var riskRatingService = new RiskRatingService(mockLogger.Object, mockAssemblyHelper.Object);
            var result = riskRatingService.GetRiskRatings();

            Assert.NotEmpty(result);
        }
    }
}