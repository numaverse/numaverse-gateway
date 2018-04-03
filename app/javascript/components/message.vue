<template lang="jade">
.card.mb-3.message(v-if="!messageData.hidden_at")
  alerts(ref="alerts")
  b-dropdown(:id="'message-actions-dropdown-'+messageData.id", class="message-actions-dropdown", size="sm", text="Actions", :right="true")
    b-dropdown-item(:href="'/transactions/'+messageData.tx_id", v-if="messageData.tx_id") View Transaction
    b-dropdown-item(:href="'/messages/'+messageData.id") Details
    b-dropdown-item(:href="'/messages/'+messageData.id+'/edit'", v-if="messageOwnedBycurrentAccount()") Edit
    b-dropdown-item(href="javascript:;", v-if="messageOwnedBycurrentAccount()", @click="hideMessage") Hide
  .card-header
    .row
      .col-2
        img.img-fluid.img-thumbnail(:src='messageData.account.avatar.thumb', :alt='messageData.sender')
      .col-10
        h5.mt-1.mb-0.text-truncate.username 
          a.text-dark(:href="'/u/'+messageData.account.username") {{ messageData.account.username_or_address }}
        small
          a.text-dark(:href="'/messages/'+messageData.id"){{ moment(messageData.timestamp).fromNow() }}
  .card-body
    .mt-2
      .mt-2

      div(v-if="messageData.json_schema === 'micro'")
        message-body(:message="message", v-if="!messageData.repost")

      div(v-else-if="messageData.json_schema === 'article'")
        h5
          a.text-dark(:href="'/messages/'+messageData.id")
            {{ messageData.title }}
        
        p.small.font-italic {{ messageData.tldr }}

        p.small
          a(:href="'/messages/'+messageData.id")
            | Read More

      div(v-else)
        .alert.alert-warning This message is improperly formatted.
        p.small {{ messageData.body }}

      div(v-if="messageData.reply_to")
        p.small.text-muted.mt-3
          a.text-muted(:href="'/messages/'+messageData.reply_to.id")
            | Replying to a message from {{ messageData.reply_to.account.username_or_address }}
        .card
          .card-body
            .row
              .col-2
                img.img-fluid.img-thumbnail(:src='messageData.reply_to.account.avatar.thumb', :alt='messageData.reply_to.sender')
              .col-10
                h6.mt-0.mb-0.text-truncate.username 
                  a.text-dark(:href="'/u/'+messageData.reply_to.account.username") {{ messageData.reply_to.account.username_or_address }}
                small
                  a.text-dark(:href="'/messages/'+messageData.reply_to.id"){{ moment(messageData.reply_to.timestamp).fromNow() }}
              .col-12.mt-2
                small(v-html="message.reply_to.sanitized_body")

      div(v-if="messageData.repost")
        p.small.text-muted.mt-3
          a.text-muted(:href="'/messages/'+messageData.repost.id")
            | Reposting a message from {{ messageData.repost.account.username_or_address }}
        .card
          .card-body
            .row
              .col-2
                img.img-fluid.img-thumbnail(:src='messageData.repost.account.avatar.thumb', :alt='messageData.repost.sender')
              .col-10
                h6.mt-0.mb-0.text-truncate.username 
                  a.text-dark(:href="'/u/'+messageData.repost.account.username") {{ messageData.repost.account.username_or_address }}
                small
                  a.text-dark(:href="'/messages/'+messageData.repost.id"){{ moment(messageData.repost.timestamp).fromNow() }}
              .col-12.mt-2
                small(v-html="message.repost.sanitized_body")


      div.mt-2.onebox-container(v-if="messageData.onebox", v-html="messageData.onebox")
    .space
  .card-footer

    small.text-muted
      i.fa.fa-spin.fa-spinner.mr-1(v-if="messageData.is_loading")
      span(v-if="!messageData.is_loading")

        i.fa.mr-1(title="Reply", v-bind:class="{pointer: (currentAccount && !messageData.is_replied), 'fa-comment-o': !messageData.is_replied, 'fa-comment': messageData.is_replied}", v-on:click="reply", :id="'reply-message-'+messageData.id")
        span(v-if="messageData.reply_count > 0")
          {{ messageData.reply_count }}

        i.ml-3.fa.mr-1(title="Favorite", v-bind:class="{pointer: (currentAccount && !messageData.is_favorited), 'fa-star-o': !messageData.is_favorited, 'fa-star': messageData.is_favorited}", v-on:click="toggleFavorite", :id="'favorite-message-'+messageData.id")
        span(v-if="messageData.favorites_count > 0")
          {{ messageData.favorites_count }}

        span(v-if="message.json_schema === 'micro'")
          i.ml-3.mr-1.fa.fa-refresh(title="Repost", v-bind:class="{pointer: (currentAccount && !messageData.is_reposted)}", v-on:click="repost", :id="'repost-message-'+messageData.id")
          span(v-if="messageData.repost_count > 0")
            {{ messageData.repost_count }}

        //- i.ml-3.mr-1.fa.fa-refresh(title="Tip", v-bind:class="{pointer: (currentAccount && !messageData.is_tipped)}", v-on:click="repost(message)", :id="'repost-message-'+messageData.id")
        //- a.text-muted.ml-3.mr-1(title="Tip", v-bind:class="{pointer: (currentAccount && !messageData.is_tipped)}", v-on:click="tip", :id="'tip-message-'+messageData.id")
        //-   {{ messageData.tips }}
      
      b-tooltip(:target="'reply-message-'+messageData.id", title="Reply")
      b-tooltip(:target="'favorite-message-'+messageData.id", title="Favorite")
      span(v-if="message.json_schema === 'micro'")
        b-tooltip(:target="'repost-message-'+messageData.id", title="Repost")
      //- b-tooltip(:target="'tip-message-'+messageData.id", :title="messageData.is_tipped ? 'Tips' : 'Send a Tip'")

      div(v-if="currentAccount")
        b-modal(:ref="'reply-modal-'+messageData.id", title="Reply", @ok="submitReply", ok-title="Reply")
          p
            small
              strong Original Message:
            br
            {{ messageData.body }}
          .mt-2
          textarea.form-control(placeholder="Type your response", v-model="replyBody")
          p.small
            span.text-muted  Max 280 characters.
            span(v-if="replyBody.length > 0", v-bind:class="{ 'text-muted': (replyBody.length <= 280), 'text-danger': (replyBody.length > 280) }")
              |  Currently {{ replyBody.length }} {{ replyBody.length === 0 ? 'character' : 'characters' }}.

        b-modal(ref="confirmHideModal", title="Are you sure?", @ok="submitHide", ok-title="Hide")
          p
            | Because Numa is built on top of a public blockchain, no one can ever permanently 'delete' a record.
            |  However, you can mark your message as hidden, which will prevent it from being displayed publicly.

          p To confirm that you want to hide this message, click "Hide".
      
      //- send-numa-modal(ref="modal",
      //-                 :account="messageData.account",
      //-                 :message="messageData"
      //-                 @sent="handleTipResponse")
