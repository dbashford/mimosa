"use strict"

liveScript = require 'LiveScript'

JSCompiler = require "./javascript"

module.exports = class LiveScriptCompiler extends JSCompiler

  @prettyName        = "LiveScript - http://gkz.github.com/LiveScript/"
  @defaultExtensions = ["ls"]

  constructor: (config, @extensions) ->
    @options = config.livescript
    super()

  compile: (file, cb) ->
    try
      output = liveScript.compile file.inputFileText, @options
    catch err
      error = err
    cb(error, output)