<template lang="jade">
#add-account
  p To add an account, you need to call a smart contract with metamask.
  p
    | Your current address is:
    br
    code {{coinbase}}
  a.btn.btn-primary.mt-3(v-on:click="signUp()", href="javascript:;") Sign Up
</template>

<script>
// import crypt from './libs/metamask';
// window.crypt = crypt;
// export default {
//   data: function () {
//     return {
//       coinbase: null
//     }
//   },
//   methods: {
//     async signUp () {
//       console.log('signing up!');
//       const contract = await crypt.contract();

//       await contract.signUp({from: this.coinbase, value: 1000});
//       console.log('signed up');
//       const userId = await contract.usersByAddress.call(this.coinbase);
//       console.log(userId.valueOf());
//       await contract.updateUser(userId, JSON.stringify({user_uuid: userUuid}), { from: this.coinbase });
//       console.log('updated');
//       // console.log(userId);
//     }
//   },
//   async mounted () {
//     const coinbase = await crypt.web3.eth.getCoinbase();
//     this.coinbase = coinbase;
//   }
// }
</script>

<style scoped>
</style>
