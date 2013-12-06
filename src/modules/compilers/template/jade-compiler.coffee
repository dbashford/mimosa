"use strict"

_compilerLib = null

_prefix = (config, libraryPath) ->
  if config.template.wrapType is 'amd'
    "define(['#{libraryPath}'], function (jade){ var templates = {};\n"
  else if config.template.wrapType is "common"
    "var jade = require('#{config.template.commonLibPath}');\nvar templates = {};\n"
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
    output = _compilerLib.compile file.inputFileText,
      compileDebug: false,
      client: true,
      filename: file.inputFileName
  catch err
    error = err
  cb(error, output)

module.exports =
  base: "jade"
  type: "template"
  defaultExtensions:  ["jade"]
  clientLibrary: "jade-runtime"
  libName: "jade"
  compile: _compile
  suffix: _suffix
  prefix: _prefix
  compilerLib: _compilerLib
