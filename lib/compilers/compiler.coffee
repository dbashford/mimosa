path = require 'path'
fs = require 'fs'

wrench = require 'wrench'

logger = require '../util/logger'
fileUtils = require '../util/file'
optimizer = require '../util/require/optimize'

module.exports = class AbstractCompiler

  isInitializationComplete:false

  constructor: (@fullConfig, @config) ->
    @srcDir = @fullConfig.watch.sourceDir
    @compDir = @fullConfig.watch.compiledDir
    @init() if @init?

    files = wrench.readdirSyncRecursive(@srcDir).filter (f) =>
      ext = path.extname(f)
      ext.length > 1 and @config.extensions.indexOf(ext.substring(1)) >= 0

    @initialFileCount = files.length
    @initialFilesHandled = 0

  # OVERRIDE THESE
  created: -> throw new Error "Method created must be implemented"
  updated: -> throw new Error "Method updated must be implemented"
  removed: -> throw new Error "Method removed must be implemented"

  setStartupDoneCallback: (@startupDoneCallback) ->
    @startupDoneCallback() if @initialFileCount is 0

  getExtensions: =>
    @config.extensions

  getOutExtension: =>
    @outExtension

  initializationComplete: (@isInitializationComplete = true) ->
    @postInitialization() if @postInitialization?

  fileNeedsCompiling: (fileName, destinationFile) ->
    return true unless fs.existsSync destinationFile
    destStats = fs.statSync destinationFile
    origStats = fs.statSync fileName
    origStats.mtime > destStats.mtime

  write: (fileName, content) =>
    if @fullConfig.virgin
      return @success "Compiled #{fileName}"

    fileUtils.writeFile fileName, content, (err) =>
      return @failed "Failed to write new file: #{fileName}" if err
      @success "Compiled/copied #{fileName}"
      @afterWrite(fileName) if @afterWrite?

  removeTheFile: (fileName, reportSuccess = true) =>
    fs.unlink fileName, (err) =>
      return logger.warn("Cannot delete compiled file, #{fileName}. This is ok if it was never successfully compiled.") if err
      @success "Deleted compiled file #{fileName}" if reportSuccess

  optimize: (fileName) ->
    optimizer.optimize(@fullConfig, fileName) if @isInitializationComplete

  failed: (message) ->
    logger.error message
    @done()

  success: (message) =>
    growlIt = @notifyOnSuccess and (@isInitializationComplete or @fullConfig.growl.onStartup)
    logger.success message, growlIt
    @done()

  done: ->
    if !@startupFinished and ++@initialFilesHandled is @initialFileCount
      @doneStartup()

  doneStartup: ->
    @_doneStartup()

  _doneStartup: ->
    @startupDoneCallback()
    @startupFinished = true