import '../setup';
import Vue from 'vue';

import Faucet from '../components/faucet.vue';

document.addEventListener('DOMContentLoaded', () => {
  // console.log('loaded from faucet');
  const app = new Vue({
    render: h => h(Faucet)
  }).$mount('#js-faucet-component');
})