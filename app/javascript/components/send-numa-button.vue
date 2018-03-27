<template lang="jade">
div(v-if="visible()")
  notifications(group="send-numa", :duration="-1")
  small
    a(href="javascript:;", @click="openSendModal()")
      | Send NUMA to @{{account.username}}

  send-numa-modal(ref="modal",
                  :account="account"
                  @sent="(response) => { $emit('response', response) }")
</template>

<script>
// import utils from 'web3-utils';

export default {
  props: [
    'account',
  ],
  data() {
    return {
      currentUser: window.currentUser,
    }
  },
  methods: {
    openSendModal() {
      this.$refs.modal.modal.show();
    },
    visible() {
      return this.currentUser && (this.currentUser.account.id != this.account.id);
    }
  },
  async mounted() {
    if (!this.visible()) {
      return true;
    }
  }
}
</script>

<style lang="sass" scoped>

</style>

