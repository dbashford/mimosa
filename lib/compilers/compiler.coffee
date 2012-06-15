growl = require 'growl'
color = require("ansi-color").set
path = require 'path'
fs = require 'fs'
mkdirp = require 'mkdirp'

module.exports = class AbstractCompiler

  constructor: (config) ->
    @notifyOnSuccess = config?.notifyOnSuccess || true

  # OVERRIDE THESE
  created: -> throw new Error "Method created must be implemented"
  updated: -> throw new Error "Method updated must be implemented"
  removed: -> throw new Error "Method removed must be implemented"

  getExtensions: -> @extensions

  setWatchedDirectories: (@origDir, @destDir) ->
    @processWatchedDirectories() if @processWatchedDirectories?

  write: (fileName, content) =>
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

  removeTheFile: (fileName) =>
    fs.unlink fileName, (err) =>
      return @notifyFail("Failed to delete compiled file: #{fileName}") if err
      @notifySuccess "Deleted compiled file #{fileName}"

  notifySuccess: (message) ->
    growl(message, {title:"Success!!!", image:"#{__dirname}/growl_images/success.png"}) if @notifyOnSuccess
    console.log color(message, "green")

  notifyFail: (message) ->
    growl(message, {title:"Hey, your shit broke", image:"#{__dirname}/growl_images/failed.png"})
    console.log color(message, "red+bold+underline")

