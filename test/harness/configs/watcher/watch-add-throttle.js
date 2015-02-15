exports.config = {
  modules: ['copy'],
  watch: {
    throttle:1,
    usePolling:false
  },
  logger: {
    growl: {
      enabled: false
    }
  }
};