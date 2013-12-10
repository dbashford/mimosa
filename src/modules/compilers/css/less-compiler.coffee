"use strict"

fs = require 'fs'
path = require 'path'

_ = require 'lodash'
logger = require 'logmimosa'

importRegex = /@import ['"](.*)['"]/g
libName = "less"
compilerLib = null

setCompilerLib = (_compilerLib) ->
  compilerLib = _compilerLib

compile = (file, config, options, done) ->
  unless compilerLib
    compilerLib = require libName

  fileName = file.inputFileName
  logger.debug "Compiling LESS file [[ #{fileName} ]], first parsing..."
  parser = new compilerLib.Parser
    paths: [config.watch.sourceDir, path.dirname(fileName)],
    filename: fileName
  parser.parse file.inputFileText, (error, tree) ->
    if error?
      return done(error, null)

    try
      logger.debug "...then converting to CSS"
      result = tree.toCSS()
    catch ex
      err = "#{ex.type}Error:#{ex.message}"
      err += " in '#{ex.filename}:#{ex.line}:#{ex.column}'" if ex.filename

    if logger.isDebug
      logger.debug "Finished LESS compile for file [[ #{fileName} ]], errors? #{err?}"

    done(err, result)

determineBaseFiles = (allFiles) ->
  imported = []
  for file in allFiles
    imports = fs.readFileSync(file, 'utf8').match(importRegex)
    continue unless imports?

    for anImport in imports
      importRegex.lastIndex = 0
      importPath = importRegex.exec(anImport)[1]
      fullImportPath = path.join path.dirname(file), importPath
      imported.push fullImportPath

  baseFiles = _.difference(allFiles, imported)
  logger.debug "Base files for LESS are:\n#{baseFiles.join('\n')}"
  baseFiles

getImportFilePath = (baseFile, importPath) ->
  path.join path.dirname(baseFile), importPath

module.exports =
  base: "less"
  type: "css"
  defaultExtensions: ["less"]
  partialKeepsExtension: true
  importRegex: importRegex
  compile: compile
  determineBaseFiles: determineBaseFiles
  getImportFilePath: getImportFilePath
  setCompilerLib: setCompilerLib
