AbstractCoffeeScriptCompiler = require './coffeescript-compiler'
iced = require 'iced-coffee-script'

module.exports = class IcedCompiler extends AbstractCoffeeScriptCompiler

  coffeeDialect: "Iced CoffeeScript"

  constructor: (config) -> super(config)

  compile: (cs, fileName, destinationFile, callback) ->
    try
      output = iced.compile cs
    catch err
      error = "#{fileName}, #{err}"
    callback(error, output, destinationFile)