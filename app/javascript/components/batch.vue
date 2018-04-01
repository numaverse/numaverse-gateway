<template lang="jade">
div.batch__container(v-if="loading || count > 0")
  .d-none.d-md-block.batch-desktop__container
    .batch-desktop(@click="showModal")
      span(v-if="loading")
        i.fa.fa-spinner.fa-pulse
        |  fetching batch items
      span(v-else)
        {{ message }}
  .d-block.d-xs-block.d-md-none.d-lg-none.batch-mobile__container
    .batch-mobile(@click="showModal")
      span(v-if="loading")
        i.fa.fa-spinner.fa-pulse
        |  fetching batch items
      span(v-else)
        {{ message }}
  b-modal(ref="modal", title="Pending Batch Items", :ok-disabled="loadingBatch", ok-title="Continue", @ok="upload")
    h5 {{ message }}
    p You've uploaded items to the Numa server, but you haven't saved them on the blockchain yet.
    p 
      | Saving them to Ethereum ensures that your data is fully decentralized
      | and available on other apps that use Numa data.
    p
      | Your pending items are:
    ul
      li(v-for="(batchItems, key) in groupedItems")
        {{ itemMessage(key, batchItems) }}
    p Click 'Continue' to create an Ethereum transaction.
  upload-wizard(ref="uploadWizard", model="batch", @success="batchSent")
</template>

<script>
import batchEvents from '../libs/batch-events';
import _ from 'underscore';

export default {
  data() {
    return {
      count: 0,
      batchID: null,
      loading: false,
      loadingBatch: false,
      items: [],
      groupedItems: {},
    };
  },
  mounted() {
    batchEvents.addListener(batchEvents.BATCH_UPDATED, this.newBatchItem);
    this.fetch();
  },
  methods: {
    newBatchItem() {
      this.loading = true;
      this.fetch();
    },
    async fetch() {
      const response = await $.getJSON('/batches/show');
      this.count = response.count;
      this.batchID = response.id;
      this.items = response.items;
      this.groupedItems = _.groupBy(this.items, 'item_type');
      this.loading = false;
    },
    async showModal() {
      this.$refs.modal.show();
    },
    async upload() {
      // console.log("uploading batch");
      const { uploadWizard } = this.$refs;
      uploadWizard.show();

      try {
        const result = await $.ajax({
          url: `/batches/${this.batchID}/upload`,
          method: 'post',
        });
        uploadWizard.ipfsUploadSuccess(result);
      } catch (error) {
        console.log(error);
        uploadWizard.hide();
      }
    },
    itemMessage(key, list) {
      const plural = list.length === 1 ? '' : 's';
      return `${list.length} ${key} update${plural}`;
    },
    batchSent() {
      
    }
  },
  beforeDestroy() {
    batchEvents.removeListener(batchEvents.BATCH_UPDATED, this.newBatchItem);
  },
  computed: {
    message() {
      return `${this.count} batch ${this.itemsPluralized} pending`;
    },
    itemsPluralized() {
      return this.count === 1 ? 'item' : 'items';
    }
  }
};
</script>

<style lang="sass" scoped>
$lightPurple: #778beb;
$lightPeach: #f3a683;
$darkPurple: #574b90;

.batch-desktop__container
  position: relative

.batch-desktop
  position: fixed
  cursor: pointer
  z-index: 10
  bottom: 20px
  left: 20px
  background-color: $lightPeach
  color: $darkPurple
  border-radius: 5px
  padding: 20px
  font-size 14px

.batch-mobile
  background-color: $lightPeach
  color: $darkPurple
  z-index: 10
  position: fixed
  bottom: 0
  left: 10px
  padding: 4px 8px
  border-radius: 3px 3px 0 0
  font-size: 12px
  cursor: pointer 

</style>
