using AutoMapper;
using Brit.BritCacheEntities.Models.Eclipse;
using Brit.Risk.Entities;
using EntrySheet.Api.Function.Clients;
using EntrySheet.Api.Function.Hydration;
using EntrySheet.Api.Function.Mappers;
using EntrySheet.Api.Function.Models;
using EntrySheet.Api.Function.Repositories;
using EntrySheet.Api.Function.Services;
using Moq;
using Newtonsoft.Json;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;

namespace EntrySheet.Api.Function.Tests.Utils
{
    public static class EntrySheetMock
    {
        public static EntrySheetService BuildEntrySheetService(string baseFolder, string policyDataFolderPath, string policiesDataFileName,
        int britPolicyId, Dictionary<int, string> placingDictionary, Dictionary<int, string> nonPrimarPolicyDataFiles, string savedEntrySheetFilePath)
        {
            var mockBritCacheClient = new Mock<IBritCacheClient>();
            var mockEclipseRiskClient = new Mock<IEclipseRiskApiClient>();
            var mockEntrySheetDetailsRepository = new Mock<IEntrySheetDetailsRepository>();
            var mockEclipseRiskValidationApiClient = new Mock<IEclipseRiskValidationApiClient>();
            var mockPlacingHydrator = new Mock<IPlacingHydrator>();

            var mockSyndicateDataRetriever = new Mock<ISyndicateDataRetriever>();
            mockSyndicateDataRetriever.Setup(x => x.GetIncludedSyndicates()).Returns(new List<string> { "2987", "2988" });
            var _entrySheetDetailsHydrator = new EntrySheetDetailsHydrator(new MapperConfiguration(cfg => cfg.AddProfile<EntrySheetDetailsModelProfile>()).CreateMapper(), mockSyndicateDataRetriever.Object);


            var getPoliciesTask = new TaskFactory<IEnumerable<Policy>>(TaskScheduler.Current).StartNew(() =>
            {
                var policiesDataFilePath = Path.Combine(baseFolder, policyDataFolderPath, policiesDataFileName);
                var policiesJson = File.ReadAllText(policiesDataFilePath);
                var policies = JsonConvert.DeserializeObject<IEnumerable<Policy>>(policiesJson);
                return policies;
            });

            if (nonPrimarPolicyDataFiles != null)
            {
                foreach (KeyValuePair<int, string> britCachedata in nonPrimarPolicyDataFiles)
                {
                    var getPoliciesTasknonPrimary = new TaskFactory<IEnumerable<Policy>>(TaskScheduler.Current).StartNew(() =>
                    {
                        var policiesDataFilePath = Path.Combine(baseFolder, policyDataFolderPath, britCachedata.Value);
                        var policiesJson = File.ReadAllText(policiesDataFilePath);
                        var policies = JsonConvert.DeserializeObject<IEnumerable<Policy>>(policiesJson);
                        return policies;
                    });
                    mockBritCacheClient.Setup(x => x.GetEclipsePoliciesAsync(new[] { britCachedata.Key })).Returns(getPoliciesTasknonPrimary);
                }
            }

            mockBritCacheClient.Setup(x => x.GetEclipsePoliciesAsync(new[] { britPolicyId })).Returns(getPoliciesTask);

            foreach (KeyValuePair<int, string> placingDataPair in placingDictionary)
            {
                var getEclipseRiskGpmDetailsTask = new TaskFactory<Placing>(TaskScheduler.Current).StartNew(() =>
                {
                    var eclipseRiskGpmDetailsDataFilePath = Path.Combine(baseFolder, policyDataFolderPath,
                        string.Format("{0}_{1}_Placing.json", placingDataPair.Key, placingDataPair.Value));
                    var placingJson = File.ReadAllText(eclipseRiskGpmDetailsDataFilePath);
                    var placing = JsonConvert.DeserializeObject<Placing>(placingJson);
                    return placing;
                });

                mockEclipseRiskClient.Setup(x => x.GetEclipseRiskGpmDetailsAsync(placingDataPair.Value))
                    .Returns(getEclipseRiskGpmDetailsTask);
            }

            var getDataFromCosmosDB = new TaskFactory<EntrySheetDetailsModel>(TaskScheduler.Current).StartNew(() =>
            {
                var savedEntrySheetDetailsPath = Path.Combine(baseFolder, policyDataFolderPath, savedEntrySheetFilePath);
                var savedEntrySheetJson = File.ReadAllText(savedEntrySheetDetailsPath);
                var entrySheet = JsonConvert.DeserializeObject<EntrySheetDetailsModel>(savedEntrySheetJson);
                return entrySheet;
            });

            mockEntrySheetDetailsRepository.Setup(x => x.GetLatestEntrySheetDetailsAsync(britPolicyId)).Returns(getDataFromCosmosDB);

            var entrySheetService = new EntrySheetService(mockBritCacheClient.Object, mockEclipseRiskClient.Object,
                _entrySheetDetailsHydrator, mockEntrySheetDetailsRepository.Object, mockEclipseRiskValidationApiClient.Object, mockPlacingHydrator.Object);
            return entrySheetService;
        }
    }
}
