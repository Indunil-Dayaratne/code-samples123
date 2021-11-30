using System.Diagnostics.CodeAnalysis;
using BritServices.BearerTokenHelper.Models;
using BritServices.BearerTokenHelper.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System.Threading.Tasks;
using EntrySheet.Api.Function.Settings;

namespace EntrySheet.Api.Function.Helpers
{
    [ExcludeFromCodeCoverage]
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

        public async Task<(bool, AADUserDetail)> AuthenticateRequestAsync(HttpRequest request)
        {
            if (request.Host.Host == "localhost")
            {
                return (true, new AADUserDetail { Name = "localhost", UPN = "localhost" });
            }

            var userDetail = _bearerTokenHelper.ExtractUserDetailsFromJWT(request);

            var userName = userDetail?.UniqueName;

            if (string.IsNullOrWhiteSpace(userName))
            {
                _logger.LogInformation("A username was not specified in the calling token.");
                return (false, null);
            }

            userDetail.Name = $"{userDetail?.GivenName} {userDetail?.FamilyName}";

            var accessToken = await _authenticationHelper?.GetAccessTokenAsync();
            var isAccessValid = await _authenticationHelper?.UserHasAccessAsync(accessToken, userName);

            if (!isAccessValid)
            {
                _logger.LogInformation("The user ({UserName}) does not have BEAS permissions to access {ApplicationName} - {ApplicationArea} - {ApplicationRole}.", userName, _beasOptions.ApplicationName, _beasOptions.ApplicationArea, _beasOptions.ApplicationRole);
                return (false, null);
            }

            return (true, userDetail);
        }
    }
}
