<template lang="jade">
div
  .home-messages(v-for='message in messagesList', :key="message.id")
    message(:message="message", 
      @reply="reply => { addMessage(reply) }",
      @repost="repost => { addMessage(repost) }",
    )
  div(v-if="messagesList.length === 0")
    .alert.alert-warning
      p 
        | It looks like there are no messages to show here.
  div(v-if="isLoading")
    .text-center
      p Loading More Messages
      .space3
      i.fa.fa-spin.fa-spinner
  div(v-else)
    div(v-observe-visibility="bottomVisible")
  div(v-if="finished")
    .space3
    .text-center
      p Yep, this is as far as it goes.
</template>

<script>
export default {
  props: [
    'messages'
  ],
  data() {
    return {
      messagesList: [],
      page: 1,
      isLoading: true,
      finished: false
    };
  },
  methods: {
    addMessage(message) {
      this.messagesList.unshift(message);
    },
    async bottomVisible(isVisible) {
      if (!this.isLoading && isVisible && !this.finished && (this.messagesList.length > 0)) {
        this.isLoading = true;
        this.fetchNextPage();
      }
    },
    async fetchNextPage() {
      let { pathname, search } = document.location;
      const seperator = search.indexOf('?') === 0 ? '&' : '?';
      this.page += 1;
      if (pathname == "/") {
        pathname = '/all';
      }
      const url = `${pathname}.json${search}${seperator}page=${this.page}`;

      
      
      const result = await $.ajax({
        url: url,
        type: 'get',
        dataType: 'json'
      });

      if (result.messages.length === 0) {
        this.finished = true;
      } else {
        this.messagesList = this.messagesList.concat(result.messages);
      }

      this.isLoading = false;
    }
  },
  mounted() {
    this.messagesList = this.messages;
    this.isLoading = false;
    this.$nextTick(() => {
      this.messagesList = this.messages;
      this.isLoading = false;
    });
  }
};
</script>

<style lang="sass" scoped>

</style>
