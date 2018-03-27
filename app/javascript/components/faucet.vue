<template lang="jade">
div
  div(v-if="recaptchaChecked")
    b-button(size="lg", variant="success", @click="submitForm") Get Free $NUMA
  div(v-else)
    .space3
    p
      | Please complete the captcha above to get some free NUMA.
</template>

<script>
export default {
  data() {
    return {
      currentUser: this.currentUser,
      recaptchaChecked: window.recaptchaChecked,
      recaptchaLoop: null,
    };
  },
  beforeDestroy() {
    if (this.recaptchaLoop) {
      clearInterval(this.recaptchaLoop);
      this.recaptchaLoop = null;
    }
  },
  mounted() {
    // console.log(this);
    if (!this.recaptchaChecked) {
      this.recaptchaLoop = setInterval(() => {
        if (window.recaptchaChecked) {
          this.recaptchaChecked = true;
          clearInterval(this.recaptchaLoop);
          this.recaptchaLoop = null;
        }
      }, 100);
    }
  },
  methods: {
    submitForm() {
      const form = document.getElementById('js-captcha-form')
      form.submit();
    }
  }
}
</script>

<style lang="sass" scoped>

</style>

