using Microsoft.Azure.KeyVault;
using Microsoft.Azure.Services.AppAuthentication;
using Microsoft.Extensions.Logging;
using System;
using System.Diagnostics.CodeAnalysis;
using System.Net.Http;
using System.Threading.Tasks;

namespace EntrySheet.Api.Function.Helpers
{
    [ExcludeFromCodeCoverage]
    public class KeyVaultHelper : IKeyVaultHelper
    {
        private readonly ILogger<KeyVaultHelper> _logger;

        public KeyVaultHelper(ILogger<KeyVaultHelper> logger)
        {
            _logger = logger;
        }

        private string ResourceId
        {
            get
            {
                return Environment.GetEnvironmentVariable("KEYVAULT_RESOURCEID");
            }
        }

        public async Task<string> GetKeyVaultValueAsync(string key)
        {
            try
            {
                var azureServiceTokenProvider = new AzureServiceTokenProvider();

                var callback = new KeyVaultClient.AuthenticationCallback(azureServiceTokenProvider.KeyVaultTokenCallback);
                using var keyVaultClient = new KeyVaultClient(callback, new HttpClient());
                var kvRecord = await keyVaultClient.GetSecretAsync(ResourceId + key).ConfigureAwait(false);

                return kvRecord.Value;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Cannot get key from vault {this.ResourceId} key {key}");

                return null;
            }
        }
    }
}
