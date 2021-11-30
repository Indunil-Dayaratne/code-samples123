import api from '../../../../../shared/api';
import Vue from 'vue';

const state = () => ({
    analyses: []
})

const getters = {
    analyses: state => state.analyses
}

const mutations = {
    updateClfAnalyses: (state, data) => {
        state.analyses = data;
    }
}

const actions = {
    async load({ commit, rootState }, { programRef, analysisId }) {
        const result = await api.getClfAnalysesFromAnalysis(programRef, analysisId);
        commit('updateClfAnalyses', result);
        Vue.bus.emit('display-tab', { tab: 'CLF', display: result.length > 0 });
    }
}

export default {
    namespaced: true,
    state,
    getters,
    mutations,
    actions
}