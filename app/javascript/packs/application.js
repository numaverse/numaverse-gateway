/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import '../setup';
import Vue from 'vue';

import App from '../app.vue';

document.addEventListener('DOMContentLoaded', () => {
  const json = document.getElementById('js-messages').getAttribute('data');
  const data = JSON.parse(json);
  console.log(data);
  const app = new Vue({
    render: h => h(App, { props: { _messages: data.messages, currentUser: data.current_user }})
  }).$mount('#js-messages');
})