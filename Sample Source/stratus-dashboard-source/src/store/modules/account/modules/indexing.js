import stratusApi from '../../../../shared/api';

const programRefCheck = (programRef, analysisProgRef) => {
    const re = new RegExp(`^${programRef}\\w*`, 'gi');
    return analysisProgRef.match(re) !== null;
}

const state = () => ({
    programs: [],
    analyses: []
})

const getters = {
    getProgram: state => programRef => {
        return state.programs.find(prog => prog.ProgramRef === programRef);
    },
    getPrograms: state => {
        return state.programs.sort((a, b) => b.CreatedOn - a.CreatedOn);
    },
    getAnalyses: state => {
        return state.analyses.filter(x => stratusApi.locationIsFolder(x.DataFileLocation)).sort((a, b) => b.CreatedOn - a.CreatedOn);
    },
    getAnalysis: state => (programRef, analysisId) => {
        return state.analyses.find(analysis => analysis.ProgramRef === programRef && analysis.AnalysisId === analysisId);
    },
    getAnalysesForProgram: state => programRef => {
        return state.analyses.filter(x => stratusApi.locationIsFolder(x.DataFileLocation)).filter(x => programRefCheck(programRef, x.ProgramRef)).sort((a, b) => b.CreatedOn - a.CreatedOn);
    },
    getAllAnalysesForProgram: state => programRef => {
        return state.analyses.filter(x => programRefCheck(programRef, x.ProgramRef)).sort((a, b) => b.CreatedOn - a.CreatedOn);
    },
    // isStandaloneAnalysis: state => (programRef, analysisId) => {
    //     return getters.getAnalyses(state).filter(x => x.ProgramRef === programRef && x.AnalysisId === analysisId).length == 1
    // }
}

const mutations = {
    updatePrograms: (state, entries) => {
        state.programs = [];
        entries.forEach((entity) => {
            state.programs.push({
                ProgramRef: entity.RowKey._,
                AccountName: entity.AccountName._,
                Summary: entity.Summary._,
                CreatedOn: entity.CreatedOn._,
                CreatedBy: entity.CreatedBy._,
                DefaultCurrency: entity.DefaultCurrency ? entity.DefaultCurrency._ : 'USD'
            })
        }); 
    },
    updateAnalyses: (state, entries) => {
        state.analyses = [];
        entries.forEach((entity) => {
            state.analyses.push({
                ProgramRef: entity.PartitionKey._,
                AnalysisId: entity.RowKey._,
                AccountName: entity.AccountName._,
                Summary: entity.Summary._,
                CreatedOn: entity.CreatedOn._,
                CreatedBy: entity.CreatedBy._,
                GroupId: entity.GroupId ? entity.GroupId._ : '',
                DefaultCurrency: entity.DefaultCurrency ? entity.DefaultCurrency._ : 'USD',
                DataFileLocation: entity.DataFileLocation ? entity.DataFileLocation._ : '',
                CurrencyExchangeRates: entity.CurrencyExchangeRates ? JSON.parse(entity.CurrencyExchangeRates._) : []
            });
        }); 
    }
}

const actions = {
    async initialise(context) {
        const tasks = [];
        tasks.push(context.dispatch('getPrograms'));
        //tasks.push(context.dispatch('getAnalyses'));
        await Promise.all(tasks);
    },
    async getPrograms({ commit }) {
        try {
            const results = await stratusApi.getPrograms();
            commit('updatePrograms', results);
        } catch (err) {
            console.error(err);
        }
    },
    async getAnalyses({commit}) {
        try {
            const results = await stratusApi.getAnalyses();
            commit('updateAnalyses', results);
        } catch (err) {
            console.error(err);
        }
    },
    async getAnalysesForProgram({commit}, programRef) {
        try {
            const results = await stratusApi.getAnalysesForProgram(programRef);
            commit('updateAnalyses', results);
        } catch (err) {
            console.error(err);
        }
    },
    async loadForProgram(context, programRef) {
        try {
            const tasks = [];
            tasks.push(context.dispatch('getPrograms'));
            tasks.push(context.dispatch('getAnalysesForProgram', programRef));
            await Promise.all(tasks);
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