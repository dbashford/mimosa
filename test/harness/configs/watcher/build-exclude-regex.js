exports.config = {
  modules: ['copy'],
  watch: {
    exclude: [/main.js$/, /require.js$/]
  },
  logger: {
    growl: {
      enabled: false
    }
  }
};