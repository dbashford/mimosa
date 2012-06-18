SingleFileCompiler = require './single-file-compiler'
path = require 'path'

module.exports = class CopyCompiler extends SingleFileCompiler

  constructor: (config) -> super(config, config.copy)

  compile: (text, fileName, destinationFile, callback) ->
    callback(null, text, destinationFile)

  findCompiledPath: (fileName) ->
    path.join(@destDir, fileName.replace(@origDir, ''))