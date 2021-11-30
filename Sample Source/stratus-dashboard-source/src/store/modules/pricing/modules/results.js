import AzureStorageUtils from '@/shared/azure-storage-utils';
import Vue from 'vue';
import api from '../../../../shared/api';
import {NodeResult} from '../../../../shared/models';

const resultsTableName = config.appPrefix + 'LossResults';

const state = () => ({
    nodeOptions: [],
    nodeData: {},
    yeltData: {},
    tableName: resultsTableName,
    visible: false,
    uiMessage: '',
    maxResultCount: 5,
    loadedNodes: [],
    loadedYelts:[]
})

const getters = {
    nodeIsLoaded: (state) => (nodeId) => {
        return state.nodeData[nodeId] != null;
    },
    getResult: (state, getters) => (type, ...args) => {
        if (type === 'STC') {
            return getters.getNodeResult(args[0]);
        } else {
            return getters.getYeltResult(args[0], args[1], args[2], args[3]);
        }
    },
    getNodeResult: (state) => (ids) => {
        let output = [];
        for (const id of ids) {
            const val = state.nodeData[id];
            if(val) output.push(val);
        }
        return output;
    },
    getYeltResult: (state) => (networkId, eventIds, lossViews, currency) => {
        if (!state.yeltData[networkId]) return null;
        const yelt = state.yeltData[networkId];
        if (!eventIds || !eventIds.length) eventIds = yelt.events;
        return eventIds.reduce((acc, eventId) => {
            if (!yelt.data[String(eventId)]) return acc;
            if (!lossViews || !lossViews.length) lossViews = Object.keys(yelt.data[String(eventId)]);
            acc.push(...lossViews.reduce((innerAcc, lv) => {
                if (!yelt.data[String(eventId)][lv] 
                    || !yelt.data[String(eventId)][lv][currency]) 
                        return innerAcc;
                innerAcc.push(...yelt.data[String(eventId)][lv][currency]);
                return innerAcc;
            }, []));
            return acc;
        }, []);
    },
    tableName(state) {
        return state.tableName;
    },
    getEventIds: (state) => (networkId) => {
        if (!state.yeltData[networkId]) return null;
        return state.yeltData[networkId].events;
    },
    getAllNodeResults: state => {
        return getters.getNodeResult(state)(Object.keys(state.nodeData));
    },
    isLoading: state => state.uiMessage !== '',
    loadedNodeCount: state => state.loadedNodes.length,
    validateSelectedNodes: state => selectedNodes => {
        const output = [];
        for (const node of selectedNodes) {
            if(state.loadedNodes.includes(node.id)) output.push(node);
        }
        return output;
    }
}

const mutations = {
    initialise(state) {
        state.nodeData = {};
        state.yeltData = {};
        state.loadedNodes = [];
    },
    clear(state) {
        state.nodeOptions = [];
        state.nodeData = {};
        state.yeltData = {};
        state.loadedNodes = [];
    },
    clearResults(state) {
        state.nodeData = {};
        state.yeltData = {};
        state.loadedNodes = [];
    },
    addNetworkYeltItem(state, networkId) {
        if (state.yeltData[networkId]) return;
        Vue.set(state.yeltData, networkId, { events: [], data: {} });
    },
    saveNodeResult(state, { nodeId, data }) {
        while(state.loadedNodes.length >= state.maxResultCount) {
            const nodeToDelete = state.loadedNodes.shift();
            Vue.delete(state.nodeData, nodeToDelete);
        }
        Vue.set(state.nodeData, nodeId, Object.freeze(new NodeResult(data)));
        state.loadedNodes.push(nodeId);
    },
    saveYeltData(state, { networkId, data, eventIds, lossViews, currency }) {
        eventIds.forEach(eventId => {
            if (!state.yeltData[networkId].data[String(eventId)]) Vue.set(state.yeltData[networkId].data, String(eventId), {});
            lossViews.forEach(lv => {
                if (!state.yeltData[networkId].data[String(eventId)][lv]) Vue.set(state.yeltData[networkId].data[String(eventId)], lv, {});
                const toAdd = Object.freeze(
                    data.filter(x => {
                        return x.eventId === eventId && 
                            x.lossViewIdentifier === lv;
                    }).map(x => { return {...x, currency } })
                );
                Vue.set(state.yeltData[networkId].data[String(eventId)][lv], currency, toAdd);
            });
        });
    },
    saveEventIds(state, { networkId, data }) {
        state.yeltData[networkId].events = Object.freeze(data.filter(x => x !== 0));
    },
    updateTabVisible(state, visible) {
        state.visible = visible;
    },
    updateLoadingState(state, message) {
        state.uiMessage = message;
    },
    saveNodeOptions(state, options) {
        state.nodeOptions = options;
    },
    updateMaxResultCount(state, newMax) {
        state.maxResultCount = Math.max(1, newMax);
        while(state.loadedNodes.length > state.maxResultCount) {
            const nodeToDelete = state.loadedNodes.shift();
            Vue.delete(state.nodeData, nodeToDelete);
        }
    }
}

