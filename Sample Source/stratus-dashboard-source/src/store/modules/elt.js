import axios from 'axios';
import azure from 'azure-storage';
import AzureStorageUtils from '../../shared/azure-storage-utils';

const simSetTableName = config.appPrefix + 'SimulationSets';

const state = () => ({
    availableEventSets: [],
    availableSimSets: []
})

const getters = {
    eventSets: state => {
        return state.availableEventSets;
    },
    simulationSets: state => {
        return state.availableSimSets;
    }
}

const mutations = {
    updateEventSets: (state, payload) => {
        state.availableEventSets = payload
    },
    updateSimSets: (state, entries) => {
        state.availableSimSets = [];
        entries.forEach((entity) => {
            if(!entity.Name) return;
            state.availableSimSets.push({
                partitionKey: entity.PartitionKey._,
                rowKey: entity.RowKey._,
                name: entity.Name._,
                folder: entity.Folder ? entity.Folder._ : "",
                sims: entity.Sims ? entity.Sims._ : 0,
                seed: entity.Seed ? entity.Seed._ : 0,
                type: entity.Type ? entity.Type._ : "",
                uploadCompleted: entity.UploadCompleted ? entity.UploadCompleted._ : null,
                uploadedBy: entity.UploadedBy ? entity.UploadedBy._ : "",
                eventSetName: entity.EventSetName ? entity.EventSetName._ : ""
            });
        });
    }
}

const actions = {
    async getEventSets({ commit }) {
        try {
            let response = await axios.post(config.getEventSetsLogicAppEndpoint);
            if (response.status !== 200) { console.error(response); return; }
            commit('updateEventSets', response.data);
        } catch(error) {
            console.error(error);
        }
    },
    async getSimulationSets(context) {
        try {
            let tableService = azure.createTableService(config.azureTableStore.account, config.azureTableStore.key);
            let query = new azure.TableQuery();
            let results = await AzureStorageUtils.queryEntitiesAsync(tableService, simSetTableName, query);
            context.commit('updateSimSets', results);
        } catch (error) {
            console.error(error);
        }
    },
    async uploadSimulationSet(context, params) {
        try {
            await axios.post(config.uploadSimulationSetLogicAppEndpoint, {
                programRef: context.rootGetters['account/get']('programRef'),
                analysisId: context.rootGetters['account/get']('analysisId'),
                user: context.rootState.auth.user.userName,
                ...params
            });
        } catch (error) {
            console.error(error);
        }
    },
    async generateSimulationSet(context, params) {
        try {
            await axios.post(config.generateSimulationSetLogicAppEndpoint, {
                programRef: context.rootGetters['account/get']('programRef'),
                analysisId: context.rootGetters['account/get']('analysisId'),
                user: context.rootState.auth.user.userName,
                ...params
            });
        } catch (error) {
            console.error(error);
        }
    },
    async refreshDayDistributions(context) {
        try {
            await axios.post(config.refreshDayDistributionsLogicAppEndpoint, {
                programRef: context.rootGetters['account/get']('programRef'),
                analysisId: context.rootGetters['account/get']('analysisId'),
                user: context.rootState.auth.user.userName
            });
        } catch (error) {
            console.error(error);
        }
    }
}

export default {
    namespaced: true,
    state,
    getters,
    mutations,
    actions
}