"use strict"

_compilerLib = null

_prefix = (config) ->
  if config.template.wrapType is 'amd'
    "define(function (){ var templates = {};\n"
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
    output = _compilerLib.precompile file.inputFileText
  catch err
    error = err
  cb(error, output)

module.exports =
  base: "eco"
  type: "template"
  defaultExtensions: ["eco"]
  libName: 'eco'
  handlesNamespacing: true
  compile: _compile
  suffix: _suffix
  prefix: _prefix
  compilerLib: _compilerLib