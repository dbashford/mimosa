path = require 'path'
fs = require 'fs'

wrench = require 'wrench'

logger = require '../../util/logger'
fileUtils = require '../../util/file'

module.exports = class AbstractCompiler

  isInitializationComplete:false

  constructor: (@config) ->
    @srcDir = @config.watch.sourceDir
    @compDir = @config.watch.compiledDir
    @init() if @init?

  # OVERRIDE THESE
  removed: -> throw new Error "Method removed must be implemented"

  setStartupDoneCallback: (@startupDoneCallback) ->
    @startupDoneCallback() if @initialFileCount is 0

  getOutExtension: => @outExtension

  initializationComplete: (@isInitializationComplete = true) ->
    @postInitialization() if @postInitialization?

  failed: (message) ->
    logger.error message
    @done()

  success: (message) =>
    growlIt = @notifyOnSuccess and (@isInitializationComplete or @config.growl.onStartup)
    logger.success message, growlIt

  done: ->
    if !@startupFinished and ++@initialFilesHandled is @initialFileCount
      logger.debug "Compiler for extensions [[ #{@extensions} ]] has completed startup"
      @doneStartup()

  doneStartup: ->
    @_doneStartup()

  _doneStartup: ->
    @startupDoneCallback()
    @startupFinished = true