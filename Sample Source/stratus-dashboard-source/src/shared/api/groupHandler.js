import AzureStorageUtils from '../azure-storage-utils';
import azure from 'azure-storage';
const groupTable = config.appPrefix + 'AnalysisGroup';
const tableService = azure.createTableService(config.azureTableStore.account, config.azureTableStore.key);

const createOrUpdateGroup = async (group) => {
    try {
        let entGen = azure.TableUtilities.entityGenerator;
        let entity = {
            PartitionKey: group.partitionKey ? entGen.String(group.partitionKey) : entGen.String(`${new Date().getTime()}`),
            RowKey: group.partitionKey ? entGen.String(group.rowKey) : entGen.String(`${new Date().getTime()}`),
            Analyses: entGen.String(JSON.stringify(group.analyses)),
            NetworkIds: entGen.String(JSON.stringify(group.networkIds)),
            GroupName: entGen.String(group.groupName)
        };

        return await AzureStorageUtils.insertOrMergeEntityAsync(tableService, groupTable, entity);
    } catch (err) {
        console.error(err);
        return null;
    }
};

const getGroups = async () => {
    try {
        return await AzureStorageUtils.getAllRowsAsync(groupTable);
    } catch (err) {
        console.error(err);
        return [];
    }
};

const getGroup = async (partitionKey, rowKey) => {
    try {
        let group = await AzureStorageUtils.retrieveEntityAsync(tableService, groupTable, partitionKey, rowKey);
        return {
            partitionKey: group.PartitionKey._,
            rowKey: group.RowKey._,
            groupId: `${group.PartitionKey._}-${group.RowKey._}`,
            groupName: group.GroupName._,
            analyses: group.Analyses ? JSON.parse(group.Analyses._) : [],
            networkIds: group.NetworkIds ? JSON.parse(group.NetworkIds._) : []
        };
    } catch (err) {
        console.error(err);
        return null;
    }
}

export default {
    createOrUpdateGroup,
    getGroups,
    getGroup
}