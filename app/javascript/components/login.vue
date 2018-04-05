<template lang="jade">
.row
  alerts(ref="alerts")
  notifications(group="login-error", :duration="10000")
  notifications(group="login-success", :duration="10000")
  .col-2.d-none.d-md-block
  .col-md-8.col-xs-12
    .card
      h4.card-header Login with Ethereum
      .card-body
        .row
          .col-2.d-none.d-md-block
          .col-md-8.col-xs-12
            div(v-if="enabled")
              div(v-if="address")
                p.text-center
                  | To login, first select an account in your dapp browser. 
                .text-center.mt-1
                p(v-if="pendingSignature")
                  | We sent a request for you to sign a message - please confirm to continue.
                p(v-else-if="loadingLogIn")
                  i.fa.fa-spinner.fa-pulse.mr-2
                  | Logging you in...
                p(v-else)
                  | When you click 'sign in', we'll ask you to sign
                  | a message, which allows us to verify that you own this address.
                .form-group
                  label(for="address") Address
                  input.disabled.form-control(type="text", v-model="address", disabled="disabled")
                b-button(variant="success", v-on:click="sign", :block="true") Sign In
              div(v-else)
                p.text-center.mt-1
                  | It looks like MetaMask is locked. Enter your password in MetaMask to log in.

            div(v-else)
              p.text-center
                | To interact with the Ethereum blockchain securely, you need to use a web3 compatible browser.

              div.text-center.mt-1(v-if="isMobile")
                p Here are a few great mobile apps you can use:

                .card.mt-2      
                  a.card-body.text-left(href="http://www.toshi.org/", target="_blank")
                    .row
                      .col-4
                        img.img-fluid.rounded(src="/toshi.png", title="Toshi")
                      .col-8
                        h4.mt-3 Toshi
                
                .card.mt-2                      
                  a.card-body.text-left(href="https://trustwalletapp.com/", target="_blank")
                    .row
                      .col-4
                        img.img-fluid.rounded(src="/trust.jpg", title="Trust")
                      .col-8
                        h4.mt-3 Trust

              div.text-center.mt-1(v-else)
                p 
                  | On desktop, we recommend using the MetaMask browser extension.
                  | Once you've installed Metamask, just refresh this page to sign in.
                
                .mt-3

                a(href="https://metamask.io", target="_blank")
                  img.img-fluid(src="/metamask.png", title="MetaMask")
</template>

<script>
import metamask from '../libs/metamask';

export default {
  data() {
    return {
      address: null,
      account: null,
      enabled: metamask.enabled,
      locked: false,
      pendingSignature: false,
      loadingLogIn: false,
    };
  },
  mounted() {
    if (this.enabled) {
      metamask.getAccount(this.accountCallback);
    }
  },
  methods: {
    accountCallback(address) {
      this.address = address;
    },
    async uploadSignature(signature) {
      this.loadingLogIn = true;
      try {
        const account = await $.ajax({
          url: '/auth/sign',
          dataType: 'json',
          data: {
            signature: signature,
            address: this.address
          }
        });
        console.log('logged in!', account);
        this.account = account;
        this.alertSuccess("You've been logged in!");

        if (account.aasm_state == 'draft') {
          document.location = `/u/${account.hash_address}/edit`;
        } else {
          document.location = '/';
        }
      } catch (error) {
        console.log(error);
        this.alertError('Sorry, we were unable to verify your signature.');
      }
      this.loadingLogIn = false;
    },
    sign() {
      console.log('signing');
      this.pendingSignature = true;
      metamask.sign('numa', (error, signature) => {
        this.pendingSignature = false;
        if (error) {
          console.log(error);
          this.alertError("We were unable to get your signature.");
        } else {
          this.uploadSignature(signature);
        }
      });
    }
  },
  computed: {
    isMobile() {
      return /iPhone|iPad|iPod|Android/i.test(navigator.userAgent);
    }
  }
};
</script>

<style lang="sass" scoped>

</style>

