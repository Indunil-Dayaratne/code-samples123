using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using EntrySheet.Api.Function.Helpers;
using EntrySheet.Api.Function.Settings;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using EclipsePolicy = Brit.BritCacheEntities.Models.Eclipse.Policy;

namespace EntrySheet.Api.Function.Clients
{
    public class BritCacheClient: IBritCacheClient
    {
        private readonly ILogger<BritCacheClient> _logger;
        private readonly ITokenServiceHelper _tokenServiceHelper;
        private readonly HttpClient _client;
        private readonly BritCacheOptions _britCacheOptions;

        public BritCacheClient(ILogger<BritCacheClient> logger,
            IHttpClientFactory httpClientFactory,
            IOptions<BritCacheOptions> britCacheOptions,
            ITokenServiceHelper tokenServiceHelper)
        {
            _britCacheOptions = britCacheOptions.Value;
            _logger = logger;
            _tokenServiceHelper = tokenServiceHelper;
            _client = httpClientFactory.CreateClient("BritCacheService");
        }

        public async Task<IEnumerable<EclipsePolicy>> GetEclipsePoliciesAsync(int[] britPolicyIds)
        {
            if (britPolicyIds == null || !britPolicyIds.Any())
            {
                throw new ArgumentNullException(nameof(britPolicyIds));
            }

            var accessToken = await _tokenServiceHelper.GetAzureAccessTokenAsync(_britCacheOptions.ClientId, _britCacheOptions.AzureConnectionString);

            var requestData = JsonConvert.SerializeObject(new
            {
                Filter = new
                {
                    FilterType = "ById",
                    Ids = britPolicyIds
                }
            });

            var urlPart = "Policies";
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
                        var policies = JsonConvert.DeserializeObject<IEnumerable<EclipsePolicy>>(json);

                        return policies;
                    }
                    else
                    {
                        _logger.LogError("GetRelatedPolicies: Error when getting Eclipse BritCache policies");
                        return null;
                    }
                }
            }
        }
    }
}
