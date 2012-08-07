fs = require 'fs'
path = require 'path'

less = require 'less'
_ = require 'lodash'

AbstractCssCompiler = require './css'
logger = require '../../util/logger'


module.exports = class LessCompiler extends AbstractCssCompiler

  importRegex: /@import ['"](.*)['"]/g
  partialKeepsExtension: true

  @prettyName        = -> "LESS - http://lesscss.org/"
  @defaultExtensions = -> ["less"]

  constructor: (config) ->
    super(config)

  compile: (fileName, text, destinationFile, callback) =>
    parser = new less.Parser
      paths: [@srcDir, path.dirname(fileName)],
      filename: fileName
    parser.parse text, (error, tree) =>
      @initBaseFilesToCompile--

      return callback("#{fileName}, Error: #{error.message}") if error?

      try
        result = tree.toCSS()
      catch ex
        err = "#{ex.type}Error:#{ex.message}"
        err += " in '#{ex.filename}:#{ex.line}:#{ex.column}'" if ex.filename

      callback(err, result, destinationFile)

  _isInclude: (fileName) -> @includeToBaseHash[fileName]?

  _determineBaseFiles: =>
    imported = []
    for file in @allFiles
      imports = fs.readFileSync(file, 'ascii').match(@importRegex)
      continue unless imports?

      for anImport in imports
        @importRegex.lastIndex = 0
        importPath = @importRegex.exec(anImport)[1]
        fullImportPath = path.join path.dirname(file), importPath
        imported.push fullImportPath

    _.difference(@allFiles, imported)

  _getImportFilePath: (baseFile, importPath) ->
    path.join path.dirname(baseFile), importPath