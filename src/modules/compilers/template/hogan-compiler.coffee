"use strict"

compilerLib = null
libName = "hogan.js"

setCompilerLib = (_compilerLib) ->
  compilerLib = _compilerLib

prefix = (config, libraryPath) ->
  if config.template.wrapType is 'amd'
    "define(['#{libraryPath}'], function (Hogan){ var templates = {};\n"
  else if config.template.wrapType is "common"
    "var Hogan = require('#{config.template.commonLibPath}');\nvar templates = {};\n"
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
    compiledOutput = compilerLib.compile(file.inputFileText, {asString:true})
    output = "templates['#{file.templateName}'] = new Hogan.Template(#{compiledOutput});\n"
  catch err
    error = err
  cb(error, output)

module.exports =
  base: "hogan"
  type: "template"
  defaultExtensions: ["hog", "hogan", "hjs"]
  clientLibrary: "hogan-template"
  compile: prefix
  suffix: suffix
  prefix: prefix
  setCompilerLib: setCompilerLib
