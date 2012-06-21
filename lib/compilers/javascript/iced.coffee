AbstractJavascriptCompiler = require './javascript-compiler'
iced = require 'iced-coffee-script'

module.exports = class IcedCompiler extends AbstractJavascriptCompiler

  constructor: (config) ->
    super(config)
    @lintOptions = config.coffeelint

  compile: (cs, fileName, destinationFile, callback) ->
    @metaLintIt(cs, @lintOptions, fileName, "Iced CoffeeScript") if @config.metalint
    try
      output = iced.compile cs
    catch err
      error = "#{fileName}, #{err}"
    callback(error, output, destinationFile)