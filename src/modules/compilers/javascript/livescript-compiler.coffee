"use strict"

liveConfig = {}
compilerLib = null
libName = 'LiveScript'

setCompilerLib = (_compilerLib) ->
  compilerLib = _compilerLib

init = (conf) ->
  liveConfig = conf.livescript

compile = (file, cb) ->
  unless compilerLib
    compilerLib = require libName

  try
    output = compilerLib.compile file.inputFileText, liveConfig
  catch err
    error = err
  cb(error, output)

module.exports =
  base: "livescript"
  compilerType: "javascript"
  defaultExtensions: ["ls"]
  init: init
  compile: compile
  setCompilerLib: setCompilerLib
