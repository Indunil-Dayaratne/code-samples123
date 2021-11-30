// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import 'core-js/es6/promise'
import 'core-js/es6/string'
import 'core-js/es7/array'
import Vue from 'vue';
import VueBus from 'vue-bus';
import App from './App';
import router from './router';
import store from './store';
import AuthService from './msal';
import BootstrapVue from 'bootstrap-vue'
import Vuelidate from 'vuelidate';
import './shared/formatters';
import './shared/charts/colourGenerator';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { library, config } from '@fortawesome/fontawesome-svg-core'
import { far } from '@fortawesome/free-regular-svg-icons'
import { fas } from '@fortawesome/free-solid-svg-icons'
import { fab } from '@fortawesome/free-brands-svg-icons'
import VuePapaParse from 'vue-papa-parse'

library.add(far);
library.add(fas);
library.add(fab);

Vue.component('fa-icon', FontAwesomeIcon)

Vue.config.productionTip = false;
Vue.prototype.$AuthService = new AuthService();
Vue.use(BootstrapVue)
Vue.use(VueBus)
Vue.use(require('vue-moment'));
Vue.use(Vuelidate);
Vue.use(VuePapaParse);

/* eslint-disable no-new */
new Vue({
  el: '#app',
  router,
  store,
  components: { App },
  template: '<App/>',
});
