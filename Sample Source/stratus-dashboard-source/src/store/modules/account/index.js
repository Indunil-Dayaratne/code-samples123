import index from './modules/indexing';
import analysis from './modules/analysis';
import program from './modules/program'
import { ACCOUNT_TYPES } from '../../../shared/types';

const state = () => ({
    type: ACCOUNT_TYPES.analysis,
    showSpinner: false,
    baseLoadPromise: null,
    loadPromise: null
})

const getters = {
    getSubModule: state => state.type.name,
    getValue: (state, getters) => (getterName, ...args) => {
        const getterRoute = `${getters.getSubModule}/${getterName}`;
        return getters[getterRoute];
    },
    get: (state, getters) => (key) => {
        if(!state[getters.getSubModule]) return null;
        return state[getters.getSubModule][key] || getters.getValue(key);
    }
}

const mutations = {
    updateType: (state, type) => {
        state.type = type;
    },
    setShowSpinner: (state, visible) => {
        state.showSpinner = visible
    },
    saveLoadPromise(state, promise) {
        //console.log(promise);
        state.baseLoadPromise = promise;
        state.loadPromise = promise.then(() => {
            state.loadPromise = null;
            state.baseLoadPromise = null;
            state.showSpinner = false;
        });
    }
}

const actions = {
    async load(context, { programRef, analysisId, type }){
        try {
            
            if(!type) type = ACCOUNT_TYPES.analysis;
            context.commit('updateType', type);
            await context.dispatch('mutate', { mutation: 'clear' });
            await context.dispatch('index/loadForProgram', programRef);
            //debugger;
            if(type.name !== ACCOUNT_TYPES.none.name) {
                //debugger;
                await context.dispatch('act', { action: 'load', data: { programRef, analysisId }});
                await context.dispatch('act', { action: 'files/load', data: { programRef, analysisId }});
                //await context.dispatch('cedeResults/loadData', { programRef, analysisId }, { root: true });
                await context.dispatch('pricing/clearNetworkSelectionData', null, { root: true });
                await context.dispatch('pricing/views/initialise', null, { root: true });
                await context.dispatch('pricing/getAvailableNetworks', null,  { root: true });
                await context.dispatch('pricing/lossSets/getLossSets', null,  { root: true });
                context.dispatch('pricing/getExchangeRates', null,  { root: true });
                context.dispatch('elt/getEventSets', null,  { root: true });
                context.dispatch('elt/getSimulationSets', null,  { root: true });
            }
            
            //context.commit('setShowSpinner', false);
        } catch (err) {
            console.error(err);
        }
    },
    mutate(context, { mutation, data }) {
        try {
            const mutationRoute = `${context.getters.getSubModule}/${mutation}`;
            context.commit(mutationRoute, data);
        } catch (err) {
            console.error(err);
        }
    },
    async act(context, { action, data }) {
        try {
            const actionRoute = `${context.getters.getSubModule}/${action}`;
            await context.dispatch(actionRoute, data);
        } catch (err) {
            console.error(err);
        }
    },
    async update({ dispatch, commit, state, getters }, route) {
        const routeType = ACCOUNT_TYPES.getTypeFromRoute(route);
        if(!routeType && !state.type) return;
        if(routeType.name === ACCOUNT_TYPES.none.name) return;
        if(routeType.name === state.type.name) {
            if(getters.getValue('isCurrentAccount')(route.params.programRef, route.params.id)) return;
        }

        commit('setShowSpinner', true);
        const load = dispatch('load', { 
            programRef: route.params.programRef,
            analysisId: route.params.id,
            type: routeType 
        });
        commit('saveLoadPromise', load);
        await load;
    },
    runAfterLoad({ commit, state, rootState, rootGetters }, fn) {
        if(!state.loadPromise) fn(rootState, rootGetters);
        else {
            const prom = state.baseLoadPromise.then(() => fn(rootState, rootGetters));
            commit('saveLoadPromise', prom);
        }
    }
}

export default {
    namespaced: true,
    state,
    getters,
    mutations,
    actions,
    modules: {
        index,
        analysis,
        program
    }
}