<template lang="jade">
a.nav-link(href="javascript:;", data-placement="bottom", title="Switch accounts using MetaMask.")
  {{name()}}
  img.img-fluid.img-thumbnail.nav__avatar.ml-1(:src='gixi()', :alt='coinbase', v-if="coinbase")
</template>

<script>
// import crypt from './crypto';
import _ from 'lodash';
import gixi from 'gixi';

// window.crypt = crypt;
export default {
  data: function () {
    return {
      coinbase: null,
      accounts: [],
      activeAccount: null
    }
  },
  methods: {
    inactiveAccounts() {
      return _.without(this.accounts, this.coinbase);
    },
    name() {
      if (this.activeAccount) {
        return this.activeAccount.username;
      } else if (this.coinbase) {
        return this.coinbase.slice(0,10);
      } else {
        return 'Install MetaMask.'
      }
    },
    gixi() {
      if (!this.coinbase)
        return '';
      return new gixi(300, this.coinbase).getImage();
    }
  },
  async mounted () {
    // const coinbase = crypt.account;
    // this.coinbase = coinbase;
    // crypt.emitter.addListener('account', (account) => { 
    //   this.coinbase = account;
    // });

    // const accounts = await crypt.web3.eth.getAccounts();
    // this.accounts = accounts;
    console.log(this);
    console.log('app nav');
    this.$nextTick(() => {
      $(this.$el).tooltip();
      // Code that will run only after the
      // entire view has been rendered
    })
  },
  beforeDestroy() {
    clearInterval(this.coinbaseRefresher)
  }
}
</script>

<style scoped lang="scss">
$avatarSize: 25px;
.nav__avatar {
  width: $avatarSize;
  height: $avatarSize;
}
</style>
