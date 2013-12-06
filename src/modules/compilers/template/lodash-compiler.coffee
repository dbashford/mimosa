"use strict"

_ = require 'lodash'

_compilerLib = null

_init = (config, compiler) ->
  module.exports.libName = compiler.libName
  module.exports.clientLibrary = compiler.clientLibrary

_prefix = (config, libraryPath) ->
  if config.template.wrapType is 'amd'
    "define(['#{libraryPath}'], function (_) { var templates = {};\n"
  else if config.template.wrapType is "common"
    "var _ = require('#{config.template.commonLibPath}');\nvar templates = {};\n"
  else
    "var templates = {};\n"

_suffix = (config) ->
  if config.template.wrapType is 'amd'
    'return templates; });'
  else if config.template.wrapType is "common"
    "\nmodule.exports = templates;"
  else
    ""

_compile = (file, cb) ->
  try
    compiledOutput = _compilerLib.template(file.inputFileText)
    output = compiledOutput.source
  catch err
    error = err
  cb(error, output)

module.exports =
  base: "lodash"
  type: "template"
  defaultExtensions:  ["tmpl", "lodash"]
  clientLibrary: "lodash"
  libName: "lodash"
  init: _init
  compile: _compile
  suffix: _suffix
  prefix: _prefix
  compilerLib: _compilerLib