"use strict"

_ = require 'lodash'

_compilerLib = null
_config = {}

_init = (conf) ->
  _config = conf.coco

_compile =  (file, cb) ->
  try
    output = _compilerLib.compile file.inputFileText, _.extend {}, _config
  catch err
    error = err
  cb(error, output)

module.exports =
  base: "coco"
  type: "javascript"
  defaultExtensions: ["co", "coco"]
  libName: 'coco'
  init: _init
  compile: _compile
  compilerLib: _compilerLib