import Vue from 'vue';
import azure from 'azure-storage';

function cedeSorter(a, b) {
    const resultsSid = a.ResultSID - b.ResultSID;
    if(resultsSid !== 0) return resultsSid;
    if(a.LineOfBusiness > b.LineOfBusiness) return 1;
    if(a.LineOfBusiness < b.LineOfBusiness) return -1;
    return 0;
}

const state = {
    cedeRunSummary: [],
    fileRunCombinations: {
        files: [],
        dict: {}
    },
    modalCede: {}
};

const getters = {
    getRunTypes: (state) => (file) => {
        return file in state.fileRunCombinations.dict ? 
            state.fileRunCombinations.dict[file] :
            []
    },
    filteredSummaries: (state) => (file, run) => {
        if (!file && !run) return state.cedeRunSummary.sort(cedeSorter);
        if (!(file in state.fileRunCombinations.dict)) return [];
        if (!state.fileRunCombinations.dict[file].includes(run)) return [];
        return state.cedeRunSummary.filter(x => x.FileName === file && x.RunCatalogType === run)
            .sort(cedeSorter);
    }
};

const mutations = {
    setCedeRunSummary: (state, {list}) => {
        state.cedeRunSummary = [];
        list.forEach((entity) => {
            state.cedeRunSummary.push({
                PartitionKey: entity.PartitionKey._,
                RowKey: entity.RowKey._,
                FileName: entity.FileName._,
                RunCatalogType: entity.RunCatalogType._,
                ActivitySID: entity.ActivitySID._,
                ResultSID: entity.ResultSID._,
                AnalysisName: entity.AnalysisName._,
                Description: entity.Description ? entity.Description._ : "",
                CurrencyCode: entity.CurrencyCode._,
                CurrencyExchangeRateSet: entity.CurrencyExchangeRateSet._,
                ExposureDataSourceName: entity.ExposureDataSourceName._,
                ExposureSetName: entity.ExposureSetName._,
                EventSet: entity.EventSet._,
                EventSetStandardName: entity.EventSetStandardName._,
                SourceTemplateName: entity.SourceTemplateName ? entity.SourceTemplateName._ : "",
                OutputTypeCode: entity.OutputTypeCode._,
                GeoLevelCode: entity.GeoLevelCode._,
                OutputGroupByCode: entity.OutputGroupByCode._,
                DemandSurgeOptionCode: entity.DemandSurgeOptionCode._,
                EventSetProductVersion: entity.EventSetProductVersion._,
                AnalysisProductVersion: entity.AnalysisProductVersion._,
                EnteredDate: entity.EnteredDate ? Vue.moment(entity.EnteredDate._).format(config.dateFormat) : null,
                ExecutedDate: entity.ExecutedDate ? Vue.moment(entity.ExecutedDate._).format(config.dateFormat) : null,
                CompletedDate: entity.CompletedDate ? Vue.moment(entity.CompletedDate._).format(config.dateFormat) : null,
                AALs: entity.AALs ? JSON.parse(entity.AALs._) : [],
                PerspectiveCode: entity.PerspectiveCode ? entity.PerspectiveCode._ : '',
                UserField1: entity.UserField1 ? entity.UserField1._ : '',
                UserField2: entity.UserField2 ? entity.UserField2._ : '',
                LineOfBusiness: entity.LineOfBusiness ? entity.LineOfBusiness._ : "All"

            });
        });
        Vue.bus.emit('display-tab', {tab: 'CEDE-RES', display: state.cedeRunSummary.length > 0});
    },
    setData: () => {
        state.fileRunCombinations = {};
        state.fileRunCombinations.dict = {};
        let combinations = [
            ...new Set(state.cedeRunSummary.map(x => {
                return {
                    FileName: x.FileName,
                    RunCatalogType: x.RunCatalogType
                }
            }))
        ];

        state.fileRunCombinations.files = [... new Set(combinations.map(x => x.FileName))];
        state.fileRunCombinations.files.forEach((value) => {
            state.fileRunCombinations.dict[value] = [...combinations.filter(x => x.FileName === value).map(x => x.RunCatalogType)];
        });
    },
    setModalRun(state, item) {
        state.modalCede = item;
    }
};

const actions = {
    loadData({ commit }, { programRef, analysisId }) {
      var tableService = azure.createTableService(config.azureTableStore.account, config.azureTableStore.key);
      var tableName = config.appPrefix + 'CedeRunSummary';
      var tableQuery = new azure.TableQuery()
  
      tableQuery = tableQuery.where('PartitionKey eq ?', programRef + '-' + analysisId);
    
      tableService.queryEntities(tableName, tableQuery, null, (error, results, response) => {
        commit('setCedeRunSummary', { list: results.entries });
        commit('setData');
      });
    }
};

export default {
    namespaced: true,
    state,
    getters,
    actions,
    mutations
  };