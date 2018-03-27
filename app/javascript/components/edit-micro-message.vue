<template lang="jade">
.row
  alerts(ref="alerts")
  .col-3
  .col-6
    .space3
    h2 Update your message:
    .space3
    textarea.form-control(placeholder="Write something on the blockchain", v-model="editedMessage")
    .space3
    a.btn.btn-primary.btn-block.btn-lg(@click="sendUpdate", href="javascript:;") Update
    p.mt-3(v-if="message")
      a(:href="'/messages/'+message.id") Go back to this message
  upload-wizard(ref="uploadWizard", model="message", @messageSuccess="messageUpdateSuccess")
</template>

<script>
export default {
  props: [
    'message'
  ],
  data() {
    return {
      currentUser: null,
      editedMessage: null
    }
  },
  methods: {
    async sendUpdate () {
      const body = this.editedMessage;
      const { uploadWizard } = this.$refs;
      uploadWizard.show();

      try {
        const result = await $.ajax({
          url: `/messages/${this.message.id}`,
          method: 'PUT',
          data: {
            body: body
          }
        });

        uploadWizard.ipfsUploadSuccess(result);
      } catch (error) {
        console.log(error);
        this.alertError("Sorry, we're to update this message.");
      }
    },
    messageUpdateSuccess(message) {
      console.log(message);
    }
  },
  mounted() {
    this.currentUser = window.currentUser;
    this.editedMessage = this.message.body;
  }
}
</script>

<style lang="sass" scoped>

</style>
