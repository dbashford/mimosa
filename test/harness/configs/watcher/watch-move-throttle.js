exports.config = {
  modules: ['copy'],
  watch: {
    throttle:500,
    usePolling:false
  },
  logger: {
    growl: {
      enabled: false
    }
  }
};