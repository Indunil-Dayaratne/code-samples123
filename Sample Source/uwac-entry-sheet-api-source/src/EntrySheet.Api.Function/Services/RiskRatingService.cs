using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using EntrySheet.Api.Function.Helpers;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace EntrySheet.Api.Function.Services
{
    public class RiskRatingService : IRiskRatingService
    {
        private readonly ILogger<RiskRatingService> _logger;
        private readonly IAssemblyHelper _assemblyHelper;
        private readonly string _dataFilePath;

        public RiskRatingService(ILogger<RiskRatingService> logger, IAssemblyHelper assemblyHelper)
        {
            _logger = logger;
            _assemblyHelper = assemblyHelper;
            _dataFilePath = Path.Combine(_assemblyHelper.GetLocationOfExecutingAssembly(), "Data\\RiskRatings.json");
        }

        public List<string> GetRiskRatings()
        {
            try
            {
                var json = File.ReadAllText(_dataFilePath);
                var riskRatings = JsonConvert.DeserializeObject<List<string>>(json);
                return riskRatings;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error while fetching Risk Ratings Exception Message {ex.Message}");
                throw;
            }
        }
    }
}