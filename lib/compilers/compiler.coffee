color = require("ansi-color").set
path = require 'path'
fs = require 'fs'
mkdirp = require 'mkdirp'
logger = require '../util/logger'
optimizer = require '../util/require-optimize'

module.exports = class AbstractCompiler

  constructor: (fullConfig, @config) ->
    @origDir = fullConfig.watch.originationDir
    @destDir = fullConfig.watch.destinationDir
    @root = fullConfig.root
    @processWatchedDirectories() if @processWatchedDirectories?

  # OVERRIDE THESE
  created: -> throw new Error "Method created must be implemented"
  updated: -> throw new Error "Method updated must be implemented"
  removed: -> throw new Error "Method removed must be implemented"

  doneStartup: -> @startupFinished = true

  getExtensions: => @config.extensions

  write: (fileName, content) =>
    fileName = fileName.replace(@root, '')
    dirname = path.dirname(fileName)
    path.exists dirname, (exists) =>
      return @writeTheFile(fileName, content) if exists
      mkdirp dirname, (err) =>
        return @notifyFail "Failed to create directory: #{dirname}" if err
        @writeTheFile(fileName, content)

  writeTheFile: (fileName, content) ->
    fs.writeFile fileName, content, "ascii", (err) =>
      return @notifyFail "Failed to write new file: #{fileName}" if err
      @notifySuccess "Compiled/copied #{fileName}"
      @postWrite(fileName) if @postWrite

  removeTheFile: (fileName) =>
    fs.unlink fileName, (err) =>
      return @notifyFail("Failed to delete compiled file: #{fileName}") if err
      @notifySuccess "Deleted compiled file #{fileName}"

  optimize: ->
    optimizer.optimize(path.join(@root, @destDir)) if @startupFinished

  notifySuccess: (message) => logger.success(message, @config.notifyOnSuccess)
  notifyFail: (message) -> logger.error message