<template lang="jade">
b-modal(ref="modal", title="Send NUMA", @ok="submitSend", ok-title="Send")
  dl.row.small
    dt.col-6 To:
    dd.col-6.text-right @{{ account.username }}

    dt.col-6 Balance:
    dd.col-6.text-right {{currentAccount.balance}}

  .form-group
    label.small Amount
    input.form-control.text-right(type="text", v-model="sendAmount")
  
  div(v-if="isNumber()")
    dl.row.small
      dt.col-6 Remaining Balance:
      dd.col-6.text-right {{ remainingBalance.toFixed() }}

    p.text-danger(v-if="amountTooHigh()")
      | You cannot send more than you have available in your wallet.

    p.text-danger(v-if="scaleTooLarge()")
      | You cannot send an amount with more than 18 digits in the decimals.

  div(v-else)
    p.text-danger
      | Sorry, that doesn't seem like a valid number.
        
</template>

<script>
// import utils from 'metamask-utils';
// import metamask from 'metamask';
import metamask from '../libs/metamask';
import {BigNumber} from 'bignumber.js';
const web3js = metamask.web3js;

export default {
  props: [
    'account',
    'message'
  ],
  data() {
    return {
      currentAccount: window.currentAccount,
      sendAmount: "0",
    }
  },
  methods: {
    openSendModal() {
      const modal = this.$refs['send-numa-modal-'+this.account.id];
      modal.show();
    },
    visible() {
      return this.currentAccount && this.currentAccount.id != this.account.id;
    },
    async submitSend(evt) {
      if (!this.isNumber() || this.scaleTooLarge() || this.amountTooHigh()) {
        evt.preventDefault();
        return true;
      }
      const nuweiAmount = web3js.toWei(this.sendAmount);
      const data = {
        amount: nuweiAmount
      };
      if (this.message) {
        data.message_id = this.message.id;
      }

      const request = $.ajax({
        url: `/u/${this.account.address}/transfer`,
        type: 'post',
        data: data,
        dataType: 'json',
      });

      request.done((response) => {
        this.account.balance = response.to_user.balance;
        const tx = response.transaction;
        this.$notify({
          group: 'send-numa',
          title: "Transaction Sent",
          type: 'success',
          text: `Sent ${tx.humanized_value} to @${this.account.username}.<br/><a href="${tx.url}">${tx.hash}</a>`
        });
        this.$emit('response', response);
        this.$emit('sent', response);
      });
    },
    scaleTooLarge() {
      return (this.amount.toString().split('.')[1] || '').length > 18;
    },
    amountTooHigh() {
      return this.remainingBalance < new BigNumber(0);
    },
    isNumber() {
      try {
        this.amount;
        return true;
      } catch (error) {
        return false;
      }
    }
  },
  async mounted() {
    this.modal = this.$refs.modal;
  },
  computed: {
    balance_numa() {
      return web3js.fromWei(web3js.toBigNumber(this.currentAccount.balance_nuwei));
    },
    remainingBalance() {
      return new BigNumber(this.balance_numa).minus(this.amount);
    },
    amount() {
      return new BigNumber(this.sendAmount == "" ? 0 : this.sendAmount);
    }
  }
}
</script>

<style lang="sass" scoped>

</style>

