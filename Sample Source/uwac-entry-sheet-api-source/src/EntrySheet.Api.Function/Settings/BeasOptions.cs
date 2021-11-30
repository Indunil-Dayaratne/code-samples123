using System.Diagnostics.CodeAnalysis;

namespace EntrySheet.Api.Function.Settings
{
    [ExcludeFromCodeCoverage]
    public class BeasOptions
    {
        public string BaseUrl { get; set; }
        public string ApplicationName { get; set; }
        public string ApplicationArea { get; set; }
        public string ApplicationRole { get; set; }
    }
}
