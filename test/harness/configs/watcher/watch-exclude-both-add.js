exports.config = {
  modules: ['copy'],
  watch: {
    exclude: [/main.js$/, "javascripts/vendor/requirejs/require.js"],
    usePolling:false
  },
  logger: {
    growl: {
      enabled: false
    }
  }
};