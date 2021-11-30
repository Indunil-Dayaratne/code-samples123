using Microsoft.Azure.Services.AppAuthentication;
using Microsoft.Azure.KeyVault;
using Microsoft.Extensions.Logging;
using System;
using System.Threading.Tasks;
using System.Net.Http;
using MediaPersistence.Functions.Helpers.Interfaces;

namespace MediaPersistence.Functions.Helpers
{
    public class KeyVaultHelper : IKeyVaultHelper
    {
        private readonly ILogger _logger;

        public KeyVaultHelper(ILogger logger)
        {
            _logger = logger;
        }

        public string ResourceId
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
                var keyVaultClient = new KeyVaultClient(callback, new HttpClient());

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
