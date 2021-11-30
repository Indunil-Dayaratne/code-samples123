import AzureStorageUtils from '../azure-storage-utils';
import azure from 'azure-storage';
const programTable = config.appPrefix + 'Program';
const tableService = azure.createTableService(config.azureTableStore.account, config.azureTableStore.key);

const createProgram = async (programDetails) => {
    const entGen = azure.TableUtilities.entityGenerator;
    const ent = {
        PartitionKey: entGen.String('program'),
        RowKey: entGen.String(programDetails.programRef),
        AccountName: entGen.String(programDetails.accountName),
        Summary: entGen.String(programDetails.summary),
        CreatedBy: entGen.String(programDetails.userName),
        CreatedOn: entGen.DateTime(new Date().toISOString()),
        DefaultCurrency: entGen.String(programDetails.defaultCurrency),
    }
    const res = await AzureStorageUtils.insertOrMergeEntityAsync(tableService, programTable, ent);
    return res;
};

const getProgram = async (programRef) => {
    const query = new azure.TableQuery().where('RowKey eq ?', programRef);
    return await AzureStorageUtils.queryEntitiesAsync(tableService, programTable, query);
}

const getPrograms = async (programRefs) => {
    if(!programRefs || !Array.isArray(programRefs) || !programRefs.length) return await AzureStorageUtils.getAllRowsAsync(programTable);
    return programRefs.reduce(async (acc, ref) => {
        acc.push(...await getProgram(ref));
        return acc;
    }, []);
}

export default {
    createProgram,
    getProgram,
    getPrograms
}