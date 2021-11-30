import rdm from '../shared/rdm'
import clf from '../shared/clf'
import cedeExp from './cedeExp';
import cedeRes from '../shared/cedeRes'
import api from '../../../../../shared/api';
import Vue from 'vue';

const stringSorter = function(a, b) {
    if(a < b) return -1;
    if(a > b) return 1;
    return 0;
};

const yearKey = year => `yoa${year}`;
const yearKeyReverse = key => key.replace('yoa', '');
const analysisFilter = (programRef, analysisId) => {
    
    return x => x.PartitionKey === programRef + '-' + analysisId;
}

const state = () => ({
    files: {},
    runSubmissions: {},
    yoa: ''
})

const getters = {
    files: state => {
        if (yearKey(state.yoa) in state.files) return state.files[yearKey(state.yoa)];
        else return [];
    },
    yoa: state => state.yoa,
    rdms: state => state.files[yearKey(state.yoa)].filter(x => x.Type === 'RDM'),
    clfs: state => state.files[yearKey(state.yoa)].filter(x => x.Type === 'CLF'),
    cedeExp: state => state.files[yearKey(state.yoa)].filter(x => x.Type === 'EXP'),
    runSubmissions: state => state.runSubmissions[yearKey(state.yoa)],
    rdmSubmissions: state => (programRef, analysisId) =>  state.runSubmissions[yearKey(state.yoa)].filter(x => x.DataType === 'RDM').filter(analysisFilter(programRef, analysisId)),
    clfSubmissions: state => (programRef, analysisId) => state.runSubmissions[yearKey(state.yoa)].filter(x => x.DataType === 'CLF').filter(analysisFilter(programRef, analysisId)),
    cedeExpSubmissions: state => (programRef, analysisId) => state.runSubmissions[yearKey(state.yoa)].filter(x => x.DataType === 'EXP').filter(analysisFilter(programRef, analysisId)),
    anyCedesHavePerilsMapped: state => state.runSubmissions[yearKey(state.yoa)].filter(x => x.DataType === 'EXP').some(x => x.IsPerilsMapped),
    cedePerilsMapped: state => (programRef, analysisId) => {
        const submission = state.runSubmissions[yearKey(state.yoa)].find(x => x.PartitionKey === programRef + '-' + analysisId);
        return submission && submission.IsPerilsMapped;
    },
    areAvailable: (state) => (type) => {
        if(!type) return state.runSubmissions[yearKey(state.yoa)] && state.runSubmissions[yearKey(state.yoa)].length > 0;
        return state.runSubmissions[yearKey(state.yoa)].filter(x => x.DataType === type.toUpperCase()).length > 0;
    },
    yoaOptions: state => Object.keys(state.files).map(x => yearKeyReverse(x)).sort((a, b) => stringSorter(b, a)),
    getFiles: (state) => state.files[yearKey(state.yoa)],
    getYearAnalysisIds: state => yoa => state.files[yearKey(yoa)].reduce((acc, x) => {
        acc.push(...x.analyses.map(y => y.AnalysisId));
        return acc;
    }, []),
    folders: (state) => {
        if(!state.files[yearKey(state.yoa)]) return [];
        return [...new Set(state.files[yearKey(state.yoa)].map(x => x.Directory).sort((a, b) => stringSorter(a, b)))];
    },
    isFileLoaded: state => path => {
        return getters.files(state).map(x => x.Path).some(x => x.toLowerCase() == path.toLowerCase());
    }
}

