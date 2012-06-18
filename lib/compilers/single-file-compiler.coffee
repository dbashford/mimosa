AbstractCompiler = require './compiler'
path = require 'path'
fs = require 'fs'

module.exports = class AbstractSingleFileCompiler extends AbstractCompiler

  constructor: (config, targetConfig) -> super(config, targetConfig)

  # OVERRIDE THIS
  compile: (fileAsText, fileName, callback) -> throw new Error "Method compile must be implemented"

  created: (fileName) => @compileAndWrite(fileName, false)
  updated: (fileName) => @compileAndWrite(fileName)
  removed: (fileName) => @removeTheFile(@findCompiledPath(fileName))

  compileAndWrite: (fileName, isUpdate = true) ->
    destinationFile = @findCompiledPath(fileName)
    if isUpdate or @_fileNeedsCompiling(fileName, destinationFile)
      fs.readFile fileName, "ascii", (err, text) =>
        @compile(text, fileName, destinationFile, @_writeToDestination)

  _writeToDestination: (error, results, destinationFile) =>
    if error
      @notifyFail("Error compiling: #{fileName}\n#{error}")
    else
      @write(destinationFile, results) if results?

  findCompiledPath: (fileName) ->
    path.join(@destDir, fileName.substring(0, fileName.lastIndexOf(".")).replace(@origDir, '') + ".#{@outExtension}")

  _fileNeedsCompiling: (fileName, destinationFile) ->
    return true unless path.existsSync(destinationFile)
    destStats = fs.statSync(destinationFile)
    origStats = fs.statSync(fileName)
    return true if origStats.mtime > destStats.mtime
    false