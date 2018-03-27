<template lang="jade">
.card
  .card-body
    .row
      .col-4
        img.img-fluid.rounded-circle(:src='account.avatar.medium')
      .col-8
        a(:href='"/u/"+account.username') @{{ account.username }}
        .mt-1.text-muted(v-if="account.location")
          small 
            i.fa.fa-globe.mr-1
            {{ account.location }}
      .col-12.mt-3
        follow-button(:account="account")
        small {{ account.bio }}

        p.mt-2
          small
            strong Address:
            .mt-0
            span.tiny {{ shortAddress }}

        p.mt-2(v-if="isCurrentAccount")
          small
            strong Fediverse Handle:
            .mt-0
            span.tiny {{ fediverseHandle }}

</template>

<script>
export default {
  props: [
    'account'
  ],
  data() {
    return {
      updatedBalance: null
    }
  },
  computed: {
    balance() {
      return this.updatedBalance || this.account.balance;
    },
    shortAddress() {
      const len = this.account.address.length;
      const addr = this.account.address;
      return addr.slice(0,15) + '..' + addr.slice(len-15);
    },
    isCurrentAccount() {
      return currentAccount && this.account.id == currentAccount.id;
    },
    fediverseHandle() {
      return `@${currentAccount.username}@${document.location.host}`;
    }
  }
}
</script>

<style lang="sass" scoped>

</style>
