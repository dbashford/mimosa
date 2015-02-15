exports.config = {
  modules: ['copy'],
  watch: {
    exclude: ["javascripts/foo.js", "javascripts/main.js", "javascripts/vendor/requirejs/require.js"],
    usePolling:false
  },
  logger: {
    growl: {
      enabled: false
    }
  }
};