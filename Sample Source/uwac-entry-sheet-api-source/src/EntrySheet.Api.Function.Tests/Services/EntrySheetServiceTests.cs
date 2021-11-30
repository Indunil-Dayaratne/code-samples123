using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;
using AutoMapper;
using Brit.BritCacheEntities.Models.Eclipse;
using Brit.Risk.Entities;
using EntrySheet.Api.Function.Clients;
using EntrySheet.Api.Function.Hydration;
using EntrySheet.Api.Function.Mappers;
using EntrySheet.Api.Function.Models;
using EntrySheet.Api.Function.Repositories;
using EntrySheet.Api.Function.Services;
using EntrySheet.Api.Function.Tests.Utils;
using Moq;
using Newtonsoft.Json;
using Xunit;

namespace EntrySheet.Api.Function.Tests.Services
{
    public class EntrySheetServiceTests
    {
        private readonly EntrySheetDetailsHydrator _entrySheetDetailsHydrator;
        private readonly string _baseFolder;

        public EntrySheetServiceTests()
        {
            var mockSyndicateDataRetriever = new Mock<ISyndicateDataRetriever>();
            mockSyndicateDataRetriever.Setup(x => x.GetIncludedSyndicates()).Returns(new List<string> { "2987", "2988" });
            _entrySheetDetailsHydrator = new EntrySheetDetailsHydrator(new MapperConfiguration(cfg => cfg.AddProfile<EntrySheetDetailsModelProfile>()).CreateMapper(), mockSyndicateDataRetriever.Object);
            _baseFolder = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
        }

        [Fact]
        public async Task GetEntrySheetDetailsAsync_Builds_Model_For_Single_Section_Multi_Line_Policy_Successfully()
        {
            const string policyDataFolderPath = @".\Data\Single_Section_Multi_Line_Policy_10044A20A000";
            const string entrySheetDetailsModelDateFileName = "10044A20A000_EntrySheetDetailsModel.json";
            const string policiesDataFileName = "1098461_BritCache_GetEclipsePoliciesAsyncResult.json";
            const int britPolicyId = 1098461;

            var placingDictionary = new Dictionary<int, string>
            {
                {britPolicyId, "10044A20A000"}
            };

            var entrySheetService = BuildEntrySheetService(policyDataFolderPath, policiesDataFileName, britPolicyId, placingDictionary);
            var actualEntrySheetDetailsModel = await entrySheetService.GetEntrySheetDetailsAsync(britPolicyId);

           var json = JsonConvert.SerializeObject(actualEntrySheetDetailsModel, Formatting.Indented);

            ExecuteEntrySheetDetailsModelComparison(policyDataFolderPath, entrySheetDetailsModelDateFileName, actualEntrySheetDetailsModel);
        }


