import '../setup';
import Vue from 'vue';

import MessagePage from '../components/message-page.vue';

document.addEventListener('DOMContentLoaded', () => {
  const json = document.getElementById('js-message').getAttribute('data');
  const data = JSON.parse(json);
  console.log(data);
  const app = new Vue({
    render: h => h(MessagePage, { props: { message: data } })
  }).$mount('#js-message');
})