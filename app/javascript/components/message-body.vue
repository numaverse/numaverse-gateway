<template lang="jade">
div
  div(v-if="!message.repost")
    div(v-if="message.json_schema === 'micro'")
      .message-body(v-html="message.sanitized_body")

    div(v-else-if="message.json_schema === 'article'")
      h5
        a.text-dark(:href="'/messages/'+message.id")
          {{ message.title }}
      
      p.small.font-italic {{ message.tldr }}

      p.small
        a(:href="'/messages/'+message.id")
          | Read More
</template>

<script>
export default {
  props: [
    'message'
  ],
};
</script>


<style lang="sass" scoped>

</style>
