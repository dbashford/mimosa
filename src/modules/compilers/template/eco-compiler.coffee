"use strict"

compilerLib = null
libName ='eco'

setCompilerLib = (_compilerLib) ->
  compilerLib = _compilerLib

prefix = (config) ->
  if config.template.wrapType is 'amd'
    "define(function (){ var templates = {};\n"
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
    output = compilerLib.precompile file.inputFileText
  catch err
    error = err
  cb(error, output)

module.exports =
  base: "eco"
  type: "template"
  defaultExtensions: ["eco"]
  compile: compile
  suffix: suffix
  prefix: prefix
  setCompilerLib: setCompilerLib
