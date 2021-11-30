using Microsoft.Azure.Services.AppAuthentication;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Diagnostics.CodeAnalysis;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text.Json;
using System.Threading.Tasks;
using EntrySheet.Api.Function.Settings;

namespace EntrySheet.Api.Function.Helpers
{
    [ExcludeFromCodeCoverage]
    public class AuthenticationHelper : IAuthenticationHelper
    {
        private readonly ILogger<AuthenticationHelper> _logger;
        private readonly KeyVaultSecrets _keyVaultSecrets;
        private readonly HttpClient _client;
        private readonly BeasOptions _beasOptions;

        public AuthenticationHelper(ILogger<AuthenticationHelper> logger,
            KeyVaultSecrets keyVaultHelper,
            IHttpClientFactory httpClientFactory,
            IOptions<BeasOptions> beasOptions)
        {
            _logger = logger;
            _keyVaultSecrets = keyVaultHelper;
            _client = httpClientFactory.CreateClient("Beas");
            _beasOptions = beasOptions.Value;
        }

        public async Task<string> GetAccessTokenAsync()
        {
            try
            {
                string beasApplicationId = _keyVaultSecrets.BeasClientId;
                if (!string.IsNullOrEmpty(beasApplicationId))
                {
                    var azureServiceTokenProvider = new AzureServiceTokenProvider();
                    var accessToken = await azureServiceTokenProvider.GetAccessTokenAsync(beasApplicationId).ConfigureAwait(false);
                    return accessToken;
                }
                else
                {
                    _logger.LogError("Failed to get ClientId for BEAS AAD Application. "
                        + "Ensure that the secret 'beas-client-id' exists in the KeyVault and it has the correct value for the AAD Application's client Id");
                    return null;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occured while trying to get Access Token for BEAS AAD Application - {Message}", ex.Message);
                return null;
            }
        }

        public async Task<bool> UserHasAccessAsync(string accessToken, string userPrincipalName)
        {
            try
            {
                string roles;

                var url = $"{_beasOptions.BaseUrl}/Roles/{userPrincipalName}?applicationName={_beasOptions.ApplicationName}&applicationAreaName={_beasOptions.ApplicationArea}";
                _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(scheme: "Bearer", parameter: accessToken);
                roles = await _client.GetStringAsync(new Uri(url)).ConfigureAwait(false);

                var rolesArray = JsonSerializer.Deserialize<string[]>(roles);

                return rolesArray.Any(x => x.Trim().Equals($"{_beasOptions.ApplicationArea}_{_beasOptions.ApplicationRole}", StringComparison.OrdinalIgnoreCase));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occured while trying to check BEAS roles for user - {UserPrincipalName}. Details - {Message}", userPrincipalName, ex.Message);
                return false;
            }
        }
    }
}
