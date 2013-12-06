"use strict"

_compilerLib = null
_config = {}

_init = (conf) ->
  _config = conf.livescript

_compile = (file, cb) ->
  try
    output = _compilerLib.compile file.inputFileText, _config
  catch err
    error = err
  cb(error, output)

module.exports =
  base: "livescript"
  type: "javascript"
  defaultExtensions: ["ls"]
  libName: 'LiveScript'
  init: _init
  compile: _compile
  compilerLib: _compilerLib