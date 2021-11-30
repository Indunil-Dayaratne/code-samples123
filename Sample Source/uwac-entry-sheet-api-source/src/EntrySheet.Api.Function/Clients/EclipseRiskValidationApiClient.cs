using Brit.Risk.Entities;
using EntrySheet.Api.Function.Helpers;
using EntrySheet.Api.Function.Models;
using EntrySheet.Api.Function.Settings;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using System.Text.Json;

namespace EntrySheet.Api.Function.Clients
{
    public class EclipseRiskValidationApiClient : IEclipseRiskValidationApiClient
    {
        private readonly ILogger<EclipseRiskValidationApiClient> _logger;
        private readonly ITokenServiceHelper _tokenServiceHelper;
        private readonly EclipseRiskValidationApiOptions _eclipseRiskValidationApiOptions;
        private readonly HttpClient _client;

        public EclipseRiskValidationApiClient(ILogger<EclipseRiskValidationApiClient> logger,
            ITokenServiceHelper tokenServiceHelper,
            IOptions<EclipseRiskValidationApiOptions> eclipseRiskValidationApiOptions,
            IHttpClientFactory httpClientFactory)
        {
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
            _tokenServiceHelper = tokenServiceHelper ?? throw new ArgumentNullException(nameof(tokenServiceHelper));
            _eclipseRiskValidationApiOptions = eclipseRiskValidationApiOptions?.Value ?? throw new ArgumentNullException(nameof(eclipseRiskValidationApiOptions));
            var httpClientFactoryProvided = httpClientFactory ?? throw new ArgumentNullException(nameof(httpClientFactory));
            _client = httpClientFactoryProvided.CreateClient("EclipseRiskValidationService");
            _client.BaseAddress = new Uri(_eclipseRiskValidationApiOptions.BaseUrl);
        }

        public async Task<RiskValidationModel> ValidateGpmDetailsAsync(Placing placing, string policyReference)
        {
            try
            {
                if (placing == null)
                {
                    throw new ArgumentNullException(nameof(placing));
                }

                if (string.IsNullOrEmpty(policyReference))
                {
                    throw new ArgumentNullException(nameof(policyReference));
                }

                var accessToken = await _tokenServiceHelper.GetAzureAccessTokenAsync(_eclipseRiskValidationApiOptions.ClientId, _eclipseRiskValidationApiOptions.AzureConnectionString);

                var requestData = JsonSerializer.Serialize(placing, JsonOptions.JsonSerializerOptions);

                var urlPart = "/api/Eclipse/Risk/Validate";
                _client.DefaultRequestHeaders.Accept.Clear();
                _client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
                _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);

                using (var stringContent = new StringContent(requestData, Encoding.UTF8, "application/json"))
                {
                    using (var response = await _client.PostAsync(urlPart, stringContent))
                    {
                        if (response.IsSuccessStatusCode)
                        {
                            var json = await response.Content.ReadAsStringAsync();
                            var validationModel = JsonSerializer.Deserialize<RiskValidationModel>(json, JsonOptions.JsonSerializerOptions);
                            return validationModel;
                        }

                        var message = $"ValidateGpmDetailsAsync: Error validating placing details for policy reference - {policyReference}";
                        _logger.LogError(message);
                        throw new ApplicationException(message);
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"ValidateGpmDetailsAsync: Error validating placing details for policy reference - {{policyReference}}. Exception {{Message}}", policyReference, ex.Message);
                throw;
            }
        }
    }
}