import '../setup';
import Vue from 'vue';

import Login from '../components/login.vue';

document.addEventListener('DOMContentLoaded', () => {
  // console.log('loaded from faucet');
  const app = new Vue({
    render: h => h(Login)
  }).$mount('#js-login');
})