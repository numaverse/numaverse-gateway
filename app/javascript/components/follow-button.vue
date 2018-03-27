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
  upload-wizard(ref="uploadWizard", model="follow")
  alerts(ref="alerts")
</template>

<script>
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
      const { uploadWizard } = this.$refs;
      uploadWizard.loading = true;
      uploadWizard.show();

      try {
        const follow = await $.ajax({
          url: '/follows',
          data: {
            to_account_id: this.account.id
          },
          type: 'post',
          dataType: 'json'
        });
        uploadWizard.ipfsUploadSuccess(follow);
        this.follow = follow;
      } catch (error) {
        uploadWizard.hide();
        this.alertError("Sorry, there was an error when creating this follow.");
      }
      
    },
    async unfollow() {
      const { uploadWizard } = this.$refs;
      uploadWizard.loading = true;
      uploadWizard.show();

      try {
        const follow = await $.ajax({
          url: `/follows/${this.follow.id}`,
          data: {
            _method: 'DELETE'
          },
          type: 'post',
          dataType: 'json'
        });
        console.log(follow);
        uploadWizard.ipfsUploadSuccess(follow);
        this.follow = null;
      } catch (error) {
        uploadWizard.hide();
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

