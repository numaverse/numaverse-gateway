import "babel-polyfill"

import Vue from 'vue';
import BootstrapVue from 'bootstrap-vue';
import VueObserveVisibility from 'vue-observe-visibility';

Vue.use(VueObserveVisibility);
Vue.use(BootstrapVue);

import FollowButton from './components/follow-button.vue';
Vue.component('follow-button', FollowButton);

import Message from './components/message.vue';
Vue.component('message', Message);

import UserCard from './components/user-card.vue';
Vue.component('user-card', UserCard);

import MessagesList from './components/messages-list.vue';
Vue.component('messages-list', MessagesList);

import SendNumaButton from './components/send-numa-button.vue';
Vue.component('send-numa-button', SendNumaButton);

import SendNumaModal from './components/send-numa-modal.vue';
Vue.component('send-numa-modal', SendNumaModal);

import MessageBody from './components/message-body.vue';
Vue.component('message-body', MessageBody);

import UploadWizard from './components/upload-wizard.vue';
Vue.component('upload-wizard', UploadWizard);

import Alerts from './components/alerts.vue';
Vue.component('alerts', Alerts);

import AlertsMixin from './components/mixins/alert-mixins';
Vue.mixin(AlertsMixin);

import Notifications from 'vue-notification';
Vue.use(Notifications);