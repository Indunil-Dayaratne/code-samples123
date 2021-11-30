using Azure.Core;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Threading.Tasks;

namespace EntrySheet.WebApp.Helpers
{
    public class KeyVaultHelper : IKeyVaultHelper
    {
        private readonly ILogger<KeyVaultHelper> _logger;
        private readonly Settings _settings;

        public KeyVaultHelper(ILogger<KeyVaultHelper> logger, IOptions<Settings> settings)
        {
            _logger = logger;
            _settings = settings.Value;
        }

        public async Task<string> GetKeyVaultValueAsync(string key)
        {
            try
            {
                SecretClientOptions options = new SecretClientOptions()
                {
                    Retry =
                    {
                        Delay= TimeSpan.FromSeconds(2),
                        MaxDelay = TimeSpan.FromSeconds(16),
                        MaxRetries = 5,
                        Mode = RetryMode.Exponential
                    }
                };
                var client = new SecretClient(new Uri(_settings.KeyVaultResourceId), new DefaultAzureCredential(), options);

                KeyVaultSecret secret = await client.GetSecretAsync(key).ConfigureAwait(false);

                string secretValue = secret.Value;

                return secretValue;

            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Cannot get key from vault {KeyVaultResourceId} key {Key}", _settings.KeyVaultResourceId, key);
                return null;
            }
        }
    }
}
