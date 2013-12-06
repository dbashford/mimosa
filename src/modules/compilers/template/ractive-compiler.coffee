"use strict"

_compilerLib = null

_prefix = (config, libraryPath) ->
  if config.template.wrapType is 'amd'
    "define(['#{libraryPath}'], function (){ var templates = {};\n"
  else
    "var templates = {};\n"

_suffix = (config) ->
  if config.template.wrapType is 'amd'
    'return templates; });'
  else if config.template.wrapType is "common"
    "module.exports = templates;"
  else
    ""

_compile = (file, cb) ->
  try
    output = _compilerLib.parse file.inputFileText
    output = JSON.stringify output
  catch err
    error = err
  cb(error, output)

module.exports =
  base: "ractive"
  type: "template"
  defaultExtensions:  ["rtv","rac"]
  clientLibrary: "ractive"
  libName: "ractive"
  compilerLib: _compilerLib
  compile: _compile
  suffix: _suffix
  prefix: _prefix