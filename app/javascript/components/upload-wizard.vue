<template lang="jade">
div
  alerts(ref="alerts")
  b-modal(ref="modal", title="Post to Ethereum", :ok-disabled="loading || metamaskPending", 
          ok-title="Post on Smart Contract", @ok="postOnEthereum", @cancel="cancel")
    h5 Step 1: Upload to IPFS
    div(v-if="loading")
      p
        i.fa.fa-spin.fa-refresh
        |  In progress
    div(v-else)
      p 
        i.fa.fa-check
        |  Complete
      p
        | IPFS Link:
        a.mt-1.d-block.text-truncate(:href="ipfsLink", target="_blank") {{ ipfsLink }}
        a.mt-1.d-block.text-truncate(:href="ipfsGatewayLink", target="_blank") {{ ipfsGatewayLink }}

    h5 Step 2: Send to Ethereum
    p(v-if="metamaskPending")
      | You need to confirm this transaction in your browser to continue.
    p(v-else)
      | Click on the button below send this data to Ethereum. It costs a small
      | amount of gas, which is paid with Ethereum.

</template>

<script>
import metamask from '../libs/metamask';
import ipfs from '../libs/ipfs_utils';
import batchEvents from '../libs/batch-events';

export default {
  props: [
    'model',
  ],
  data() {
    return {
      loading: false,
      ipfsHash: null,
      address: currentAccount.hash_address,
      metamaskPending: false,
      modelData: null,
    };
  },
  methods: {
    ipfsUploadSuccess(data) {
      console.log('uploaded to ipfs', data);
      this.modelData = data;
      this.ipfsHash = data.ipfs_hash;
      this.loading = false;
    },
    show() {
      this.loading = true;
      this.$refs.modal.show();
    },
    hide() {
      this.loading = false;
      this.modelData = null;
      this.ipfsHash = null;
      this.$refs.modal.hide();
    },
    async attachTransaction(result) {
      const url = `/batches/${this.modelData.id}/attach_transaction`;

      try {
        const response = await $.ajax({
          url: url,
          method: 'post',
          dataType: 'json',
          data: {
            tx_hash: result
          }
        });
        console.log(response);
        if (this.modelData) {
          this.modelData.tx_id = response.transaction.id;
        }
        let link = `<a href="${response.transaction.url}">View Transaction</a>`;
        this.alertSuccess("All set - our servers have recorded your transaction.", { text: link });
        batchEvents.triggerNewBatch();
      } catch (error) {
        console.log(error);
        this.alertError("Your transaction was saved on Ethereum, but there was an error updating our servers with that info.");
      }
    },
    async sendTransaction() {
      const contract = await metamask.contract();
      try {
        const result = await contract.newBatch.sendTransaction(this.ipfsBytes32, this.transactionOptions);
        console.log(result);
        await this.attachTransaction(result);
        this.alertSuccess("Awesome! Your batch has been sent to Ethereum.");
        this.hide();
        this.$emit('batchSuccess');
      } catch (error) {
        console.log(error);
        this.cancel();
      }
    },
    async postOnEthereum(event) {
      event.preventDefault();
      this.metamaskPending = true;
      await this.sendTransaction();
      this.metamaskPending = false;
    },
    async cancel() {
      this.loading = true;
      this.metamaskPending = false;
      try {
        await $.ajax({
          url: `/batches/${this.modelData.id}/cancel`,
          method: 'post'
        });

        batchEvents.triggerNewBatch();
        this.loading = false;
        this.alertSuccess('Your batch has been canceled.');
      } catch (error) {
        console.log(error);
        this.alertError("Sorry, there was an error when canceling your transaction");
      }
      this.hide();
    }
  },
  computed: {
    ipfsLink() {
      return `ipfs://${this.ipfsHash}`;
    },
    ipfsGatewayLink() {
      return `${ipfsGatewayAddress}/ipfs/${this.ipfsHash}`;
    },
    ipfsBytes32() {
      return ipfs.bytes32(this.ipfsHash);
    },
    transactionOptions() {
      return { from: this.address };
    }
  },
  async mounted() { }
};
</script>

<style lang="sass" scoped>

</style>
