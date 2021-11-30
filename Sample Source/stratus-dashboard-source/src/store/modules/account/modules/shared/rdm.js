import api from '../../../../../shared/api';
import Vue from 'vue';

const state = {
    analyses: []
}

const getters = {
    analyses: state => state.analyses
}

const mutations = {
    updateRdmAnalyses: (state, data) => {
        state.analyses = [];
        state.analyses.push(...data);
    }
}

const actions = {
    async load({ commit }, { programRef, analysisId }) {
        const result = await api.getRdmAnalysesFromAnalysis(programRef, analysisId);
        commit('updateRdmAnalyses', result);
        Vue.bus.emit('display-tab', { tab: 'RDM', display: result.length > 0 });
    }
}

export default {
    namespaced: true,
    state,
    getters,
    mutations,
    actions
}