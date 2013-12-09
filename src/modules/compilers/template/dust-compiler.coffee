"use strict"

compilerLib = null
libName = 'dustjs-linkedin'

setCompilerLib = (_compilerLib) ->
  compilerLib = _compilerLib

prefix = (config, libraryPath) ->
  if config.template.wrapType is "amd"
    "define(['#{libraryPath}'], function (dust){ "
  else if config.template.wrapType is "common"
    "var dust = require('#{config.template.commonLibPath}');\n"
  else
    ""

suffix = (config) ->
  if config.template.wrapType is "amd"
    'return dust; });'
  else if config.template.wrapType is "common"
    "\nmodule.exports = dust;"
  else
    ""

compile = (file, cb) ->
  unless compilerLib
    compilerLib = require libName

  try
    output = compilerLib.compile file.inputFileText, file.templateName
  catch err
    error = err
  cb(error, output)

module.exports =
  base: "dust"
  type: "template"
  defaultExtensions: ["dust"]
  clientLibrary: "dust"
  handlesNamespacing: true
  compile: compile
  suffix: suffix
  prefix: prefix
  setCompilerLib: setCompilerLib
