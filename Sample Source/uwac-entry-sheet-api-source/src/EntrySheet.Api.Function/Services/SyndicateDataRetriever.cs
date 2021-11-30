using System;
using System.Collections.Generic;
using System.IO;
using EntrySheet.Api.Function.Helpers;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace EntrySheet.Api.Function.Services
{
    public class SyndicateDataRetriever : ISyndicateDataRetriever
    {
        private readonly ILogger<SyndicateDataRetriever> _logger;
        private readonly string _dataFilePath;
        private List<string> _includedSyndicates;

        public SyndicateDataRetriever(ILogger<SyndicateDataRetriever> logger, IAssemblyHelper assemblyHelper)
        {
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
            var assemblyHelperProvided = assemblyHelper ?? throw new ArgumentNullException(nameof(assemblyHelper));
            _dataFilePath = Path.Combine(assemblyHelperProvided.GetLocationOfExecutingAssembly(), "Data\\IncludedSyndicates.json");

            _includedSyndicates = GetIncludedSyndicates();
        }

        public List<string> GetIncludedSyndicates()
        {
            try
            {
                if(_includedSyndicates != null)
                {
                    return _includedSyndicates;
                }

                string json = File.ReadAllText(_dataFilePath);
                _includedSyndicates = JsonConvert.DeserializeObject<List<string>>(json);
                return _includedSyndicates;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error while fetching IncludedSyndicates, Exception Message {ex.Message}");
                throw;
            }
        }
    }
}