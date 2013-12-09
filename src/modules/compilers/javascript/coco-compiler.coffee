"use strict"

_ = require 'lodash'

compilerLib = null
libName = "coco"
cocoConfig = {}

setCompilerLib = (_compilerLib) ->
  compilerLib = _compilerLib

init = (conf) ->
  cocoConfig = conf.coco

prefix =  (file, cb) ->
  unless compilerLib
    compilerLib = require libName

  try
    output = compilerLib.compile file.inputFileText, _.extend {}, cocoConfig
  catch err
    error = err
  cb(error, output)

module.exports =
  base: "coco"
  type: "javascript"
  defaultExtensions: ["co", "coco"]
  init: init
  compile: prefix
  setCompilerLib: setCompilerLib
