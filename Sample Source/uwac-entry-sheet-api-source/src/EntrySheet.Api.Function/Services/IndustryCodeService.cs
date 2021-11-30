using EntrySheet.Api.Function.Helpers;
using EntrySheet.Api.Function.Models;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;

namespace EntrySheet.Api.Function.Services
{
    public class IndustryCodeService : IIndustryCodeService
    {
        private readonly ILogger<IIndustryCodeService> _logger;
        private readonly IAssemblyHelper _assemblyHelper;
        private readonly string _dataFilePath;

        public IndustryCodeService(ILogger<IndustryCodeService> logger,
            IAssemblyHelper assemblyHelper)
        {
            _logger = logger;
            _assemblyHelper = assemblyHelper;
            _dataFilePath = Path.Combine(_assemblyHelper.GetLocationOfExecutingAssembly(), "Data\\IndustryCodes.json");
        }


        public async Task<IEnumerable<IndustryCodeModel>> GetIndustryCodesAsync()
        {
            try
            {
                string json = File.ReadAllText(_dataFilePath);
                var industryCodes = JsonConvert.DeserializeObject<List<IndustryCodeModel>>(json);
                return industryCodes;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error while fetching Industry Code values Exception Message {ex.Message}");
                return null;
            }
        }
    }
}
