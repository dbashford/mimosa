exports.config = {
  modules: ['copy'],
  watch: {
    exclude: [/foo.js$/, /main.js$/, "javascripts/vendor/requirejs/require.js"],
    usePolling:false
  },
  logger: {
    growl: {
      enabled: false
    }
  }
};