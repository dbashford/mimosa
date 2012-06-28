color = require("ansi-color").set
path = require 'path'
fs = require 'fs'
mkdirp = require 'mkdirp'
logger = require '../util/logger'
optimizer = require '../optimize/require-optimize'

module.exports = class AbstractCompiler

  constructor: (@fullConfig, @config) ->
    @srcDir = @fullConfig.watch.sourceDir
    @compDir = @fullConfig.watch.compiledDir
    @processWatchedDirectories() if @processWatchedDirectories?

  # OVERRIDE THESE
  created: -> throw new Error "Method created must be implemented"
  updated: -> throw new Error "Method updated must be implemented"
  removed: -> throw new Error "Method removed must be implemented"

  setDoneCallback: (@compileDoneCallback) ->

  doneStartup: ->
    @startupFinished = true
    @compileDoneCallback = null

  getExtensions: => @config.extensions

  write: (fileName, content) =>
    fileName = fileName.replace(@fullConfig.root, '')
    dirname = path.dirname(fileName)
    path.exists dirname, (exists) =>
      mkdirp.sync dirname unless exists
      fs.writeFile fileName, content, "ascii", (err) =>
        return @failed "Failed to write new file: #{fileName}" if err
        @success "Compiled/copied #{fileName}"
        @postWrite(fileName) if @postWrite?

  removeTheFile: (fileName) =>
    fs.unlink fileName, (err) =>
      return @failed("Failed to delete compiled file: #{fileName}, #{err}") if err
      @success "Deleted compiled file #{fileName}"

  optimize: ->
    optimizer.optimize(@fullConfig) if @startupFinished

  failed: (message) ->
    logger.error message
    @done()

  success: (message) =>
    logger.success(message, @config.notifyOnSuccess)
    @done()

  done: ->
    @compileDoneCallback() if @compileDoneCallback
