import Vue from 'vue';
import azure from 'azure-storage';

const state = {
    submissionData: []
  }

const mutations = {
  setSubmissionData: (state, { list }) => {
      state.submissionData = [];
      list.forEach((entity) => {

        let modelAnalysisIds = [];
        
        if (entity.WsstWithDemandSurgeModelAnalysisIds) {
          modelAnalysisIds.push({ RunCatalogType : "WsstWithDemandSurge", ModelAnalysisIds: JSON.parse(entity.WsstWithDemandSurgeModelAnalysisIds._) });
        }

        if (entity.WsstWithoutDemandSurgeModelAnalysisIds) {
          modelAnalysisIds.push({ RunCatalogType : "WsstWithoutDemandSurge", ModelAnalysisIds: JSON.parse(entity.WsstWithoutDemandSurgeModelAnalysisIds._) });
        }

        if (entity.StdWithDemandSurgeModelAnalysisIds) {
          modelAnalysisIds.push({ RunCatalogType : "StdWithDemandSurge", ModelAnalysisIds: JSON.parse(entity.StdWithDemandSurgeModelAnalysisIds._) });
        }

        if (entity.StdWithoutDemandSurgeModelAnalysisIds) {
          modelAnalysisIds.push({ RunCatalogType : "StdWithoutDemandSurge", ModelAnalysisIds: JSON.parse(entity.StdWithoutDemandSurgeModelAnalysisIds._) });
        }

        state.submissionData.push({          
          PartitionKey: entity.PartitionKey._,
          RowKey: entity.RowKey._,
          DataType: entity.DataType ? entity.DataType._ : "",
          DatabaseName:  entity.DatabaseName ? entity.DatabaseName._: "",
          FilePath: entity.FilePath ? entity.FilePath._ : "",
          SourceType: entity.SourceType ? entity.SourceType._ : "",
          FileName: entity.FilePath ? (entity.FilePath._.substring(entity.FilePath._.lastIndexOf("\\") + 1)) : "",
          LossUploaded: entity.LossUploaded ? JSON.parse(entity.LossUploaded._) : [],
          RunCatalogTypes:  entity.RunCatalogTypes ? JSON.parse(entity.RunCatalogTypes._) : [],
          RunTypes: entity.RunTypes ? JSON.parse(entity.RunTypes._) : [],
          IsPerilsMapped: entity.IsPerilsMapped ? entity.IsPerilsMapped._ : false,
          LossSetMetadata: entity.LosssetMetaData ? JSON.parse(entity.LossSetMetaData._) : [],
          ModelAnalysisIds: modelAnalysisIds
        });
      });
    }
}

const getters = {    
  rdms: state => state.submissionData.filter(x => x.DataType === 'RDM'),
  clfs: state => state.submissionData.filter(x => x.DataType === 'CLF'),
  cedeExp: state => state.submissionData.filter(x => x.DataType === 'EXP'),
  anyCedesHavePerilsMapped: state => state.submissionData.filter(x => x.DataType === 'EXP').some(x => x.IsPerilsMapped)
}

const actions = {
  load({ commit }, { programRef, analysisId }) {
      var tableService = azure.createTableService(config.azureTableStore.account, config.azureTableStore.key);
      var tableName = config.appPrefix + 'SubmissionData';
      var tableQuery = new azure.TableQuery()
  
      tableQuery = tableQuery.where('PartitionKey eq ?', programRef + '-' + analysisId)
    
      tableService.queryEntities(tableName, tableQuery, null, (error, results, response) => {
        commit('setSubmissionData', { list: results.entries });
      });      
  }
}

export default {
  namespaced: true,
  state,
  actions,
  getters,
  mutations
}
