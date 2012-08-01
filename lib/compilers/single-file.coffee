fs = require 'fs'

AbstractCompiler = require './compiler'

module.exports = class AbstractSingleFileCompiler extends AbstractCompiler

  constructor: (config, targetConfig) ->
    super config, targetConfig

  compile: (fileName, fileAsText, destinationFile, callback) ->
    throw new Error "Method compile must be implemented"

  created: (fileName) =>
    @readAndCompile fileName, false

  updated: (fileName) =>
    @readAndCompile fileName

  removed: (fileName) =>
    @removeTheFile @findCompiledPath(fileName)

  readAndCompile: (fileName, isUpdate = true) ->
    destinationFile = @findCompiledPath fileName
    return @done() unless isUpdate or @fileNeedsCompiling(fileName, destinationFile)
    fs.readFile fileName, (err, text) =>
      return @failed(err) if err
      text = text.toString() unless @keepBuffer?
      @compile fileName, text, destinationFile, @_compileComplete

  _compileComplete: (error, results, destinationFile) =>
    if error
      @failed "Error compiling: #{error}"
    else
      results = @afterCompile(destinationFile, results) if @afterCompile?
      @write destinationFile, results

  findCompiledPath: (fileName) ->
    fileName.replace(@srcDir, @compDir).substring(0, fileName.lastIndexOf(".")) + ".#{@outExtension}"
