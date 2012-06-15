AbstractCompiler = require '../compiler'
path = require 'path'
find = require 'findit'

module.exports = class AbstractTemplateCompiler extends AbstractCompiler

  constructor: (config) ->
    super(config)
    @outputFileName = config?.outputFileName || "javascripts/templates"

  setWatchedDirectories: (@origDir, @destDir) =>
    @fileName = path.join(@destDir, @outputFileName + ".js")

  # OVERRIDE THIS
  compile: (fileNames, callback) -> throw new Error "Method compile must be implemented"

  created: => @_compileAndWrite()
  updated: => @_compileAndWrite()
  removed: => @_compileAndWrite(true)

  _compileAndWrite: (isRemove = false) ->
    fileNames = []
    allFiles = find.sync @origDir
    allFiles.forEach (file) =>
      extension = path.extname(file).substring(1)
      fileNames.push(file) if @extensions.indexOf(extension) >= 0

    if fileNames.length is 0
      @removeTheFile(@fileName) if isRemove
    else
      output = @compile(fileNames, @_write)

  _write: (error, output) =>
    if error
      @notifyFail(err)
    else
      @write(@fileName, output) if output?
