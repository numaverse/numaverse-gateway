<template lang="jade">
.message-body(v-html="message.sanitized_body")
//- .message-body
//-   {{ message.body }}
</template>

<script>
// import linkify from 'linkifyjs';
// import hashtag from 'linkifyjs/plugins/hashtag';
// hashtag(linkify);
// import html from 'linkifyjs/html';

export default {
  props: [
    'message'
  ],
  computed: {
    linkifiedBody() {
      // return html(this.message.body);
    }
  }
}
</script>


<style lang="sass" scoped>

</style>
