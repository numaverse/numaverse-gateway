<template lang="jade">
div
  p.small.text-muted.mt-3
    a.text-muted(:href="'/messages/'+message.id")
      slot
  .card
    .card-body
      .row
        .col-2
          img.img-fluid.img-thumbnail(:src='message.account.avatar.thumb', :alt='message.sender')
        .col-10
          h6.mt-0.mb-0.text-truncate.username 
            a.text-dark(:href="'/u/'+message.account.username") {{ message.account.username_or_address }}
          small
            a.text-dark(:href="'/messages/'+message.id"){{ moment(message.timestamp).fromNow() }}
        .col-12.mt-2
          small
            message-body(:message="message")
</template>

<script>
import moment from 'moment';

export default {
  props: [
    'message'
  ],
  data() {
    return {
      moment: moment,
    };
  }
};
</script>

<style lang="sass" scoped>

</style>
