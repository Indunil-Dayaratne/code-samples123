import AzureStorageUtils from '../azure-storage-utils';
import azure from 'azure-storage';
const table = config.appPrefix + 'Rpx';
const tableService = azure.createTableService(config.azureTableStore.account, config.azureTableStore.key);

const getRpxs = async (programRef, analysisId) => {
    var tableQuery = new azure.TableQuery()

    if(analysisId) {
        tableQuery = tableQuery.where('PartitionKey eq ?', programRef + '-' + analysisId);
    } else {
        tableQuery = tableQuery.where('PartitionKey >= ?', programRef).and('PartitionKey < ?', programRef + '0');
    }
    
    return await AzureStorageUtils.queryEntitiesAsync(tableService, table, tableQuery);    
}

export default {
    getRpxs
}