        [Fact]
        public async Task GetEntrySheetDetailsAsync_Excludes_PolicyLines_Removed_From_Eclipse_Successfully()
        {
            const string policyDataFolderPath = @".\Data\Multi_Section_Multi_Line_Policy_CF040E20B000";
            const string entrySheetDetailsModelDateFileName = "CF040E20B000_EntrySheetDetailsModel.json";
            const string policiesDataFileName = "1118453_BritCache_GetEclipsePoliciesAsyncResult.json";
            const int britPolicyId = 1118453;

            var placingDictionary = new Dictionary<int, string>
            {
                {1118453,"CF040E20B000"},
                {1118454,"CF040E20C000"}
            };

            var mockBritCacheClient = new Mock<IBritCacheClient>();
            var mockEclipseRiskClient = new Mock<IEclipseRiskApiClient>();
            var mockEntrySheetDetailsRepository = new Mock<IEntrySheetDetailsRepository>();
            var mockEclipseRiskValidationApiClient = new Mock<IEclipseRiskValidationApiClient>();
            var mockPlacingHydrator = new Mock<IPlacingHydrator>();

            var getPoliciesTask = new TaskFactory<IEnumerable<Policy>>(TaskScheduler.Current).StartNew(() =>
            {
                var policiesDataFilePath = Path.Combine(_baseFolder, policyDataFolderPath, policiesDataFileName);
                var policiesJson = File.ReadAllText(policiesDataFilePath);
                var policies = JsonConvert.DeserializeObject<IEnumerable<Policy>>(policiesJson);
                return policies;
            });

            mockBritCacheClient.Setup(x => x.GetEclipsePoliciesAsync(new[] { britPolicyId })).Returns(getPoliciesTask);

            foreach (KeyValuePair<int, string> placingDataPair in placingDictionary)
            {
                var getEclipseRiskGpmDetailsTask = new TaskFactory<Placing>(TaskScheduler.Current).StartNew(() =>
                {
                    var eclipseRiskGpmDetailsDataFilePath = Path.Combine(_baseFolder, policyDataFolderPath,
                        string.Format("{0}_{1}_Placing.json", placingDataPair.Key, placingDataPair.Value));
                    var placingJson = File.ReadAllText(eclipseRiskGpmDetailsDataFilePath);
                    var placing = JsonConvert.DeserializeObject<Placing>(placingJson);

                    var contractSection = placing.ContractSections.First();
                    if (contractSection.SectionReference == "CF040E20B000")
                    {
                        var marketToRemove = contractSection.ContractMarkets
                            .First(x => x.Insurer.Party.Id == "2988");

                        contractSection.ContractMarkets.Remove(marketToRemove);
                    }

                    return placing;
                });

                mockEclipseRiskClient.Setup(x => x.GetEclipseRiskGpmDetailsAsync(placingDataPair.Value))
                    .Returns(getEclipseRiskGpmDetailsTask);
            }

            var entrySheetDetailsModelFilePath =
                Path.Combine(_baseFolder, policyDataFolderPath, entrySheetDetailsModelDateFileName);
            var entrySheetDetailsModelJson = File.ReadAllText(entrySheetDetailsModelFilePath);
            var expectedEntrySheetDetailsModel =
                JsonConvert.DeserializeObject<EntrySheetDetailsModel>(entrySheetDetailsModelJson);

            mockEntrySheetDetailsRepository.Setup(x => x.GetLatestEntrySheetDetailsAsync(britPolicyId))
                .Returns(Task.FromResult(expectedEntrySheetDetailsModel));

            var entrySheetService = new EntrySheetService(mockBritCacheClient.Object, mockEclipseRiskClient.Object,
                _entrySheetDetailsHydrator, mockEntrySheetDetailsRepository.Object, mockEclipseRiskValidationApiClient.Object, mockPlacingHydrator.Object);

            var actualEntrySheetDetailsModel = await entrySheetService.GetEntrySheetDetailsAsync(britPolicyId);

            Assert.True(actualEntrySheetDetailsModel.PolicyLines.Count == 3);
        }

        [Fact]
        public async Task GetEntrySheetDetailsAsync_Builds_Model_For_Single_Section_Single_Line_Policy_Successfully()
        {
            const string policyDataFolderPath = @".\Data\Single_Section_Single_Line_Policy_BB585S20A000";
            const string entrySheetDetailsModelDateFileName = "BB585S20A000_EntrySheetDetailsModel.json";
            const string policiesDataFileName = "1084411_BritCacheClient_GetEclipsePoliciesAsyncResult.json";
            const int britPolicyId = 1084411;

            var placingDictionary = new Dictionary<int, string>
            {
                {britPolicyId, "BB585S20A000"}
            };

            var entrySheetService = BuildEntrySheetService(policyDataFolderPath, policiesDataFileName, britPolicyId, placingDictionary);
            var actualEntrySheetDetailsModel = await entrySheetService.GetEntrySheetDetailsAsync(britPolicyId);

            var json = JsonConvert.SerializeObject(actualEntrySheetDetailsModel, Formatting.Indented);

            ExecuteEntrySheetDetailsModelComparison(policyDataFolderPath, entrySheetDetailsModelDateFileName, actualEntrySheetDetailsModel);
        }

