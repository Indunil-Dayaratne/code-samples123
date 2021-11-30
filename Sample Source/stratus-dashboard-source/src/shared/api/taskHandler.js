import AzureStorageUtils from '../azure-storage-utils';
import azure from 'azure-storage';
const table = config.appPrefix + 'Task';
const tableService = azure.createTableService(config.azureTableStore.account, config.azureTableStore.key);

const getTasksAsync = async (from, to, ref) => {
    let tableQuery = new azure.TableQuery();
    tableQuery = tableQuery.where('CreatedOn gt ? and CreatedOn lt ?', from, to);

    if (ref) {
        tableQuery = tableQuery.and('PartitionKey >= ?', ref).and('PartitionKey < ?', ref + '0');
    }

    return await AzureStorageUtils.queryEntitiesAsync(tableService, table, tableQuery);
}

export default {
    getTasksAsync
}