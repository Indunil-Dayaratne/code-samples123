import azure from 'azure-storage';
import rdm from '../shared/rdm';
import clf from '../shared/clf';
import cedeExp from '../shared/cedeExp';
import cedeRes from '../shared/cedeRes';

const state = () => ({
    files: [],
    runSubmissions: []
})

const getters = {
    files: state => state.files,
    yoa: state => 2020,
    rdms: state => state.files.filter(x => x.Type === 'RDM'),
    clfs: state => state.files.filter(x => x.Type === 'CLF'),
    cedeExp: state => state.files.filter(x => x.Type === 'EXP'),
    runSubmissions: state => state.runSubmissions,
    rdmSubmissions: state => (programRef, analysisId) => state.runSubmissions.filter(x => x.DataType === 'RDM'),
    clfSubmissions: state => (programRef, analysisId) => state.runSubmissions.filter(x => x.DataType === 'CLF'),
    cedeExpSubmissions: state => (programRef, analysisId) => state.runSubmissions.filter(x => x.DataType === 'EXP'),
    anyCedesHavePerilsMapped: state => state.runSubmissions.filter(x => x.DataType === 'EXP').some(x => x.IsPerilsMapped),
    cedePerilsMapped: state => (programRef, analysisId) => {
        const submission = state.runSubmissions.find(x => x.PartitionKey === programRef + '-' + analysisId);
        return submission && submission.IsPerilsMapped;
    },
    areAvailable: (state) => (type) => {
        if(!type) return state.runSubmissions.length > 0;
        return state.runSubmissions.filter(x => x.DataType === type.toUpperCase()).length > 0;
    },
    yoaOptions: state => [],
    getYearAnalysisIds: state => yoa => [],
    folders: (state) => [],
    isFileLoaded: state => path => {
        return getters.files(state).map(x => x.Path).includes(path);
    }
}

const mutations = {
    setSubmissionData: (state, { list }) => {
        state.runSubmissions = [];
        list.forEach((entity) => {

            let modelAnalysisIds = [];

            if (entity.WsstWithDemandSurgeModelAnalysisIds) {
                modelAnalysisIds.push({ RunCatalogType: "WsstWithDemandSurge", ModelAnalysisIds: JSON.parse(entity.WsstWithDemandSurgeModelAnalysisIds._) });
            }

            if (entity.WsstWithoutDemandSurgeModelAnalysisIds) {
                modelAnalysisIds.push({ RunCatalogType: "WsstWithoutDemandSurge", ModelAnalysisIds: JSON.parse(entity.WsstWithoutDemandSurgeModelAnalysisIds._) });
            }

            if (entity.StdWithDemandSurgeModelAnalysisIds) {
                modelAnalysisIds.push({ RunCatalogType: "StdWithDemandSurge", ModelAnalysisIds: JSON.parse(entity.StdWithDemandSurgeModelAnalysisIds._) });
            }

            if (entity.StdWithoutDemandSurgeModelAnalysisIds) {
                modelAnalysisIds.push({ RunCatalogType: "StdWithoutDemandSurge", ModelAnalysisIds: JSON.parse(entity.StdWithoutDemandSurgeModelAnalysisIds._) });
            }

            state.runSubmissions.push({
                PartitionKey: entity.PartitionKey._,
                RowKey: entity.RowKey._,
                DataType: entity.DataType ? entity.DataType._ : "",
                DatabaseName: entity.DatabaseName ? entity.DatabaseName._ : "",
                FilePath: entity.FilePath ? entity.FilePath._ : "",
                SourceType: entity.SourceType ? entity.SourceType._ : "",
                FileName: entity.FilePath ? (entity.FilePath._.substring(entity.FilePath._.lastIndexOf("\\") + 1)) : "",
                LossUploaded: entity.LossUploaded ? JSON.parse(entity.LossUploaded._) : [],
                RunCatalogTypes: entity.RunCatalogTypes ? JSON.parse(entity.RunCatalogTypes._) : [],
                RunTypes: entity.RunTypes ? JSON.parse(entity.RunTypes._) : [],
                IsPerilsMapped: entity.IsPerilsMapped ? entity.IsPerilsMapped._ : false,
                LossSetMetadata: entity.LosssetMetaData ? JSON.parse(entity.LossSetMetaData._) : [],
                ModelAnalysisIds: modelAnalysisIds
            });
        });
    }
}

const actions = {
    loadSubmissionData({ commit }, { programRef, analysisId }) {
        var tableService = azure.createTableService(config.azureTableStore.account, config.azureTableStore.key);
        var tableName = config.appPrefix + 'SubmissionData';
        var tableQuery = new azure.TableQuery()

        tableQuery = tableQuery.where('PartitionKey eq ?', programRef + '-' + analysisId)

        tableService.queryEntities(tableName, tableQuery, null, (error, results, response) => {
            commit('setSubmissionData', { list: results.entries });
        });
    },
    async load({ dispatch }, { programRef, analysisId }) {
        const accountInfo = { programRef, analysisId };
        await dispatch('loadSubmissionData', accountInfo);
        await dispatch('rdm/load', accountInfo);
        await dispatch('clf/load', accountInfo);
        await dispatch('cedeExp/load', accountInfo);
        await dispatch('cedeRes/load', accountInfo);
    }
}

export default {
    namespaced: true,
    state,
    getters,
    mutations,
    actions,
    modules: {
        rdm,
        clf,
        cedeExp,
        cedeRes
    }
}