"use strict"

_compilerLib = null

_prefix = (config, libraryPath) ->
  if config.template.wrapType is 'amd'
    "define(['#{libraryPath}'], function (Hogan){ var templates = {};\n"
  else if config.template.wrapType is "common"
    "var Hogan = require('#{config.template.commonLibPath}');\nvar templates = {};\n"
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
    compiledOutput = _compilerLib.compile(file.inputFileText, {asString:true})
    output = "templates['#{file.templateName}'] = new Hogan.Template(#{compiledOutput});\n"
  catch err
    error = err
  cb(error, output)

module.exports =
  base: "hogan"
  type: "template"
  defaultExtensions: ["hog", "hogan", "hjs"]
  clientLibrary: "hogan-template"
  libName: "hogan.js"
  compile: _compile
  suffix: _suffix
  prefix: _prefix
  compilerLib: _compilerLib
