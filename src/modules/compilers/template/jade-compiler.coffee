"use strict"

compilerLib = null
libName = "jade"

setCompilerLib = (_compilerLib) ->
  compilerLib = _compilerLib

prefix = (config, libraryPath) ->
  if config.template.wrapType is 'amd'
    "define(['#{libraryPath}'], function (jade){ var templates = {};\n"
  else if config.template.wrapType is "common"
    "var jade = require('#{config.template.commonLibPath}');\nvar templates = {};\n"
  else
    "var templates = {};\n"

suffix = (config) ->
  if config.template.wrapType is 'amd'
    'return templates; });'
  else if config.template.wrapType is "common"
    "\nmodule.exports = templates;"
  else
    ""

compile = (file, cb) ->
  unless compilerLib
    compilerLib = require libName

  try
    output = compilerLib.compile file.inputFileText,
      compileDebug: false,
      client: true,
      filename: file.inputFileName
  catch err
    error = err
  cb(error, output)

module.exports =
  base: "jade"
  compilerType: "template"
  defaultExtensions:  ["jade"]
  clientLibrary: "jade-runtime"
  compile: compile
  suffix: suffix
  prefix: prefix
  setCompilerLib: setCompilerLib
