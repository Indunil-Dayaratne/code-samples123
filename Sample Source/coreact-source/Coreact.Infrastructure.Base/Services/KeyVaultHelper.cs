

using Microsoft.Azure.KeyVault;
using Microsoft.Azure.Services.AppAuthentication;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

namespace Coreact.Infrastructure.Base.Services
{
    /// <summary>
    /// Methods to help work with Azure KeyVault
    /// </summary>
    public  class KeyVaultHelper : IKeyVaultHelper
    {
        private readonly ILogger _logger;
    private readonly IFunctionCache _functionCache;

        public KeyVaultHelper(ILogger logger,IFunctionCache cache)
        {
            _logger = logger;
            _functionCache = cache;
        }

        public string RESOURCEID { get { return Environment.GetEnvironmentVariable("KEYVAULT_RESOURCEID"); } }

        /// <summary>
        /// Get a value from the Key Vault
        /// </summary>
        /// <param name="key"></param>
        /// <returns></returns>
        public async Task<string> GetKeyVaultValue(string key)
        {
            try
            {
                var result = await _functionCache.GetOrAdd<string>(key, async () =>
                {
                   var azureServiceTokenProvider = new AzureServiceTokenProvider();

                   var callback = new KeyVaultClient.AuthenticationCallback(azureServiceTokenProvider.KeyVaultTokenCallback);
                   var keyVaultClient = new KeyVaultClient(callback, new HttpClient());

                   var kvRecord = await keyVaultClient.GetSecretAsync(this.RESOURCEID + key);

                   return kvRecord.Value;
                },TimeSpan.FromMinutes(60));

                return result;
            }
            catch(Exception ex)
            {
                _logger.LogError(ex, $"Cannot get key from vault {this.RESOURCEID} key {key}");

                throw new Exception($"Cannot get key from vault {this.RESOURCEID} key {key}",ex);
            }
        }
    }
}
