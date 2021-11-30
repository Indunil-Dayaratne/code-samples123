using MediaPersistence.Functions.Commands;
using MediaPersistence.Functions.Helpers.Interfaces;
using Microsoft.Azure.Services.AppAuthentication;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;

namespace MediaPersistence.Functions.Helpers
{
    public class AuthenticationHelper : IAuthenticationHelper
    {
        private readonly ILogger _logger;
        private readonly IKeyVaultHelper _keyVaultHelper;

        public AuthenticationHelper(ILogger logger, IKeyVaultHelper keyVaultHelper)
        {
            _logger = logger;
            _keyVaultHelper = keyVaultHelper;
        }

        public async Task<string> GetAccessTokenAsync()
        {
            try
            {
                string BEASApplicationId = await _keyVaultHelper.GetKeyVaultValueAsync("beas-client-id").ConfigureAwait(false);
                if (!string.IsNullOrEmpty(BEASApplicationId))
                {
                    var azureServiceTokenProvider = new AzureServiceTokenProvider();
                    var accessToken = await azureServiceTokenProvider.GetAccessTokenAsync(BEASApplicationId).ConfigureAwait(false);
                    return accessToken;
                }
                else
                {
                    _logger.LogError($"Failed to get ClientId for BEAS AAD Application. " +
                        $"Ensure that the secret 'beas-client-id' exists in the KeyVault and it has the correct value for the AAD Application's client Id");
                    return null;
                }
                
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,$"Error occured while trying to get Access Token for BEAS AAD Application");
                return null;
            }

        }

        public async Task<string> GetMediaDBAccessTokenAsync()
        {
            try
            {
                string mediaApplicationId = await _keyVaultHelper.GetKeyVaultValueAsync("cosmos-account-primary-key").ConfigureAwait(false);
                if (!string.IsNullOrEmpty(mediaApplicationId))
                {
                    return mediaApplicationId;
                }
                else
                {
                    _logger.LogError($"Failed to get ClientId for media DB AAD Application. " +
                                     $"Ensure that the secret 'cosmos-account-primary-key' exists in the KeyVault and it has the correct value for the AAD Application's client Id");
                    return null;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "Error occured while trying to get Access Token for media persistence cosmos db AAD Application");
                return null;
            }

        }

        public async Task<bool> UserHasAccessAsync(string accessToken, UserRoleCommand command)
        {
            try
            {
                var BEASBaseUrl = Environment.GetEnvironmentVariable("BEASBaseUrl");
                string roles;
                using (var client = new HttpClient())
                {
                    var url = $"{BEASBaseUrl}/Roles/{command?.UserPrincipalName}?applicationName={command?.ApplicationName}&applicationAreaName={command?.ApplicationAreaName}";
                    client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(scheme: "Bearer", parameter: accessToken);
                    roles = await client.GetStringAsync(new Uri(url)).ConfigureAwait(false);
                }

                return roles.Trim().Contains(command?.RoleName, StringComparison.InvariantCultureIgnoreCase);
            }
            catch (Exception ex)
            {

                _logger.LogError($"Error occured while trying to check BEAS roles for user - {command?.UserPrincipalName}. Details - {ex}");
                return false;
            }
            
        }

    }
}
