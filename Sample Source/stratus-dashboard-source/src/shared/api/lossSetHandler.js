import AzureStorageUtils from '../azure-storage-utils';
import azure from 'azure-storage';
import moment from 'moment';

const lossSetTableName = config.appPrefix + 'LossSet';
const tableService = azure.createTableService(config.azureTableStore.account, config.azureTableStore.key);

const getLossSets = async (groupIds) => {
    try {      
        if(typeof(groupIds) !== 'string' && !Array.isArray(groupIds)) return [];
        const groups = typeof(groupIds) === 'string' ? [groupIds] : groupIds;
        const output = [];

        for (let i = 0; i < groups.length; i++) {
            const groupId = groups[i];
            var tableQuery = new azure.TableQuery();
            tableQuery = tableQuery.where('PartitionKey eq ?', groupId);
        
            var results = await AzureStorageUtils.queryEntitiesAsync(tableService, lossSetTableName, tableQuery);

            results.forEach(entity => {
                let metadata = JSON.parse(entity.Metadata._);
                let splits = metadata.FileUrl.split("/");
                
                output.push({
                    id: entity.RowKey._,                
                    groupId: entity.PartitionKey._,
                    lossSetId: entity.RowKey._,               
                    uploadedOn: moment(entity.UploadedOn._).format(config.dateFormat),
                    uploadedBy: entity.UploadedBy._,
                    networkId: entity.NetworkId._,
                    nodeId: entity.NodeId._,
                    yoa: entity.Yoa ? entity.Yoa._ : 2020,
                    programRef: splits[4],
                    analysisId: splits[5],
                    parquetfileName: splits[6],
                    currency: metadata.Currency,
                    fileUrl: metadata.FileUrl,
                    runCatalogType: metadata.RunCatalogType,
                    userField1: metadata.UserField1,
                    userField2: metadata.UserField2,
                    eventCatalogType: metadata.EventCatalogType,
                    dataType: metadata.DataType,
                    sourcefileName: metadata.FileName,
                    simulations: metadata.Simulations || 10000
                });
            });
        }
        return output;
    } catch (err) {
        console.error(err);
    }
}

export default {
    getLossSets
}