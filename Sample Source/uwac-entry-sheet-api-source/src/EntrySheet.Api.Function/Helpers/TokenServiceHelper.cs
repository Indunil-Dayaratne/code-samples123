using Microsoft.Azure.Services.AppAuthentication;
using Microsoft.Extensions.Logging;
using System;
using System.Diagnostics.CodeAnalysis;
using System.Threading.Tasks;

namespace EntrySheet.Api.Function.Helpers
{
    [ExcludeFromCodeCoverage]
    public class TokenServiceHelper : ITokenServiceHelper
    {
        private readonly ILogger<TokenServiceHelper> _logger;
        public TokenServiceHelper(ILogger<TokenServiceHelper> logger)
        {
            _logger = logger;
        }
        public async Task<string> GetAzureAccessTokenAsync(string applicationId, string connectionString)
        {
            var tenantId = Environment.GetEnvironmentVariable("tenantid");

            try
            {
                var azureServiceTokenProvider = new AzureServiceTokenProvider(connectionString);
                var accessToken = await azureServiceTokenProvider.GetAccessTokenAsync(applicationId, tenantId);
                return accessToken;
            }

            catch (Exception ex)
            {
                _logger.LogError(ex,
                    $"GetAzureAccessToken : Could not acquire token for application with ID -  {applicationId}",
                    applicationId);
                throw;
            }
        }
    }
}
