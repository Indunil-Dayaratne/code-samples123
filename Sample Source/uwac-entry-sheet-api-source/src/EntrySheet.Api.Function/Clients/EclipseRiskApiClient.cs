using System;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using Brit.Risk.Entities;
using EntrySheet.Api.Function.Helpers;
using EntrySheet.Api.Function.Models;
using EntrySheet.Api.Function.Settings;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System.Text.Json;

namespace EntrySheet.Api.Function.Clients
{
    public class EclipseRiskApiClient : IEclipseRiskApiClient
    {
        private readonly ILogger<EclipseRiskApiClient> _logger;
        private readonly ITokenServiceHelper _tokenServiceHelper;
        private readonly EclipseRiskApiOptions _eclipseRiskApiOptions;
        private readonly HttpClient _client;

        public EclipseRiskApiClient(ILogger<EclipseRiskApiClient> logger,
            IOptions<EclipseRiskApiOptions> eclipseRiskApiOptions,
            IHttpClientFactory httpClientFactory,
            ITokenServiceHelper tokenServiceHelper)
        {
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
            _eclipseRiskApiOptions = eclipseRiskApiOptions?.Value ?? throw new ArgumentNullException(nameof(eclipseRiskApiOptions));
            _tokenServiceHelper = tokenServiceHelper ?? throw new ArgumentNullException(nameof(tokenServiceHelper));
            var httpClientFactoryProvided = httpClientFactory ?? throw new ArgumentNullException(nameof(httpClientFactory));
            _client = httpClientFactoryProvided.CreateClient("EclipseRiskService");
            _client.BaseAddress = new Uri(_eclipseRiskApiOptions.BaseUrl);
        }

        public async Task<Placing> GetEclipseRiskGpmDetailsAsync(string policyReference)
        {
            try
            {
                if (string.IsNullOrEmpty(policyReference))
                {
                    throw new ArgumentNullException(nameof(policyReference));
                }

                var urlPart = $"/api/Eclipse/Risk/{policyReference}";
                var accessToken = await _tokenServiceHelper.GetAzureAccessTokenAsync(_eclipseRiskApiOptions.ClientId, _eclipseRiskApiOptions.AzureConnectionString);

                var request = new HttpRequestMessage(HttpMethod.Get, _eclipseRiskApiOptions.BaseUrl + urlPart);
                request.Headers.Accept.Clear();
                request.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
                request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);

                using (var response = await _client.SendAsync(request))
                {
                    if (response.IsSuccessStatusCode)
                    {
                        var json = await response.Content.ReadAsStringAsync();
                        if (!string.IsNullOrEmpty(json))
                        {
                            var placing = JsonSerializer.Deserialize<Placing>(json, JsonOptions.JsonSerializerOptions);

                            if (placing == null)
                            {
                                throw new ApplicationException("GetEclipseRiskGpmDetailsAsync: Error when deserializing GPM data");
                            }

                            return placing;
                        }
                        else
                        {
                            throw new ApplicationException("GetEclipseRiskGpmDetailsAsync: Error when deserializing GPM data");
                        }
                    }

                    string message = $"GetEclipseRiskGpmDetailsAsync: Error when getting eclipse policy risk details, for policy reference - {policyReference}";
                    _logger.LogError(message);
                    throw new ApplicationException(message);
                }

            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    $"GetEclipseRiskGpmDetails: Error when getting eclipse policy risk details, for policy reference - {{policyReference}}. Exception {{Message}}", policyReference, ex.Message);
                throw;
            }
        }

        public async Task<CreateRiskResponseModel> SubmitCreateRiskRequestAsync(RiskMapperModel riskMapperModel, string policyReference)
        {
            try
            {
                if (riskMapperModel == null)
                {
                    throw new ArgumentNullException(nameof(riskMapperModel));
                }
                if (string.IsNullOrEmpty(policyReference))
                {
                    throw new ArgumentNullException(nameof(policyReference));
                }

                var accessToken = await _tokenServiceHelper.GetAzureAccessTokenAsync(_eclipseRiskApiOptions.ClientId, _eclipseRiskApiOptions.AzureConnectionString);

                var requestData = JsonSerializer.Serialize(riskMapperModel, JsonOptions.JsonSerializerOptions);
                

                var urlPart = "/api/Eclipse/Risk";
                _client.DefaultRequestHeaders.Accept.Clear();
                _client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
                _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);

                using (var stringContent = new StringContent(requestData, Encoding.UTF8, "application/json"))
                {
                    using (var response = await _client.PostAsync(_eclipseRiskApiOptions.BaseUrl + urlPart, stringContent))
                    {
                        if (response.IsSuccessStatusCode)
                        {
                            var json = await response.Content.ReadAsStringAsync();
                            var messageId = JsonSerializer.Deserialize<string>(json, JsonOptions.JsonSerializerOptions);

                            return new CreateRiskResponseModel {MessageId = messageId};
                        }

                        if (response.StatusCode == HttpStatusCode.UnprocessableEntity)
                        {
                            var json = await response.Content.ReadAsStringAsync();
                            var riskValidationModel = JsonSerializer.Deserialize<RiskValidationModel>(json, JsonOptions.JsonSerializerOptions);

                            return new CreateRiskResponseModel {RiskValidationModel = riskValidationModel};
                        }

                        var message = $"SubmitCreateRiskRequest: Error submitting a create risk request for policy reference - {policyReference}";
                        _logger.LogError(message);
                        throw new ApplicationException(message);
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"SubmitCreateRiskRequest: Error submitting a create risk request for policy reference - {{policyReference}}. Exception {{Message}}", policyReference, ex.Message);
                throw;
            }
        }
    }
}
