AbstractCoffeeScriptCompiler = require './coffeescript'
coffee = require 'coffee-script'

module.exports = class CoffeeCompiler extends AbstractCoffeeScriptCompiler

  @prettyName        = -> "CoffeeScript - http://coffeescript.org/"
  @defaultExtensions = -> ["coffee"]

  constructor: (config) -> super(config)

  compile: (cs, fileName, destinationFile, callback) ->
    try
      output = coffee.compile cs
    catch err
      error = "#{fileName}, #{err}"
    callback(error, output, destinationFile)