const mutations = {
    setSubmissionData: (state, { yoa, list }) => {
        if(!(yearKey(yoa) in state.runSubmissions)) Vue.set(state.runSubmissions, yearKey(yoa), []);
        const toAdd = [];
        list.forEach((entity) => {

            let modelAnalysisIds = [];

            if (entity.WsstWithDemandSurgeModelAnalysisIds) {
                modelAnalysisIds.push({ RunCatalogType: "WsstWithDemandSurge", ModelAnalysisIds: JSON.parse(entity.WsstWithDemandSurgeModelAnalysisIds._) });
            }

            if (entity.WsstWithoutDemandSurgeModelAnalysisIds) {
                modelAnalysisIds.push({ RunCatalogType: "WsstWithoutDemandSurge", ModelAnalysisIds: JSON.parse(entity.WsstWithoutDemandSurgeModelAnalysisIds._) });
            }

            if (entity.StdWithDemandSurgeModelAnalysisIds) {
                modelAnalysisIds.push({ RunCatalogType: "StdWithDemandSurge", ModelAnalysisIds: JSON.parse(entity.StdWithDemandSurgeModelAnalysisIds._) });
            }

            if (entity.StdWithoutDemandSurgeModelAnalysisIds) {
                modelAnalysisIds.push({ RunCatalogType: "StdWithoutDemandSurge", ModelAnalysisIds: JSON.parse(entity.StdWithoutDemandSurgeModelAnalysisIds._) });
            }

            toAdd.push({
                PartitionKey: entity.PartitionKey._,
                RowKey: entity.RowKey._,
                DataType: entity.DataType ? entity.DataType._ : "",
                DatabaseName: entity.DatabaseName ? entity.DatabaseName._ : "",
                FilePath: entity.FilePath ? entity.FilePath._ : "",
                SourceType: entity.SourceType ? entity.SourceType._ : "",
                FileName: entity.FilePath ? (entity.FilePath._.substring(entity.FilePath._.lastIndexOf("\\") + 1)) : "",
                LossUploaded: entity.LossUploaded ? JSON.parse(entity.LossUploaded._) : [],
                RunCatalogTypes: entity.RunCatalogTypes ? JSON.parse(entity.RunCatalogTypes._) : [],
                RunTypes: entity.RunTypes ? JSON.parse(entity.RunTypes._) : [],
                IsPerilsMapped: entity.IsPerilsMapped ? entity.IsPerilsMapped._ : false,
                LossSetMetadata: entity.LosssetMetaData ? JSON.parse(entity.LossSetMetaData._) : [],
                ModelAnalysisIds: modelAnalysisIds
            });
        });
        Vue.set(state.runSubmissions, yearKey(yoa), [...state.runSubmissions[yearKey(yoa)], ...toAdd]);
    },
    resetSubmissionData(state) {
        state.runSubmissions = {};
    },
    saveFiles: (state, files) => {
        if(Array.isArray(state.files)) state.files = {};
        [...new Set(files.map(x => x.YOA))].forEach(yoa => {
            Vue.set(state.files, yearKey(yoa), []);
        });
        files.forEach(file => {
            const key = yearKey(file.YOA);
            Vue.set(state.files, key, [...state.files[key], file]);
        });
    },
    setYoa(state, yoa) {
        const options = getters.yoaOptions(state);
        if(options.includes(yoa)) state.yoa = String(yoa);
        else if(options.length > 0) state.yoa = options[0];
        else state.yoa = '';
    }
}

const actions = {
    async loadExposureData({ dispatch }, { programRef, analysisId }) {
        await dispatch('cedeExp/load', { programRef, analysisId });
        await dispatch('cedeRes/load', { programRef, analysisId });
    },
    async loadFiles({ commit, rootGetters }, programRef) {
        try {
            const files = await api.getLoadedFiles(programRef);
            const programAnalyses = rootGetters['account/index/getAllAnalysesForProgram'](programRef);
            const clientFiles = files.filter(x => !x.RelatedTo);
            const createdFiles = files.filter(x => !!x.RelatedTo);
            commit('resetSubmissionData');
            for (let i = 0; i < clientFiles.length; i++) {
                const file = clientFiles[i];
                const analyses = api.getRelatedAnalyses(programAnalyses, file.Path); //programAnalyses.filter(x => x.DataFileLocation === file.Path);
                file.analyses = analyses;
                const submissions = await api.getSubmissions(programRef, analyses.map(x => x.AnalysisId));
                file.submissions = submissions;
                commit('setSubmissionData', {
                    yoa: file.YOA,
                    list: submissions
                });
                file.Type = submissions.length ? submissions[0].DataType._ : ''
                file.related = api.getRelatedFiles(createdFiles, file.RowKey);
            }

            commit('saveFiles', clientFiles);
        } catch (err) {
            console.error(err);
        }
    },
    async loadSubmissionData({ commit, state, getters }, programRef) {
        const yoas = getters.yoaOptions;
        for (let i = 0; i < yoas.length; i++) {
            const yoa = yoas[i];
            let analysisIds = getters.getYearAnalysisIds(yoa);
            const results = await api.getSubmissions(programRef, analysisIds);
            commit('setSubmissionData', {
                yoa,
                list: results
            });
        }
    },
    async load({ dispatch, commit }, { programRef }) {
        await dispatch('loadFiles', programRef);
        commit('setYoa');
    }
}

export default {
    namespaced: true,
    state,
    getters,
    mutations,
    actions,
    modules: {
        rdm,
        clf,
        cedeExp,
        cedeRes
    }
}