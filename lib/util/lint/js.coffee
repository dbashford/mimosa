jslint =     require('jshint').JSHINT

logger =  require '../logger'
ScriptLinter = require './script'

module.exports = class JSLinter extends ScriptLinter

  constructor: (@options) ->

  lint: (fileName, source) =>
    lintok = jslint source, @options

    unless lintok
      for e in jslint.errors
        continue unless e?
        result =
          message: e.reason
          lineNumber: e.line
        @logLint(fileName, "JavaScript", result, "Error", logger.warn)