        [Fact]
        public async Task GetEntrySheetDetailsAsync_Builds_Model_For_Multi_Section_Multi_Line_Policy_Successfully()
        {
            const string policyDataFolderPath = @".\Data\Multi_Section_Multi_Line_Policy_CF040E20B000";
            const string entrySheetDetailsModelDateFileName = "CF040E20B000_EntrySheetDetailsModel.json";
            const string policiesDataFileName = "1118453_BritCache_GetEclipsePoliciesAsyncResult.json";
            const string policiesDataFileNameNonPrimary = "1118454_BritCache_GetEclipsePoliciesAsyncResult.json";
            const int britPolicyId = 1118453;

            var placingDictionary = new Dictionary<int, string>
            {
                {1118453,"CF040E20B000"},
                {1118454,"CF040E20C000"}
            };

            var entrySheetService = BuildEntrySheetService(policyDataFolderPath, policiesDataFileName, britPolicyId, placingDictionary,new Dictionary<int, string> { { 1118454, policiesDataFileNameNonPrimary } });
            var actualEntrySheetDetailsModel = await entrySheetService.GetEntrySheetDetailsAsync(britPolicyId);

            var json = JsonConvert.SerializeObject(actualEntrySheetDetailsModel, Formatting.Indented);

            ExecuteEntrySheetDetailsModelComparison(policyDataFolderPath, entrySheetDetailsModelDateFileName, actualEntrySheetDetailsModel);
        }

        [Fact(Skip ="Integration Tests")]
        public async Task GetEntrySheetDetailsAsync_Loads_Saved_Model_And_OverWrites_Data_From_Latest_Gpm_Details()
        {
            const string policyDataFolderPath = @".\Data\Multi_Section_Multi_Line_Policy_CF040E20B000";
            const string entrySheetDetailsModelDateFileName = "CF040E20B000_EntrySheetDetailsModel.json";
            const string policiesDataFileName = "1118453_BritCache_GetEclipsePoliciesAsyncResult.json";
            const int primaryBritPolicyId = 1118453;
            const int nonPrimaryBritPolicyId = 1118454;
            List<string> updatedInsuredNames = new List<string>();
            var placingDictionary = new Dictionary<int, string>
            {
                {primaryBritPolicyId,"CF040E20B000"},
                {nonPrimaryBritPolicyId,"CF040E20C000"}
            };

            var mockBritCacheClient = new Mock<IBritCacheClient>();
            var mockEclipseRiskClient = new Mock<IEclipseRiskApiClient>();
            var mockEntrySheetDetailsRepository = new Mock<IEntrySheetDetailsRepository>();
            var mockEclipseRiskValidationApiClient = new Mock<IEclipseRiskValidationApiClient>();
            var mockPlacingHydrator = new Mock<IPlacingHydrator>();

            var entrySheetDetailsModelFilePath =
                Path.Combine(_baseFolder, policyDataFolderPath, entrySheetDetailsModelDateFileName);
            var entrySheetDetailsModelJson = File.ReadAllText(entrySheetDetailsModelFilePath);
            var savedEntrySheetDetailsModel =
                JsonConvert.DeserializeObject<EntrySheetDetailsModel>(entrySheetDetailsModelJson);

            mockEntrySheetDetailsRepository.Setup(x => x.GetLatestEntrySheetDetailsAsync(primaryBritPolicyId))
                .Returns(Task.FromResult(savedEntrySheetDetailsModel));

            var getPoliciesTask = new TaskFactory<IEnumerable<Policy>>(TaskScheduler.Current).StartNew(() =>
            {
                var policiesDataFilePath = Path.Combine(_baseFolder, policyDataFolderPath, policiesDataFileName);
                var policiesJson = File.ReadAllText(policiesDataFilePath);
                var policies = JsonConvert.DeserializeObject<IEnumerable<Policy>>(policiesJson);
                return policies;
            });

            mockBritCacheClient.Setup(x => x.GetEclipsePoliciesAsync(new[] { nonPrimaryBritPolicyId })).Returns(getPoliciesTask);
            mockBritCacheClient.Setup(x => x.GetEclipsePoliciesAsync(new[] { primaryBritPolicyId })).Returns(getPoliciesTask);

            foreach (KeyValuePair<int, string> placingDataPair in placingDictionary)
            {
                var getEclipseRiskGpmDetailsTask = new TaskFactory<Placing>(TaskScheduler.Current).StartNew(() =>
                {
                    var eclipseRiskGpmDetailsDataFilePath = Path.Combine(_baseFolder, policyDataFolderPath,
                        string.Format("{0}_{1}_Placing.json", placingDataPair.Key, placingDataPair.Value));
                    var placingJson = File.ReadAllText(eclipseRiskGpmDetailsDataFilePath);

                    var placing = JsonConvert.DeserializeObject<Placing>(placingJson);
                    placing.Insured.Party.Name = placing.Insured.Party.Name + "_Updated";

                    updatedInsuredNames.Add(placing.Insured.Party.Name);

                    return placing;
                });

                mockEclipseRiskClient.Setup(x => x.GetEclipseRiskGpmDetailsAsync(placingDataPair.Value))
                    .Returns(getEclipseRiskGpmDetailsTask);
            }

            var entrySheetService = new EntrySheetService(mockBritCacheClient.Object, mockEclipseRiskClient.Object,
                _entrySheetDetailsHydrator, mockEntrySheetDetailsRepository.Object, mockEclipseRiskValidationApiClient.Object, mockPlacingHydrator.Object);

            var latestEntrySheetDetailsModel1 = await entrySheetService.GetEntrySheetDetailsAsync(nonPrimaryBritPolicyId);

            Assert.Equal(latestEntrySheetDetailsModel1.RelatedPoliciesDetails.First(item=>item.BritPolicyId== nonPrimaryBritPolicyId).Insured.PartyName, updatedInsuredNames[0]);
            Assert.Equal(latestEntrySheetDetailsModel1.BritPolicyId, nonPrimaryBritPolicyId);

            var latestEntrySheetDetailsModel2 = await entrySheetService.GetEntrySheetDetailsAsync(primaryBritPolicyId);

            Assert.Equal(latestEntrySheetDetailsModel1.RelatedPoliciesDetails.First(item => item.BritPolicyId == primaryBritPolicyId).Insured.PartyName, updatedInsuredNames[1]);
            Assert.Equal(latestEntrySheetDetailsModel2.BritPolicyId, primaryBritPolicyId);
        }

