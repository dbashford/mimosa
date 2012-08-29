fs = require 'fs'
path = require 'path'

AbstractCompiler = require './compiler'
logger = require '../util/logger'

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
    unless isUpdate or @fileNeedsCompiling(fileName, destinationFile)
      logger.debug "File [[ #{fileName} ]] does not need compiling"
      return @done()
    fs.readFile fileName, (err, text) =>
      return @failed(err) if err
      text = text.toString() unless @keepBuffer?
      @compile fileName, text, destinationFile, @_compileComplete

  _compileComplete: (error, results, destinationFile) =>
    if error
      @failed "Error compiling: #{error}"
    else
      logger.debug "Compile/Copy for [[ #{destinationFile} ]] has finished"
      results = @afterCompile(destinationFile, results) if @afterCompile?
      @write destinationFile, results

  findCompiledPath: (fileName) ->
    baseCompDir = fileName.replace(@srcDir, @compDir)
    baseCompDir.substring(0, baseCompDir.lastIndexOf(".")) + ".#{@outExtension}"

  _isCSS: (fileName) ->
    path.extname(fileName) is ".css"

  _isJS: (fileName) ->
    path.extname(fileName) is ".js"

  _isVendor: (fileName) ->
    fileName.split(path.sep).indexOf('vendor') > -1

  _isJSNotVendor: (fileName) ->
    @_isJS(fileName) and !@_isVendor(fileName)