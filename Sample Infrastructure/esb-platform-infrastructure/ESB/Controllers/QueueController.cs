using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using ESB.Models;
using ESB.Repositories;
using ESB.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.ServiceBus.Primitives;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Microsoft.WindowsAzure.Storage.Blob;

namespace ESB.Controllers
{
    [Produces("application/json")]
    public class QueueController : Controller
    {
        // we want to ensure that the blob expires after the topic message, so we we add some extra to the TTL for the blob. Small change.
        private readonly ILogger _logger;
        private readonly IAzureRepository _azureRepository;
        private readonly IContainerCache _containerCache;
        private readonly IHttpContextAccessor _httpContentAccessor;

        public QueueController(ILogger<QueueController> logger, IAzureRepository azureRepository, IContainerCache containerCache, IHttpContextAccessor httpContentAccessor)
        {
            _logger = logger;
            _azureRepository = azureRepository;
            _containerCache = containerCache;
            _httpContentAccessor = httpContentAccessor;
        }

        [HttpPost("Queue/{queueName}/{sourceSystem}")]
        [Authorize("ESB-Write")]
        public async Task<string> PostMessage(string queueName, string sourceSystem, [FromBody] string messageBody)
        {
            string remoteIPAddress = "";
            try
            {
                remoteIPAddress = _httpContentAccessor.HttpContext.Connection.RemoteIpAddress.ToString();
                _logger.LogDebug($"PostMessage queue={queueName}, sourceSystem={sourceSystem}, remoteIPAddress={remoteIPAddress}, messageBody={messageBody}");

                BusMessageContainers containers = _containerCache.GetQueueContainers(queueName);
                string messageid = await _azureRepository.SendMessageWithBlobAsync(containers, sourceSystem, messageBody, User.Identity.Name, remoteIPAddress);
                return messageid;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Queue - PostMessage queueName={queueName}, sourceSystem={sourceSystem}, remoteIPAddress={remoteIPAddress}, messageBody={messageBody}, error:{ex.Message}");
                throw;
            }
        }

        [HttpPost("QueueWithBytePayload/{queueName}/{sourceSystem}")]
        [Authorize("ESB-Write")]
        public async Task<string> PostMessageWithBytePayload(string queueName, string sourceSystem, [FromBody] MessageBlobContents messageBody)
        {
            string remoteIPAddress = "";
            try
            {
                remoteIPAddress = _httpContentAccessor.HttpContext.Connection.RemoteIpAddress.ToString();
                _logger.LogDebug($"PostMessageWithBytePayload queue={queueName}, sourceSystem={sourceSystem}, remoteIPAddress={remoteIPAddress}, messageBody={messageBody}");

                BusMessageContainers containers = _containerCache.GetQueueContainers(queueName);
                string messageid = await _azureRepository.SendMessageWithBlobAsync(containers, sourceSystem, messageBody.Document, User.Identity.Name, remoteIPAddress,messageBody.Metadata);
                return messageid;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Queue - PostMessageWithBytePayload queueName={queueName}, sourceSystem={sourceSystem}, remoteIPAddress={remoteIPAddress}, messageBody={messageBody}, error:{ex.Message}");
                throw;
            }
        }

        [HttpPost("QueueWithFilePayload/{queueName}/{sourceSystem}/{filePath}")]
        [Authorize("ESB-Write")]
        public async Task<string> PostMessageWithFilePayload(string queueName, string sourceSystem, string filePath)
        {
            string remoteIPAddress = "";
            try
            {
                remoteIPAddress = _httpContentAccessor.HttpContext.Connection.RemoteIpAddress.ToString();
                _logger.LogDebug($"PostMessageWithFilePayload queue={queueName}, sourceSystem={sourceSystem}, remoteIPAddress={remoteIPAddress}, filePath={filePath}");

                BusMessageContainers containers = _containerCache.GetQueueContainers(queueName);
                string messageid = await _azureRepository.SendMessageWithFileAsync(containers, sourceSystem, filePath, User.Identity.Name, remoteIPAddress);
                return messageid;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Queue - PostMessageWithFilePayload queueName={queueName}, sourceSystem={sourceSystem}, remoteIPAddress={remoteIPAddress}, filePath={filePath}, error:{ex.Message}");
                throw;
            }
        }

        [HttpGet("Queue/{queueName}/BusSASToken")]
        [Authorize("ESB-Read")]
        public async Task<SecurityToken> GetBusSASToken(string queueName, [FromQuery] string appliesTo, [FromServices] IBusSASTokenProviderFactory busSASTokenProviderFactory, [FromServices] IOptions<AzureBusSettings> busSettings)
        {
            try
            {
                ITokenProvider tokenProvider = await busSASTokenProviderFactory.GetQueueTokenProviderAsync(queueName);
                SecurityToken token = await tokenProvider.GetTokenAsync(appliesTo, busSettings.Value.SASTokenTimeout);
                return token;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"GetBusSASToken Error:{ex.Message}, queueName={queueName}, appliesTo={appliesTo}");
                throw;
            }
        }

    }
}