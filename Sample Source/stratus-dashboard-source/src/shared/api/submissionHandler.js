import AzureStorageUtils from '../azure-storage-utils';
import azure from 'azure-storage';
const table = config.appPrefix + 'SubmissionData';
const tableService = azure.createTableService(config.azureTableStore.account, config.azureTableStore.key);

const getSubmissions = async (programRef, analysisIds) => {
    try {
        let output = [];
        if(!Array.isArray(analysisIds)) analysisIds = [analysisIds];
        var tableQuery = new azure.TableQuery()
        for (let i = 0; i < analysisIds.length; i++) {
            const id = analysisIds[i];
            tableQuery = new azure.TableQuery().where('PartitionKey eq ?', programRef + '-' + id);
            const results = await AzureStorageUtils.queryEntitiesAsync(tableService, table, tableQuery);
            output.push(...results);
        }
        return output;
    } catch (err) {
        console.error(err);
        return [];
    }
}

export default {
    getSubmissions
}