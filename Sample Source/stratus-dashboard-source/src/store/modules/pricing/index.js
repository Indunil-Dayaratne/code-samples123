import structure from './modules/structure';
import filter from './modules/filter';
import views from './modules/views';
import lossSets from './modules/lossSets';
import results from './modules/results';
import azure from 'azure-storage';
import AzureStorageUtils from '../../../shared/azure-storage-utils';
import api from '../../../shared/api';

const tableName = config.appPrefix + 'PricingNetwork';

const state = {
    selectedNetworkId: null,
    networks: [],
    exchangeRates: [],
    isLoading: false
};

const getters = {
    networkLoaded: state => !!state.selectedNetworkId && !!getters.getSelectedNetworkProperties(state),
    getSelectedNetworkProperties(state) {
        return state.networks.find(x => x.networkId === state.selectedNetworkId);
    },
    unsavedChanges: (state) => {
        return state.structure.unsavedChanges || state.views.unsavedChanges;
    },
    getRevisionForNetwork: (state) => (id) => {
        let network = state.networks.find(x => x.networkId == id);
        if (!network) return null;
        return network.revision;
    },
    getNetworkProperties: (state) => (id) => {
        return state.networks.find(x => x.networkId === id);
    },
    isValidNetworkId: state => id => {
        return !!state.networks.find(x => x.networkId == id);
    }
}

const mutations = {
    loadData(state, {networkId}) {
        state.selectedNetworkId = networkId;
    },
    loadExchangeRates(state, data) {
        state.exchangeRates = data;
    },
    createLocalNetwork(state, networkProperties) {
        state.networks.push(networkProperties);
    },
    loadAvailableNetworks(state, { list }) {
        state.networks = [...list];
    },
    updateNetworkProperties(state, properties) {
        properties.forEach(element => {
            const i = state.networks.findIndex(x => x.networkId === element.networkId);
            if(i >= 0) state.networks.splice(i, 1);
            state.networks.push(element);
        });
    },
    clearData(state) {
        state.selectedNetworkId = null;
        //state.networks = [];
    },
    setCalculationOutOfDateFlag(state, value) {
        let networkProperties = state.networks.find(x => x.networkId === state.selectedNetworkId);
        if (!networkProperties) { console.error(`Inconsistent data stored in pricing store. Selected network ID not found in network list.`); return; }
        networkProperties.calculationUpToDate = value;
    },
    updateNetworkNotes(state, { networkId, notes }) {
        let network = state.networks.find(x => x.networkId === networkId);
        if (!network) return;
        network.notes = notes;
    },
    updateIsLoading(state, isLoading) {
        state.isLoading = isLoading;
    }
};

