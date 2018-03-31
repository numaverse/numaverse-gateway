import '../../setup';
import Vue from 'vue';

import Edit from '../../components/accounts/edit.vue';

document.addEventListener('DOMContentLoaded', () => {
  const app = new Vue({
    render: h => h(Edit)
  }).$mount('#js-edit');
})