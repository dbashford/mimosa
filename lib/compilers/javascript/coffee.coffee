AbstractCoffeeScriptCompiler = require './coffeescript-compiler'
coffee = require 'coffee-script'

module.exports = class CoffeeCompiler extends AbstractCoffeeScriptCompiler

  coffeeDialect: "CoffeeScript"

  constructor: (config) -> super(config)

  compile: (cs, fileName, destinationFile, callback) ->
    try
      output = coffee.compile cs
    catch err
      error = "#{fileName}, #{err}"
    callback(error, output, destinationFile)