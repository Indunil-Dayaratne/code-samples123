using BritServices.BearerTokenHelper.Configuration;
using BritServices.BearerTokenHelper.Constants;
using BritServices.BearerTokenHelper.Models;
using BritServices.ConfigurationHelper;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Logging;
using Microsoft.IdentityModel.Protocols;
using Microsoft.IdentityModel.Protocols.OpenIdConnect;
using Microsoft.IdentityModel.Tokens;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Threading;
using System.Threading.Tasks;

namespace BritServices.BearerTokenHelper.Services
{
    public class BearerTokenHelper : IBearerTokenHelper
    {
        private readonly ILogger<BearerTokenHelper> _logger;
        private readonly ISettings _settings;
        private readonly IConfigurationManager<OpenIdConnectConfiguration> _configurationManager;

        public BearerTokenHelper(ILogger<BearerTokenHelper> logger, ISettings settings = null)
        {
            _logger = logger;
            IdentityModelEventSource.ShowPII = true;
            if (settings == null)
            {
                IConfigurationReader configurationReader = new ConfigurationReader();
                _settings = configurationReader.InitializeProperties<Settings>();
            }
            else
            {
                _settings = settings;
            }

            string wellKnownEndpoint = _settings.OpenIdConfigurationEndPoint;

            var documentRetriever = new HttpDocumentRetriever { RequireHttps = wellKnownEndpoint.StartsWith("https://") };
            _configurationManager = new ConfigurationManager<OpenIdConnectConfiguration>(
                wellKnownEndpoint,
                new OpenIdConnectConfigurationRetriever(),
                documentRetriever
            );

        }

        private async Task<ClaimsPrincipal> ValidateAsync(string bearerToken)
        {
            var issuers = _settings.ValidIssuers;
            List<string> validIssuers = new List<string>(issuers.Split(','));
            // check for bearer token in header
            if (string.IsNullOrEmpty(bearerToken))
            {
                return null;
            }

            // connect to config
            OpenIdConnectConfiguration config = await _configurationManager.GetConfigurationAsync(CancellationToken.None);

            // TBD - Need to find way of populating Audience locally so can be validated
            var audience = _settings.Audience;

            var validationParameter = new TokenValidationParameters
            {
                RequireSignedTokens = true,
                ValidAudience = audience ?? string.Empty,
                ValidateAudience = false,
                ValidIssuers = validIssuers,
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
                    _logger.LogError(ex, "Security token not found");
                    tries++;
                }
                catch (SecurityTokenException ex)
                {
                    _logger.LogError(ex, "Error when validating Token");

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

        public async Task<bool> ValidateBearerTokenAsync(string bearerToken)
        {
            if (string.IsNullOrEmpty(bearerToken))
            {
                return false;
            }


            var validationResult = await this.ValidateAsync(bearerToken);

            if (validationResult == null)
            {
                return false;
            }

            return true;
        }

        public AADUserDetail ExtractUserDetailsFromJWT(HttpRequest req)
        {
            AADUserDetail userDetail = new AADUserDetail();
            try
            {
                if (!req.Headers.ContainsKey("Authorization"))
                {
                    return null;
                }
                else
                {
                    string authorizationHeader = req.Headers["Authorization"];
                    if (!authorizationHeader.StartsWith("Bearer "))
                    {
                        return null;
                    }

                    string bearerToken = authorizationHeader.Substring("Bearer ".Length);
                    var jwtHandler = new JwtSecurityTokenHandler();
                    var readableToken = jwtHandler.CanReadToken(bearerToken);

                    if (readableToken)
                    {
                        var token = jwtHandler.ReadJwtToken(bearerToken);

                        //Extract the payload of the JWT
                        var claims = token.Claims;
                        foreach (Claim claim in claims)
                        {
                            var claimType = claim.Type.ToLower();
                            switch (claimType)
                            {
                                case ClaimsExtension.FAMILY_NAME:
                                    userDetail.FamilyName = claim.Value;
                                    break;
                                case ClaimsExtension.GIVEN_NAME:
                                    userDetail.GivenName = claim.Value;
                                    break;
                                case ClaimsExtension.NAME:
                                    userDetail.Name = claim.Value;
                                    break;
                                case ClaimsExtension.UNIQUE_NAME:
                                    userDetail.UniqueName = claim.Value;
                                    break;
                                case ClaimsExtension.UPN:
                                    userDetail.UPN = claim.Value;
                                    break;
                                case ClaimsExtension.OID:
                                    userDetail.ObjectId = claim.Value;
                                    break;
                                case ClaimsExtension.EMAIL:
                                    userDetail.Email = claim.Value;
                                    break;
                                default:
                                    break;
                            }
                        }
                        Uri uri = new Uri(token.Issuer);
                        //B2C issuer : https://britnonprodb2c.b2clogin.com/85a14b60-5bb6-411e-873f-b6bdd20d687d/v2.0/
                        //we should check for domain b2cLogin.com
                        userDetail.IsExternalUser = uri.Host.EndsWith("b2cLogin.com", StringComparison.InvariantCultureIgnoreCase);
                        return userDetail;
                    }
                    return null;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error while decoding Token");
                throw;
            }

        }

    }
}
