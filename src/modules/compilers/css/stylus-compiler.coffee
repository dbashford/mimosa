"use strict"

fs = require 'fs'
path = require 'path'

stylus = require 'stylus'
_ = require 'lodash'
logger = require 'logmimosa'

AbstractCssCompiler = require './css'

module.exports = class StylusCompiler extends AbstractCssCompiler

  importRegex: /@import ['"](.*)['"]/g

  @prettyName        = "(*) Stylus - http://learnboost.github.com/stylus/"
  @defaultExtensions = ["styl"]
  @isDefault         = true

  constructor: (config, @extensions) ->
    super()

  compile: (file, config, options, done) =>
    text = file.inputFileText
    fileName = file.inputFileName

    cb = (err, css) =>
      logger.debug "Finished Stylus compile for file [[ #{fileName} ]], errors?  #{err?}"
      @initBaseFilesToCompile--
      done(err, css)

    logger.debug "Compiling Stylus file [[ #{fileName} ]]"

    stylus(text)
      .include(path.dirname(fileName))
      .include(config.watch.sourceDir)
      .set('compress', false)
      .set('firebug', config.isOptimize? and !config.isOptimize)
      .set('filename', fileName)
      .use(config.stylus.resolvedUse...)
      .import(config.stylus.use...)
      .render(cb)

  _determineBaseFiles: =>
    imported = []
    for file in @allFiles
      imports = fs.readFileSync(file, 'utf8').match(@importRegex)
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