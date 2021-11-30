using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ESB.Models;
using ESB.Repositories;
using ESB.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.ServiceBus;
using Microsoft.Azure.ServiceBus.Primitives;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Microsoft.WindowsAzure.Storage.Blob;

namespace ESB.Controllers
{
    [Produces("application/json")]
    public class TopicController : Controller
    {
        private readonly ILogger _logger;
        private readonly IAzureRepository _azureRepository;
        private readonly IContainerCache _containerCache;
        private readonly IHttpContextAccessor _httpContentAccessor;

        public TopicController(ILogger<TopicController> logger, IAzureRepository azureRepository, IContainerCache containerCache, IHttpContextAccessor httpContentAccessor)
        {
            _logger = logger;
            _azureRepository = azureRepository;
            _containerCache = containerCache;
            _httpContentAccessor = httpContentAccessor;
        }

        [HttpPost("Topic/{topicName}/{sourceSystem}")]
        [Authorize("ESB-Write")]
        public async Task<string> PostMessageAsync([FromRoute] string topicName, [FromRoute] string sourceSystem, [FromBody] string messageBody)
        {
            //Small change to test VSTS builds
            string remoteIPAddress = "";
            try
            {
                remoteIPAddress = _httpContentAccessor.HttpContext.Connection.RemoteIpAddress.ToString();
                _logger.LogDebug($"PostMessage topic={topicName}, sourceSystem={sourceSystem}, remoteIPAddress={remoteIPAddress}, messageBody={messageBody}");

                BusMessageContainers containers = _containerCache.GetTopicContainers(topicName);
                string messageid = await _azureRepository.SendMessageWithBlobAsync(containers, sourceSystem, messageBody, User.Identity.Name, remoteIPAddress);
                return messageid;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Topic - PostMessage topicName={topicName}, sourceSystem={sourceSystem}, remoteIPAddress={remoteIPAddress}, messageBody={messageBody}, error:{ex.Message}");
                throw;
            }
        }

        [HttpPost("TopicWithBytePayload/{topicName}/{sourceSystem}")]
        [Authorize("ESB-Write")]
        public async Task<string> PostMessageWithBytePayload([FromRoute] string topicName, [FromRoute] string sourceSystem, [FromBody] MessageBlobContents messageBody)
        {
            string remoteIPAddress = "";
            try
            {
                remoteIPAddress = _httpContentAccessor.HttpContext.Connection.RemoteIpAddress.ToString();
                _logger.LogDebug($"PostMessageWithBytePayload topic={topicName}, sourceSystem={sourceSystem}, remoteIPAddress={remoteIPAddress}, messageBody={messageBody}");

                BusMessageContainers containers = _containerCache.GetTopicContainers(topicName);
                string messageid = await _azureRepository.SendMessageWithBlobAsync(containers, sourceSystem, messageBody.Document, User.Identity.Name, remoteIPAddress,messageBody.Metadata);
                return messageid;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Topic - PostMessageWithBytePayload topicName={topicName}, sourceSystem={sourceSystem}, remoteIPAddress={remoteIPAddress}, messageBody={messageBody}, error:{ex.Message}");
                throw;
            }
        }

        [HttpPost("TopicWithFilePayload/{topicName}/{sourceSystem}/{filePath}")]
        [Authorize("ESB-Write")]
        public async Task<string> PostMessageWithFilePayload([FromRoute] string topicName, [FromRoute] string sourceSystem, string filePath)
        {
            string remoteIPAddress = "";
            try
            {
                remoteIPAddress = _httpContentAccessor.HttpContext.Connection.RemoteIpAddress.ToString();
                _logger.LogDebug($"PostMessageWithFilePayload topic={topicName}, sourceSystem={sourceSystem}, remoteIPAddress={remoteIPAddress}, filePath={filePath}");

                BusMessageContainers containers = _containerCache.GetTopicContainers(topicName);
                string messageid = await _azureRepository.SendMessageWithBlobAsync(containers, sourceSystem, filePath, User.Identity.Name, remoteIPAddress);
                return messageid;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Topic - PostMessageWithFilePayload topicName={topicName}, sourceSystem={sourceSystem}, remoteIPAddress={remoteIPAddress}, filePath={filePath}, error:{ex.Message}");
                throw;
            }
        }

        [HttpPost("TopicWithMetadata/{topicName}/{sourceSystem}")]
        [Authorize("ESB-Write")]
        public async Task<string> PostMessageWithMetadataAsync([FromRoute] string topicName, [FromRoute] string sourceSystem, [FromBody] BusMessage busMessage)
        {
            string remoteIPAddress = "";
            try
            {
                remoteIPAddress = _httpContentAccessor.HttpContext.Connection.RemoteIpAddress.ToString();
                _logger.LogDebug($"PostMessage topic={topicName}, sourceSystem={sourceSystem}, remoteIPAddress={remoteIPAddress}, busMessage={busMessage}");

                BusMessageContainers containers = _containerCache.GetTopicContainers(topicName);
                string messageid = await _azureRepository.SendMessageWithMetadataAsync(containers, sourceSystem, busMessage, User.Identity.Name, remoteIPAddress);
                return messageid;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Topic - PostMessage topicName={topicName}, sourceSystem={sourceSystem}, remoteIPAddress={remoteIPAddress}, busMessage={busMessage}, error:{ex.Message}");
                throw;
            }
        }

        [HttpGet("Topic/{topicName}/BusSASToken")]
        [Authorize("ESB-Read")]
        public async Task<SecurityToken> GetBusSASToken([FromRoute] string topicName, [FromQuery] string appliesTo, [FromServices] IBusSASTokenProviderFactory busSASTokenProviderFactory, [FromServices] IOptions<AzureBusSettings> busSettings)
        {
            try
            {
                ITokenProvider tokenProvider = await busSASTokenProviderFactory.GetTopicTokenProviderAsync(topicName);
                SecurityToken token = await tokenProvider.GetTokenAsync(appliesTo, busSettings.Value.SASTokenDuration);
                return token;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"GetBusSASToken Error:{ex.Message}, topicName={topicName}, appliesTo={appliesTo}");
                throw;
            }
        }

    }
}