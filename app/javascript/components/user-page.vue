<template lang="jade">
.row
  check-network
  .col-3
    user-card(:account="account")
  .col-6
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
