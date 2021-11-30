using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Threading;
using System.Threading.Tasks;
using EntrySheet.Api.Function.Helpers;
using EntrySheet.Api.Function.Models;
using EntrySheet.Api.Function.Repositories;
using EntrySheet.Api.Function.Settings;
using EntrySheet.Api.Function.Tests.Utils;
using Microsoft.Azure.Cosmos;
using Microsoft.Extensions.Options;
using Moq;
using Newtonsoft.Json;
using Xunit;

namespace EntrySheet.Api.Function.Tests.Repositories
{
    public class EntrySheetDetailsRepositoryTests : IDisposable
    {
        private const int BritPolicyId = 9999999;
        private readonly int[] _britPolicyIds = {9999999, 9999998, 9999997};

        private Mock<IKeyVaultHelper> _keyVaultMock;
        private IEntrySheetDetailsRepository _entrySheetDetailsRepository;
        private string _baseFolder;
        private Container _latestDataContainer;
        private Container _historyDataContainer;

        private bool _disposed = false;
        private CosmosClient _client;

        public EntrySheetDetailsRepositoryTests()
        {
            Initialise();
        }

        ~EntrySheetDetailsRepositoryTests() => Dispose(false);

        private void Initialise()
        {
            const string authKey = "dlYnU8c6qHhWT8GrsCkwYNK3q2Cep348A6kOb8mha99dV3INt6ZdH3BQCYVVwDSDeDlGlhwIfKirVDF1OVwISA==";

            _keyVaultMock = new Mock<IKeyVaultHelper>();
            _keyVaultMock
                .Setup(x => x.GetKeyVaultValueAsync(It.IsAny<string>()))
                .Returns(Task.FromResult(authKey));

            var cosmosOptions = new CosmosOptions
            {
                AccountPrimaryKey = "cosmos-account-primary-key",
                DatabaseEndpoint = "https://apps-common-cosmos-nonprod.documents.azure.com:443/",
                DatabaseName = "shared",
                LatestDataContainerName = "entry-sheet-eclipse-dev",
                HistoryDataContainerName = "entry-sheet-eclipse-history-dev"
            };
            var options = Options.Create(cosmosOptions);

            _entrySheetDetailsRepository = new EntrySheetDetailsRepository(_keyVaultMock.Object, options);
            _baseFolder = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);

            _client = new CosmosClient(cosmosOptions.DatabaseEndpoint, authKey);
            _latestDataContainer = _client.GetContainer(cosmosOptions.DatabaseName, cosmosOptions.LatestDataContainerName);
            _historyDataContainer = _client.GetContainer(cosmosOptions.DatabaseName, cosmosOptions.HistoryDataContainerName);
            
            Environment.SetEnvironmentVariable("KEYVAULT_RESOURCEID", "https://entry-sheet-kv-uks-dev.vault.azure.net/secrets/");
        }

        [Fact]
        public async Task GetLatestEntrySheetDetailsAsyncReturnsNullForInvalidBritPolicyId()
        {
            var response = await _entrySheetDetailsRepository.GetLatestEntrySheetDetailsAsync(88888888);

            Assert.Null(response);
        }

        [Fact]
        public async Task GetLatestEntrySheetDetailsAsyncReturnsDataSuccessfully()
        {
            await InsertEntrySheetDetailsModel(BritPolicyId);

            var response = await _entrySheetDetailsRepository.GetLatestEntrySheetDetailsAsync(BritPolicyId);

            Assert.NotNull(response);
            Assert.Equal(response.BritPolicyId, BritPolicyId);
        }

        [Fact]
        public async Task SaveAsyncPersistsLatestEntrySheetDetailsAndBuildsUpModelHistorySuccessfully()
        {
            await InsertEntrySheetDetailsModel(BritPolicyId);

            Thread.Sleep(TimeSpan.FromMilliseconds(100));

            await InsertEntrySheetDetailsModel(BritPolicyId);

            var latestEntrySheetDetailsModels = GetLatestEntrySheetDetailsModels(new []{ BritPolicyId });
            var historyEntrySheetDetailsModels = GetEntrySheetDetailsModelHistory(new[] { BritPolicyId });

            Assert.NotNull(latestEntrySheetDetailsModels);
            Assert.NotNull(historyEntrySheetDetailsModels);

            Assert.True(latestEntrySheetDetailsModels.Count == 1);
            Assert.True(historyEntrySheetDetailsModels.Count == 2);

            var entrySheetDetailsModelComparer = new EntrySheetDetailsModelComparer();
            entrySheetDetailsModelComparer.CompareModels(latestEntrySheetDetailsModels[0], historyEntrySheetDetailsModels[0]);
        }

