"use strict"

path = require 'path'

_ = require 'lodash'

compilerLib = null
libName = 'iced-coffee-script'
icedConfig = {}

setCompilerLib = (_compilerLib) ->
  compilerLib = _compilerLib

init = (conf) ->
  icedConfig = conf.iced

prefix = (file, cb) ->
  unless compilerLib
    compilerLib = require libName

  conf = _.extend {}, icedConfig, sourceFiles:[path.basename(file.inputFileName) + ".src"]
  conf.literate = compilerLib.helpers.isLiterate(file.inputFileName)

  if conf.sourceMap
    if conf.sourceMapExclude?.indexOf(file.inputFileName) > -1
      conf.sourceMap = false
    else if conf.sourceMapExcludeRegex? and file.inputFileName.match(conf.sourceMapExcludeRegex)
      conf.sourceMap = false

  try
    output = compilerLib.compile file.inputFileText, conf
    if output.v3SourceMap
      sourceMap = output.v3SourceMap
      output = output.js
  catch err
    error = "#{err}, line #{err.location?.first_line}, column #{err.location?.first_column}"
  cb error, output, icedConfig, sourceMap

module.exports =
  base: "iced"
  type: "javascript"
  defaultExtensions: ["iced"]
  cleanUpSourceMaps: true
  init: init
  compile: prefix
  setCompilerLib: setCompilerLib
  config: icedConfig