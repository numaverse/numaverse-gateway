<template lang="jade">
div(v-if="visible()")
  b-button(:block="true", @click="toggleFollow()", :variant="variant()")
    span(v-if="isLoading")
      i.fa.fa-spin.fa-spinner.mr-1
      | Loading...
    span(v-if="!isLoading && !follow")
      | Follow
    span(v-if="!isLoading && follow")
      | Unfollow
  alerts(ref="alerts")
</template>

<script>
import batchEvents from '../libs/batch-events';

export default {
  props: [
    'account',
  ],
  data() {
    return {
      currentAccount: window.currentAccount,
      isLoading: true,
      follow: null
    }
  },
  methods: {
    async toggleFollow() {
      this.isLoading = true;
      if (this.follow) {
        await this.unfollow();
      } else {
        await this.createFollow();
      }
      this.isLoading = false;
    },
    async createFollow() {
      try {
        const follow = await $.ajax({
          url: '/follows',
          data: {
            to_account_id: this.account.id
          },
          type: 'post',
          dataType: 'json'
        });
        batchEvents.triggerNewBatch();
        this.follow = follow;
        this.alertSuccess(`You've followed @${this.account.username}`);
      } catch (error) {
        this.alertError("Sorry, there was an error when creating this follow.");
      }
    },
    async unfollow() {
      try {
        const follow = await $.ajax({
          url: `/follows/${this.follow.id}`,
          data: {
            _method: 'DELETE'
          },
          type: 'post',
          dataType: 'json'
        });
        batchEvents.triggerNewBatch();
        this.alertSuccess(`You've unfollowed @${this.account.username}`);
        this.follow = null;
      } catch (error) {
        this.alertError("Sorry, there was an error when creating this follow.");
      }
    },
    visible() {
      return this.currentAccount && (this.currentAccount.id != this.account.id);
    },
    variant() {
      if (this.isLoading) {
        return 'outline-secondary';
      } else if (this.follow) {
        return 'outline-secondary';
      } else {
        return 'outline-success';
      }
    }
  },
  async mounted() {
    if (!this.visible()) {
      return true;
    }

    const follow = await $.ajax({
      url: `/follows/${this.account.id}`,
      type: 'get',
      dataType: 'json'
    });

    this.follow = follow;
    this.isLoading = false;
  }
}
</script>

<style lang="sass" scoped>

</style>

