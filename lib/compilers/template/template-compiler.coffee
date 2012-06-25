AbstractCompiler = require '../compiler'
path = require 'path'
find = require 'findit'

module.exports = class AbstractTemplateCompiler extends AbstractCompiler

  constructor: (config) ->
    super(config, config.compilers.template)
    @fileName = path.join(@compDir, @config.outputFileName + ".js")

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
      @removeTheFile(@fileName) if isRemove
    else
      @compile(fileNames, @_write)

  _write: (error, output) =>
    if error
      @failed(err)
    else
      @write(@fileName, output) if output?

  postWrite: (fileName) -> @optimize()


