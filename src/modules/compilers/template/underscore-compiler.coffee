"use strict"

_ = require 'lodash'

compilerLib = null
libName = "underscore"

setCompilerLib = (_compilerLib) ->
  compilerLib = _compilerLib

prefix = (config, libraryPath) ->
  if config.template.wrapType is 'amd'
    "define(['#{libraryPath}'], function (_) { var templates = {};\n"
  else if config.template.wrapType is "common"
    "var _ = require('#{config.template.commonLibPath}');\nvar templates = {};\n"
  else
    "var templates = {};\n"

suffix = (config) ->
  if config.template.wrapType is 'amd'
    'return templates; });'
  else if config.template.wrapType is "common"
    "\nmodule.exports = templates;"
  else
    ""

prefix = (file, cb) ->
  unless compilerLib
    compilerLib = require libName

  try
    compiledOutput = compilerLib.template(file.inputFileText)
    output = compiledOutput.source
  catch err
    error = err
  cb(error, output)

module.exports =
  base: "underscore"
  type: "template"
  defaultExtensions:  ["tpl", "underscore"]
  clientLibrary: "underscore"
  compile: prefix
  suffix: suffix
  prefix: prefix
  setCompilerLib: setCompilerLib
