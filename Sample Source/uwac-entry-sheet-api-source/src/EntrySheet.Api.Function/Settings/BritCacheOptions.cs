using System.Diagnostics.CodeAnalysis;

namespace EntrySheet.Api.Function.Settings
{
    [ExcludeFromCodeCoverage]
    public class BritCacheOptions
    {
        public string ClientId { get; set; }
        public string BaseURL { get; set; }
        public string AzureConnectionString { get; set; }

    }
}
