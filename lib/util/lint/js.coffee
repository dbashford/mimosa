jslint =     require('jshint').JSHINT
coffeelint = require 'coffeelint'

logger =  require '../logger'

module.exports = class JSLinter

  logLint: (language, result, type, loggerMethod, fileName, options = {}) ->
    message = "#{language} Lint #{type}: #{result.message}"
    if result.rule then message += ", lint rule [#{result.rule}]"
    message += ", in file [#{fileName}]"
    if result.lineNumber then message += ", at line number [#{result.lineNumber}]"
    if result.value
      val = result.value
      if result.rule and options[result.rule]?.value?
        val = options[result.rule].value
      message += ", lint setting [#{val}]"
    loggerMethod message

  lintJs: (source, destFileName, options) ->
    lintok = jslint(source, options)

    unless lintok
      for e in jslint.errors
        continue unless e?
        result =
          message: e.reason
          lineNumber: e.line
        @logLint("JavaScript", result, "Error", logger.warn, destFileName)

  lintCoffee: (source, fileName, options) =>
    try
      lintResults = coffeelint.lint(source, options)
    catch err
      return # is an error in compilation of coffeescript, compiler will take care of that

    for result in lintResults
      switch result.level
        when 'error' then @logLint("CoffeeScript", result, 'Error',   logger.warn, fileName, options)
        when 'warn'  then @logLint("CoffeeScript", result, 'Warning', logger.info, fileName, options)



