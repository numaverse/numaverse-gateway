import "babel-polyfill"

import Vue from 'vue'
import AddAccount from '../add_account.vue'

document.addEventListener('DOMContentLoaded', () => {
  const app = new Vue({
    render: h => h(AddAccount)
  }).$mount('#js-add-account');
})