        [Fact]
        public async Task SaveEntrySheetDetailsAsync_Successful()
        {
            const string policyDataFolderPath = @".\Data\Multi_Section_Multi_Line_Policy_CF040E20B000";
            const string entrySheetDetailsModelDateFileName = "CF040E20B000_EntrySheetDetailsModel.json";

            var entrySheetDetailsModelFilePath = Path.Combine(_baseFolder, policyDataFolderPath, entrySheetDetailsModelDateFileName);
            var entrySheetDetailsModelJson = File.ReadAllText(entrySheetDetailsModelFilePath);
            var entrySheetDetailsModel = JsonConvert.DeserializeObject<EntrySheetDetailsModel>(entrySheetDetailsModelJson);

            var mockBritCacheClient = new Mock<IBritCacheClient>();
            var mockEclipseRiskClient = new Mock<IEclipseRiskApiClient>();
            var mockEntrySheetDetailsRepository = new Mock<IEntrySheetDetailsRepository>();
            var mockEclipseRiskValidationApiClient = new Mock<IEclipseRiskValidationApiClient>();
            var placingHydrator = new PlacingHydrator();

            var mockSaveResponse = Task.FromResult(entrySheetDetailsModel);

            mockEntrySheetDetailsRepository.Setup(x => x.SaveAsync(It.IsAny<EntrySheetDetailsModel>()))
                .Returns(mockSaveResponse);

            mockEclipseRiskValidationApiClient
                .Setup(x => x.ValidateGpmDetailsAsync(It.IsAny<Placing>(), It.IsAny<string>()))
                .Returns(Task.FromResult(new RiskValidationModel {IsValid = true}));

            mockEclipseRiskClient
                .Setup(x => x.SubmitCreateRiskRequestAsync(It.IsAny<RiskMapperModel>(), It.IsAny<string>()))
                .Returns(Task.FromResult(new CreateRiskResponseModel {MessageId = "128"}));

            var entrySheetService = new EntrySheetService(mockBritCacheClient.Object, mockEclipseRiskClient.Object,
                _entrySheetDetailsHydrator, mockEntrySheetDetailsRepository.Object, mockEclipseRiskValidationApiClient.Object, placingHydrator);

            var saveResponse = await entrySheetService.SaveEntrySheetDetailsAsync(new SaveEntrySheetRequestModel {EntrySheetDetails = entrySheetDetailsModel, SaveRequestApiUri = "https://entry-sheet-api-func-uks-dev.azurewebsites.net/api/EntrySheet/Policy"});

            Assert.NotNull(saveResponse);
            Assert.True(saveResponse.SaveToCosmosDbSuccessful);
            Assert.True(saveResponse.PlacingValidationSuccessful);
            Assert.True(saveResponse.CreateRiskSubmissionsSuccessful);
            Assert.Equal(2, saveResponse.PlacingValidationDetails.Count);
            Assert.Equal(2, saveResponse.CreateRiskRequestSubmissionDetails.Count);
        }

