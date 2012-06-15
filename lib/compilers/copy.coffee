SingleFileCompiler = require './single-file-compiler'
path = require 'path'

module.exports = class CopyCompiler extends SingleFileCompiler

  constructor: (config) ->
    @extensions = config?.extensions || ["js","css","png","jpg","jpeg","gif"]
    unless config?.notifyOnSuccess?
      config ?= {}
      config.notifyOnSuccess = false;
    super(config)

  compile: (text, fileName, destinationFile, callback) ->
    callback(null, text, destinationFile)

  findCompiledPath: (fileName) ->
    path.join(@destDir, fileName.replace(@origDir, ''))