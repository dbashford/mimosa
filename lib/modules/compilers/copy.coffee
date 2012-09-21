path = require 'path'

AbstractCompiler = require './compiler'
logger = require '../../util/logger'

module.exports = class CopyCompiler extends AbstractCompiler

  keepBuffer: true

  constructor: (config) ->
    @extensions = config.copy.extensions
    super(config)

    @notifyOnSuccess = config.growl.onSuccess.copy

  compile: (fileName, text, destinationFile, callback) ->
    callback(null, text, destinationFile)