import files from './files';
import Vue from 'vue';
import api from '../../../../../shared/api';

const state = () => ({
    programRef: null,
    accountName: null,
    summary: null,
    requestedOn: null,
    dataFileLocation: null,
    requestedBy: null,
    defaultCurrency: null,
    groupId: null,
    group: null
})

const getters = {
    isCurrentAccount: state => programRef => {
        return state.programRef === programRef;
    },
    pricingGroups: (state, getters, rootState, rootGetters) => {
        const analysisPricingGroups = rootGetters['account/index/getAnalysesForProgram'](state.programRef)
            .filter(x => x.GroupId !== '')
            .map(x => x.GroupId);
        return [
            ...new Set([state.groupId, ...analysisPricingGroups])
        ]
    },
    groupAnalyses: (state, getters, rootState, rootGetters) => {
        return rootGetters['account/index/getAllAnalysesForProgram'](state.programRef);
    }
}

const mutations = {
    setProgram(state, program) {
        state.programRef = program.ProgramRef;
        state.accountName = program.AccountName;
        state.summary = program.Summary;
        state.requestedBy = program.CreatedBy;
        state.requestedOn = Vue.moment(program.CreatedOn).format(config.dateFormat);
        state.defaultCurrency = program.DefaultCurrency;
    },
    setGroup(state, group) {
        state.group = group;
        state.groupId = group.groupId;
    },
    clear(state) {
        state.programRef = null;
        state.accountName = null;
        state.summary = null;
        state.requestedOn = null;
        state.dataFileLocation = null;
        state.requestedBy = null;
        state.files.files = {};
        state.files.rdm.analyses = [];
        state.files.clf.analyses = [];
    },
    addNetworkToGroup: (state, networkId) => {
        state.group.networkIds.push(networkId);
    }
}

const actions = {
    async load({ dispatch }, accountInfo) {
        await dispatch('loadProgramDetails', accountInfo.programRef);
        await dispatch('loadGroup');
    },
    async loadProgramDetails({ commit, dispatch, rootGetters }, programRef) {
        let program = rootGetters['account/index/getProgram'](programRef);
        if(!program) {
            await dispatch('account/index/getPrograms', null, { root: true });
            program = rootGetters['account/index/getProgram'](programRef);
        }
        commit('setProgram', program);
    },
    async loadGroup({ commit, state }) {
        let group = await api.getGroup('program', state.programRef);
        if(!group) {
            group = {
                partitionKey: 'program',
                rowKey: state.programRef,
                groupName: state.programRef, 
                analyses: [`${state.programRef}`], 
                networkIds: []  
            };
            group = await api.createOrUpdateGroup(group);
        }
        commit('setGroup', group);
    },
    async addNetworkToGroup(context, networkId) {
        if(!context.group || !context.group.networkIds) await context.dispatch('loadGroup');
        if (context.state.group.networkIds.includes(networkId)) return;
        context.commit('addNetworkToGroup', networkId);
        const group = await api.createOrUpdateGroup(context.state.group);
        context.commit('setGroup', group);
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