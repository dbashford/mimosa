AbstractJavaScriptCompiler = require './javascript-compiler'
coffee = require 'coffee-script'

module.exports = class CoffeeCompiler extends AbstractJavaScriptCompiler

  constructor: (config) ->
    super(config)
    @extensions = config?.extensions || ["coffee"]

  compile: (cs, fileName, destinationFile, callback) ->
    try
      output = coffee.compile cs
    catch err
      error = err
    callback(error, output, destinationFile)