"use strict"

liveConfig = {}
compilerLib = null
libName = 'LiveScript'

setCompilerLib = (_compilerLib) ->
  compilerLib = _compilerLib

init = (conf) ->
  liveConfig = conf.livescript

prefix = (file, cb) ->
  unless compilerLib
    compilerLib = require libName

  try
    output = compilerLib.compile file.inputFileText, liveConfig
  catch err
    error = err
  cb(error, output)

module.exports =
  base: "livescript"
  type: "javascript"
  defaultExtensions: ["ls"]
  init: init
  compile: prefix
  setCompilerLib: setCompilerLib
