AbstractCompiler = require '../compiler'
path = require 'path'
find = require 'findit'
fs = require 'fs'
logger = require '../../util/logger'

module.exports = class AbstractTemplateCompiler extends AbstractCompiler

  constructor: (config) ->
    super(config, config.compilers.template)
    @templateFileName = path.join(@compDir, @config.outputFileName + ".js")
    @baseDir = path.dirname(@templateFileName)

  # OVERRIDE THIS
  compile: (fileNames, callback) -> throw new Error "Method compile must be implemented"

  created: =>
    if @startupFinished then @_gatherFiles() else @done()

  updated: =>
    @_gatherFiles()

  removed: =>
    @_gatherFiles(true)

  cleanup: ->
    @_removeClientLibrary()
    @removeTheFile(@templateFileName, false) if path.existsSync @templateFileName

  doneStartup: -> @_gatherFiles()

  _gatherFiles: (isRemove = false) ->
    fileNames = []
    allFiles = find.sync @srcDir
    allFiles.forEach (file) =>
      extension = path.extname(file).substring(1)
      fileNames.push(file) if @config.extensions.indexOf(extension) >= 0

    if fileNames.length is 0
      if isRemove
        @removeTheFile(@templateFileName)
        @_removeClientLibrary()
    else
      @_writeClientLibrary()
      @compile(fileNames, @_write) if @_templateNeedsCompiling(fileNames)

  _templateNeedsCompiling: (fileNames) ->
    for file in fileNames
      return true if @fileNeedsCompiling(file, @templateFileName)
    false

  _write: (error, output) =>
    if error
      @failed(err)
    else
      @write(@templateFileName, output) if output?

    unless @startupFinished
      console.log "CALLING STARTUP FINISHED?"
      @startupDoneCallback()
      @startupFinished = true

  _removeClientLibrary: ->
    fs.unlink @_clientPath() if path.existsSync @_clientPath()

  _writeClientLibrary: ->
    return if path.existsSync @_clientPath()
    mimosaLibraryPath = path.join __dirname, "client", "#{@clientLibrary}.js"
    fs.readFile mimosaLibraryPath, "ascii", (err, data) =>
      return logger.error "Cannot read client library: #{@clientLibrary}" if err?
      fs.writeFile @_clientPath(), data, 'ascii', (err) =>
        return logger.error "Cannot write client library: #{@clientLibrary}" if err?

  _clientPath: -> path.join @baseDir, "#{@clientLibrary}.js"

  afterWrite: (fileName) -> @optimize()


