import Vue from 'vue';

const state = {
    user: {},
    idToken: localStorage.getItem('msal.idtoken') || ''
}

const getters = {    
    isLoggedIn: state => !!state.idToken && state.user.userName !== 'Anonymous',
}

const mutations = {
    setUser: (state, { user }) => {
      state.user = user;
      state.idToken = localStorage.getItem('msal.idtoken');
    }
}

const actions = {
    logIn: ({ commit }) => {
      Vue.prototype.$AuthService.loginRedirect();
    },
    logOut: ({ commit }) => {
      Vue.prototype.$AuthService.logout();
      commit('setUser', { user: { userName: 'Anonymous' } });
    },
    setUser: ({ commit }) => {
      if (Vue.prototype.$AuthService == undefined)
        commit('setUser', { user: { userName: 'Anonymous' } });
      else
        commit('setUser', { user: Vue.prototype.$AuthService.getUser() });
    }
}

export default {
    namespaced: true,
    state,
    getters,
    actions,
    mutations
  }