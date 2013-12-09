"use strict"

compilerLib = null
libName = "ractive"

setCompilerLib = (_compilerLib) ->
  compilerLib = _compilerLib

prefix = (config, libraryPath) ->
  if config.template.wrapType is 'amd'
    "define(['#{libraryPath}'], function (){ var templates = {};\n"
  else
    "var templates = {};\n"

suffix = (config) ->
  if config.template.wrapType is 'amd'
    'return templates; });'
  else if config.template.wrapType is "common"
    "module.exports = templates;"
  else
    ""

compile = (file, cb) ->
  unless compilerLib
    compilerLib = require libName

  try
    output = compilerLib.parse file.inputFileText
    output = JSON.stringify output
  catch err
    error = err
  cb(error, output)

module.exports =
  base: "ractive"
  type: "template"
  defaultExtensions:  ["rtv","rac"]
  clientLibrary: "ractive"
  compile: compile
  suffix: suffix
  prefix: prefix
  setCompilerLib: setCompilerLib