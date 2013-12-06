"use strict"

path = require 'path'

_ = require 'lodash'

_compilerLib = null
_config = {}

_init = (conf) ->
  _config = conf.iced

_compile = (file, cb) ->
  conf = _.extend {}, _config, sourceFiles:[path.basename(file.inputFileName) + ".src"]
  conf.literate = _compilerLib.helpers.isLiterate(file.inputFileName)

  if conf.sourceMap
    if conf.sourceMapExclude?.indexOf(file.inputFileName) > -1
      conf.sourceMap = false
    else if conf.sourceMapExcludeRegex? and file.inputFileName.match(conf.sourceMapExcludeRegex)
      conf.sourceMap = false

  try
    output = _compilerLib.compile file.inputFileText, conf
    if output.v3SourceMap
      sourceMap = output.v3SourceMap
      output = output.js
  catch err
    error = "#{err}, line #{err.location?.first_line}, column #{err.location?.first_column}"
  cb error, output, _config, sourceMap

module.exports =
  base: "iced"
  type: "javascript"
  defaultExtensions: ["iced"]
  cleanUpSourceMaps: true
  libName: 'iced-coffee-script'
  init: _init
  compile: _compile
  compilerLib: _compilerLib
  config: _config