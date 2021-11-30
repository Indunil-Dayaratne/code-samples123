import AzureStorageUtils from '../azure-storage-utils';
import azure from 'azure-storage';
const exposureTable = config.appPrefix + 'ExposureSummary';
const tableService = azure.createTableService(config.azureTableStore.account, config.azureTableStore.key);

const savePerils = async (perils) => {
    try {
        const exposureSets = perils.filter(x => x.PerilSetCode === 0).map(function(peril) {
            return {
              PartitionKey: peril.PartitionKey,
              RowKey: peril.RowKey,
              Perils: perils.filter(x => x.ExposureSetSID ===  peril.ExposureSetSID),
            }
        });

        const promises = [];
        let entGen = azure.TableUtilities.entityGenerator;
        for (let i = 0; i < exposureSets.length; i++) {
            const exposureSet = exposureSets[i];
            let entity = {
                PartitionKey: entGen.String(exposureSet.PartitionKey),
                RowKey: entGen.String(exposureSet.RowKey),
                Perils: entGen.String(JSON.stringify(exposureSet.Perils)),
            };
            promises.push(AzureStorageUtils.insertOrMergeEntityAsync(tableService, exposureTable, entity));
        }

        await Promise.all(promises);
    } catch (err) {
        console.log(err);
        throw err;
    }
};

export default {
    savePerils
}