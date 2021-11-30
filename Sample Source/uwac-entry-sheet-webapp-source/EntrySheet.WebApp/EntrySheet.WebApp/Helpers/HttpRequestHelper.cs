using System.Threading.Tasks;
using BritServices.BearerTokenHelper.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace EntrySheet.WebApp.Helpers
{
    public class HttpRequestHelper : IHttpRequestHelper
    {
        private readonly ILogger<HttpRequestHelper> _logger;
        private readonly IBearerTokenHelper _bearerTokenHelper;
        private readonly IAuthenticationHelper _authenticationHelper;
        private readonly BeasOptions _beasOptions;

        public HttpRequestHelper(IBearerTokenHelper bearerTokenHelper,
            IAuthenticationHelper authenticationHelper,
            ILogger<HttpRequestHelper> logger,
            IOptions<BeasOptions> beasOptions)
        {
            _logger = logger;
            _bearerTokenHelper = bearerTokenHelper;
            _authenticationHelper = authenticationHelper;
            _beasOptions = beasOptions.Value;
        }


        public async Task<bool> AuthenticateRequestAsync(HttpRequest request)
        {
            var userName = _bearerTokenHelper.ExtractUserDetailsFromJWT(request)?.UniqueName;

            _logger.LogTrace($"A username {userName}.");

            if (string.IsNullOrWhiteSpace(userName))
            {
                _logger.LogInformation("A username was not specified in the calling token.");
                return false;
            }

            var isAccessValid = await _authenticationHelper?.UserHasAccessAsync(userName);

            if (!isAccessValid)
            {
                _logger.LogInformation("The user ({UserName}) does not have BEAS permissions to access {ApplicationName} - {ApplicationArea} - {ApplicationRole}.", userName, _beasOptions.ApplicationName, _beasOptions.ApplicationArea, _beasOptions.ApplicationRole);
                return false;
            }

            return true;
        }

        public async Task<bool> CheckUserHasReadAccessAsync(HttpRequest request)
        {
            var userName = _bearerTokenHelper.ExtractUserDetailsFromJWT(request)?.UniqueName;

            _logger.LogTrace($"A username {userName}.");

            if (string.IsNullOrWhiteSpace(userName))
            {
                _logger.LogInformation("A username was not specified in the calling token.");
                return false;
            }

            var hasReadAccess = await _authenticationHelper?.UserHasReadAccessAsync(userName);

            if (!hasReadAccess)
            {
                _logger.LogInformation("The user ({UserName}) does not have BEAS permissions to access {ApplicationName} - {ApplicationArea} - {ApplicationRole}.", userName, _beasOptions.ApplicationNameInternal, _beasOptions.ApplicationAreaInternal, _beasOptions.ApplicationRoleReadOnly);
                return false;
            }

            return true;
        }

        public async Task<bool> CheckUserHasWriteAccessAsync(HttpRequest request)
        {
            var userName = _bearerTokenHelper.ExtractUserDetailsFromJWT(request)?.UniqueName;

            _logger.LogTrace($"A username {userName}.");

            if (string.IsNullOrWhiteSpace(userName))
            {
                _logger.LogInformation("A username was not specified in the calling token.");
                return false;
            }

            var hasReadAccess = await _authenticationHelper?.UserHasWriteAccessAsync(userName);

            if (!hasReadAccess)
            {
                _logger.LogInformation("The user ({UserName}) does not have BEAS permissions to access {ApplicationName} - {ApplicationArea} - {ApplicationRole}.", userName, _beasOptions.ApplicationNameInternal, _beasOptions.ApplicationAreaInternal, _beasOptions.ApplicationRoleWrite);
                return false;
            }

            return true;
        }
    }
}
