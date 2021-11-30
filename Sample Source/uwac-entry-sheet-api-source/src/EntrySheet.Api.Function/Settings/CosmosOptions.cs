using System.Diagnostics.CodeAnalysis;

namespace EntrySheet.Api.Function.Settings
{
    [ExcludeFromCodeCoverage]
    public class CosmosOptions
    {
        public string AccountPrimaryKey { get; set; }
        public string DatabaseEndpoint { get; set; }
        public string DatabaseName { get; set; }
        public string LatestDataContainerName { get; set; }
        public string HistoryDataContainerName { get; set; }
    }
}