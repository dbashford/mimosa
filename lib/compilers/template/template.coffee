path = require 'path'
fs = require 'fs'

wrench = require 'wrench'

fileUtils = require '../../util/file'
logger = require '../../util/logger'
AbstractCompiler = require '../compiler'

module.exports = class AbstractTemplateCompiler extends AbstractCompiler

  constructor: (config) ->
    super(config, config.compilers.template)
    @templateFileName = path.join(@compDir, @config.outputFileName + ".js")
    if @clientLibrary?
      @mimosaClientLibraryPath = path.join __dirname, "client", "#{@clientLibrary}.js"
      @clientPath = path.join path.dirname(@templateFileName), 'vendor', "#{@clientLibrary}.js"
    @notifyOnSuccess = config.growl.onSuccess.template

  # OVERRIDE THIS
  compile: (fileNames, callback) ->
    throw new Error "Method compile(fileNames, callback) must be implemented"

  created: =>
    if @startupFinished then @_gatherFiles() else @done()

  updated: =>
    @_gatherFiles()

  removed: =>
    @_gatherFiles true
    @optimize(fileName)

  cleanup: ->
    @_removeClientLibrary()
    @removeTheFile(@templateFileName, false) if fs.existsSync @templateFileName

  doneStartup: ->
    @_gatherFiles()

  _gatherFiles: (isRemove = false) ->
    fileNames = []
    allFiles = wrench.readdirSyncRecursive(@srcDir)
      .map (file) => path.join(@srcDir, file)

    for file in allFiles
      extension = path.extname(file).substring(1)
      fileNames.push(file) if @config.extensions.indexOf(extension) >= 0

    if fileNames.length is 0
      if isRemove
        @removeTheFile @templateFileName
        @_removeClientLibrary()
    else
      @_writeClientLibrary =>
        if @_templateNeedsCompiling fileNames
          AbstractTemplateCompiler::done = =>
            @_reportStartupDone() if !@startupFinished
          @compile fileNames, @_write
        else
          @_reportStartupDone()

  _templateNeedsCompiling: (fileNames) ->
    for file in fileNames
      return true if @fileNeedsCompiling(file, @templateFileName)
    false

  _write: (error, output) =>
    if error
      @failed error
    else
      @write(@templateFileName, output) if output?

  _reportStartupDone: =>
    unless @startupFinished
      @startupDoneCallback()
      @startupFinished = true

  _removeClientLibrary: ->
    fs.unlink @clientPath if @clientPath? and fs.existsSync @clientPath

  _writeClientLibrary: (callback) ->
    return callback() if @fullConfig.virgin or !@clientPath? or fs.existsSync @clientPath

    fs.readFile @mimosaClientLibraryPath, "ascii", (err, data) =>
      if err?
        logger.error("Cannot read client library: #{@mimosaClientLibraryPath}") if err?
        return callback()
      fileUtils.writeFile @clientPath, data, (err) =>
        @failed("Cannot write client library: #{err}") if err?
        callback()

  templatePreamble: (fileName, templateName) ->
    """
    \n//
    // Source file: [#{fileName}]
    // Template name: [#{templateName}]
    //\n
    """

  addTemplateToOutput: (fileName, templateName, source) =>
    """
    #{@templatePreamble(fileName, templateName)}
    templates['#{templateName}'] = #{source};\n
    """

  afterWrite: (fileName) ->
    @optimize(fileName)
