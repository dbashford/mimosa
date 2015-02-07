exports.config = {
  modules: ['copy'],
  watch: {
    exclude:[/main.js$/]
  },
  logger: {
    growl: {
      enabled: false
    }
  }
};