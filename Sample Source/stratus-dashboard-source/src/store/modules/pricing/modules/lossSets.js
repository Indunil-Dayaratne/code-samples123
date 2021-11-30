import api from '../../../../shared/api';

const tableName = config.appPrefix + 'LossSet';

const state = {
    data: [],
    activeLossSet: 0   
}

const getters = {
    getLossSetById: (state) => (id) => {
        var lossSet = state.data.find(x => x.id === id);
        if (!lossSet) { console.error(`No loss set found with ID: ${id}`); return; }
        return lossSet;
    },
}

const mutations = {
    loadLossSets(state, { list }) {
        state.data = list;
    },
    clear(state) {
        state.data = [];
        state.activeLossSet = 0;
    },
    activateLossSet(state, id) {       
        var view = state.data.find(x => x.id === id);
        if (!view) { console.error(`No loss set found with ID: ${id}`); return; }
        state.activeLossSet = id;
    },    
    deactivateLossSet(state) {
        state.activeLossSet = 0;
    }
};

var actions = {
    async getLossSets(context) {
        try {
            let groupIds = context.rootGetters['account/get']('pricingGroups');
            if (!groupIds.length) return;
            const results = await api.getLossSets(groupIds);
            context.commit('loadLossSets', { list: results });
        } catch (err) {
            console.error(err);
        }
    },
    clear(context) {
        context.commit('clear');
    }
};

export default{
    namespaced: true,
    state,
    getters,
    mutations,
    actions    
}