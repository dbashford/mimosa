path = require 'path'
fs = require 'fs'

wrench = require 'wrench'

logger = require '../util/logger'
fileUtils = require '../util/file'
optimizer = require '../util/require/optimize'

module.exports = class AbstractCompiler

  isInitializationComplete:false

  constructor: (@config) ->
    @srcDir = @config.watch.sourceDir
    @compDir = @config.watch.compiledDir
    @init() if @init?

    files = wrench.readdirSyncRecursive(@srcDir).filter (f) =>
      ext = path.extname(f)
      ext.length > 1 and @extensions.indexOf(ext.substring(1)) >= 0

    @initialFileCount = files.length
    logger.debug "File count for extension(s) [[ #{@extensions} ]]: #{@initialFileCount}"
    @initialFilesHandled = 0

  # OVERRIDE THESE
  created: -> throw new Error "Method created must be implemented"
  updated: -> throw new Error "Method updated must be implemented"
  removed: -> throw new Error "Method removed must be implemented"

  setStartupDoneCallback: (@startupDoneCallback) ->
    @startupDoneCallback() if @initialFileCount is 0

  getExtensions: => @extensions

  getOutExtension: => @outExtension

  initializationComplete: (@isInitializationComplete = true) ->
    @postInitialization() if @postInitialization?

  fileNeedsCompiling: (fileName, destinationFile) ->
    return true unless fs.existsSync destinationFile
    destStats = fs.statSync destinationFile
    origStats = fs.statSync fileName
    origStats.mtime > destStats.mtime

  write: (fileName, content) =>
    if @config.virgin
      logger.debug "Virgin is turned on, not writing [[ #{fileName} ]]"
      @success "Compiled [[ #{fileName} ]]"
      return @done()

    logger.debug "Writing file [[ #{fileName} ]]"
    fileUtils.writeFile fileName, content, (err) =>
      return @failed "Failed to write new file: #{fileName}" if err
      @success "Compiled/copied [[ #{fileName} ]]"
      @afterWrite(fileName) if @afterWrite?
      @done()

  removeTheFile: (fileName, reportSuccess = true) =>
    logger.debug "Removing file [[ #{fileName} ]]"
    fs.unlink fileName, (err) =>
      unless err?
        @success "Deleted compiled file [[ #{fileName} ]]" if reportSuccess
        @done()

  optimize: (fileName) ->
    optimizer.optimize(@config, fileName) if @isInitializationComplete

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