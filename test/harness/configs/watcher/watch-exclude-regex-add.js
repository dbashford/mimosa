exports.config = {
  modules: ['copy'],
  watch: {
    exclude: [/foo.js$/, /main.js$/, /require.js$/],
    usePolling:false
  },
  logger: {
    growl: {
      enabled: false
    }
  }
};