<template lang="jade">
div
  common
  alerts(ref="alerts")
  .row(v-if="!account.ipfs_hash")
    .col-3.d-none.d-md-block
    .col-md-6.col-xs-12
      .alert.alert-danger.mt-3.mb-3
        | You haven't setup your account on the blockchain yet. Fill out your profile first!

  .row
    .col-3.d-none.d-md-block
    .col-md-6.col-xs-12
      .card
        h4.card-header Update your profile
        .card-body
          label Avatar
          p.text-muted.small 
            | Max 2 MB.
            span(v-if="account.avatar && account.avatar.medium")  Leave blank to keep your current avatar.
          vue-dropzone(ref="dropzone", id="dropzone", :options="dropzoneOptions", @vdropzone-success="uploadSuccess", @vdropzone-error="uploadError")
          .form-group.mt-3
            label(for="username") Username
            input.form-control(type="text", v-model="username", name="username", placeholder="For @ mentions")
          .form-group
            label(for="display_name") 
              | Display Name
              span.small.text-muted  Optional
            input.form-control(type="text", v-model="display_name", name="display_name", placeholder="What should we call you?")
          .form-group
            label(for="bio") 
              | Bio
              span.small.text-muted  Optional
            textarea.form-control(v-model="bio", name="bio", placeholder="Tell us your story")
          .form-group
            label(for="location") 
              | Location
              span.small.text-muted  Optional
            input.form-control(type="text", v-model="location", name="location", placeholder="i.e. 'Mars'")

          .form-group
            label(for="email") 
              | Email Address
              span.small.text-muted  Optional
            input.form-control(type="email", v-model="email", name="email")
            span.small.text-muted Your email is only used to send you notifications. It is never shared or posted on the blockchain.
          
          b-button(:block="true", variant="primary", size="lg", @click="sendUpdate") Update
</template>

<script>
import vue2Dropzone from 'vue2-dropzone';
import 'vue2-dropzone/dist/vue2Dropzone.css';
import batchEvents from '../../libs/batch-events';

export default {
  data() {
    return {
      account: currentAccount,
      dropzoneOptions: {
        url: "/upload_avatar",
        maxFileSize: 2,
        addRemoveLinks: true
      },
      avatar_ipfs_hash: currentAccount.avatar_ipfs_hash,
      username: currentAccount.username,
      display_name: currentAccount.display_name,
      bio: currentAccount.bio,
      location: currentAccount.location,
      email: currentAccountEmail,
    };
  },
  components: {
    vueDropzone: vue2Dropzone
  },
  mounted() {
    
  },
  methods: {
    uploadSuccess(file, response) {
      console.log(file, response);
      const json = JSON.parse(response);
      this.avatar_ipfs_hash = json.ipfs_hash;
      const { dropzone } = this.$refs.dropzone;
      while (dropzone.files.length > 1) {
        dropzone.removeFile(dropzone.files[0]);
      }
      this.alertSuccess("Successfully uploaded a new image.");
    },
    uploadError(file, data, xhr) {
      console.log(file, data, xhr);
      let message = "Sorry, there was an error when uploading a new avatar.";
      try {
        message = JSON.parse(data).message;
      } catch (error) { 
        console.log(error);
      }
      this.$refs.dropzone.removeAllFiles();
      this.alertError(message);
    },
    async sendUpdate() {
      console.log("sending data", this);
      const data = {
        username: this.username,
        bio: this.bio,
        location: this.location,
        avatar_ipfs_hash: this.avatar_ipfs_hash,
        display_name: this.display_name,
        email: this.email,
      };

      try {
        await $.ajax({
          url: `/u/${this.account.hash_address}`,
          method: 'put',
          dataType: 'json',
          data: { account: data },
        });
        batchEvents.triggerNewBatch();
        this.alertSuccess("Your account has been updated!");
        document.location = "/";
      } catch (error) {
        console.log(error);
        let message = 'There was an error with your update';
        if (error.responseJSON && error.responseJSON.errors) {
          message += `: ${error.responseJSON.errors[0]}`;
        }
        this.alertError(message);
      }
    }
  }
};
</script>

<style lang="sass" scoped>

</style>
