<template lang="jade">
.row
  notifications(group="login-error", :duration="10000")
  notifications(group="login-success", :duration="10000")
  .col-2.d-none.d-md-block
  .col-md-8.col-xs-12
    .card
      h4.card-header Login with MetaMask
      .card-body
        .row
          .col-2.d-none.d-md-block
          .col-md-8.col-xs-12
            div(v-if="enabled")
              div(v-if="address")
                p.text-center
                  | To login, first select an account in MetaMask. 
                p.text-center.mt-1
                  |When you click 'sign in', we'll ask you to sign
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
                | To interact with the Ethereum blockchain securely, you need to install
                a(href="https://metamask.io", target="_blank")  Metamask
                |.

              p.text-center.mt-1
                | Once you've installed Metamask, just refresh this page to sign in.
              
              .mt-3
              p.mt-3.text-center
                a.btn.btn-primary.btn-lg.btn-block(href="https://metamask.io", target="_blank")  Install Metamask
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
    sign() {
      console.log('signing');
      metamask.sign('numa', (error, signature) => {
        console.log(error, signature);
        $.ajax({
          url: '/auth/sign',
          dataType: 'json',
          data: {
            signature: signature,
            address: this.address
          },
          success: (account) => {
            console.log('logged in!', account);
            this.account = account;
            this.$notify({
              group: 'login-success',
              title: "You've been logged in!",
              type: 'success'
            });

            if (account.aasm_state == 'draft') {
              document.location = `/u/${account.hash_address}/edit`;
            } else {
              document.location = '/';
            }
          },
          error: (error) => {
            console.log(error);
            this.$notify({
              group: 'login-error',
              title: 'Sorry, we were unable to verify your signature.',
              type: 'error'
            })
          }
        })
      })
    }
  }
}
</script>

<style lang="sass" scoped>

</style>

