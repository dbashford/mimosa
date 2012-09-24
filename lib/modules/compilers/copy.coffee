module.exports = class CopyCompiler

  constructor: (config) ->
    @extensions = config.copy.extensions

  compile: (fileName, text, destinationFile, callback) ->
    callback(null, text, destinationFile)