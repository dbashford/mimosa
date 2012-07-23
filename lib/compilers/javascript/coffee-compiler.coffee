AbstractCoffeeScriptCompiler = require './coffeescript'
coffee = require 'coffee-script'

module.exports = class CoffeeCompiler extends AbstractCoffeeScriptCompiler

  @prettyName        = -> "(*) CoffeeScript - http://coffeescript.org/"
  @defaultExtensions = -> ["coffee"]

  constructor: (config) ->
    super(config)

  compile: (fileName, text, destinationFile, callback) ->
    try
      output = coffee.compile text
    catch err
      error = "#{fileName}, #{err}"
    callback(error, output, destinationFile)