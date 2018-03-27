<template lang="jade">
#app
  notifications(group="app-errors", :duration="-1")
  notifications(group="app-message", :duration="10000")
  alerts(ref="alerts")
  .row.mt-2
    .col-3
      .home-user.home-user__welcome.card(v-if="!currentAccount")
        .card-body
          h5.mb-3 Welcome to Numa!
          .small
            p
              | Numa is a distributed social network.
            p
              | It's built on top of an Ethereum-based blockchain,
              | so all the core data is open to anyone.

            p
              | To encourage users to joins, we're currently giving away millions of NUMA,
              | the cryptocurrency that lets you post messages
              | onto the blockchain.

            p
              | To get started, just
              a(href="/users/sign_up")  sign up for a free account
              |  and you'll get 5 NUMA right away.

            p
              | By following people, posting messages, 


      .home-user(v-if="currentAccount")
        user-card(:account="currentAccount")
        
    .col-6
      div(v-if="currentAccount")
        upload-wizard(ref="uploadWizard", model="message", @messageSuccess="showNewMessage")
        textarea.form-control(placeholder="Write something on the Ethereum blockchain", v-model="newMessage")
        a.btn.btn-primary.mt-1(v-on:click="postMessage()", href="javascript:;", 
          v-bind:class="{ disabled: !canSendNewMessage() }",
          :disabled="!canSendNewMessage()")
          span(v-if="!isLoading")
            | Post
          span(v-else)
            i.fa.fa-spin.fa-spinner.mr-1
            | Loading
        .text-right.mt-3.small.pull-right 
          span(v-if="newMessage.length > 0", v-bind:class="{ 'text-muted': (newMessage.length <= 280), 'text-danger': (newMessage.length > 280) }")
            | Currently {{ newMessage.length }} {{ newMessage.length === 0 ? 'character' : 'characters' }}.
          span.text-muted  Max 280 characters.

        .mt-3
        p.small.text-muted
          | Got more to say? Write an
          | {{ ' ' }}
          a.text-dark(href="/messages/new") article
          | .

        .space3

      p.small.text-muted(v-if="isFollowingFeed") Messages from people you follow:
      p.small.text-muted(v-else) Public Feed:
      .mt-3
      messages-list(:messages="messages")
              

    .col-3
  
</template>

<script>
import moment from 'moment';

export default {
  props: [
    '_messages'
  ],
  data: function () {
    return {
      newMessage: "",
      isUser: null,
      userId: null,
      moment: moment,
      messages: [],
      replyBody: "",
      isLoading: false,
      currentAccount: window.currentAccount,
    }
  },
  methods: {
    async postMessage() {
      if (!this.canSendNewMessage()) {
        return true;
      }
      const data = {
        body: this.newMessage,
        json_schema: 'micro'
      }

      const url = '/messages';
      const method = 'POST';

      this.newMessage = "";
      this.isLoading = true;

      const { uploadWizard } = this.$refs;
      uploadWizard.loading = true;
      uploadWizard.show();

      $.ajax({
        url: url,
        data: data,
        dataType: 'json',
        method: method,
        success: this.$refs.uploadWizard.ipfsUploadSuccess,
        error: (error) => {
          this.newMessage = data.body;
          uploadWizard.hide();
          this.alertError('Sorry, an error happened when posting that message.');
        }
      });
      this.isLoading = false;
    },
    showNewMessage(message) {
      this.messages.unshift(message)
    },
    userLink(username) {
      return `/u/${username}`
    },
    addMessage(message) {
      this.messages.unshift(message);
    },
    canSendNewMessage() {
      return !this.isLoading && (this.newMessage.length <= 280);
    }
  },
  computed: {
    isFollowingFeed() {
      return this.currentAccount && document.location.pathname == "/";
    }
  },
  mounted: async function () {
    this.messages = this._messages;
  }
}
</script>

<style scoped lang="scss">
.message {
  .message-actions {
    i {
      cursor: pointer;
    }
  }
  .username {
    max-width: 240px;
  }
}

.home-user {
  height: auto;
}
.home-user__welcome {
  p {
    font-size: 14px;
  }
}

.favorite-star {
  cursor: pointer;
}
</style>

