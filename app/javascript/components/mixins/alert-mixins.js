import _ from 'underscore';

export default {
  methods: {
    alertSuccess(message, opts) {
      this.$refs.alerts.$notify(_.defaults(opts || {}, {
        group: 'alerts',
        title: message,
        type: 'success',
      }))
    },
    alertError(message, opts) {
      this.$refs.alerts.$notify(_.defaults(opts || {}, {
        group: 'alerts',
        title: message,
        type: 'error'
      }))
    }
  }
}