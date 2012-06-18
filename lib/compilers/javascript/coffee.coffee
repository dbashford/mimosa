AbstractJavascriptCompiler = require './javascript-compiler'
coffee = require 'coffee-script'

module.exports = class CoffeeCompiler extends AbstractJavascriptCompiler

  constructor: (config) -> super(config)

  compile: (cs, fileName, destinationFile, callback) ->
    try
      output = coffee.compile cs
    catch err
      error = err
    callback(error, output, destinationFile)