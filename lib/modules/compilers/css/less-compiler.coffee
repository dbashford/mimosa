fs = require 'fs'
path = require 'path'

less = require 'less'
_ = require 'lodash'

AbstractCssCompiler = require './css'
logger = require '../../../util/logger'


module.exports = class LessCompiler extends AbstractCssCompiler

  importRegex: /@import ['"](.*)['"]/g
  partialKeepsExtension: true

  @prettyName        = "LESS - http://lesscss.org/"
  @defaultExtensions = ["less"]

  constructor: (config, @extensions) ->
    super()

  compile: (file, config, options, done) =>
    text = file.sourceFileText
    fileName = file.sourceFileName
    logger.debug "Compiling LESS file [[ #{fileName} ]], first parsing..."
    parser = new less.Parser
      paths: [config.watch.sourceDir, path.dirname(fileName)],
      filename: fileName
    parser.parse text, (error, tree) =>
      @initBaseFilesToCompile--

      return done("#{fileName}, Error: #{error.message}") if error?

      try
        logger.debug "...then converting to CSS"
        result = tree.toCSS()
      catch ex
        err = "#{ex.type}Error:#{ex.message}"
        err += " in '#{ex.filename}:#{ex.line}:#{ex.column}'" if ex.filename

      logger.debug "Finished LESS compile for file [[ #{fileName} ]], errors? #{err?}"

      done(err, result)

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

    baseFiles = _.difference(@allFiles, imported)
    logger.debug "Base files for LESS are:\n#{baseFiles.join('\n')}"
    baseFiles

  _getImportFilePath: (baseFile, importPath) ->
    path.join path.dirname(baseFile), importPath