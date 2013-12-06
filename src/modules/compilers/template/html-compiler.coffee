"use strict"

_compilerLib = null

_prefix = (config) ->
  if config.template.wrapType is 'amd'
    "define(function () { var templates = {};\n"
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
  # we don't want underscore to actually work, just to wrap stuff
  _compilerLib.templateSettings =
    evaluate    : /<%%%%%%%%([\s\S]+?)%%%%%%%>/g,
    interpolate : /<%%%%%%%%=([\s\S]+?)%%%%%%%>/g

  try
    compiledOutput = _compilerLib.template(file.inputFileText)
    output = "#{compiledOutput.source}()"
  catch err
    error = err

  # set it back
  _compilerLib.templateSettings =
    evaluate    : /<%([\s\S]+?)%>/g,
    interpolate : /<%=([\s\S]+?)%>/g

  cb(error, output)

module.exports =
  base: "html"
  type: "template"
  defaultExtensions: ["template"]
  libName: "underscore"
  compile: _compile
  suffix: _suffix
  prefix: _prefix
  compilerLib: _compilerLib