<template lang="jade">
.row
  check-network
  .col-md-3.d-none.d-md-block
    user-card(:account="account")
  .col-md-6.col-xs-12
    messages-list(:messages="messages")
</template>

<script>
export default {
  props: [
    'account',
    'messages'
  ],
  data() {
    return {
      currentAccount: window.currentAccount
    }
  },
  methods: {
    addMessage(message) {
      // TODO: do something
    }
  },
  mounted() {
  }
}
</script>

<style lang="sass" scoped>

</style>
