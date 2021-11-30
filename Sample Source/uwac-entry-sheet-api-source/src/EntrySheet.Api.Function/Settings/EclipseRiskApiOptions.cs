using System.Diagnostics.CodeAnalysis;

namespace EntrySheet.Api.Function.Settings
{
    [ExcludeFromCodeCoverage]
    public class EclipseRiskApiOptions
    {
        public string BaseUrl { get; set; }
        public string ClientId { get; set; }
        public string AzureConnectionString { get; set; }
    }
}