        [Fact]
        public async Task SaveEntrySheetDetailsAsync_OnlyAttemptsToCreateRiskIfValidationIsSuccessful()
        {
            const string policyDataFolderPath = @".\Data\Multi_Section_Multi_Line_Policy_CF040E20B000";
            const string entrySheetDetailsModelDateFileName = "CF040E20B000_EntrySheetDetailsModel.json";

            var entrySheetDetailsModelFilePath = Path.Combine(_baseFolder, policyDataFolderPath, entrySheetDetailsModelDateFileName);
            var entrySheetDetailsModelJson = File.ReadAllText(entrySheetDetailsModelFilePath);
            var entrySheetDetailsModel = JsonConvert.DeserializeObject<EntrySheetDetailsModel>(entrySheetDetailsModelJson);

            var mockBritCacheClient = new Mock<IBritCacheClient>();
            var mockEclipseRiskClient = new Mock<IEclipseRiskApiClient>();
            var mockEntrySheetDetailsRepository = new Mock<IEntrySheetDetailsRepository>();
            var mockEclipseRiskValidationApiClient = new Mock<IEclipseRiskValidationApiClient>();
            var placingHydrator = new PlacingHydrator();

            var mockSaveResponse = Task.FromResult(entrySheetDetailsModel);

            mockEntrySheetDetailsRepository.Setup(x => x.SaveAsync(It.IsAny<EntrySheetDetailsModel>()))
                .Returns(mockSaveResponse);

            mockEclipseRiskValidationApiClient
                .Setup(x => x.ValidateGpmDetailsAsync(It.IsAny<Placing>(), It.IsAny<string>()))
                .Returns(Task.FromResult(new RiskValidationModel { IsValid = false }));

            mockEclipseRiskClient
                .Setup(x => x.SubmitCreateRiskRequestAsync(It.IsAny<RiskMapperModel>(), It.IsAny<string>()))
                .Returns(Task.FromResult(new CreateRiskResponseModel { MessageId = "128" }));

            var entrySheetService = new EntrySheetService(mockBritCacheClient.Object, mockEclipseRiskClient.Object,
                _entrySheetDetailsHydrator, mockEntrySheetDetailsRepository.Object, mockEclipseRiskValidationApiClient.Object, placingHydrator);

            var saveResponse = await entrySheetService.SaveEntrySheetDetailsAsync(new SaveEntrySheetRequestModel { EntrySheetDetails = entrySheetDetailsModel, SaveRequestApiUri = "https://entry-sheet-api-func-uks-dev.azurewebsites.net/api/EntrySheet/Policy" });

            Assert.NotNull(saveResponse);
            Assert.False(saveResponse.PlacingValidationSuccessful);
            Assert.False(saveResponse.SaveToCosmosDbSuccessful);
            Assert.False(saveResponse.CreateRiskSubmissionsSuccessful);
            Assert.Equal(2, saveResponse.PlacingValidationDetails.Count);
            Assert.Equal(0, saveResponse.CreateRiskRequestSubmissionDetails.Count);
        }

