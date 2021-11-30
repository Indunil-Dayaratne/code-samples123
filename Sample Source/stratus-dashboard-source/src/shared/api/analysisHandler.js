import AzureStorageUtils from '../azure-storage-utils';
import azure from 'azure-storage';

const analysisTable = config.appPrefix + 'Analysis';
const tableService = azure.createTableService(config.azureTableStore.account, config.azureTableStore.key);

const getAnalysis = async (programRef, analysisId) => {
    let query = new azure.TableQuery();
    if(programRef) {
        query = query.where('PartitionKey eq ?', programRef);
        if(analysisId) query = query.and('RowKey eq ?', analysisId);
    }
    return await AzureStorageUtils.queryEntitiesAsync(tableService, analysisTable, query);
}

const getAnalyses = async (analyses) => {
    if(!analyses || !Array.isArray(analyses) || !analyses.length) return await AzureStorageUtils.getAllRowsAsync(analysisTable);
    return analyses.reduce(async (acc, ref) => {
        if(ref.programRef) acc.push(...await getAnalysis(ref.programRef, ref.analysisId));
        return acc;
    }, []);
}

const getAnalysesForProgram = async (programRef) => {
    let query = new azure.TableQuery();
    query = query.where('PartitionKey ge ?', programRef)
        .and('PartitionKey le ?', programRef + 'z');
    return await AzureStorageUtils.queryEntitiesAsync(tableService, analysisTable, query);
}

export default {
    getAnalysis,
    getAnalyses,
    getAnalysesForProgram
}