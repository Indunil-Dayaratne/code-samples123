import _ from 'lodash';
import Vue from 'vue';

const state = {
    data: [],
    activeView: 0,
    viewTypes: [
        'STC',
        'DET'
    ],
    stochasticViewId: 'v20',
    deterministicViewId: 'v19',
    unsavedChanges: false
}

const getters = {
    viewCount: (state) => {
        return state.data.filter(x => !!x).length;
    },
    slotsRemaining: (state) => {
        return state.data.filter(x => !x).length;
    },
    getViewById: (state) => (id) => {
        var view = state.data.find(x => !!x && x.id === id);
        if (!view) { console.error(`No view found with ID: ${id}`); return; }
        return view;
    },
    isValidLabel: (state) => (label) => {
        var currentLabels = state.data.map(x => x.identifier);
        return currentLabels.includes(label);
    },
    missingMappingsExist: (state, getters) => (viewId) => {
        return getters.getUnmappedInputs(viewId).length !== 0;
    },
    getUnmappedInputs: (state, getters, rootstate) => (viewId) => {
        var view = state.data.find(x => !!x && x.id === viewId);
        if (!view) { console.error(`No view found with ID: ${viewId}`); return; }
        var unMappedInputs = rootstate.pricing.structure.inputs.filter(x => !x.data.paths[view.identifier]);
        return unMappedInputs;
    },
    getMappedInputs: (state, getters, rootstate) => (viewId) => {
        var view = state.data.find(x => !!x && x.id === viewId);
        if (!view) { console.error(`No view found with ID: ${viewId}`); return; }
        var mappedInputs = rootstate.pricing.structure.inputs.filter(x => !!x.data.paths[view.identifier]);
        return mappedInputs;
    },
    getFirstValidIndex: (state) => {
        return state.data.findIndex(x => !x);
    },
    getValidViews: (state) => {
        return state.data.filter(x => !!x);
    }
}

const mutations = {
    initialise(state, count) {
        for (let i = 0; i < count; i++) {
            state.data.push(undefined);
        }
        state.unsavedChanges = false;
    },
    loadData(state, views) {
        state.data = views;
        state.activeView = 0;
        state.unsavedChanges = false;
    },
    addView(state, index) {
        let view = {
            id: new Date().getTime(),
            label: 'Name',
            description: '',
            identifier: 'v' + (index + 1),
            type: '',
            currency: '',
            simulations: 0,
            forStcPortfolio: false,
            forDetPortfolio: false
        }
        Vue.set(state.data, index, view);
        //state.activeView = view.Id;
        state.unsavedChanges = true;
    },
    updateView(state, data) {
        var view = state.data.find(x => !!x && x.id === data.id);
        if (!view) { console.error(`No view found with ID: ${data.id}`); return; }
        Object.assign(view, data);
        state.unsavedChanges = true;
    },
    removeView(state, id) {
        var index = state.data.findIndex(x => x && x.id === id);
        if (index < 0) { console.error(`No view found with ID: ${id}`); return; }
        Vue.set(state.data, index, null);
        state.unsavedChanges = true;
    },
    activateView(state, id) {
        var view = state.data.find(x => !!x && x.id === id);
        if (!view) { console.error(`No view found with ID: ${id}`); return; }
        state.activeView = id;
    },
    deactivateView(state) {
        state.activeView = 0;
    },
    updateSimulations(state, {viewId, sims}) {
        var view = state.data.find(x => !!x && x.id === viewId);
        if (!view) { console.error(`No view found with ID: ${viewId}`); return; }
        Vue.set(view, 'simulations', sims);
    },
    clear(state) {
        state.data = [];
        state.unsavedChanges = false;
    }
}

const actions = {
    initialise(context, count) {
        context.commit('initialise', (count && Math.min(count, 18)) || 18);
    },
    loadData(context, views) {
        context.commit('loadData', views);
    },
    async mapInput(context, data) {
        try {
            let preActionMappedInputCount = context.getters.getMappedInputs(data.viewId).length;
            await context.dispatch('pricing/structure/commitChange', { mutation: 'mapLossSetToInput', data }, { root: true });
            let postActionMappedInputCount = context.getters.getMappedInputs(data.viewId).length;
            if(preActionMappedInputCount === 0 || postActionMappedInputCount === 0) {
                context.commit('updateSimulations', {
                    viewId: data.viewId,
                    sims: data.simulations
                });
            }
        } catch(err) {
            console.error(err);
        }
    },
    async deleteLossView(context, id) {
        try {
            const view = context.getters.getViewById(id);
            if(!view) return;
            context.dispatch('commitChange', { mutation: 'removeView', data: id });
            await context.dispatch('pricing/structure/commitChange', { mutation: 'removeLossSetMappings', data: view.identifier }, { root: true });
        } catch (err) {
            console.error(err);
        }
    },
    commitChange(context, { mutation, data }) {
        try {
            let initialStateUnsavedChanges = context.state.unsavedChanges;
            context.commit(mutation, data);
            if (context.state.unsavedChanges && !initialStateUnsavedChanges) context.dispatch('pricing/updateCalculationOutOfDateFlag', null, { root: true });
        } catch (err) {
            console.error(err);
        }
    },
    clear(context) {
        context.commit('clear');
    }
}

export default {
    namespaced: true,
    state,
    getters,
    mutations,
    actions
}