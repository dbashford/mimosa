"use strict"

JSCompiler = require "./javascript"

module.exports = class LiveScriptCompiler extends JSCompiler.JSCompiler
  libName: 'LiveScript'

  @prettyName        = "LiveScript - http://gkz.github.com/LiveScript/"
  @defaultExtensions = ["ls"]

  constructor: (config, @extensions) ->
    @options = config.livescript
    super()

  compile: (file, cb) ->
    try
      output = @compilerLib.compile file.inputFileText, @options
    catch err
      error = err
    cb(error, output)