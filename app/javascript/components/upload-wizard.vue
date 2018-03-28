<template lang="jade">
div
  alerts(ref="alerts")
  b-modal(ref="modal", title="Post to Ethereum", :ok-disabled="loading || metamaskPending", 
          :cancel-disabled="metamaskPending", ok-title="Post on Smart Contract", @ok="postOnEthereum")
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
    p
      | Click on the button below send this data to Ethereum. You'll have to use MetaMask to update
      | your profile on the Numa smart contract, which allows other peers to see this data. It costs a small
      | amount of gas, which is paid with Ethereum.

</template>

<script>
import metamask from '../libs/metamask';
import ipfs from '../libs/ipfs_utils';

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
      modelTypes: [
        'message',
        'account',
        'follow',
        'favorite',
        'tip'
      ]
    }
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
      const url = this.isUser() ? `/u/${this.address}/attach_transaction` : `/${this.model}s/${this.modelData.id}/attach_transaction`;

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
        if (this.model == "message") {
          link += `<br/><a href="/messages/${this.modelData.id}">View Message</a>`
        }
        this.alertSuccess("All set - our servers have recorded your transaction.", { text: link });
      } catch (error) {
        console.log(error);
        this.alertError("Your transaction was saved on Ethereum, but there was an error updating our servers with that info.")
      }
    },
    async sendToMessagesContract() {
      const contract = await metamask.contract();
      try {
        let result = null;
        if (this.modelData.foreign_id) {
          result = await contract.updateMessage.sendTransaction(this.modelData.foreign_id, this.ipfsBytes32, this.transactionOptions);
        } else {
          result = await contract.createMessage.sendTransaction(this.ipfsBytes32, this.transactionOptions);
        }
        this.alertSuccess(`Awesome! Your ${this.model} has been sent to the Ethereum blockchain.`);
        await this.attachTransaction(result);
        this.$emit(`${this.model}Success`, this.modelData);
        this.hide();
      } catch (error) {
        console.log(error);
        this.alertError("Sorry, there was an error when posting your transaction on Ethereum.");
      }
    },
    async sendToUsersContract() {
      const contract = await metamask.contract();
      try {
        const result = await contract.updateUser.sendTransaction(this.ipfsBytes32, this.transactionOptions)
        console.log(result);
        this.attachTransaction(result);
        this.alertSuccess("Awesome! Your profile has been updated on Ethereum.");
        this.hide();
        this.$emit("userSuccess");
      } catch (error) {
        this.alertError("Sorry, there was an error when updating your profile on Ethereum.");
        console.log(error);
      }
      // contract.updateUser(this.ipfsBytes32, this.transactionOptions).then((result) => {
      //   console.log(result);
      //   this.attachTransaction(result);
      //   this.alertSuccess("Awesome! Your profile has been updated on Ethereum.");
      //   this.hide();
      //   this.$emit("userSuccess");
      // }).catch((error) => {
      //   this.alertError("Sorry, there was an error when updating your profile on Ethereum.");
      //   console.log(error);
      // })
    },
    async postOnEthereum(event) {
      event.preventDefault();
      this.metamaskPending = true;
      if (this.isUser()) {
        await this.sendToUsersContract();
      } else {
        await this.sendToMessagesContract();
      }
      this.metamaskPending = false;
    },
    isUser() {
      return this.model == 'account';
    }
  },
  computed: {
    ipfsLink() {
      return `ipfs://${this.ipfsHash}`
    },
    ipfsGatewayLink() {
      return `${ipfsGatewayAddress}/ipfs/${this.ipfsHash}`
    },
    ipfsBytes32() {
      return ipfs.bytes32(this.ipfsHash);
    },
    transactionOptions() {
      return { from: this.address };
    }
  },
  async mounted() {
    if (this.modelTypes.indexOf(this.model) === -1) {
      throw "You must specify a valid model type for upload-wizard component.";
    }
  }
}
</script>

<style lang="sass" scoped>

</style>
