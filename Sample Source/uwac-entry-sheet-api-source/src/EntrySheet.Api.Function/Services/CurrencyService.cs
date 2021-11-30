using EntrySheet.Api.Function.Helpers;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;

namespace EntrySheet.Api.Function.Services
{
    public class CurrencyService : ICurrencyService
    {
        private readonly ILogger<CurrencyService> _logger;
        private readonly IAssemblyHelper _assemblyHelper;
        private readonly string _dataFilePath;

        public CurrencyService(ILogger<CurrencyService> logger, 
            IAssemblyHelper assemblyHelper)
        {
            _logger = logger;
            _assemblyHelper = assemblyHelper;
            _dataFilePath = Path.Combine(_assemblyHelper.GetLocationOfExecutingAssembly(), "Data\\Currencies.json");

        }

        public async Task<List<string>> GetCurrencyAsync()
        {
            try
            {
                string json = File.ReadAllText(_dataFilePath);
                var currencyList = JsonConvert.DeserializeObject<List<string>>(json);
                return currencyList;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error while fetching currency values Exception Message {ex.Message}");
                return null;
            }
        }
    }
}
