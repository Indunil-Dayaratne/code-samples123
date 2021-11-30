import shared from '../shared/cedeExp';
import api from '../../../../../shared/api';

shared.actions.loadRpxs = async function({commit}, { programRef, analysisId }) {
    const rpxs = await api.getRpxs(programRef);
    commit('setRpx', { list: rpxs });
}

export default {
    ...shared
}