        [Fact]
        public async Task GetLatestEntrySheetsAsyncReturnsDataSuccessfully()
        {
            foreach (var britPolicyId in _britPolicyIds)
            {
                await InsertEntrySheetDetailsModel(britPolicyId);
            }

            var response = await _entrySheetDetailsRepository.GetLatestEntrySheetsAsync(_britPolicyIds);

            Assert.NotNull(response);
            Assert.True(response.Count == _britPolicyIds.Length);

            foreach (var britPolicyId in _britPolicyIds)
            {
                Assert.True(response.Exists(x => x.BritPolicyId == britPolicyId));
            }
        }

        [Fact]
        public async Task GetLatestEntrySheetsAsyncReturnsAnEmptyListForInvalidBritPolicyIds()
        {
            var response = await _entrySheetDetailsRepository.GetLatestEntrySheetsAsync(new [] {7777775, 88888888});

            Assert.NotNull(response);
            Assert.True(response.Count == 0);
        }

        private List<EntrySheetDetailsModel> GetEntrySheetDetailsModelHistory(int[] britPolicyIds)
        {
            return _historyDataContainer
                .GetItemLinqQueryable<EntrySheetDetailsModel>(allowSynchronousQueryExecution: true)
                .Where(x => britPolicyIds.Contains(x.BritPolicyId)).OrderByDescending(x => x.LastUpdatedOn).ToList();
        }

        private List<EntrySheetDetailsModel> GetLatestEntrySheetDetailsModels(int[] britPolicyIds)
        {
            return _latestDataContainer
                .GetItemLinqQueryable<EntrySheetDetailsModel>(allowSynchronousQueryExecution: true)
                .Where(x => britPolicyIds.Contains(x.BritPolicyId)).ToList();
        }

        [Fact] 
        public async Task SaveAsyncValidatesEntrySheetDetailsModel()
        {
            await Assert.ThrowsAsync<ArgumentNullException>(() => _entrySheetDetailsRepository.SaveAsync(null));
            await Assert.ThrowsAsync<ArgumentException>(() => _entrySheetDetailsRepository.SaveAsync(new EntrySheetDetailsModel()));
        }

        private async Task<EntrySheetDetailsModel> InsertEntrySheetDetailsModel(int britPolicyId)
        {
            const string policyDataFolderPath = @".\Data\Multi_Section_Multi_Line_Policy_CF040E20B000";
            const string entrySheetDetailsModelDateFileName = "CF040E20B000_EntrySheetDetailsModel.json";

            var entrySheetDetailsModelFilePath = Path.Combine(_baseFolder, policyDataFolderPath, entrySheetDetailsModelDateFileName);
            var entrySheetDetailsModelJson = File.ReadAllText(entrySheetDetailsModelFilePath);
            var entrySheetDetailsModel = JsonConvert.DeserializeObject<EntrySheetDetailsModel>(entrySheetDetailsModelJson);

            entrySheetDetailsModel.BritPolicyId = britPolicyId;

            var response = await _entrySheetDetailsRepository.SaveAsync(entrySheetDetailsModel);
            return response;
        }

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        protected virtual void Dispose(bool disposing)
        {
            if (_disposed)
            {
                return;
            }

            if (disposing)
            {
                var latestEntrySheetDetailsModels = GetLatestEntrySheetDetailsModels(_britPolicyIds);
                var historyEntrySheetDetailsModels = GetEntrySheetDetailsModelHistory(_britPolicyIds);

                foreach (var entrySheetDetailsModel in latestEntrySheetDetailsModels)
                {
                    var response = _latestDataContainer.DeleteItemAsync<EntrySheetDetailsModel>(entrySheetDetailsModel.Id, new PartitionKey(entrySheetDetailsModel.BritPolicyId)).Result;
                }

                foreach (var entrySheetDetailsModel in historyEntrySheetDetailsModels)
                {
                    var response = _historyDataContainer.DeleteItemAsync<EntrySheetDetailsModel>(entrySheetDetailsModel.Id, new PartitionKey(entrySheetDetailsModel.BritPolicyId)).Result;
                }

                _client.Dispose();
            }

            _disposed = true;
        }
    }
}