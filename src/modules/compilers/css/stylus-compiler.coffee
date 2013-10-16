"use strict"

fs = require 'fs'
path = require 'path'

_ = require 'lodash'
logger = require 'logmimosa'

AbstractCssCompiler = require './css'

module.exports = class StylusCompiler extends AbstractCssCompiler
  libName: 'stylus'
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

    stylusSetup = @compilerLib(text)
      .include(path.dirname(fileName))
      .include(config.watch.sourceDir)
      .set('compress', false)
      #.set('firebug', not config.isOptimize)
      #.set('linenos', not config.isOptimize and not config.isBuild)
      .set('filename', fileName)
      .set('include css', true)

    if config.stylus.url
      stylusSetup.define 'url', @compilerLib.url config.stylus.url

    config.stylus.includes?.forEach (inc) ->
      stylusSetup.include inc

    config.stylus.resolvedUse?.forEach (ru) ->
      stylusSetup.use ru

    config.stylus.import?.forEach (imp) ->
      stylusSetup.import imp

    Object.keys(config.stylus.define).forEach (define) ->
      stylusSetup.define define, config.stylus.define[define]

    stylusSetup.render cb

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