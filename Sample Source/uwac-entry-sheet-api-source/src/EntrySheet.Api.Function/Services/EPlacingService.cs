using EntrySheet.Api.Function.Helpers;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;

namespace EntrySheet.Api.Function.Services
{
    public class EPlacingService : IEPlacingService
    {
        private readonly ILogger<IEPlacingService> _logger;
        private readonly string _dataFilePath;

        public EPlacingService(ILogger<EPlacingService> logger,
            IAssemblyHelper assemblyHelper)
        {
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
            var assemblyHelperProvided = assemblyHelper ?? throw new ArgumentNullException(nameof(assemblyHelper));
            _dataFilePath = Path.Combine(assemblyHelperProvided.GetLocationOfExecutingAssembly(), "Data\\E-Placing.json");
        }

        public async Task<IEnumerable<string>> GetEPlacingValuesAsync()
        {
            try
            {
                string json = File.ReadAllText(_dataFilePath);
                var ePlacingValues = JsonConvert.DeserializeObject<List<string>>(json);
                return ePlacingValues;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error while fetching E-Placing values Exception Message {ex.Message}");
                return null;
            }
        }
    }
}
