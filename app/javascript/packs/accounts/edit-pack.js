import '../../setup';
import Vue from 'vue';

import Edit from '../../components/accounts/edit.vue';

document.addEventListener('DOMContentLoaded', () => {
  const json = document.getElementById('js-edit').getAttribute('data');
  const account = JSON.parse(json);
  // console.log('loaded from faucet');
  const app = new Vue({
    render: h => h(Edit, { props: { account: account }})
  }).$mount('#js-edit');
})