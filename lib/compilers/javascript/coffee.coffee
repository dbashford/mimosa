AbstractJavascriptCompiler = require './javascript-compiler'
coffee = require 'coffee-script'

module.exports = class CoffeeCompiler extends AbstractJavascriptCompiler

  constructor: (config) ->
    super(config)
    @lintOptions = config.coffeelint

  compile: (cs, fileName, destinationFile, callback) ->
    @metaLintIt(cs, @lintOptions, fileName, "CoffeeScript") if @config.metalint
    try
      output = coffee.compile cs
    catch err
      error = "#{fileName}, #{err}"

    callback(error, output, destinationFile)