        private EntrySheetService BuildEntrySheetService(string policyDataFolderPath, string policiesDataFileName,
            int britPolicyId, Dictionary<int, string> placingDictionary,Dictionary<int,string> nonPrimarPolicyDataFiles = null)
        {
            var mockBritCacheClient = new Mock<IBritCacheClient>();
            var mockEclipseRiskClient = new Mock<IEclipseRiskApiClient>();
            var mockEntrySheetDetailsRepository = new Mock<IEntrySheetDetailsRepository>();
            var mockEclipseRiskValidationApiClient = new Mock<IEclipseRiskValidationApiClient>();
            var mockPlacingHydrator = new Mock<IPlacingHydrator>();

            var getPoliciesTask = new TaskFactory<IEnumerable<Policy>>(TaskScheduler.Current).StartNew(() =>
            {
                var policiesDataFilePath = Path.Combine(_baseFolder, policyDataFolderPath, policiesDataFileName);
                var policiesJson = File.ReadAllText(policiesDataFilePath);
                var policies = JsonConvert.DeserializeObject<IEnumerable<Policy>>(policiesJson);
                return policies;
            });

            if(nonPrimarPolicyDataFiles !=null)
            {
                foreach (KeyValuePair<int, string> britCachedata in nonPrimarPolicyDataFiles)
                {
                    var getPoliciesTasknonPrimary = new TaskFactory<IEnumerable<Policy>>(TaskScheduler.Current).StartNew(() =>
                    {
                        var policiesDataFilePath = Path.Combine(_baseFolder, policyDataFolderPath, britCachedata.Value);
                        var policiesJson = File.ReadAllText(policiesDataFilePath);
                        var policies = JsonConvert.DeserializeObject<IEnumerable<Policy>>(policiesJson);
                        return policies;
                    });
                    mockBritCacheClient.Setup(x => x.GetEclipsePoliciesAsync(new[] { britCachedata.Key })).Returns(getPoliciesTasknonPrimary);
                }
            }

            mockBritCacheClient.Setup(x => x.GetEclipsePoliciesAsync(new []{britPolicyId})).Returns(getPoliciesTask);

            foreach (KeyValuePair<int, string> placingDataPair in placingDictionary)
            {
                var getEclipseRiskGpmDetailsTask = new TaskFactory<Placing>(TaskScheduler.Current).StartNew(() =>
                {
                    var eclipseRiskGpmDetailsDataFilePath = Path.Combine(_baseFolder, policyDataFolderPath,
                        string.Format("{0}_{1}_Placing.json", placingDataPair.Key, placingDataPair.Value));
                    var placingJson = File.ReadAllText(eclipseRiskGpmDetailsDataFilePath);
                    var placing = JsonConvert.DeserializeObject<Placing>(placingJson);
                    return placing;
                });

                mockEclipseRiskClient.Setup(x => x.GetEclipseRiskGpmDetailsAsync(placingDataPair.Value))
                    .Returns(getEclipseRiskGpmDetailsTask);
            }

            var entrySheetService = new EntrySheetService(mockBritCacheClient.Object, mockEclipseRiskClient.Object,
                _entrySheetDetailsHydrator, mockEntrySheetDetailsRepository.Object, mockEclipseRiskValidationApiClient.Object, mockPlacingHydrator.Object);
            return entrySheetService;
        }

        private void ExecuteEntrySheetDetailsModelComparison(string policyDataFolderPath,
            string entrySheetDetailsModelDateFileName, EntrySheetDetailsModel actualEntrySheetDetailsModel)
        {
            var entrySheetDetailsModelFilePath =
                Path.Combine(_baseFolder, policyDataFolderPath, entrySheetDetailsModelDateFileName);
            var entrySheetDetailsModelJson = File.ReadAllText(entrySheetDetailsModelFilePath);
            var expectedEntrySheetDetailsModel =
                JsonConvert.DeserializeObject<EntrySheetDetailsModel>(entrySheetDetailsModelJson);

            var entrySheetDetailsModelComparer = new EntrySheetDetailsModelComparer();
            var json = JsonConvert.SerializeObject(expectedEntrySheetDetailsModel, Formatting.Indented);
            entrySheetDetailsModelComparer.CompareModels(actualEntrySheetDetailsModel, expectedEntrySheetDetailsModel);
        }
    }
}