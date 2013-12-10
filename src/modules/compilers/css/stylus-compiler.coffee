"use strict"

fs = require 'fs'
path = require 'path'

_ = require 'lodash'
logger = require 'logmimosa'

importRegex = /@import[\s\t]*[\(]?[\s\t]*['"]?([a-zA-Z0-9*\/\.\-\_]*)[\s\t]*[\n;\s'")]?/g
compilerLib = null
libName = "stylus"

setCompilerLib = (_compilerLib) ->
  compilerLib = _compilerLib

compile = (file, config, options, done) ->
  unless compilerLib
    compilerLib = require libName

  text = file.inputFileText
  fileName = file.inputFileName

  cb = (err, css) ->
    if logger.isDebug
      logger.debug "Finished Stylus compile for file [[ #{fileName} ]], errors?  #{err?}"
    done(err, css)

  logger.debug "Compiling Stylus file [[ #{fileName} ]]"

  stylusSetup = compilerLib(text)
    .include(path.dirname(fileName))
    .include(config.watch.sourceDir)
    .set('compress', false)
    #.set('firebug', not config.isOptimize)
    #.set('linenos', not config.isOptimize and not config.isBuild)
    .set('filename', fileName)
    .set('include css', true)

  if config.stylus.url
    stylusSetup.define 'url', compilerLib.url config.stylus.url

  config.stylus.includes?.forEach (inc) ->
    stylusSetup.include inc

  config.stylus.resolvedUse?.forEach (ru) ->
    stylusSetup.use ru

  config.stylus.import?.forEach (imp) ->
    stylusSetup.import imp

  Object.keys(config.stylus.define).forEach (define) ->
    stylusSetup.define define, config.stylus.define[define]

  stylusSetup.render cb

determineBaseFiles = (allFiles) ->
  imported = []
  for file in allFiles
    imports = fs.readFileSync(file, 'utf8').match(importRegex)
    continue unless imports?

    for anImport in imports
      importRegex.lastIndex = 0
      importPath = importRegex.exec(anImport)[1]
      fullImportPath = path.join path.dirname(file), importPath
      for fullFilePath in allFiles
        if fullFilePath.indexOf(fullImportPath) is 0
          fullImportPath += path.extname(fullFilePath)
          break
      imported.push fullImportPath

  baseFiles = _.difference(allFiles, imported)
  if logger.isDebug
    logger.debug "Base files for Stylus are:\n#{baseFiles.join('\n')}"
  baseFiles

getImportFilePath = (baseFile, importPath) ->
  path.join path.dirname(baseFile), importPath

module.exports =
  base: "stylus"
  type: "css"
  defaultExtensions: ["styl"]
  importRegex: importRegex
  compile: compile
  determineBaseFiles: determineBaseFiles
  getImportFilePath: getImportFilePath
  setCompilerLib: setCompilerLib
