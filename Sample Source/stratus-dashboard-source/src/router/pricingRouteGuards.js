import store from '../store';

const beforeEach = async (to, router) => {
    store.commit('pricing/updateIsLoading', true);
    await store.dispatch('account/runAfterLoad', async () => {
        let redirect = Object.assign({}, to);
        if(!!to.query.networkId) {
            if(!store.getters['pricing/isValidNetworkId'](to.query.networkId)) {
                redirect.query.networkId = undefined;
                store.commit('pricing/updateIsLoading', false);
                router.push(redirect);
                return;
            }
        } else {
            const props = store.getters['pricing/getSelectedNetworkProperties'];
            if(props) {
                redirect.query.networkId = props.networkId;
                store.commit('pricing/updateIsLoading', false);
                router.push(redirect);
                return;
            }
        }
        //console.log("Route:", to);
        await store.dispatch('pricing/loadFromRoute', to);
        store.commit('pricing/updateIsLoading', false);
    });
};

const networkLoadedBeforeEachGuard = (store, router) => async (to, from, next) => {
    await store.dispatch('account/runAfterLoad', (state, getters) => {
        if(!getters['pricing/networkLoaded']) router.push({ name: 'program_pricing_networks', params: to.params, query: to.query });
        else store.commit('pricing/results/updateTabVisible', true);
    });
    next();
}

export default {
    beforeEach,
    networkLoadedBeforeEachGuard
}