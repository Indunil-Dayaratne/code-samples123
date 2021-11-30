import Vue from 'vue';
import azure from 'azure-storage';
import AzureStorageUtils from '@/shared/azure-storage-utils';
import api from '../../../../../shared/api';

//Modules
import files from './files';

const analysisTableName = config.appPrefix + 'Analysis';

const state = {  
    programRef: null,
    analysisId: null,
    accountName: null,
    summary: null,
    requestedOn: null,
    dataFileLocation: null,
    requestedBy: null,
    failed: null,
    currencyExchangeRates: null,
    groupId: null,
    group: null,
    groupAnalyses: [],
    groups: [],
    showSpinner: false,
    defaultCurrency: null
}

const getters = {
    isCurrentAccount: (state) => (programRef, analysisId) => {
        return state.programRef === programRef && state.analysisId === analysisId;
    },
    pricingGroups: state => {
        return [state.groupId];
    },
    groupAnalyses: (state, getters, rootState, rootGetters) => {
        return rootGetters['account/index/getAllAnalysesForProgram'](state.programRef);
    }
}

const mutations = {
    setAnalysis: (state, item) => {
        state.groupAnalyses = [];
        state.group = null;
        state.programRef = item.PartitionKey._;
        state.analysisId = item.RowKey._;
        state.accountName = item.AccountName._;
        state.summary = item.Summary._;
        state.groupId = item.GroupId ? item.GroupId._ : '';
        state.requestedOn = Vue.moment(item.CreatedOn._).format(config.dateFormat);
        state.dataFileLocation = item.DataFileLocation._;
        state.requestedBy = item.CreatedBy._;
        state.CurrencyExchangeRateSetSID = item.CurrencyExchangeRateSetSID ? item.CurrencyExchangeRateSetSID._ : null;
        state.currencyExchangeRates = item.CurrencyExchangeRates ? JSON.parse(item.CurrencyExchangeRates._) : [];
        state.defaultCurrency = item.DefaultCurrency ? item.DefaultCurrency._ : 'USD';
    },
    setGroups: (state, { list }) => {
        state.groups = [];
        list.forEach((entity) => {
          state.groups.push({
            partitionKey: entity.PartitionKey._,
            rowKey: entity.RowKey._,
            groupId: `${entity.PartitionKey._}-${entity.RowKey._}`,
            groupName: entity.GroupName._,
            analyses:   entity.Analyses ? JSON.parse(entity.Analyses._) : [],
            networkIds: entity.NetworkIds ? JSON.parse(entity.NetworkIds._) : []
          });
        });

        state.groups.sort(function(a,b){
            let nameA = a.groupName.toUpperCase();
            let nameB = b.groupName.toUpperCase();
            if (nameA < nameB) {
                return -1;
            }

            if (nameA > nameB) {
                return 1;
            }
            
            // names must be equal
            return 0;
        });
    },
    addAnalysisToGroup: (state, analysis) => {
        state.groupAnalyses.push( {
            ProgramRef: analysis.PartitionKey._,
            AnalysisId: analysis.RowKey._,
            AccountName: analysis.AccountName._,
            Summary: analysis.Summary._,
            GroupId: analysis.GroupId ? analysis.GroupId._ : '',
            RequestedOn: Vue.moment(analysis.CreatedOn._).format(config.dateFormat),
            DataFileLocation: analysis.DataFileLocation._,
            RequestedBy: analysis.CreatedBy._
        });
    },
    addNetworkToGroup: (state, networkId) => {
        state.group.networkIds.push(networkId);
    },
    setShowSpinner(state, showSpinner) {
        state.showSpinner = showSpinner;
    },
    clear(state) {
        state.programRef = null;
        state.accountName = null;
        state.summary = null;
        state.requestedOn = null;
        state.dataFileLocation = null;
        state.requestedBy = null;
        state.groupId = null;
        state.group = null;
        state.groupAnalyses = [];
        state.groups = [];
        state.files.files = [];
        state.files.rdm.analyses = [];
        //---
        state.files.cedeExp.geoLevels = [];
        state.files.cedeExp.constructions = [];
        state.files.cedeExp.occupancies = [];
        state.files.cedeExp.perils = [];
        state.files.cedeExp.stories = [];
        state.files.cedeExp.subAreas = [];
        state.files.cedeExp.wsTiers = [];
        state.files.cedeExp.yearBuilts = [];
        state.files.cedeExp.carlifoniaEQZones = [];
        state.files.cedeExp.distanceToCoast = [];
        state.files.cedeExp.lobs = [];
        state.files.cedeExp.rpxs = [];
        state.files.cedeExp.savedLobMappings = {};
    }
}

const actions = {
    async loadAnalysis(context, { programRef, analysisId }) {
        try {
            let tableService = azure.createTableService(config.azureTableStore.account, config.azureTableStore.key);
            let result = await AzureStorageUtils.retrieveEntityAsync(tableService, analysisTableName, programRef.toUpperCase(), analysisId);

            context.commit('setAnalysis', result);
            if (result.GroupId) {
                let split = result.GroupId._.split("-");
                context.dispatch("getAnalysisGroups", { partitionKey: split[0], rowKey: split[1] });
            }
        } catch (err) {
            console.error(err);
        }
    },
    async loadGroups({commit}) {
        try {
            let results = await api.getGroups();
            commit('setGroups', { list: results });
        } catch (err) {
            console.error(err);
        }
    },
    async createOrUpdateGroup(context, { group }) {
        try {
            const entity = await api.createOrUpdateGroup(group);
            context.dispatch("updateAnalysis", { groupId: `${entity.PartitionKey._}-${entity.RowKey._}` });
            context.dispatch("getAnalysisGroups", { partitionKey: entity.PartitionKey._, rowKey: entity.RowKey._ });
        } catch (err) {
            console.error(err);
        }
    },
    async getAnalysisGroups(context, { partitionKey, rowKey }) {
        try {
            let group = await api.getGroup(partitionKey, rowKey);

            context.state.group = group;
            context.state.groupAnalyses = [];

            group.analyses.sort().forEach(async (ref) => {
                let split = ref.split("-");
                let result = await api.getAnalysis(split[0].toUpperCase(), split[1]);
                context.commit('addAnalysisToGroup', result[0]);
            }); 
        } catch (err) {
            console.error(err);
        }  
    },
    async updateAnalysis(context, { groupId }) {
        try {
            let tableService = azure.createTableService(config.azureTableStore.account, config.azureTableStore.key);

            let entGen = azure.TableUtilities.entityGenerator;
            context.state.groupId = groupId;
            let entity = {
                PartitionKey: entGen.String(context.state.programRef),
                RowKey: entGen.String(context.state.analysisId),
                GroupId: entGen.String(groupId)
            };

            await AzureStorageUtils.insertOrMergeEntityAsync(tableService, analysisTableName, entity);
        } catch (err) {
            console.error(err);
        }
    },
    async addNetworkToGroup(context, networkId) {
        if (context.state.group.networkIds.includes(networkId)) return;
        context.commit('addNetworkToGroup', networkId);
        await context.dispatch('createOrUpdateGroup', { group: context.state.group });
    },
    async load({dispatch}, accountInfo) {
        await dispatch('loadAnalysis', accountInfo);
        await dispatch('loadGroups');
    }
}

export default {
    namespaced: true,
    state,
    getters,
    mutations,    
    actions,
    modules: {
        files
    }
}
