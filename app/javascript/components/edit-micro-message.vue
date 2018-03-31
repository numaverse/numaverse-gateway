<template lang="jade">
.row
  common
  alerts(ref="alerts")
  .col-3
  .col-6
    .space3
    h2 Update your message:
    .space3
    textarea.form-control(placeholder="Write something on the blockchain", v-model="editedMessage")
    .space3
    b-button(:disabled="loading", variant="primary", :block="true", @click="sendUpdate()", size="lg")
      span(v-if="loading")
        i.fa.fa-spinner.fa-pulse.mr-2
      | Update
    p.mt-3(v-if="message")
      a(:href="'/messages/'+message.id") Go back to this message
</template>

<script>
import batchEvents from '../libs/batch-events';

export default {
  props: [
    'message'
  ],
  data() {
    return {
      currentUser: null,
      editedMessage: null,
      loading: false,
    }
  },
  methods: {
    async sendUpdate () {
      console.log("sending")
      this.loading = true;
      try {
        const result = await $.ajax({
          url: `/messages/${this.message.id}`,
          method: 'PUT',
          data: { body: this.editedMessage }
        });

        batchEvents.triggerNewBatch();
        const link = `<br/><a href="/messages/${this.message.id}">View Message</a>`;
        this.alertSuccess("Your message has been successfully updated.", { text: link });
      } catch (error) {
        console.log(error);
        this.alertError("Sorry, we're to update this message.");
      }
      this.loading = false;
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
