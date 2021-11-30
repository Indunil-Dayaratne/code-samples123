import Vue from 'vue'
import Vuex from 'vuex'
import auth from './modules/auth'
import tasks from './modules/tasks'
import cedeExposure from './modules/cedeExposure'
import cedeResults from './modules/cedeResults'
import submissionData from './modules/submissionData'
import pricing from './modules/pricing'
import elt from './modules/elt'
import account from './modules/account'

Vue.use(Vuex)

const debug = process.env.NODE_ENV !== 'production'

const actions = {
  // Backwards compatibility for loading analysis
  async initialise({ dispatch }, { programRef, analysisId }) {
    try {
      await dispatch('account/load', { programRef, analysisId });
    } catch (err) {
      console.error(err);
    } 
  }
}

export default new Vuex.Store({
  actions,
  modules: {
    account,
    auth,
    tasks,
    cedeExposure,
    cedeResults,
    submissionData,
    pricing,
    elt
  }
});