const actions = {
    async load({ dispatch, commit }) {
        try {
            await dispatch('getAvailableNodes');
            await dispatch('getAllNodeResults');
        } catch (err) {
            commit('updateLoadingState', '');
            console.error(err);
        }
    },
    clear(context) {
        context.commit('clear');
    },
    async getAvailableNodes({ commit, rootState, rootGetters }) {
        try {
            commit('updateLoadingState', 'Loading available layers');
            let results = await api.getStandardNetworkResults(rootState.pricing.selectedNetworkId, rootGetters['pricing/structure/getNodeById']);
            commit('saveNodeOptions', results);
        } catch (err) {
            console.log(err);
        } finally {
            commit('updateLoadingState', '');
        }
    },
    async getResultsForNodeById(context, {networkId, nodeId}) {
        try {
            let tableService = azure.createTableService(config.azureTableStore.account, config.azureTableStore.key);
            let result = await AzureStorageUtils.retrieveEntityAsync(tableService, resultsTableName, networkId, nodeId);
            await context.dispatch('getNodeResultFromBlob', { nodeId, url: result.BlobUri._ })
        } catch (err) {
            console.error(err);
        }
    },
    async getAllNodeResults({ commit, dispatch, state }) {
        try {
            commit('updateLoadingState', 'Loading all results');
            commit('clearResults');
            const reqs = [];
            // get ceded layers first
            const initialNodes = state.nodeOptions.filter(x => x.node && x.node.data && x.node.data.objType === 'layer' && (!x.node.data.layer_type || x.node.data.layer_type === 'ceded'));
            const initialNodeIds = initialNodes.map(x => x.id);
            const remainingNodes = state.nodeOptions.filter(x => !initialNodeIds.includes(x.id));
            let loadedNodes = 0;
            while(loadedNodes < Math.min(state.nodeOptions.length, state.maxResultCount)) {
                const option = loadedNodes < initialNodes.length ? initialNodes[loadedNodes] : remainingNodes[loadedNodes - initialNodes.length];
                reqs.push(dispatch('getNodeResultFromBlob', { nodeId: option.id, url: option.url }));
                loadedNodes++;
            };
            await Promise.all(reqs);
        } catch (err) {
            console.log(err);
        } finally {
            commit('updateLoadingState', '');
        }
    },
    async getNodeResults({ dispatch, state}, selectedNodes) {
        try {
            for (let i = 0; i < Math.min(selectedNodes.length, state.maxResultCount); i++) {
                const node = selectedNodes[Math.max((selectedNodes.length - state.maxResultCount), 0) + i];
                await dispatch('getNodeResultFromBlob', node);
            }
        } catch (err) {
            console.log(err);
        }
    },
    async getNodeResultFromBlob(context, {nodeId, url}) {
        try {
            if(context.getters.nodeIsLoaded(nodeId)) return;
            let response = await api.graphene.getNodeResultsFromBlobStorage(url);
            if (response.status !== 200) throw response;
            context.commit('saveNodeResult', {
                nodeId,
                data: response.data
            });
        } catch (err) {
            console.error(err);
        }
    },
    async getEventIds(context, { networkId, lossViewIdentifiers }) {
        try {
            context.commit('updateLoadingState', 'Downloading event IDs');
            let response = await api.graphene.getEventIds({
                networkId: networkId,
                lossViewIdentifiers: lossViewIdentifiers
            });
            if (response.status !== 200) throw response;
            context.commit('addNetworkYeltItem', networkId);
            context.commit('saveEventIds', { networkId, data: response.data });
        } catch (err) {
            console.error(err);
        } finally {
            context.commit('updateLoadingState', '');
        }
    },
    async getYeltData(context, { networkId, lossViewIdentifiers, currency, eventIds }) {
        try {
            context.commit('updateLoadingState', 'Downloading YELT data');
            let response = await api.graphene.getYeltByEvent({
                networkId: networkId,
                lossViewIdentifiers: lossViewIdentifiers,
                currency,
                eventIds: eventIds
            });
            if (response.status !== 200) throw response;
            context.commit('addNetworkYeltItem', networkId);
            context.commit('saveYeltData', { networkId, data: response.data, eventIds, lossViews: lossViewIdentifiers, currency });
            context.commit('updateLoadingState', '');
        } catch (err) {
            console.error(err);
        }
    },
    async runPricingAnalysis(context) {
        try {
            let networkProperties = context.rootGetters['pricing/getSelectedNetworkProperties'];
            await api.graphene.runPricingAnalysis({
                programRef: context.rootGetters['account/get']('programRef'),
                analysisId: context.rootGetters['account/get']('analysisId'),
                groupId: networkProperties.groupId,
                networkId: context.rootState.pricing.selectedNetworkId,
                nodeIds: context.rootGetters['pricing/structure/getAllNodeIds'],
                user: context.rootState.auth.user.userName,
                structure: {
                    networkId: networkProperties.networkId,
                    revision: networkProperties.revision,
                    inputs: context.rootState.pricing.structure.inputs,
                    layers: context.rootState.pricing.structure.layers,
                    links: context.rootState.pricing.relationships,
                    data: {
                        properties: networkProperties,
                        lossViews: context.rootState.pricing.views.data
                    }
                }
            });
        } catch (err) {
            console.error(err);
        }
    },
    async exportToPrime(context, {networkId, mode, eventCatalogIds}) {
        try {
            let ids = [];
            let response = await api.graphene.getNetwork({networkId});
            if(response.status !== 200) { console.error(`Unknown network - ID: ${networkId}`); return; }
            let structure = response.data;

            switch (mode.toLowerCase()) {
                case 'layers':
                    ids = structure.layers.map(x => x.id);
                    break;

                case 'inputs':
                    ids = structure.inputs.map(x => x.id);
                    break;

                case 'all':
                    ids.push(...structure.layers.map(x => x.id));
                    ids.push(...structure.inputs.map(x => x.id));
                    break;
            
                default:
                    throw 'Unknown export to Prime type';
            }

            ids.forEach(id => {
                api.graphene.exportToPrime({
                    programRef: context.rootGetters['account/get']('programRef'),
                    analysisId: context.rootGetters['account/get']('analysisId'),
                    networkId: structure.networkId,
                    revision: structure.revision,
                    nodeId: id,
                    user: context.rootState.auth.user.userName,
                    eventCatalogIds
                });
            });
            
        } catch (err) {
            console.error(err);
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