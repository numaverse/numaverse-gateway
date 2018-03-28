<template lang="jade">
div
  div(v-if="enabled && currentAccount")
    b-modal(ref="modal", title="Uh Oh! Wrong Network.")
      p
        | It looks like you're connected to the wrong Ethereum network.

      p.mt-1
        | Make sure you're connected to the {{ chainName }} Network, otherwise you won't be able to
        | interact with the smart contracts on the Numa network.
</template>

<script>
import metamask from '../libs/metamask';
export default {
  data() {
    return {
      enabled: metamask.enabled,
      wrongNetwork: false,
      chainName: metamask.chainName,
      currentAccount: window.currentAccount,
    }
  },
  async mounted() {
    console.log(this);
    metamask.web3js.version.getNetwork((err, network) => {
      console.log(this);
      const currentNetworkId = parseInt(network);
      if (currentNetworkId !== chainID) {
        this.wrongNetwork = true;
        this.$refs.modal.show();
      }
    })
  }
}
</script>

<style lang="sass" scoped>

</style>
