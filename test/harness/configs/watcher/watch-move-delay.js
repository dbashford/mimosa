exports.config = {
  modules: ['copy'],
  watch: {
    delay:50,
    usePolling:false
  },
  logger: {
    growl: {
      enabled: false
    }
  }
};