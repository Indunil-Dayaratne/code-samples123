using System.Diagnostics.CodeAnalysis;

namespace EntrySheet.Api.Function.Settings
{
    [ExcludeFromCodeCoverage]
    public class KeyVaultSecrets
    {
        public string BeasClientId { get; set; }
        public string BritcacheClientId { get; set; }

    }
}
