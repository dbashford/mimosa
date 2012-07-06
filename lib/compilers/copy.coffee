SingleFileCompiler = require './single-file'
path = require 'path'

module.exports = class CopyCompiler extends SingleFileCompiler

  keepBuffer: true

  constructor: (config) ->
    super(config, config.copy)

  compile: (text, fileName, destinationFile, callback) ->
    callback(null, text, destinationFile)

  findCompiledPath: (fileName) ->
    path.join(@compDir, fileName.replace(@srcDir, ''))