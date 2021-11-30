
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Protocols;
using Microsoft.IdentityModel.Protocols.OpenIdConnect;
using Microsoft.IdentityModel.Tokens;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace Coreact.Infrastructure.Base.Services
{
    public class BearerTokenValidator : IBearerTokenValidator
    {
        private readonly ILogger _logger;
        private readonly IFunctionCache _functionCache;
        private readonly IConfigurationManager<OpenIdConnectConfiguration> _configurationManager;

        public BearerTokenValidator(ILogger logger,IFunctionCache cache)
        {
            _logger = logger;
            _functionCache = cache;

            string wellKnownEndpoint = "https://login.microsoftonline.com/britinsurance.com/v2.0/.well-known/openid-configuration";

            var documentRetriever = new HttpDocumentRetriever { RequireHttps = wellKnownEndpoint.StartsWith("https://") };
            _configurationManager = new ConfigurationManager<OpenIdConnectConfiguration>(
                wellKnownEndpoint,
                new OpenIdConnectConfigurationRetriever(),
                documentRetriever
            );
        }

        private async Task<ClaimsPrincipal> ValidateAsync(string authorizationHeader)
        {
            // check for bearer token in header
            if (!authorizationHeader.StartsWith("Bearer "))
                return null;

            string bearerToken = authorizationHeader.Substring("Bearer ".Length);

            // connect to config
            OpenIdConnectConfiguration config = await _configurationManager.GetConfigurationAsync(CancellationToken.None);

            // TBD - Need to find way of populating Audience locally so can be validated
            var audience = Environment.GetEnvironmentVariable("audience");

            var validationParameter = new TokenValidationParameters()
            {
                RequireSignedTokens = true,
                ValidAudience = audience,
                ValidateAudience = false,
                ValidIssuer = config.Issuer,
                ValidateIssuer = true,
                ValidateIssuerSigningKey = true,
                ValidateLifetime = true,
                IssuerSigningKeys = config.SigningKeys
            };

            ClaimsPrincipal result = null;
            var tries = 0;

            while (result == null && tries <= 1)
            {
                try
                {
                    var handler = new JwtSecurityTokenHandler();

                    result = handler.ValidateToken(bearerToken, validationParameter, out SecurityToken _);

                }
                catch (SecurityTokenSignatureKeyNotFoundException ex)
                {
                    // This exception is thrown if the signature key of the JWT could not be found.
                    // This could be the case when the issuer changed its signing keys, so we trigger a 
                    // refresh and retry validation.
                    //ConfigurationManager.RequestRefresh();

                    _logger.LogError(ex, "Security token not found"); 
                    tries++;
                }
                catch (SecurityTokenException ex)
                {
                    _logger.LogError(ex,"Error when validating Token");

                    return null;
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error when validating Token");

                    return null;
                }
            }

            return result;
        }

        public async Task<bool> ValidateRequest(HttpRequest req)
        {
            if (!req.Headers.ContainsKey("Authorization"))
                return false;

            var validationResult = await this.ValidateAsync(req.Headers["Authorization"]);

            if (validationResult == null)
                return false;

            if (!validationResult.Identity.IsAuthenticated)
                return false;

            return true;
        }
    }
}
