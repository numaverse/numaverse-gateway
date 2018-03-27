<template lang="jade">
div
  notifications(group="account-error", :duration="10000")
  notifications(group="account-success", :duration="10000")
  .row(v-if="!account.ipfs_hash")
    .col-3
    .col-6
      .alert.alert-danger.mt-3.mb-3
        | You haven't setup your account on the blockchain yet. Fill out your profile first!

  .row
    .col-3
    .col-6
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
          
          b-button(:block="true", variant="primary", size="lg", @click="sendUpdate") Update
  upload-wizard(ref="uploadWizard", model="account")
</template>

<script>
import vue2Dropzone from 'vue2-dropzone';
import 'vue2-dropzone/dist/vue2Dropzone.css';
import loginVue from '../login.vue';

export default {
  props: [
    'account',
  ],
  data() {
    return {
      dropzoneOptions: {
        url: "/upload_avatar",
        maxFileSize: 2,
        addRemoveLinks: true
      },
      avatar_ipfs_hash: this.account.avatar_ipfs_hash,
      username: this.account.username,
      display_name: this.account.display_name,
      bio: this.account.bio,
      location: this.account.location,
    }
  },
  components: {
    vueDropzone: vue2Dropzone
  },
  mounted() {
    
  },
  methods: {
    uploadSuccess(file, response) {
      console.log(file, response);
      this.avatar_ipfs_hash = response.ipfs_hash;
      const { dropzone } = this.$refs.dropzone;
      while (dropzone.files.length > 1) {
        dropzone.removeFile(dropzone.files[0]);
      };
      this.$notify({
        group: 'account-success',
        title: "Successfully uploaded a new image.",
        type: 'success'
      });
    },
    uploadError(file, data, xhr) {
      console.log(file, data, xhr);
      const message = data.message ? data.message : "Sorry, there was an error when uploading a new avatar."; 
      this.$refs.dropzone.removeAllFiles();
      this.$notify({
        group: 'account-error',
        title: message,
        type: 'error'
      });
    },
    sendUpdate() {
      console.log("sending data", this);
      const data = {
        username: this.username,
        bio: this.bio,
        location: this.location,
        avatar_ipfs_hash: this.avatar_ipfs_hash,
        display_name: this.display_name
      }

      const { uploadWizard } = this.$refs;
      uploadWizard.loading = true;
      uploadWizard.show();

      const request = $.ajax({
        url: `/u/${this.account.hash_address}`,
        method: 'put',
        dataType: 'json',
        data: { account: data },
        success: uploadWizard.ipfsUploadSuccess,
        error: this.ipfsUploadFailed
      })
    },
    ipfsUploadFailed(xhr, message, data) {
      // console.log(xhr, message, data);
      this.$refs.uploadWizard.hide();
      const error = xhr.responseJSON.errors[0];
      this.$notify({
        group: 'account-error',
        title: "There was an error with your update: " + error,
        type: 'error'
      })
    }
  }
}
</script>

<style lang="sass" scoped>

</style>
