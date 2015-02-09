exports.config = {
  modules: ['copy'],
  watch: {
    exclude: ["javascripts/main.js", "javascripts/vendor/requirejs/require.js"]
  },
  logger: {
    growl: {
      enabled: false
    }
  }
};