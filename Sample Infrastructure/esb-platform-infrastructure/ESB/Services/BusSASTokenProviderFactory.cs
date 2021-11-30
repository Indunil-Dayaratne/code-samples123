using ESB.Models;
using Microsoft.Azure.Management.ResourceManager.Fluent;
using Microsoft.Azure.Management.ResourceManager.Fluent.Authentication;
using Microsoft.Azure.Management.ServiceBus.Fluent;
using Microsoft.Azure.ServiceBus.Primitives;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace ESB.Services
{
    public class BusSASTokenProviderFactory : IBusSASTokenProviderFactory
    {
        private readonly ILogger _logger;
        private readonly IMemoryCache _cache;
        private readonly AzureBusSettings _busSettings;

        private const string _listenPolicyRuleName = "listen";

        public BusSASTokenProviderFactory(ILogger<BusSASTokenProviderFactory> logger, IMemoryCache cache, IOptions<AzureBusSettings> busSettings)
        {
            _logger = logger;
            _cache = cache;
            _busSettings = busSettings.Value;
        }

        public async Task<ITokenProvider> GetQueueTokenProviderAsync(string queueName)
        {
            try
            {
                const string keyPrefix = "BusTokenProvider-";
                string key = $"{keyPrefix}{queueName}";

                TokenProvider provider = await _cache.GetOrCreateAsync(key, async entry =>
                {
                    entry.AbsoluteExpirationRelativeToNow = _busSettings.TokenProviderCacheDuration;
                    return await CreateQueueListenTokenProvideryAsync(queueName);
                });

                return provider;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"GetQueueTokenProviderAsync Error:{ex.Message}");
                throw;
            }
        }

        public async Task<ITokenProvider> GetTopicTokenProviderAsync(string topicName)
        {
            try
            {
                const string keyPrefix = "BusTokenProvider-";
                string key = $"{keyPrefix}{topicName}";

                TokenProvider provider = await _cache.GetOrCreateAsync(key, async entry =>
                {
                    entry.AbsoluteExpirationRelativeToNow = _busSettings.TokenProviderCacheDuration;
                    return await CreateTopicListenTokenProvideryAsync(topicName);
                });

                return provider;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"GetTopicTokenProviderAsync Error:{ex.Message}");
                throw;
            }
        }

        public async Task<IServiceBusNamespace> GetServiceBusNamespaceAsync()
        {
            try
            {
                _logger.LogDebug($"GetServiceBusNamespaceAsync resourceGroupName={_busSettings.ResourceGroupName}");
                AzureCredentials credentials = SdkContext.AzureCredentialsFactory.FromServicePrincipal(_busSettings.AppId, _busSettings.SecretKey, _busSettings.TenantId, AzureEnvironment.AzureGlobalCloud);
                IServiceBusManager sbManager = ServiceBusManager.Authenticate(credentials, _busSettings.SubscriptionId);

                Regex exp = new Regex("^Endpoint=sb://(?<namespace>.*?).servicebus", RegexOptions.Singleline);
                Match m = exp.Match(_busSettings.ConnectionString);

                if (!m.Success)
                    throw new ApplicationException("Could not extract bus namespace from connection string");

                string namespaceName = m.Groups["namespace"].Value;
                _logger.LogDebug($"GetServiceBusNamespaceAsync namespaceName={namespaceName}");

                IServiceBusNamespace sbNamespace = await sbManager.Namespaces.GetByResourceGroupAsync(_busSettings.ResourceGroupName, namespaceName);
                return sbNamespace;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"GetServiceBusNamespace, error:{ex.Message}");
                throw;
            }
        }

        public async Task<TokenProvider> CreateTopicListenTokenProvideryAsync(string topicName)
        {
            try
            {
                IServiceBusNamespace ns = await GetServiceBusNamespaceAsync();

                _logger.LogDebug($"CreateTopicListenTokenProvideryAsync getting Topic, topicName={topicName}");
                ITopic topic = await ns.Topics.GetByNameAsync(topicName);

                _logger.LogDebug($"CreateTopicListenTokenProvideryAsync getting Topic Authorization Rule and keys, ruleName={_listenPolicyRuleName}");
                ITopicAuthorizationRule rule = await topic.AuthorizationRules.GetByNameAsync(_listenPolicyRuleName);
                IAuthorizationKeys keys = await rule.GetKeysAsync();

                _logger.LogDebug($"CreateTopicListenTokenProvideryAsync creating SASToken provider, SASTokenDuration={_busSettings.SASTokenDuration}");
                TokenProvider provider = TokenProvider.CreateSharedAccessSignatureTokenProvider(_listenPolicyRuleName, keys.PrimaryKey, _busSettings.SASTokenDuration);
                return provider;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"CreateTopicListenTokenProvideryAsync, topicName={topicName}, error:{ex.Message}");
                throw;
            }
        }

        public async Task<TokenProvider> CreateQueueListenTokenProvideryAsync(string queueName)
        {
            try
            {
                IServiceBusNamespace ns = await GetServiceBusNamespaceAsync();

                _logger.LogDebug($"CreateQueueListenTokenProvideryAsync getting Queue, queueName={queueName}");
                IQueue queue = await ns.Queues.GetByNameAsync(queueName);

                _logger.LogDebug($"CreateQueueListenTokenProvideryAsync getting Queue Authorization Rule and keys, ruleName={_listenPolicyRuleName}");
                IQueueAuthorizationRule rule = await queue.AuthorizationRules.GetByNameAsync(_listenPolicyRuleName);
                IAuthorizationKeys keys = await rule.GetKeysAsync();

                _logger.LogDebug($"CreateQueueListenTokenProvideryAsync creating SASToken provider, SASTokenDuration={_busSettings.SASTokenDuration}");
                TokenProvider provider = TokenProvider.CreateSharedAccessSignatureTokenProvider(_listenPolicyRuleName, keys.PrimaryKey, _busSettings.SASTokenDuration);
                return provider;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"CreateQueueListenTokenProvideryAsync, queueName={queueName}, error:{ex.Message}");
                throw;
            }
        }

    }
}