</template>

<script>
import moment from 'moment';
import batchEvents from '../libs/batch-events';

export default {
  props: {
    message: {
      type: Object
    },
    compact: {
      type: Boolean,
      default: true
    }
  },
  data() {
    return {
      moment: moment,
      replyBody: '',
      currentAccount: window.currentAccount,
      messageData: this.message,
    };
  },
  methods: {
    userLink(username) {
      return `/u/${username}`;
    },
    async toggleFavorite() {
      const { messageData } = this;
      if (!this.currentAccount || messageData.is_favorited) {
        return true;
      }
      const url = `/favorites?message_id=${messageData.id}`;

      messageData.is_loading = true;

      try {
        await $.ajax({
          url: url,
          method: 'POST',
          dataType: 'json'
        });
        batchEvents.triggerNewBatch();
        this.alertSuccess("Your favorite has been created");
        messageData.is_favorited = true;
        messageData.favorites_count += 1;
        messageData.is_loading = false;
      } catch (error) {
        messageData.is_loading = false;
        this.alertError("Sorry, there was an error when uploading your favorite to IPFS.");
      }
    },
    async repost() {
      const { messageData } = this;
      if (!this.currentAccount || messageData.is_reposted) {
        return true;
      }  
      
      messageData.is_loading = true;

      try {
        const repost = await $.ajax({
          url: `/messages/${messageData.id}/repost`,
          method: 'POST',
          dataType: 'json'
        }); 
        batchEvents.triggerNewBatch();
        messageData.is_reposted = true;
        messageData.repost_count += 1;
        messageData.is_loading = false;

        this.$emit('repost', repost);
        this.alertSuccess("Your repost has been created");
      } catch (error) {
        console.log(error);
        messageData.is_loading = false;
        this.alertError("Sorry, there was an error when uploading your repost to IPFS.");
      }
    },
    async reply() {
      const { messageData } = this;
      if (!this.currentAccount || messageData.is_replied) {
        return true;
      }
      
      const modal = this.$refs['reply-modal-'+messageData.id];
      modal.show();
    },
    async submitReply(evt) {
      const { messageData } = this;
      if (!this.currentAccount || messageData.is_replied || (this.replyBody.length > 280)) {
        evt.preventDefault();
        return true;
      }
      messageData.is_loading = true;

      try {
        const reply = await $.ajax({
          url: `messages/${messageData.id}/reply`,
          method: 'POST',
          dataType: 'json',
          data: {
            body: this.replyBody,
            json_schema: 'micro'
          }
        });
        console.log(reply);
        batchEvents.triggerNewBatch();
        this.alertSuccess("Your reply has been created");
        messageData.is_replied = true;
        messageData.reply_count += 1;
        this.$emit('reply', reply);
      } catch (error) {
        console.log(error);
        this.alertError("Sorry, there was an error when uploading your reply to IPFS.");
      }
      messageData.is_loading = false;
    },
    messageOwnedBycurrentAccount() {
      return this.currentAccount && (this.currentAccount.id === this.messageData.account.id);
    },
    tip() {
      if (!this.currentAccount || this.messageData.is_tipped || this.messageOwnedBycurrentAccount()) {
        return true;
      }
      this.$refs.modal.modal.show();
    },
    handleTipResponse(response) {
      console.log(response);
      if (response.tip && response.tip.message_tips_sum) {
        this.messageData.tips = response.tip.message_tips_sum;
        this.messageData.is_tipped = true;
      }
    },
    hideMessage() {
      this.$refs.confirmHideModal.show();
    },
    async submitHide() {
      if (!this.messageOwnedBycurrentAccount()) {
        return true;
      }
      const { messageData } = this;
      messageData.is_loading = true;
      try {
        const message = await $.ajax({
          url: `/messages/${this.messageData.id}`,
          dataType: 'json',
          method: 'delete'
        });
        this.messageData = message;
        batchEvents.triggerNewBatch();
        this.alertSuccess("Your message has been hidden.");
      } catch (error) {
        console.log(error);
        this.alertError('Sorry, an error occurred while trying to hide this message.');
      }
      messageData.is_loading = false;
    }
  }
};
</script>

<style lang="sass" scoped>
.message-actions-dropdown
  display: none
  z-index: 100;

.card:hover
  .message-actions-dropdown
    display: block;
    position: absolute;
    right: 10px;
    top: 5px;

.onebox-container
  max-width: 100%
  iframe
    max-width: 100%
</style>
