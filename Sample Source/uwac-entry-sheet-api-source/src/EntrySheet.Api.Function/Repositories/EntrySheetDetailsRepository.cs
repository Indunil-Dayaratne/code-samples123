using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EntrySheet.Api.Function.Helpers;
using EntrySheet.Api.Function.Models;
using EntrySheet.Api.Function.Settings;
using Microsoft.Azure.Cosmos;
using Microsoft.Extensions.Options;

namespace EntrySheet.Api.Function.Repositories
{
    public class EntrySheetDetailsRepository : IEntrySheetDetailsRepository
    {
        private readonly IKeyVaultHelper _keyVault;
        private readonly CosmosOptions _cosmosOptions;

        public EntrySheetDetailsRepository(IKeyVaultHelper keyVault, IOptions<CosmosOptions> cosmosOptions)
        {
            _keyVault = keyVault;
            _cosmosOptions = cosmosOptions.Value;
        }

        public async Task<EntrySheetDetailsModel> GetLatestEntrySheetDetailsAsync(int britPolicyId)
        {
            var key = await _keyVault.GetKeyVaultValueAsync(_cosmosOptions.AccountPrimaryKey);

            using (var client = new CosmosClient(_cosmosOptions.DatabaseEndpoint, key))
            {
                var latestDataContainer = client.GetContainer(_cosmosOptions.DatabaseName, _cosmosOptions.LatestDataContainerName);

                return latestDataContainer
                    .GetItemLinqQueryable<EntrySheetDetailsModel>(allowSynchronousQueryExecution: true)
                    .Where(x => x.Id == britPolicyId.ToString() && x.BritPolicyId == britPolicyId)
                    .AsEnumerable().FirstOrDefault();
            }
        }

        public async Task<List<EntrySheetDetailsModel>> GetLatestEntrySheetsAsync(int[] britPolicyIds)
        {
            var key = await _keyVault.GetKeyVaultValueAsync(_cosmosOptions.AccountPrimaryKey);

            using (var client = new CosmosClient(_cosmosOptions.DatabaseEndpoint, key))
            {
                var latestDataContainer = client.GetContainer(_cosmosOptions.DatabaseName, _cosmosOptions.LatestDataContainerName);
                return latestDataContainer
                    .GetItemLinqQueryable<EntrySheetDetailsModel>(allowSynchronousQueryExecution: true)
                    .Where(x => britPolicyIds.Contains(x.BritPolicyId)).ToList();
            }
        }

        public async Task<EntrySheetDetailsModel> SaveAsync(EntrySheetDetailsModel entrySheetDetailsModel)
        {
            Validate(entrySheetDetailsModel);

            entrySheetDetailsModel.Id = entrySheetDetailsModel.BritPolicyId.ToString();
            entrySheetDetailsModel.LastUpdatedOn = DateTime.UtcNow;

            var key = await _keyVault.GetKeyVaultValueAsync(_cosmosOptions.AccountPrimaryKey);

            ItemResponse<EntrySheetDetailsModel> response;

            using (var client = new CosmosClient(_cosmosOptions.DatabaseEndpoint, key))
            {
                var latestDataContainer = client.GetContainer(_cosmosOptions.DatabaseName, _cosmosOptions.LatestDataContainerName);
                response = await latestDataContainer.UpsertItemAsync(entrySheetDetailsModel, new PartitionKey(entrySheetDetailsModel.BritPolicyId));
            }

            await SaveHistoryAsync(entrySheetDetailsModel);

            return response.Resource;
        }

        private static void Validate(EntrySheetDetailsModel entrySheetDetailsModel)
        {
            if (entrySheetDetailsModel == null)
            {
                throw new ArgumentNullException(nameof(entrySheetDetailsModel));
            }

            if (entrySheetDetailsModel.BritPolicyId == 0)
            {
                throw new ArgumentException("BritPolicyId cannot be zero");
            }
        }

        private async Task SaveHistoryAsync(EntrySheetDetailsModel entrySheetDetailsModel)
        {
            Validate(entrySheetDetailsModel);

            entrySheetDetailsModel.Id = Guid.NewGuid().ToString();

            var key = await _keyVault.GetKeyVaultValueAsync(_cosmosOptions.AccountPrimaryKey);

            using (var client = new CosmosClient(_cosmosOptions.DatabaseEndpoint, key))
            {
                var historyDataContainer = client.GetContainer(_cosmosOptions.DatabaseName, _cosmosOptions.HistoryDataContainerName);
                await historyDataContainer.CreateItemAsync(entrySheetDetailsModel, new PartitionKey(entrySheetDetailsModel.BritPolicyId));
            }
        }
    }
}