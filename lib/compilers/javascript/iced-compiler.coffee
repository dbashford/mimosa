AbstractCoffeeScriptCompiler = require './coffeescript'
iced = require 'iced-coffee-script'

module.exports = class IcedCompiler extends AbstractCoffeeScriptCompiler

  @prettyName        = -> "Iced CoffeeScript - http://maxtaco.github.com/coffee-script/"
  @defaultExtensions = -> ["iced"]

  constructor: (config) -> super(config)

  compile: (cs, fileName, destinationFile, callback) ->
    try
      output = iced.compile cs
    catch err
      error = "#{fileName}, #{err}"
    callback(error, output, destinationFile)