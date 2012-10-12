liveScript = require 'livescript'

JSCompiler = require "./javascript"

module.exports = class LiveScriptCompiler extends JSCompiler

  @prettyName        = "LiveScript - http://gkz.github.com/LiveScript/"
  @defaultExtensions = ["ls"]

  constructor: (config, @extensions) ->
    super()

  compile: (file, cb) ->
    try
      output = liveScript.compile file.inputFileText
    catch err
      error = err
    cb(error, output)