using EntrySheet.Api.Function.Helpers;
using EntrySheet.Api.Function.Services;
using Microsoft.Extensions.Logging;
using Moq;
using System;
using System.Collections.Generic;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using Xunit;
using EntrySheet.Api.Function.Models;

namespace EntrySheet.Api.Function.Tests.Services
{
    public class IndustryCodeServiceTests
    {
        [Fact]
        public async Task GetIndustryCodes_Returns_Successfully()
        {
            var mockLogger = new Mock<ILogger<IndustryCodeService>>();
            var mockAssembly = new Mock<IAssemblyHelper>();
            var path = Assembly.GetExecutingAssembly().Location.Replace("EntrySheet.Api.Function.Tests.dll", "");
            mockAssembly.Setup(x => x.GetLocationOfExecutingAssembly()).Returns(path);

            var sut = new IndustryCodeService(mockLogger.Object, mockAssembly.Object);
            var result = await sut.GetIndustryCodesAsync();
            Assert.NotEmpty(result);
        }
    }
}