const actions = {
    async getAvailableNetworks(context) {
        try {
            let groupIds = context.rootGetters['account/get']('pricingGroups');
            if (!groupIds.length) return;
            const results = await api.getNetworks(groupIds);
            context.commit('loadAvailableNetworks', { list: results });
        } catch (err) {
            console.error(err);
        }
    },
    async refreshLoadedNetwork(context) {
        try {
            const result = await api.getNetworks([context.getters['getSelectedNetworkProperties'].groupId]);
            context.commit('updateNetworkProperties', result);
        } catch (err) {
            console.error(err);
        }
    },
    async createNetwork(context, { name, yoa, notes, copyFromNetwork }) {
        try {
            let networkProperties = {
                networkId: -(new Date().getTime()),
                revision: 0,
                groupId: context.rootGetters['account/get']('groupId'),
                name: name,
                yoa: yoa,
                notes: notes,
                createdBy: context.rootState.auth.user.userName,
                createdOn: new Date(),
                modifiedBy: context.rootState.auth.user.userName,
                modifiedOn: new Date(),
                calculationUpToDate: false,
                isRunning: false
            };
            context.commit('createLocalNetwork', networkProperties);
            if (copyFromNetwork.networkId !== 0) await context.dispatch('getNetwork', {
                networkId: copyFromNetwork.networkId,
                revision: copyFromNetwork.revision
            });
            let newStructure = {
                networkId: networkProperties.networkId,
                revision: networkProperties.revision,
                inputs: copyFromNetwork.networkId === 0 ? [] : [...context.state.structure.inputs],
                layers: copyFromNetwork.networkId === 0 ? [api.getNewSubjectLoss(true)] : [...context.state.structure.layers],
                links: copyFromNetwork.networkId === 0 ? [] : [...context.state.structure.relationships],
                data: {
                    properties: networkProperties,
                    lossViews: context.state.views.data.map((x) => copyFromNetwork.networkId === 0 || !x ? undefined : { ...x })
                }
            }
            await context.dispatch('loadNetwork', newStructure);
            await context.dispatch('saveNetwork');
        } catch (err) {
            console.error(err);
        }
    },
    async saveNetworkHeader(context, networkProperties) {
        try {
            let tableService = azure.createTableService(config.azureTableStore.account, config.azureTableStore.key);
            let entGen = azure.TableUtilities.entityGenerator;
            let entity = {
                PartitionKey: entGen.String(networkProperties.groupId),
                RowKey: entGen.String(`${networkProperties.networkId}`),
                Revision: entGen.Int64(networkProperties.revision),
                YOA: entGen.Int64(networkProperties.yoa),
                Name: entGen.String(networkProperties.name),
                Notes: entGen.String(networkProperties.notes || ''),
                CreatedOn: entGen.DateTime(networkProperties.createdOn),
                CreatedBy: entGen.String(networkProperties.createdBy),
                ModifiedOn: entGen.DateTime(new Date()),
                ModifiedBy: entGen.String(context.rootState.auth.user.userName),
                CalculationUpToDate: entGen.Boolean(networkProperties.calculationUpToDate),
                //IsRunning: entGen.Boolean(networkProperties.isRunning)
            };
            await AzureStorageUtils.insertOrMergeEntityAsync(tableService, tableName, entity);
            await context.dispatch('getAvailableNetworks', entity.PartitionKey._);
        } catch (err) {
            console.error(err);
        }
    },
    async getNetwork(context, {networkId}) {
        try {
            context.commit('updateIsLoading', true);
            let response = await api.graphene.getNetwork({networkId});
            if (response.status !== 200) { console.error(response); return; }
            await context.dispatch('loadNetwork', response.data);
            context.commit('updateIsLoading', false);
        } catch (err) {
            console.error(err);
            context.commit('updateIsLoading', false);
        }
    },
    async loadNetwork(context, payload) {
        try {
            const clearPromise = context.dispatch('clearNetworkSelectionData');
            context.commit('updateIsLoading', true);
            await clearPromise;
            context.commit('loadData', { networkId: payload.networkId });
            await context.dispatch('structure/loadData', {
                inputs: payload.inputs,
                layers: payload.layers,
                links: payload.links
            });
            context.commit('views/loadData', payload.data.lossViews);
            await context.dispatch('results/load');
            context.commit('updateIsLoading', false);
        } catch (err) {
            console.error(err);
            context.commit('updateIsLoading', false);
        }
    },
    async saveNetwork(context) {
        try {
            context.commit("structure/isSaving", true);
            let networkProperties = context.state.networks.find(x => x.networkId === context.state.selectedNetworkId);
            if (!networkProperties) throw `Invalid selected network ID: ${context.state.selectedNetworkId}`;
            networkProperties.modifiedBy = context.rootState.auth.user.userName;
            networkProperties.modifiedOn = new Date();
            
            let data = {
                networkId: networkProperties.networkId,
                revision: networkProperties.revision,
                inputs: context.state.structure.inputs,
                layers: context.state.structure.layers,
                links: context.state.structure.relationships,
                data: {
                    properties: networkProperties,
                    lossViews: context.state.views.data
                }
            };
            if(data.inputs.length > 0 || data.layers.length > 0 || data.links.length > 0) {
                let response = await api.graphene.saveNetwork(data);
                if (response.status !== 200) throw response;
                let updatedNetworkProperties = response.data.data.properties;
                updatedNetworkProperties.networkId = response.data.networkId;
                updatedNetworkProperties.revision = response.data.revision;
                //updatedNetworkProperties.isRunning = networkProperties.isRunning;
                await context.dispatch('saveNetworkHeader', updatedNetworkProperties);
                await context.dispatch('account/act', { action: 'addNetworkToGroup', data: updatedNetworkProperties.networkId }, { root: true });
                await context.dispatch('structure/loadData', response.data);
                await context.dispatch('views/loadData', response.data.data.lossViews);
                context.commit('loadData', { networkId: updatedNetworkProperties.networkId });
            }
        } catch (err) {            
            console.error(err);
        } finally {
            context.commit("structure/isSaving", false);
        }
    },
    async clearNetworkSelectionData({ commit, dispatch }) {
        commit('clearData');

        const tasks = [];
        tasks.push(dispatch('views/clear'));
        tasks.push(dispatch('structure/clear'));
        //tasks.push(dispatch('lossSets/clear'));
        tasks.push(dispatch('results/clear'));
        await Promise.all(tasks);
    },
    async updateCalculationOutOfDateFlag(context) {
        context.commit('setCalculationOutOfDateFlag', false);
        //if (context.state.selectedNetworkId < 0) return;
        //await context.dispatch('saveNetworkHeader', context.state.networks.find(x => x.networkId === context.state.selectedNetworkId));
    },
    async getExchangeRates(context, force) {
        try {
            if(!force && context.state.exchangeRates.length > 0) return;
            let response = await api.graphene.getExchangeRates();
            if (response.status !== 200) throw response;
            context.commit('loadExchangeRates', response.data);
        } catch (err) {
            console.error(err);
        }
    },
    async uploadExchangeRates(context, rates) {
        try {
            let response = await api.graphene.uploadExchangeRates(rates);
            if (response.status !== 200) throw response;
            await context.dispatch('getExchangeRates', true);
        } catch (err) {
            console.error(err);
        }
    },
    async loadFromRoute({ dispatch, state, getters }, route) {
        const networkId = route.query.networkId;
        if(!networkId) return;
        //const revision = getters.getRevisionForNetwork(networkId);
        if(state.selectedNetworkId === networkId) return;
        await dispatch('getNetwork', { 
            networkId
        });
    },
};

export default {
    namespaced: true,
    state,
    getters,
    mutations,
    actions,
    modules: {
        structure,
        filter,
        views,
        lossSets,
        results
    }
}
