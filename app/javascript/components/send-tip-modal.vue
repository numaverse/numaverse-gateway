<template lang="jade">
b-modal(ref="modal", title="Send NUMA", @ok="submitSend", ok-title="Send")
  alerts(ref='alerts')
  dl.row
    dt.col-6 To:
    dd.col-6.text-right @{{ account.username }}

    dt.col-6 Balance (ETH):
    dd.col-6.text-right 
      span(v-if="loadingBalance") 
        i.fa.fa-spinner.fa-pulse.mr-2
        | Loading..
      span(v-else-if="balance")
        | Ξ{{ balance.toFixed() }}
    
    dt.col-6 Balance (USD):
    dd.col-6.text-right(v-if="balance")
      | ${{ balanceUSD.toFixed(2) }}

  .form-group
    label Amount ($USD)
    input.form-control.text-right(type="text", v-model="sendAmount", placeholder="Enter amount in $USD")
  
  div(v-if="isNumber()")
    dl.row
      dt.col-6 Tip amount ETH
      dd.col-6.text-right Ξ{{ amountETH.toFixed() }}

  div(v-else)
    p.text-danger
      | Sorry, that doesn't seem like a valid number.

  div(v-if="isNumber() && balance")
    dl.row(v-if="balance")
      dt.col-6 Remaining Balance (ETH):
      dd.col-6.text-right Ξ{{ remainingBalance.toFixed() }}

      dt.col-6 Remaining Balance (USD):
      dd.col-6.text-right ${{ remainingBalanceUSD.toFixed(2) }}

    p.text-danger(v-if="amountTooHigh()")
      | You cannot send more than you have available in your wallet.

    p.text-danger(v-if="scaleTooLarge()")
      | You cannot send an amount with more than 18 digits in the decimals.
  
  div
    p Send a message with your tip (optional):
    textarea.form-control(v-model="body", placeholder="Awesome post!")
        
</template>

<script>
// import utils from 'metamask-utils';
// import metamask from 'metamask';
import metamask from '../libs/metamask';
import {BigNumber} from 'bignumber.js';
const { web3js } = metamask;

export default {
  props: [
    'account',
    'message'
  ],
  data() {
    return {
      currentAccount: window.currentAccount,
      sendAmount: "0",
      balanceBN: null,
      balance: null,
      loadingBalance: false,
      body: "",
      pendingTransaction: false,
    };
  },
  methods: {
    show() {
      const modal = this.$refs.modal;
      this.loadingBalance = true;
      modal.show();
      metamask.web3js.eth.getBalance(this.currentAccount.address, (error, balance) => {
        if (error) {
          this.alertError("Sorry, we couldn't get your current balance.");
        } else {
          this.balanceBN = balance;
          this.balance = metamask.web3js.fromWei(balance);
        }
        this.loadingBalance = false;
      });
    },
    visible() {
      return this.currentAccount && this.currentAccount.id != this.account.id;
    },
    async submitSend(evt) {
      evt.preventDefault();
      if (!this.isNumber() || this.scaleTooLarge() || this.amountTooHigh()) {
        return true;
      }
      const amountETH = web3js.toWei(this.amountETH.toFixed(18));
      web3js.eth.sendTransaction({
        from: currentAccount.address, 
        to: this.message.account.address, 
        value: amountETH,
      }, async (error, txHash) => {
        if (error) {
          console.log(error);
          this.alertError("Sorry, there was an error when sending your transaction");
        } else {
          const data = {
            message_id: this.message.id,
            tx_hash: txHash,
            body: this.body,
          };

          try {
            const response = await $.ajax({
              url: `/messages/${this.message.id}/tip`,
              type: 'post',
              data: data,
              dataType: 'json',
            });

            const { tx_url } = response.tip;
            let link = `<a href="${tx_url}">View Transaction</a>`;
            this.alertSuccess("Your tip has been sent.", { text: link });
            this.$emit('response', response);
            this.$emit('sent', response);
          } catch (error) {
            console.log(error);
            this.alertError("Your tip was sent, but we were unable to save it on the server.");
          }
        }
      });
    },
    scaleTooLarge() {
      return false; //return (this.amountETH.toString().split('.')[1] || '').length > 18;
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
      return new BigNumber(this.balance).minus(this.amountETH);
    },
    remainingBalanceUSD() {
      return this.remainingBalance.times(ETH_USD);
    },
    amount() {
      return new BigNumber(this.sendAmount == "" ? 0 : this.sendAmount);
    },
    amountETH() {
      return this.amount.div(ETH_USD);
    },
    balanceUSD() {
      return this.balance.times(ETH_USD);
    }
  }
};
</script>

<style lang="sass" scoped>

</style>

