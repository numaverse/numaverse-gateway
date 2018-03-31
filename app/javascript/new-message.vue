<template lang="jade">
#new_message.new_message
  alerts(ref="alerts")
  common
  .row
    .col-12
      .form-group
        label.mb-0(for="title") Title
        input.form-control(name="title", v-model="title", placeholder="Give your post the title it deserves")
      div(v-if="title.length > 140")
        p.text-danger.small Title must be less than 140 characters.
      .form-group(v-if="use_tldr")
        label.mb-0(for="tldr")
          //- abbr(title="tl;dr stands for \"too long; didn't read\"") tl;dr
          | tl;dr
        p.mb-1
          small.text-muted Write a short summary of your post. Keep it under 140 characters.
          small.ml-1(v-if="tldr.length > 0", v-bind:class="{ 'text-danger': (tldr.length > 140) }")
            | Currently {{tldr.length}} characters.
        textarea.form-control(v-model="tldr", name="tldr")
      .form-group
        label.mb-0 Content
        p.mb-1
          small.text-muted
            | Format your posts using 
            a(href="https://simplemde.com/markdown-guide", target="_blank") Markdown
        textarea.CodeMirror(placeholder="Post Something", ref="body")
      a.toolbar-btn.btn.btn-primary(href="javascript:;", v-on:click="save", ref="save") Save
</template>

<script>
import _ from 'underscore';
import batchEvents from './libs/batch-events';

export default {
  props: [
    'message'
  ],
  data: function () {
    return {
      coinbase: null,
      body: null,
      editor: null,
      preview: "",
      converter: null,
      title: "",
      use_tldr: true,
      tldr: "",
      messageId: null,
    }
  },
  computed: {
    isValid() {
      return (this.tldr.length < 140) && (this.title.length < 140);
    }
  },
  methods: {
    async save() {
      if (!this.isValid) {
        this.alertError("You'll need to make sure there are no errors before saving.");
        return true;
      }
      const data = {
        body: this.body,
        title: this.title,
        tldr: this.tldr,
        json_schema: 'article'
      }

      const url = this.message ? `/messages/${this.message.id}` : '/messages';
      const method = this.message ? 'PUT' : 'POST';

      try {
        const message = await $.ajax({
          url: url,
          data: data,
          method: method,
          dataType: 'json'
        });
        batchEvents.triggerNewBatch();
        const link = `<br/><a href="/messages/${message.id}">View Message</a>`;
        const alert = `Your message has been successfully ${this.messageId ? 'updated' : 'created'}.`;
        this.alertSuccess(alert, { text: link });
        this.messageId = message.id;
      } catch (error) {
        console.log(error);
        this.alertError("Sorry, there was an error when posting your article.");
      }
    },
  },
  async mounted () {
    this.editor = new SimpleMDE({
      element: this.$refs.body,
      spellChecker: false
    });
    if (this.message) {
      this.title = this.message.title;
      this.body = this.message.body;
      this.editor.value(this.body);
      this.tldr = this.message.tldr;
      this.messageId = this.message.id;
    }
    this.editor.codemirror.on("change", () => {
      const value = this.editor.value();
      this.body = value;
    });
  }
}
</script>

<style src="vue-multiselect/dist/vue-multiselect.min.css"></style>

<style scoped lang="scss">
.body {
  height: 500px;
}
.editor-toolbar a.toolbar-btn {
  height: auto;
  width: auto;
  color: white !important;
  &:hover {
    color: #212529 !important;
  }
}
</style>
