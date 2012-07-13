path = require 'path'
fs = require 'fs'

wrench = require 'wrench'

logger = require '../util/logger'
fileUtils = require '../util/file'
optimizer = require '../optimize/require-optimize'

module.exports = class AbstractCompiler

  constructor: (@fullConfig, @config) ->
    @srcDir = @fullConfig.watch.sourceDir
    @compDir = @fullConfig.watch.compiledDir
    @processWatchedDirectories() if @processWatchedDirectories?

    files = wrench.readdirSyncRecursive(path.join @fullConfig.root, @srcDir)
    files = files.filter (f) =>
      ext = path.extname(f)
      return false if ext.length < 2
      @config.extensions.indexOf(ext.substring(1)) >= 0

    @initialFileCount = files.length
    @initialFilesHandled = 0

  # OVERRIDE THESE
  created: -> throw new Error "Method created must be implemented"
  updated: -> throw new Error "Method updated must be implemented"
  removed: -> throw new Error "Method removed must be implemented"

  setStartupDoneCallback: (@startupDoneCallback) -> @startupDoneCallback() if @initialFileCount is 0

  getExtensions: => @config.extensions

  getOutExtension: => @outExtension

  initializationComplete: (@isInitializationComplete = true) ->

  fileNeedsCompiling: (fileName, destinationFile) ->
    return true unless fs.existsSync(destinationFile)
    destStats = fs.statSync(destinationFile)
    origStats = fs.statSync(fileName)
    return true if origStats.mtime > destStats.mtime
    false

  write: (fileName, content) =>
    fileName = fileName.replace(@fullConfig.root, '')
    dirname = path.dirname(fileName)
    fs.exists dirname, (exists) =>
      fileUtils.mkdirRecursive dirname unless exists
      fs.writeFile fileName, content, "ascii", (err) =>
        return @failed "Failed to write new file: #{fileName}" if err
        @success "Compiled/copied #{fileName}"
        @afterWrite(fileName) if @afterWrite?

  removeTheFile: (fileName, reportSuccess = true) =>
    fs.unlink fileName, (err) =>
      return logger.warn("Cannot delete compiled file, #{fileName}. This is ok if it was never successfully compiled.") if err
      @success "Deleted compiled file #{fileName}" if reportSuccess

  optimize: ->
    optimizer.optimize(@fullConfig) if @isInitializationComplete

  failed: (message) ->
    logger.error message
    @done()

  success: (message) =>
    logger.success(message, @config.notifyOnSuccess)
    @done()

  done: ->
    @doneStartup() if ++@initialFilesHandled is @initialFileCount

  doneStartup: ->
    @startupDoneCallback()
    @startupFinished = true
