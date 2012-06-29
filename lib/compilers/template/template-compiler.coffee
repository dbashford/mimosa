AbstractCompiler = require '../compiler'
path = require 'path'
find = require 'findit'
fs = require 'fs'
logger = require '../../util/logger'

module.exports = class AbstractTemplateCompiler extends AbstractCompiler

  constructor: (config) ->
    super(config, config.compilers.template)
    @fileName = path.join(@compDir, @config.outputFileName + ".js")
    @baseDir = path.dirname(@fileName)

  # OVERRIDE THIS
  compile: (fileNames, callback) -> throw new Error "Method compile must be implemented"

  created: => @_gatherFiles()
  updated: => @_gatherFiles()
  removed: => @_gatherFiles(true)

  _gatherFiles: (isRemove = false) ->
    fileNames = []
    allFiles = find.sync @srcDir
    allFiles.forEach (file) =>
      extension = path.extname(file).substring(1)
      fileNames.push(file) if @config.extensions.indexOf(extension) >= 0

    if fileNames.length is 0
      if isRemove
        @removeTheFile(@fileName)
        @_removeClientLibrary()
    else
      @_writeClientLibrary()
      @compile(fileNames, @_write)

  _write: (error, output) =>
    if error
      @failed(err)
    else
      @write(@fileName, output) if output?

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

  postWrite: (fileName) -> @optimize()


