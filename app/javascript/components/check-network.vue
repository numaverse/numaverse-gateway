<template lang="jade">
div
  div(v-if="enabled && currentAccount")
    b-modal(ref="modal", title="Uh Oh! Wrong Network.")
      p
        | It looks like you're connected to the wrong Ethereum network.

      p
        | Your current Network ID is: {{ currentNetworkId }}. Expected: {{ chainID }}.

      p.mt-1
        | Make sure you're connected to the {{ chainName }} Network, otherwise you won't be able to
        | interact with the smart contracts on the Numa network.
</template>

<script>
import metamask from '../libs/metamask';
import _ from 'underscore';

export default {
  data() {
    return {
      enabled: metamask.enabled,
      wrongNetwork: false,
      chainName: metamask.chainName,
      currentAccount: window.currentAccount,
      networkResult: null,
      chainID: chainID,
      currentNetworkId: null,
    };
  },
  async mounted() {
    console.log(this);
    metamask.web3js.version.getNetwork((err, network) => {
      console.log(this);
      this.networkResult = network;
      this.currentNetworkId = parseInt(network);
      if (this.networkResult && this.currentNetworkId !== this.chainID) {
        this.wrongNetwork = true;
        this.$refs.modal.show();
      } else {
        this.wrongNetwork = false;
        this.$refs.modal.hide();
      }
    });
  },
  methods: {
    isUndefined() {
      return _.isUndefined(this.networkResult);
    }
  }
};
</script>

<style lang="sass" scoped>

</style>
