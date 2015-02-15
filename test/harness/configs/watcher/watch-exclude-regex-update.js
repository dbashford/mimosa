exports.config = {
  modules: ['copy'],
  watch: {
    exclude: [/main.js$/, /require.js$/],
    usePolling:false
  },
  logger: {
    growl: {
      enabled: false
    }
  }
};