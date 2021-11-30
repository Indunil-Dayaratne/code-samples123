import AzureStorageUtils from '../azure-storage-utils';
import azure from 'azure-storage';
const resultsTable = config.appPrefix + 'LossResults';
const tableService = azure.createTableService(config.azureTableStore.account, config.azureTableStore.key);

const getStandardNetworkResults = async (networkId, getNode) => {
    let tableQuery = new azure.TableQuery();
    tableQuery = tableQuery.where('PartitionKey eq ?', String(networkId));
    let results = await AzureStorageUtils.queryEntitiesAsync(tableService, resultsTable, tableQuery);

    const output = [];
    results.forEach(x => {
        if (x.RowKey._.includes('-')) return;
        const res = {
            id: x.RowKey._,
            url: x.BlobUri._
        }
        if(getNode) {
            const node = getNode(Number.parseInt(res.id));
            if(node) output.push({...res, node});
        }
        else output.push(res);
    });

    return output;
}

export default {
    getStandardNetworkResults
}