using System.Reflection;
using EntrySheet.Api.Function.Helpers;
using EntrySheet.Api.Function.Services;
using Microsoft.Extensions.Logging;
using Moq;
using Xunit;

namespace EntrySheet.Api.Function.Tests.Services
{
    public class SyndicateDataRetrieverTests
    {
        [Fact]
        public void GetIncludedSyndicates_Returns_Data_Successfully()
        {
            var mockLogger = new Mock<ILogger<SyndicateDataRetriever>>();
            var mockAssemblyHelper = new Mock<IAssemblyHelper>();
            var path = Assembly.GetExecutingAssembly().Location.Replace("EntrySheet.Api.Function.Tests.dll", "");
            mockAssemblyHelper.Setup(x => x.GetLocationOfExecutingAssembly()).Returns(path);

            var syndicateDataRetriever = new SyndicateDataRetriever(mockLogger.Object, mockAssemblyHelper.Object);
            var includedSyndicates = syndicateDataRetriever.GetIncludedSyndicates();

            Assert.NotNull(includedSyndicates);
            Assert.True(includedSyndicates.Count == 2);
            Assert.True(includedSyndicates.Exists(x=>x == "2987"));
            Assert.True(includedSyndicates.Exists(x => x == "2988"));
        }
    }
}