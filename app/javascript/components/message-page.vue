<template lang="jade">
div
  div(v-if="message.json_schema === 'article'")
    .row
      .col-2
      .col-8
        .row
          .col-2
            img.img-fluid.rounded-circle(:src="message.account.avatar.medium")
          .col-10
            small.text-muted
              | by
              a(:href='"/u/"+message.account.username')  @{{message.account.username}}
              span(v-if="message.account.bio")
                br
                {{ message.account.bio }}
              span(v-if="message.account.location")
                br
                i.fa.fa-globe.mr-1
                {{ message.account.location }}
              br
              | Published {{ moment(message.timestamp).fromNow() }}
      
        h1.mt-3
          span(v-if="message.title")
            {{ message.title }}
          span(v-else)
            | Untitled
        
        .space3

        .mt-3
        div(v-if="message.tldr")
          p.font-weight-light {{ message.tldr }}

        .space3

        .mt-3
        .message-body(v-html="message.sanitized_body")
  div(v-else)
    .row
      .col-3
        user-card(:user="message.user")
      .col-6
        div(v-if="message.json_schema === 'article'")
          h2 
        div(v-else)
          message(:message="message", @reply="reply => { newReply(reply) }")

        div(v-if="replies.length > 0")
          .space
          hr
          .space
          h3.mb-3 Replies:

          messages-list(:messages="replies")

        div(v-if="tips.length > 0")
          .space
          hr
          .space
          h3.mb-3 Tips:

          ul(v-for="tip in tips")
            li
              a(:href="'/transactions/'+tip.tx_id")
                {{ tip.humanized_value }} 
              | from 
              span(v-if="tip.username")
                a(:href="'/u/'+tip.username")  @{{ tip.username }}
              span(v-else)
                {{ tip.sender }}
</template>

<script>
import moment from 'moment';

export default {
  props: [
    'message'
  ],
  data() {
    return {
      replies: [],
      moment: moment,
      tips: []
    }
  },
  methods: {
    newReply(reply) {
      this.replies.unshift(reply)
    }
  },
  mounted() {
    this.replies = this.message.replies;
    this.tips = this.message.tips_list;
  }
}
</script>

<style lang="sass" scoped>

</style>
