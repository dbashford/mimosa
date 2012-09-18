fs = require 'fs'
path = require 'path'

nib = require 'nib'
stylus = require 'stylus'
_ = require 'lodash'

AbstractCssCompiler = require './css'
logger = require '../../../util/logger'

module.exports = class StylusCompiler extends AbstractCssCompiler

  importRegex: /@import ['"](.*)['"]/g

  @prettyName        = "(*) Stylus - http://learnboost.github.com/stylus/"
  @defaultExtensions = ["styl"]
  @isDefault         = true

  constructor: (config, @extensions) ->
    super(config)

  compile: (fileName, text, destinationFile, callback) =>

    cb = (err, css) =>
      logger.debug "Finished Stylus compile for file [[ #{fileName} ]], errors?  #{err?}"
      @initBaseFilesToCompile--
      callback(err, css, destinationFile)

    logger.debug "Compiling Stylus file [[ #{fileName} ]]"

    stylus(text)
      .include(path.dirname(fileName))
      .include(@srcDir)
      .set('compress', false)
      .set('firebug', @config.optimize? and !@config.optimize)
      .set('filename', fileName)
      .use(nib())
      .import('nib')
      .render(cb)

  _isInclude: (fileName) ->
    @includeToBaseHash[fileName]?

  _determineBaseFiles: =>
    imported = []
    for file in @allFiles
      imports = fs.readFileSync(file, 'ascii').match(@importRegex)
      continue unless imports?

      for anImport in imports
        @importRegex.lastIndex = 0
        importPath = @importRegex.exec(anImport)[1]
        fullImportPath = path.join path.dirname(file), importPath
        for fullFilePath in @allFiles
          if fullFilePath.indexOf(fullImportPath) is 0
            fullImportPath += path.extname(fullFilePath)
            break
        imported.push fullImportPath

    baseFiles = _.difference(@allFiles, imported)
    logger.debug "Base files for Stylus are:\n#{baseFiles.join('\n')}"
    baseFiles

  _getImportFilePath: (baseFile, importPath) ->
    path.join path.dirname(baseFile), importPath