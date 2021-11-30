using Microsoft.Azure.Services.AppAuthentication;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text.Json;
using System.Threading.Tasks;

namespace EntrySheet.WebApp.Helpers
{
    public class AuthenticationHelper : IAuthenticationHelper
    {
        private readonly ILogger<AuthenticationHelper> _logger;
        private readonly IKeyVaultHelper _keyVaultHelper;
        private readonly HttpClient _client;
        private readonly BeasOptions _beasOptions;

        public AuthenticationHelper(ILogger<AuthenticationHelper> logger,
            IKeyVaultHelper keyVaultHelper,
            IHttpClientFactory httpClientFactory,
            IOptions<BeasOptions> beasOptions)
        {
            _logger = logger;
            _keyVaultHelper = keyVaultHelper;
            _client = httpClientFactory.CreateClient();
            _beasOptions = beasOptions.Value;
        }

        private async Task<string> GetAccessTokenAsync()
        {
            try
            {
                string beasApplicationId = await _keyVaultHelper.GetKeyVaultValueAsync("BeasClientId").ConfigureAwait(false);
                if (!string.IsNullOrEmpty(beasApplicationId))
                {
                    var azureServiceTokenProvider = new AzureServiceTokenProvider();
                    var accessToken = await azureServiceTokenProvider.GetAccessTokenAsync(beasApplicationId).ConfigureAwait(false);
                    return accessToken;
                }
                else
                {
                    _logger.LogError("Failed to get ClientId for BEAS AAD Application. "
                        + "Ensure that the secret 'BeasClientId' exists in the KeyVault and it has the correct value for the AAD Application's client Id");
                    return null;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occured while trying to get Access Token for BEAS AAD Application - {Message}", ex.Message);
                return null;
            }
        }

        private async Task<string[]> GetUserRolesAsync(string userPrincipalName, string applicationName, string applicationArea)
        {
            string accessToken = await GetAccessTokenAsync();
            var url = $"{_beasOptions.BaseUrl}/Roles/{userPrincipalName}?applicationName={applicationName}&applicationAreaName={applicationArea}";
            _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(scheme: "Bearer", parameter: accessToken);
            string roles = await _client.GetStringAsync(new Uri(url)).ConfigureAwait(false);
            return JsonSerializer.Deserialize<string[]>(roles);
        }

        public async Task<bool> UserHasAccessAsync(string userPrincipalName)
        {
            try
            {
                var rolesArray = await GetUserRolesAsync(userPrincipalName, _beasOptions.ApplicationName, _beasOptions.ApplicationArea);

                return rolesArray.Any(x => x.Trim().Equals($"{_beasOptions.ApplicationArea}_{_beasOptions.ApplicationRole}", StringComparison.InvariantCultureIgnoreCase));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occured while trying to check BEAS roles for user - {UserPrincipalName}. Details - {Message}", userPrincipalName, ex.Message);
                return false;
            }
        }

        public async Task<bool> UserHasReadAccessAsync(string userPrincipalName)
        {
            try
            {
                var rolesArray = await GetUserRolesAsync(userPrincipalName, _beasOptions.ApplicationNameInternal, _beasOptions.ApplicationAreaInternal);

                return rolesArray.Any(x => x.Trim().Equals($"{_beasOptions.ApplicationAreaInternal}_{_beasOptions.ApplicationRoleReadOnly}", StringComparison.InvariantCultureIgnoreCase));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "UserHasReadAccessAsync : Error occured while trying to check BEAS roles for user - {UserPrincipalName}. Details - {Message}", userPrincipalName, ex.Message);
                return false;
            }
        }

        public async Task<bool> UserHasWriteAccessAsync(string userPrincipalName)
        {
            try
            {
                var rolesArray = await GetUserRolesAsync(userPrincipalName, _beasOptions.ApplicationNameInternal, _beasOptions.ApplicationAreaInternal);

                return rolesArray.Any(x => x.Trim().Equals($"{_beasOptions.ApplicationAreaInternal}_{_beasOptions.ApplicationRoleWrite}", StringComparison.InvariantCultureIgnoreCase));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "UserHasWriteAccessAsync : Error occured while trying to check BEAS roles for user - {UserPrincipalName}. Details - {Message}", userPrincipalName, ex.Message);
                return false;
            }
        }
        
    }
}
