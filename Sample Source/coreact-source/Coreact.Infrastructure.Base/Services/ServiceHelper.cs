
using Microsoft.Azure.Services.AppAuthentication;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace Coreact.Infrastructure.Base.Services
{
    /// <summary>
    /// Methods to help access functions and properties of the execution environment
    /// </summary>
    public class ServiceHelper : IServiceHelper
    {
        private readonly ILogger _logger;

        public ServiceHelper(ILogger logger)
        {
            _logger = logger;
        }

        /// <summary>
        /// Tries to acquire an AccessToken for the given Resource
        /// </summary>
        /// <param name="resourceId"></param>
        /// <returns></returns>
        public async Task<string> GetServiceAccessTokenForResource(string resourceId)
        {
            _logger.LogTrace($"Getting token for resource:{resourceId}");

            var azureServiceTokenProvider = new AzureServiceTokenProvider();

            return await azureServiceTokenProvider.GetAccessTokenAsync(resourceId, Environment.GetEnvironmentVariable("tenantid"));
        }

        
  }
}
