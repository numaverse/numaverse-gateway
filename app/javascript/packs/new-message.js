import '../setup';
import "babel-polyfill"

import Vue from 'vue'
import NewMessage from '../new-message.vue'
import EditMicroMessage from '../components/edit-micro-message.vue'

document.addEventListener('DOMContentLoaded', () => {
  const articleEl = document.querySelector('#js-new-message');
  if (articleEl) {
    const data = articleEl.getAttribute('data');
    let message = null;
    if (data) {
      message = JSON.parse(data);
    }
    const app = new Vue({
      render: h => h(NewMessage, { props: { message: message } })
    }).$mount('#js-new-message');
  }

  const microEl = document.querySelector('#js-edit-message');
  if (microEl) {
    const data = microEl.getAttribute('data');
    let message = null;
    if (data) {
      message = JSON.parse(data);
    }
    const app = new Vue({
      render: h => h(EditMicroMessage, { props: { message: message } })
    }).$mount('#js-edit-message');
  }
  
})