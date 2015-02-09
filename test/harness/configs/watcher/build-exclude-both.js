exports.config = {
  modules: ['copy'],
  watch: {
    exclude: [/main.js$/, "javascripts/vendor/requirejs/require.js"]
  },
  logger: {
    growl: {
      enabled: false
    }
  }
};