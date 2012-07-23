coffeelint = require 'coffeelint'

logger =  require '../logger'
ScriptLinter = require './script'

module.exports = class CoffeeLinter extends ScriptLinter

  constructor: (@options) ->

  lint: (fileName, source) =>
    try
      lintResults = coffeelint.lint(source, @options)
    catch err
      return # is an error in compilation of coffeescript, compiler will take care of that

    for result in lintResults
      switch result.level
        when 'error' then @logLint(fileName, "CoffeeScript", result, 'Error',   logger.warn)
        when 'warn'  then @logLint(fileName, "CoffeeScript", result, 'Warning', logger.info)