import '../setup';
import Vue from 'vue';

import UserPage from '../components/user-page.vue';

document.addEventListener('DOMContentLoaded', () => {
  const json = document.getElementById('js-user').getAttribute('data');
  const data = JSON.parse(json);
  console.log(data);
  const app = new Vue({
    render: h => h(UserPage, { props: { messages: data.messages, account: data.account } })
  }).$mount('#js-user');
})