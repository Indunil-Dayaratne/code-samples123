
using EnsureThat;
using Microsoft.Azure.KeyVault;
using Microsoft.Azure.Services.AppAuthentication;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

namespace Coreact.CoreProcesser.Function.Services
{
    /// <summary>
    /// Methods to help work with Azure KeyVault
    /// </summary>
    public  class KeyVaultHelper : IKeyVaultHelper
    {
        private readonly ILogger _logger;

        public KeyVaultHelper(ILogger logger)
        {
            _logger = logger;
        }

        public string RESOURCEID { get { return Environment.GetEnvironmentVariable("KEYVAULT_RESOURCEID"); } }

        /// <summary>
        /// Get a value from the Key Vault
        /// </summary>
        /// <param name="key"></param>
        /// <returns></returns>
        public async Task<string> GetKeyVaultValue(string key)
        {
            Ensure.That(key).IsNotNullOrEmpty();

            try
            {
                var azureServiceTokenProvider = new AzureServiceTokenProvider();

                var callback = new KeyVaultClient.AuthenticationCallback(azureServiceTokenProvider.KeyVaultTokenCallback);
                var keyVaultClient = new KeyVaultClient(callback, new HttpClient());

                var kvRecord = await keyVaultClient.GetSecretAsync(this.RESOURCEID + key);

                return kvRecord.Value;
            }
            catch(Exception ex)
            {
                _logger.LogError(ex, $"Cannot get key from vault {this.RESOURCEID} key {key}");

                throw new Exception($"Cannot get key from vault {this.RESOURCEID} key {key}",ex);
            }
        }
    }
}
